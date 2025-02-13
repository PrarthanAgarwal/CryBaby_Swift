import SwiftUI
import SwiftData

struct SessionDetailView: View {
    let session: CrySession
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                List {
                    Section("Basic Info") {
                        LabeledContent("Name", value: session.name)
                        LabeledContent("Reason", value: session.reason.rawValue)
                        LabeledContent("Volume", value: session.volume.rawValue)
                    }
                    
                    Section("Time Details") {
                        LabeledContent("Date", value: session.date.formatted(date: .long, time: .shortened))
                        LabeledContent("Duration", value: formatDuration(session.duration))
                    }
                    
                    Section("Satisfaction") {
                        HStack {
                            ForEach(0..<5) { index in
                                Image(systemName: index < session.satisfaction ? "star.fill" : "star")
                                    .foregroundColor(Color(hex: "#FFD95F"))
                            }
                        }
                    }
                    
                    if let notes = session.notes, !notes.isEmpty {
                        Section("Notes") {
                            Text(notes)
                                .font(.body)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.tertiary)
                }
            }
        }
        .interactiveDismissDisabled(false)
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
} 