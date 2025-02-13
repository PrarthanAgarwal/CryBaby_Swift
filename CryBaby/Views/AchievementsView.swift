import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query private var achievements: [Achievement]
    @Query private var sessions: [CrySession]
    
    private var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Card
                    HStack(spacing: 20) {
                        // Progress ring
                        ZStack {
                            Circle()
                                .stroke(AppTheme.Colors.secondary.opacity(0.8), lineWidth: 6)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: achievements.isEmpty ? 0 : Double(unlockedCount) / Double(achievements.count))
                                .stroke(
                                    AppTheme.Colors.tertiary.opacity(0.9),
                                    style: StrokeStyle(
                                        lineWidth: 6,
                                        lineCap: .round,
                                        lineJoin: .round
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut, value: unlockedCount)
                            
                            // Add percentage text in the center
                            Text("\(Int((Double(unlockedCount) / Double(max(1, achievements.count))) * 100))%")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.text)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(unlockedCount) of \(achievements.count)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.Colors.tertiary)
                            
                            Text("Achievements Unlocked")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // Achievements Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("YOUR ACHIEVEMENTS")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 16) {
                            ForEach(achievements) { achievement in
                                AchievementRowView(achievement: achievement)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Achievements")
        }
    }
}

struct AchievementRowView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            // Achievement Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? AppTheme.Colors.tertiary.opacity(0.1) : AppTheme.Colors.secondary)
                    .frame(width: 48, height: 48)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 20))
                    .foregroundColor(achievement.isUnlocked ? AppTheme.Colors.tertiary : AppTheme.Colors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(.headline)
                    .foregroundColor(AppTheme.Colors.text)
                
                Text(achievement.achievementDescription)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                if !achievement.isUnlocked {
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(AppTheme.Colors.secondary.opacity(0.3))
                                .frame(height: 4)
                                .cornerRadius(2)
                            
                            Rectangle()
                                .fill(AppTheme.Colors.tertiary)
                                .frame(width: geometry.size.width * achievement.progress, height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .frame(height: 4)
                    .padding(.top, 4)
                }
            }
            
            Spacer()
            
            // Unlock Status
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.success)
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Achievement.self, configurations: config)
    
    let achievement = Achievement(
        name: "First Tears",
        description: "Log your first crying session",
        icon: "1.circle.fill",
        type: .firstCry,
        progress: 0.5
    )
    
    container.mainContext.insert(achievement)
    
    return AchievementRowView(achievement: achievement)
} 