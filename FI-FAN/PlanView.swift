import SwiftUI
import FoundationModels

struct PlanInput {
    var city: String
    var startHour: Int
    var endHour: Int
    var wantFood: Bool
    var wantBars: Bool
    var budget: Int
    var diets: [String]
}

protocol LLMAgent {
    func makeItinerary(input: PlanInput, matches: [Match], pois: [POI]) async -> Itinerary
}

struct SimplePlanner: LLMAgent {
    func makeItinerary(input: PlanInput, matches: [Match], pois: [POI]) async -> Itinerary {
        let dateISO = ISO8601DateFormatter().string(from: .now)
        var blocks: [ItineraryBlock] = []
        
        if let todayMatch = matches.first(where: { $0.city.lowercased().contains(input.city.lowercased()) }) {
            let start = hourISO(input.startHour + 2)
            let end = hourISO(input.startHour + 4)
            blocks.append(ItineraryBlock(startISO: start, endISO: end, title: "Partido: \(todayMatch.teams.joined(separator: " vs ")) @ \(todayMatch.venueName)", poiId: nil))
        }
        
        if input.wantFood, let food = pois.first(where: { $0.city.lowercased().contains(input.city.lowercased()) && $0.category == .food }) {
            blocks.insert(ItineraryBlock(startISO: hourISO(input.startHour), endISO: hourISO(input.startHour + 1), title: "Comer en \(food.name)", poiId: food.id), at: 0)
        }
        
        if input.wantBars, let bar = pois.first(where: { $0.city.lowercased().contains(input.city.lowercased()) && $0.category == .bar }) {
            blocks.append(ItineraryBlock(startISO: hourISO(input.endHour - 2), endISO: hourISO(input.endHour), title: "Bar: \(bar.name)", poiId: bar.id))
        }
        
        if blocks.isEmpty {
            blocks.append(ItineraryBlock(startISO: hourISO(input.startHour), endISO: hourISO(input.endHour), title: "Paseo libre por \(input.city)", poiId: nil))
        }
        
        return Itinerary(dateISO: dateISO, blocks: blocks, notes: "Plan generado localmente (SimplePlanner).")
    }
    
    private func hourISO(_ h: Int) -> String {
        let cal = Calendar.current
        let now = Date()
        let comps = cal.dateComponents([.year,.month,.day], from: now)
        let date = cal.date(from: DateComponents(year: comps.year, month: comps.month, day: comps.day, hour: min(max(h, 7), 23))) ?? now
        return ISO8601DateFormatter().string(from: date)
    }
}

struct PlanView: View {
    @EnvironmentObject var matchesStore: MatchesStore
    @EnvironmentObject var poiStore: POIStore
    @EnvironmentObject var userPrefs: UserPrefs
    let agent: LLMAgent
    
    @State private var selectedTab = 0
    @State private var city: String = "Ciudad de México"
    @State private var startHour: Double = 12
    @State private var endHour: Double = 22
    @State private var wantFood = true
    @State private var wantBars = false
    @State private var result: Itinerary?
    
    var body: some View {
        ChatPlanView(
            city: $city,
            matchesStore: _matchesStore,
            poiStore: _poiStore,
            userPrefs: _userPrefs,
            agent: agent)
    }
}





// MARK: - Vista de Formulario
struct ChatMessage: Identifiable, Hashable {
    let id: UUID
    var content: String
    var isUser: Bool
    var timestamp: Date
}

// MARK: - Vista de Chat Corregida
struct ChatPlanView: View {
    @Binding var city: String
    @EnvironmentObject var matchesStore: MatchesStore
    @EnvironmentObject var poiStore: POIStore
    @EnvironmentObject var userPrefs: UserPrefs
    let agent: LLMAgent
    
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isGenerating: Bool = false
    
    // Foundation Models
    @State private var session: LanguageModelSession?
    @State private var modelAvailability: SystemLanguageModel.Availability = SystemLanguageModel.default.availability
    
    private var isModelAvailable: Bool {
        if case .available = modelAvailability { return true }
        return false
    }
    
