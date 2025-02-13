import Foundation
import SwiftData

@Model
final class CrySession {
    var id: UUID
    var name: String
    @Attribute private var reasonRaw: String
    @Attribute private var volumeRaw: String
    var date: Date
    var duration: TimeInterval
    var satisfaction: Int
    var notes: String?
    
    var reason: CryReason {
        get { CryReason(rawValue: reasonRaw) ?? .justBecause }
        set { reasonRaw = newValue.rawValue }
    }
    
    var volume: CryVolume {
        get { CryVolume(rawValue: volumeRaw) ?? .glass }
        set { volumeRaw = newValue.rawValue }
    }
    
    init(id: UUID = UUID(),
         name: String,
         reason: CryReason,
         volume: CryVolume,
         date: Date = Date(),
         duration: TimeInterval,
         satisfaction: Int,
         notes: String? = nil) {
        self.id = id
        self.name = name
        self.reasonRaw = reason.rawValue
        self.volumeRaw = volume.rawValue
        self.date = date
        self.duration = duration
        self.satisfaction = satisfaction
        self.notes = notes
    }
}

enum CryReason: String, CaseIterable {
    case heartbreak = "Hurt Feelings 🥺"
    case anxiety = "Anxiety 😶‍🌫️"
    case justBecause = "Just Because 🤷"
    case happyTears = "Happy Tears 🥹"
    case overwhelmed = "Overwhelmed 😩"
    case memoryLane = "Memory Lane 🎞️ "
    case frustration = "Frustration 😤"
    case laughingFit = "Grateful Heart ❤️"
}

enum CryVolume: String, CaseIterable {
    case glass = "Glass 🥛"
    case pint = "Pint 🍺"
    case gallon = "Bucket 🪣"
    case waterfall = "Waterfall 🌊"
    case floods = "Floods 🌊🏡"
    case tsunami = "Tsunami 🌊🏙️"
} 