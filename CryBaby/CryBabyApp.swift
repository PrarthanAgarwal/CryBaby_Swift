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
        // Register custom fonts
        Bundle.main.registerFonts()
        
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
            .tint(AppTheme.Colors.primary)
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
                       type: .volume)
        ]
        
        achievements.forEach { achievement in
            container.mainContext.insert(achievement)
        }
    }
}
