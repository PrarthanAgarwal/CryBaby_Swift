import SwiftUI

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Layout.padding)
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.Layout.cornerRadius)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(isEnabled ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
            .foregroundColor(.white)
            .cornerRadius(AppTheme.Layout.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(AppTheme.Colors.surface)
            .foregroundColor(AppTheme.Colors.primary)
            .cornerRadius(AppTheme.Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadius)
                    .stroke(AppTheme.Colors.primary, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// View extensions for easy modifier application
extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
} 