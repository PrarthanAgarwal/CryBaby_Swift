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
    case notes = "Notes"
    case satisfaction = "Satisfaction"
    case intensity = "Intensity"
    case timeCollector = "Time Collector"
    case quickRelease = "Quick Release"
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
                // Check for a session longer than 1 hour
                shouldUnlock = sessions.contains { $0.duration >= 3600 }
                
            case .notes:
                // Check for 10 consecutive sessions with notes
                let sortedSessions = sessions.sorted { $0.date > $1.date }
                var consecutiveWithNotes = 0
                for session in sortedSessions {
                    if let notes = session.notes, !notes.isEmpty {
                        consecutiveWithNotes += 1
                        if consecutiveWithNotes >= 10 {
                            shouldUnlock = true
                            break
                        }
                    } else {
                        break
                    }
                }
                
            case .satisfaction:
                // Check for 3 consecutive 5-star sessions
                let sortedSessions = sessions.sorted { $0.date > $1.date }
                var consecutiveFiveStars = 0
                for session in sortedSessions {
                    if session.satisfaction == 5 {
                        consecutiveFiveStars += 1
                        if consecutiveFiveStars >= 3 {
                            shouldUnlock = true
                            break
                        }
                    } else {
                        consecutiveFiveStars = 0
                    }
                }
                
            case .intensity:
                // Check for 3 sessions within 24 hours
                let calendar = Calendar.current
                let sortedSessions = sessions.sorted { $0.date > $1.date }
                for i in 0..<(sortedSessions.count - 2) {
                    let firstSession = sortedSessions[i]
                    let thirdSession = sortedSessions[i + 2]
                    let hoursBetween = calendar.dateComponents([.hour], from: thirdSession.date, to: firstSession.date).hour ?? 0
                    if hoursBetween < 24 {
                        shouldUnlock = true
                        break
                    }
                }
                
            case .timeCollector:
                // Check for sessions in every hour of the day
                let hours = Set(sessions.map { Calendar.current.component(.hour, from: $0.date) })
                shouldUnlock = hours.count == 24
                
            case .quickRelease:
                // Check for a session under 5 minutes
                shouldUnlock = sessions.contains { $0.duration <= 300 }
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