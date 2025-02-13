import SwiftUI
import SwiftData

private struct DebugKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isDebugging: Bool {
        get { self[DebugKey.self] }
        set { self[DebugKey.self] = newValue }
    }
}

extension View {
    func debugLog(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}

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
    @Environment(\.isDebugging) private var isDebugging
    
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
    
    private func log(_ message: String) {
        if isDebugging {
            debugLog(message)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Session Name").font(.headline).fontWeight(.bold)) {
                    TextField("Give your cry a memorable name...", text: $name)
                        .focused($focusedField, equals: .name)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(AppTheme.Colors.secondary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                
                Section(header: Text("Why Today?").font(.headline).fontWeight(.bold)) {
                    VStack(spacing: 0) {
                        TabView(selection: $currentPage) {
                            ForEach(0..<numberOfReasonPages, id: \.self) { pageIndex in
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ], spacing: 12) {
                                    ForEach(pageReasons(for: pageIndex), id: \.self) { reason in
                                        TappableReasonCard(
                                            reason: reason,
                                            isSelected: reason == selectedReason
                                        ) {
                                            withAnimation(.spring(response: 0.2)) {
                                                selectedReason = reason
                                            }
                                        }
                                        .id(reason)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 4)
                                .tag(pageIndex)
                                .frame(minHeight: 0, maxHeight: .infinity)
                            }
                        }
                        .frame(height: 170)
                        .clipped()
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        
                        // Custom page indicator
                        HStack(spacing: 8) {
                            ForEach(0..<numberOfReasonPages, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? AppTheme.Colors.tertiary : AppTheme.Colors.textSecondary.opacity(0.7))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, 2)
                        .padding(.bottom, 4)
                    }
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("How Much Tears?").font(.headline).fontWeight(.bold)) {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 12) {
                                ForEach(CryVolume.allCases, id: \.self) { volume in
                                    TappableVolumeCard(
                                        volume: volume,
                                        isSelected: volume == selectedVolume
                                    ) {
                                        withAnimation(.spring(response: 0.2)) {
                                            selectedVolume = volume
                                        }
                                    }
                                    .id(volume)
                                    .frame(width: 80, height: 80)
                                }
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .frame(minHeight: 96)
                        }
                        .clipped()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    proxy.scrollTo(selectedVolume, anchor: .center)
                                }
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Time Details").font(.headline).fontWeight(.bold)) {
                    VStack {
                        DatePicker("Date", selection: $date, in: dateRange)
                            .tint(AppTheme.Colors.tertiary)
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
                                    .foregroundColor(AppTheme.Colors.tertiary)
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
                
                Section(header: Text("Post-Cry Check-in").font(.headline).fontWeight(.bold)) {
                    VStack {
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { rating in
                                TappableRatingButton(
                                    rating: rating,
                                    currentRating: satisfaction
                                ) {
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
                
                Section(header: Text("Tell your story").font(.headline).fontWeight(.bold)) {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                        .focused($focusedField, equals: .notes)
                        .padding(5)
                        .background(AppTheme.Colors.secondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .overlay(
                            Text("Dear Diary...")
                                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.8))
                                .padding(.leading, 8)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                                .opacity(notes.isEmpty ? 1 : 0)
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
                        .background(name.isEmpty || satisfaction == 0 ? AppTheme.Colors.textSecondary : AppTheme.Colors.tertiary)
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
                    .foregroundColor(AppTheme.Colors.tertiary)
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
        .overlay(debugOverlay)
    }
    
    @ViewBuilder
    private var debugOverlay: some View {
        if isDebugging {
            VStack {
                HStack {
                    Text("Debug Mode")
                        .font(.caption)
                        .padding(4)
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(4)
                    Spacer()
                }
                Spacer()
            }
            .padding()
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
            
            Picker("Duration", selection: $tempDuration) {
                ForEach(0...90, id: \.self) { minutes in
                    Text("\(minutes) minutes").tag(Double(minutes))
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            
            HStack(spacing: 20) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(AppTheme.Colors.textSecondary)
                
                Button("Done") {
                    duration = tempDuration
                    dismiss()
                }
                .foregroundColor(AppTheme.Colors.tertiary)
                .fontWeight(.bold)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TappableReasonCard: View {
    let reason: CryReason
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            let parts = reason.rawValue.split(separator: " ")
            let emoji = String(parts.last ?? "")
            let text = parts.dropLast().joined(separator: " ")
            
            Text(emoji)
                .font(.system(size: 28))
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 70)
        .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.secondary)
        .foregroundColor(AppTheme.Colors.text)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.black : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .highPriorityGesture(
            TapGesture()
                .onEnded { _ in
                    print("🔵 Reason tapped: \(reason) at \(Date())")
                    withAnimation(.spring(response: 0.2)) {
                        action()
                    }
                }
        )
    }
}

struct TappableVolumeCard: View {
    let volume: CryVolume
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            let parts = volume.rawValue.split(separator: " ")
            let emoji = String(parts.last ?? "")
            let text = String(parts.first ?? "")
            
            Text(emoji)
                .font(.system(size: 28))
            Text(text)
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
        .contentShape(Rectangle())
        .highPriorityGesture(
            TapGesture()
                .onEnded { _ in
                    print("🔵 Volume tapped: \(volume) at \(Date())")
                    withAnimation(.spring(response: 0.2)) {
                        action()
                    }
                }
        )
    }
}

struct TappableRatingButton: View {
    let rating: Int
    let currentRating: Int
    let action: () -> Void
    
    var body: some View {
        Image(systemName: rating <= currentRating ? "star.fill" : "star")
            .font(.system(size: 24))
            .foregroundColor(rating <= currentRating ? Color(hex: "#FFD95F") : AppTheme.Colors.textSecondary.opacity(0.3))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
            .highPriorityGesture(
                TapGesture()
                    .onEnded { _ in
                        print("⭐️ Rating tapped: \(rating) at \(Date())")
                        action()
                    }
            )
    }
}

struct TappableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

extension View {
    func preventAutomaticKeyboardDismissal() -> some View {
        self.textFieldStyle(.plain)
            .ignoresSafeArea(.keyboard, edges: .bottom)
    }
} 