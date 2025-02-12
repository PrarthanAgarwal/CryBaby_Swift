import Foundation
import SwiftData

@Model
final class Achievement {
    var id: UUID
    var name: String
    var achievementDescription: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var icon: String // SF Symbol name
    var type: AchievementType
    var progress: Double // 0.0 to 1.0
    
    init(id: UUID = UUID(),
         name: String,
         description: String,
         isUnlocked: Bool = false,
         unlockedDate: Date? = nil,
         icon: String,
         type: AchievementType,
         progress: Double = 0.0) {
        self.id = id
        self.name = name
        self.achievementDescription = description
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
        self.icon = icon
        self.type = type
        self.progress = progress
    }
}

enum AchievementType: String, Codable, CaseIterable {
    case firstCry = "First Cry"
    case streak = "Streak"
    case volume = "Volume"
    case variety = "Variety"
    case frequency = "Frequency"
    case duration = "Duration"
}

extension Achievement {
    static func checkAchievements(sessions: [CrySession], modelContext: ModelContext) -> Achievement? {
        // Get all achievements
        let descriptor = FetchDescriptor<Achievement>()
        guard let achievements = try? modelContext.fetch(descriptor) else { return nil }
        
        // Check each achievement
        for achievement in achievements where !achievement.isUnlocked {
            var shouldUnlock = false
            
            switch achievement.type {
            case .firstCry:
                shouldUnlock = sessions.count == 1
                
            case .streak:
                // Check for 3-day streak
                let calendar = Calendar.current
                let sortedDates = sessions.map { $0.date }.sorted()
                var currentStreak = 1
                
                for i in 1..<sortedDates.count {
                    let daysBetween = calendar.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day ?? 0
                    if daysBetween == 1 {
                        currentStreak += 1
                        if currentStreak >= 3 {
                            shouldUnlock = true
                            break
                        }
                    } else {
                        currentStreak = 1
                    }
                }
                
            case .volume:
                // Check if user has tried all volumes
                let uniqueVolumes = Set(sessions.map { $0.volume })
                shouldUnlock = uniqueVolumes.count == CryVolume.allCases.count
                
            case .variety:
                // Check if user has tried all reasons
                let uniqueReasons = Set(sessions.map { $0.reason })
                shouldUnlock = uniqueReasons.count == CryReason.allCases.count
                
            case .frequency:
                // Check for 5 sessions in a week
                let calendar = Calendar.current
                let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
                let sessionsInWeek = sessions.filter { $0.date >= oneWeekAgo }
                shouldUnlock = sessionsInWeek.count >= 5
                
            case .duration:
                // Check for a session longer than 30 minutes
                shouldUnlock = sessions.contains { $0.duration >= 1800 }
            }
            
            if shouldUnlock {
                achievement.isUnlocked = true
                achievement.unlockedDate = Date()
                return achievement
            }
        }
        
        return nil
    }
} 