    private var plannerInstructions: String {
        """
        Eres "Mundial Planner", un asistente planificador de viajes y ocio. Tu objetivo es crear y ajustar itinerarios de un día para una ciudad dada, considerando horarios de partidos, preferencias de comida, bares y presupuesto.
        Estilo y reglas:
        - Responde en español, tono cercano, proactivo y experto.
        - Haz preguntas aclaratorias cuando falte información relevante (horarios, barrio, presupuesto, restricciones alimentarias).
        - Propón opciones concretas y ordenadas por hora. Usa viñetas y horas en formato 24h.
        - Mantén respuestas claras y concisas; máximo 8 líneas salvo que el usuario pida más detalle.
        - Si no hay suficiente información, propone 2 alternativas razonables.
        - No inventes datos de disponibilidad; si asumes algo, dilo explícitamente.
        Contexto del usuario:
        - Ciudad actual: \(city)
        - Presupuesto por día (estimado): \(userPrefs.budgetPerDay)
        - Dietas/restricciones: \(userPrefs.diets.joined(separator: ", "))
        - Preferencias generales: comida=\(true), bares=\(true)
        Objetivo: ayudar a planificar el día alrededor de posibles partidos y puntos de interés.
        """
    }
    
    let examplePrompts = [
        "Tengo un partido a las 15:00 y quiero comer algo bueno antes",
        "Quiero visitar museos por la mañana y bares por la noche",
        "Necesito un plan económico para todo el día",
        "Tengo 4 horas libres antes del partido, ¿qué hago?"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            if !isModelAvailable {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.yellow)
                    Text("Apple Intelligence no está disponible en este dispositivo. Se usará una respuesta básica.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
            // Lista de mensajes
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            SimpleChatMessageView(message: message)
                        }
                        
                        if isGenerating {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Generando itinerario...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Ejemplos de prompts
            if messages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(examplePrompts, id: \.self) { prompt in
                            Button(action: {
                                inputText = prompt
                                sendMessage()
                            }) {
                                Text(prompt)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .clipShape(Capsule())
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
            }
            
            // Input area
            VStack(spacing: 0) {
                Divider()
                HStack(alignment: .bottom, spacing: 12) {
                    TextField("Describe tu plan ideal...", text: $inputText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
                }
                .padding()
            }
        }
        .onAppear {
            if messages.isEmpty {
                let welcomeMessage = ChatMessage(
                    id: UUID(),
                    content: """
                    ¡Hola! Soy tu asistente de viajes para el Mundial. 🏆\n\nPuedo ayudarte a crear itinerarios personalizados en \(city).\nCuéntame qué te gustaría hacer hoy.
                    """,
                    isUser: false,
                    timestamp: Date()
                )
                messages.append(welcomeMessage)
            }
            
            // Update availability and prepare session
            modelAvailability = SystemLanguageModel.default.availability
            if isModelAvailable && session == nil {
                session = LanguageModelSession(instructions: plannerInstructions)
            }
        }
    }
    
    private func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let userMessage = ChatMessage(
            id: UUID(),
            content: trimmedText,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        inputText = ""
        
        isGenerating = true
        Task {
            if isModelAvailable, let session {
                do {
                    let options = GenerationOptions(temperature: 0.7)
                    let response = try await session.respond(to: trimmedText, options: options)
                    await MainActor.run {
                        let botMessage = ChatMessage(
                            id: UUID(),
                            content: response.content,
                            isUser: false,
                            timestamp: Date()
                        )
                        messages.append(botMessage)
                        isGenerating = false
                    }
                } catch {
                    await MainActor.run {
                        let botMessage = ChatMessage(
                            id: UUID(),
                            content: "Lo siento, hubo un problema generando la respuesta. Intenta de nuevo.",
                            isUser: false,
                            timestamp: Date()
                        )
                        messages.append(botMessage)
                        isGenerating = false
                    }
                }
            } else {
                // Fallback basic response when model is unavailable
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                let responseContent = """
                Entendido. Puedo sugerir un plan base para \(city):\n\n• 09:00 - Desayuno en zona céntrica\n• 11:00 - Paseo por atracción cultural\n• 13:00 - Comida local (ajusto si indicas dieta)\n• 15:00 - Partido (si aplica)\n• 18:00 - Actividad vespertina o bar\n\n¿Prefieres priorizar comida, cultura o noche? ¿Algún presupuesto objetivo?
                """
                await MainActor.run {
                    let botMessage = ChatMessage(
                        id: UUID(),
                        content: responseContent,
                        isUser: false,
                        timestamp: Date()
                    )
                    messages.append(botMessage)
                    isGenerating = false
                }
            }
        }
    }
}

struct SimpleChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.isUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    PlanView(agent: SimplePlanner())
        .environmentObject(MatchesStore())
        .environmentObject(POIStore())
        .environmentObject(UserPrefs())
}
