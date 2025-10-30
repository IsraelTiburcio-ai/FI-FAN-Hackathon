import SwiftUI

struct ContentView: View {
    @State private var showIntro = true
    @State private var animationFinished = false
    
    var body: some View {
        ZStack {
            if showIntro {
                IntroImageView(showIntro: $showIntro, animationFinished: $animationFinished)
            } else {
                HomeView()
                    .environmentObject(MatchesStore())
                    .environmentObject(POIStore())
                    .environmentObject(UserPrefs())
            }
        }
    }
}

struct IntroImageView: View {
    @Binding var showIntro: Bool
    @Binding var animationFinished: Bool
    @State private var scaleEffect = 0.8
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            // Fondo negro
            Color.black.ignoresSafeArea()
            
            // Imagen de intro
            if let image = UIImage(named: "Intro_image") {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scaleEffect)
                    .opacity(opacity)
                    .padding(40)
            } else {
                // Fallback si no encuentra la imagen
                VStack(spacing: 20) {
                    Image(systemName: "Mariposa")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("FI-FAN")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Tu mejor guÍA para vivir el Mundial")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            }
            
            // Botón para saltar (aparece después de 1 segundo)
            if !animationFinished {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            skipIntro()
                        }) {
                            Text("Saltar")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Capsule())
                        }
                        .padding(.top, 50)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
                .opacity(opacity)
            }
            
            // Overlay de bienvenida cuando termine la animación
            if animationFinished {
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image("Mariposa")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .scaleEffect(scaleEffect)
                    
                    Text("Bienvenido a FI-FAN")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Tu mejor guÍA para vivir el Mundial")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showIntro = false
                        }
                    }) {
                        Text("Comenzar")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(width: 200, height: 60)
                            .background(
                                LinearGradient(
                                    colors: [.fifanBlue, .fifanGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 20)
                }
                .padding(40)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Animación de entrada
        withAnimation(.easeOut(duration: 1.0)) {
            opacity = 1.0
            scaleEffect = 1.0
        }
        
        // Mostrar botón de skip después de 1 segundo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                // El botón ya está configurado para aparecer con opacity
            }
        }
        
        // Cambiar a pantalla de bienvenida después de 3 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                animationFinished = true
            }
        }
    }
    
    private func skipIntro() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showIntro = false
        }
    }
}

// MARK: - ScaleButtonStyle (si lo necesitas en otros lugares
