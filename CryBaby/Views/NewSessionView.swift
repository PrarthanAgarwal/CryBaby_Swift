import SwiftUI
import SwiftData

struct NewSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @FocusState private var focusedField: Field?
    @State private var name = ""
    @State private var selectedReason = CryReason.justBecause
    @State private var selectedVolume = CryVolume.glass
    @State private var date: Date
    @State private var durationMinutes: Double = 5
    @State private var satisfaction = 3
    @State private var notes = ""
    @State private var showingSuccessAlert = false
    @State private var showingDurationPicker = false
    @State private var currentPage = 0
    @State private var showingAchievementPopup = false
    @State private var unlockedAchievement: Achievement?
    
    init() {
        _date = State(initialValue: Date())
    }
    
    private let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sevenDaysAgo...Date()
    }()
    
    private enum Field {
        case name
        case notes
    }
    
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    private let reasonsPerPage = 4
    private var numberOfReasonPages: Int {
        Int(ceil(Double(CryReason.allCases.count) / Double(reasonsPerPage)))
    }
    
    private var formattedDuration: String {
        if durationMinutes >= 60 {
            let hours = Int(durationMinutes) / 60
            let minutes = Int(durationMinutes) % 60
            if minutes == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(minutes)m"
        }
        return "\(Int(durationMinutes))m"
    }
    
    private var satisfactionDescription: String {
        switch satisfaction {
        case 1: return "Still Low"
        case 2: return "Somewhat Heavy"
        case 3: return "Meh"
        case 4: return "Lighter"
        case 5: return "Relieved"
        default: return ""
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Session Name").font(.headline).fontWeight(.bold)) {
                    TextField("Session Name", text: $name)
                        .focused($focusedField, equals: .name)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(AppTheme.Colors.secondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Why Today?").font(.headline).fontWeight(.bold)) {
                    VStack {
                        TabView(selection: $currentPage) {
                            ForEach(0..<numberOfReasonPages, id: \.self) { pageIndex in
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ], spacing: 12) {
                                    ForEach(pageReasons(for: pageIndex), id: \.self) { reason in
                                        Button {
                                            selectedReason = reason
                                        } label: {
                                            ReasonCard(reason: reason, isSelected: reason == selectedReason)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 4)
                                .tag(pageIndex)
                            }
                        }
                        .frame(height: 170)
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        
                        // Custom page indicator
                        HStack(spacing: 8) {
                            ForEach(0..<numberOfReasonPages, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary.opacity(0.7))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, 2)
                        .padding(.bottom, 4)
                    }
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("How Much Tears?").font(.headline).fontWeight(.bold)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(CryVolume.allCases, id: \.self) { volume in
                                Button {
                                    selectedVolume = volume
                                } label: {
                                    VolumeCard(volume: volume, isSelected: volume == selectedVolume)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                    }
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Time Details").font(.headline).fontWeight(.bold)) {
                    VStack {
                        DatePicker("Date", selection: $date, in: dateRange)
                            .tint(AppTheme.Colors.primary)
                        Divider()
                        Button {
                            showingDurationPicker.toggle()
                        } label: {
                            HStack {
                                Text("Duration")
                                Spacer()
                                Text(formattedDuration)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                Image(systemName: "clock.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .background(AppTheme.Colors.secondary)
                    .cornerRadius(12)
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Rate Your Session").font(.headline).fontWeight(.bold)) {
                    VStack {
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { rating in
                                ZStack {
                                    Image(systemName: rating <= satisfaction ? "star.fill" : "star")
                                        .font(.system(size: 24))
                                        .foregroundColor(rating <= satisfaction ? Color(hex: "#FFD95F") : AppTheme.Colors.textSecondary.opacity(0.3))
                                }
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        satisfaction = rating
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Text(satisfactionDescription)
                            .font(.headline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .animation(.easeInOut, value: satisfaction)
                    }
                    .padding()
                    .background(AppTheme.Colors.secondary)
                    .cornerRadius(12)
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Additional Notes").font(.headline).fontWeight(.bold)) {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                        .focused($focusedField, equals: .notes)
                        .padding(5)
                        .background(AppTheme.Colors.secondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .listRowBackground(Color.clear)
                
                Section {
                    Button(action: {
                        withAnimation {
                            saveSession()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Save Session")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(name.isEmpty || satisfaction == 0 ? AppTheme.Colors.textSecondary : AppTheme.Colors.primary)
                        .cornerRadius(12)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(name.isEmpty || satisfaction == 0)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background)
            .listSectionSpacing(.compact)
            .listStyle(.insetGrouped)
            .navigationTitle("Describe Your Cry")
            .navigationBarTitleDisplayMode(.large)
            .alert("Session Saved!", isPresented: $showingSuccessAlert) {
                Button("OK", role: .cancel) { }
            }
            .sheet(isPresented: $showingDurationPicker) {
                NavigationView {
                    DurationPickerView(duration: $durationMinutes)
                }
                .presentationDetents([.height(300)])
            }
            .onTapGesture {
                focusedField = nil
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
        .overlay {
            if showingAchievementPopup, let achievement = unlockedAchievement {
                AchievementPopupView(
                    achievement: achievement,
                    isPresented: $showingAchievementPopup
                )
            }
        }
    }
    
    private func pageReasons(for pageIndex: Int) -> [CryReason] {
        let startIndex = pageIndex * reasonsPerPage
        let endIndex = min(startIndex + reasonsPerPage, CryReason.allCases.count)
        return Array(CryReason.allCases[startIndex..<endIndex])
    }
    
    private func saveSession() {
        let session = CrySession(
            name: name,
            reason: selectedReason,
            volume: selectedVolume,
            date: date,
            duration: TimeInterval(durationMinutes * 60),
            satisfaction: satisfaction,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(session)
        
        // Check for achievements
        let descriptor = FetchDescriptor<CrySession>()
        if let sessions = try? modelContext.fetch(descriptor),
           let achievement = Achievement.checkAchievements(sessions: sessions, modelContext: modelContext) {
            unlockedAchievement = achievement
            showingAchievementPopup = true
        } else {
            showingSuccessAlert = true
        }
        
        // Reset form
        name = ""
        selectedReason = .justBecause
        selectedVolume = .glass
        date = Date()
        durationMinutes = 5
        satisfaction = 3
        notes = ""
    }
}

struct ReasonCard: View {
    let reason: CryReason
    let isSelected: Bool
    
    private var reasonParts: (text: String, emoji: String) {
        let components = reason.rawValue.split(separator: " ")
        let emoji = String(components.last ?? "")
        let text = components.dropLast().joined(separator: " ")
        return (text: text, emoji: emoji)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text(reasonParts.emoji)
                .font(.system(size: 28))
            Text(reasonParts.text)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.secondary)
        .foregroundColor(AppTheme.Colors.text)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.black : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.2), value: isSelected)
    }
}

struct VolumeCard: View {
    let volume: CryVolume
    let isSelected: Bool
    
    private var volumeParts: (text: String, emoji: String) {
        let components = volume.rawValue.split(separator: " ")
        return (
            text: String(components.first ?? ""),
            emoji: String(components.last ?? "")
        )
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text(volumeParts.emoji)
                .font(.system(size: 28))
            Text(volumeParts.text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(width: 80, height: 80)
        .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.secondary)
        .foregroundColor(AppTheme.Colors.text)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.black : Color.clear, lineWidth: 1)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.2), value: isSelected)
        .contentShape(Rectangle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DurationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var duration: Double
    @State private var tempDuration: Double
    
    init(duration: Binding<Double>) {
        self._duration = duration
        self._tempDuration = State(initialValue: duration.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Duration")
                .font(.headline)
                .padding(.top)
            
            Picker("", selection: $tempDuration) {
                ForEach(0...90, id: \.self) { minutes in
                    Text("\(minutes) minutes").tag(Double(minutes))
                }
            }
            .pickerStyle(.wheel)
            
            HStack(spacing: 20) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(AppTheme.Colors.textSecondary)
                
                Button("Done") {
                    duration = tempDuration
                    dismiss()
                }
                .foregroundColor(AppTheme.Colors.primary)
                .fontWeight(.bold)
            }
            .padding(.bottom)
        }
    }
} 