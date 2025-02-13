import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CrySession.date, order: .reverse) private var sessions: [CrySession]
    @State private var selectedDate: Date?
    @State private var showingDetail = false
    @State private var selectedSession: CrySession?
    @State private var showingAllSessions = false
    
    private var sessionsByDate: [Date: [CrySession]] {
        let calendar = Calendar.current
        return Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.date)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    CalendarView(selectedDate: $selectedDate,
                               markedDates: Array(sessionsByDate.keys))
                        .frame(height: 300)
                }
                
                if let selectedDate = selectedDate,
                   let daysSessions = sessionsByDate[Calendar.current.startOfDay(for: selectedDate)] {
                    Section("Sessions on \(selectedDate.formatted(date: .long, time: .omitted))") {
                        ForEach(daysSessions, id: \.id) { session in
                            SessionRowView(session: session)
                                .onTapGesture {
                                    selectedSession = session
                                    showingDetail = true
                                }
                        }
                    }
                } else if selectedDate != nil {
                    Section {
                        Text("No sessions recorded on this date")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                
                Section {
                    Button(action: {
                        showingAllSessions = true
                    }) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("View All Sessions")
                            Spacer()
                            Text("\(sessions.count)")
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background)
            .navigationTitle("Journal")
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
            .sheet(isPresented: $showingAllSessions) {
                NavigationStack {
                    List {
                        if sessions.isEmpty {
                            Text("No sessions recorded yet")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(sessions) { session in
                                SessionRowView(session: session)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedSession = session
                                        showingAllSessions = false
                                    }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(AppTheme.Colors.background)
                    .navigationTitle("All Sessions")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showingAllSessions = false
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SessionRowView: View {
    let session: CrySession
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: session.date)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: session.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.name)
                    .font(.headline)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formattedDate)
                    Text(formattedTime)
                }
                .font(.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            HStack {
                Text(session.reason.rawValue)
                Text("•")
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Text(session.volume.rawValue)
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<session.satisfaction, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "#FFD95F"))
                            .font(.caption)
                    }
                }
            }
            .font(.subheadline)
            .foregroundColor(AppTheme.Colors.text)
            
            if let notes = session.notes, !notes.isEmpty {
                Text(notes)
                    .font(.footnote)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date?
    let markedDates: [Date]
    
    var body: some View {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        VStack {
            Text("\(Date(), formatter: monthYearFormatter)")
                .font(.title2)
                .padding(.top)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                ForEach(daysInMonth(month: currentMonth, year: currentYear), id: \.self) { date in
                    if let date = date {
                        let isMarked = markedDates.contains { calendar.isDate($0, inSameDayAs: date) }
                        let dayId = calendar.startOfDay(for: date).timeIntervalSince1970
                        
                        Circle()
                            .fill(isMarked ? AppTheme.Colors.primary.opacity(0.2) : Color.clear)
                            .overlay(
                                Text("\(calendar.component(.day, from: date))")
                                    .foregroundColor(isMarked ? AppTheme.Colors.primary : AppTheme.Colors.text)
                            )
                            .id(dayId)
                            .onTapGesture {
                                selectedDate = date
                            }
                    } else {
                        Color.clear
                            .id(UUID())
                    }
                }
            }
            .padding()
        }
    }
    
    private var weekdaySymbols: [String] {
        let symbols = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        return symbols
    }
    
    private func daysInMonth(month: Int, year: Int) -> [Date?] {
        let calendar = Calendar.current
        
        guard let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: startDate)
        else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: startDate)
        let leadingSpaces = firstWeekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: leadingSpaces)
        
        for day in range {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                days.append(date)
            }
        }
        
        return days
    }
}

private let monthYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}() 