import SwiftUI
import Lottie

struct AchievementPopupView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Achievement Icon and Badge
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.surface)
                    .frame(width: 66, height: 66)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.Colors.tertiary)
            }
            
            // Achievement Text
            VStack(spacing: 6) {
                Text("Achievement Unlocked!")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.text)
                
                Text(achievement.name)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 32)
        .background(
            ZStack {
                // Solid white background
                Color.white
                
                // Surface color overlay
                AppTheme.Colors.surface
                
                // Small confetti effect in background
                LottieView(name: "confetti", loopMode: .playOnce)
                    .frame(width: 250, height: 250)
                    .opacity(0.8)
                    .allowsHitTesting(false)
            }
        )
        .cornerRadius(20)
        .shadow(
            color: Color.black.opacity(0.2),
            radius: 28,
            x: 0,
            y: 14
        )
        // Animate the popup from top
        .transition(.move(edge: .top).combined(with: .opacity))
        // Position it at the top of the screen with some padding
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 60)
        // Add tap to dismiss
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPresented = false
            }
        }
        // Semi-transparent background
        .background(
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
        )
        .onAppear {
            print("🏅 Achievement popup appeared: \(achievement.name)")
        }
    }
}

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        if let animation = LottieAnimation.named(name) {
            animationView.animation = animation
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = loopMode
            animationView.play()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
} 