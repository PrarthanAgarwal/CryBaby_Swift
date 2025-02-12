import SwiftUI
import Lottie

struct AchievementPopupView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Achievement Icon and Badge
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.surface)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.primary)
            }
            
            // Achievement Text
            VStack(spacing: 4) {
                Text("Achievement Unlocked!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.text)
                
                Text(achievement.name)
                    .font(.footnote)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(
            ZStack {
                AppTheme.Colors.surface
                
                // Small confetti effect in background
                LottieView(name: "confetti", loopMode: .playOnce)
                    .frame(width: 200, height: 200)
                    .opacity(0.6)
                    .allowsHitTesting(false)
            }
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        // Animate the popup from top
        .transition(.move(edge: .top).combined(with: .opacity))
        // Position it at the top of the screen with some padding
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 44)
        // Add tap to dismiss
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPresented = false
            }
        }
        // Semi-transparent background
        .background(
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
        )
        // Auto-dismiss after 3 seconds
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isPresented = false
                }
            }
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