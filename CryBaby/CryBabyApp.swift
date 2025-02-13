//
//  CryBabyApp.swift
//  CryBaby
//
//  Created by Prarthan Agarwal on 09/02/25.
//

import SwiftUI
import SwiftData

@main
struct CryBabyApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([CrySession.self, Achievement.self])
            let config = ModelConfiguration("CryBaby", schema: schema)
            container = try ModelContainer(for: schema, configurations: config)
            
            // Add default achievements if none exist
            if try container.mainContext.fetch(FetchDescriptor<Achievement>()).isEmpty {
                createDefaultAchievements()
            }
        } catch {
            fatalError("Could not initialize SwiftData: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NewSessionView()
                    .tabItem {
                        Label("New Cry", systemImage: "plus.circle.fill")
                    }
                
                JournalView()
                    .tabItem {
                        Label("Journal", systemImage: "calendar")
                    }
                
                StatsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }
                
                AchievementsView()
                    .tabItem {
                        Label("Achievements", systemImage: "trophy.fill")
                    }
            }
            .tint(AppTheme.Colors.tertiary)
            .background(AppTheme.Colors.background)
        }
        .modelContainer(container)
    }
    
    // MARK: - Private Methods
    
    private func createDefaultAchievements() {
        let achievements = [
            Achievement(name: "First Tears",
                       description: "Log your first crying session",
                       icon: "1.circle.fill",
                       type: .firstCry),
            Achievement(name: "Emotional Explorer",
                       description: "Try all different types of crying reasons",
                       icon: "face.smiling.fill",
                       type: .variety),
            Achievement(name: "Consistent Crier",
                       description: "Maintain a 3-day crying streak",
                       icon: "flame.fill",
                       type: .streak),
            Achievement(name: "Volume Master",
                       description: "Experience all volumes of crying",
                       icon: "speaker.wave.3.fill",
                       type: .volume),
            Achievement(name: "Diary Master",
                       description: "Write detailed notes for 10 consecutive sessions",
                       icon: "book.fill",
                       type: .notes),
            Achievement(name: "Emotional Growth",
                       description: "Achieve 5-star satisfaction in 3 consecutive sessions",
                       icon: "heart.fill",
                       type: .satisfaction),
            Achievement(name: "Marathon Crier",
                       description: "Complete a crying session lasting over 1 hour",
                       icon: "clock.badge.checkmark.fill",
                       type: .duration),
            Achievement(name: "Cry-athlon Champion",
                       description: "Complete 3 crying sessions within 24 hours",
                       icon: "trophy.circle.fill",
                       type: .intensity),
            Achievement(name: "Tear Time Traveler",
                       description: "Log a session in every hour of the day",
                       icon: "clock.arrow.circlepath",
                       type: .timeCollector),
            Achievement(name: "Speed Crier",
                       description: "Complete a session in under 5 minutes",
                       icon: "bolt.circle.fill",
                       type: .quickRelease)
        ]
        
        achievements.forEach { achievement in
            container.mainContext.insert(achievement)
        }
    }
}
