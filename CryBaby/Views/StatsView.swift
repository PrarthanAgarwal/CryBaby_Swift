import SwiftUI
import SwiftData
import Charts

enum TimeFilter: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case allTime = "All Time"
}

struct StatsView: View {
    @Query private var sessions: [CrySession]
    @State private var selectedTimeFilter: TimeFilter = .week
    
    private var filteredSessions: [CrySession] {
        let calendar = Calendar.current
        let now = Date()
        
        return sessions.filter { session in
            switch selectedTimeFilter {
            case .week:
                return calendar.isDate(session.date, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(session.date, equalTo: now, toGranularity: .month)
            case .allTime:
                return true
            }
        }
    }
    
    private var timeOfDayDistribution: [(String, Int)] {
        let distribution = Dictionary(grouping: filteredSessions) { session -> String in
            let hour = Calendar.current.component(.hour, from: session.date)
            switch hour {
            case 5..<12: return "Morning"
            case 12..<17: return "Afternoon"
            case 17..<21: return "Evening"
            default: return "Night"
            }
        }
        return distribution.map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
    }
    
    private var reasonDistribution: [(String, Int)] {
        let distribution = Dictionary(grouping: filteredSessions, by: { $0.reason.rawValue })
        return distribution.map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
    }
    
    private var volumeDistribution: [(String, Int)] {
        let distribution = Dictionary(grouping: filteredSessions, by: { $0.volume.rawValue })
        return distribution.map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
    }
    
    private var averageVolume: String {
        guard !filteredSessions.isEmpty else { return "N/A" }
        let volumes = CryVolume.allCases
        let avgIndex = filteredSessions.reduce(0.0) { sum, session in
            sum + Double(volumes.firstIndex(of: session.volume) ?? 0)
        } / Double(filteredSessions.count)
        return volumes[Int(round(avgIndex))].rawValue
    }
    
    private var averageDuration: String {
        guard !filteredSessions.isEmpty else { return "N/A" }
        let avgMinutes = filteredSessions.reduce(0.0) { $0 + $1.duration } / Double(filteredSessions.count) / 60
        return String(format: "%.1f min", avgMinutes)
    }
    
    private var averageSatisfaction: String {
        guard !filteredSessions.isEmpty else { return "N/A" }
        let avg = filteredSessions.reduce(0.0) { $0 + Double($1.satisfaction) } / Double(filteredSessions.count)
        return String(format: "%.1f", avg)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Time Filter
                    Picker("Time Filter", selection: $selectedTimeFilter) {
                        ForEach(TimeFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Summary Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        StatBox(
                            title: "Cry Count",
                            value: "\(filteredSessions.count)",
                            icon: "drop.fill",
                            color: Color(hex: "#A1E3F9")
                        )
                        
                        StatBox(
                            title: "Avg Duration",
                            value: averageDuration,
                            icon: "clock.fill",
                            color: Color(hex: "#98FB98")
                        )
                        
                        StatBox(
                            title: "Avg Volume",
                            value: averageVolume,
                            icon: "gauge.medium",
                            color: Color(hex: "#FFB6C1")
                        )
                        
                        StatBox(
                            title: "Avg Satisfaction",
                            value: averageSatisfaction,
                            icon: "star.fill",
                            color: Color(hex: "#FFD95F")
                        )
                    }
                    .padding(.horizontal)
                    
                    // Charts
                    VStack(spacing: 16) {
                        ChartCard(title: "Time of Day", data: timeOfDayDistribution)
                        ChartCard(title: "Emotions", data: reasonDistribution)
                        ChartCard(title: "Volume Levels", data: volumeDistribution)
                        
                        if !filteredSessions.isEmpty {
                            KeywordsCard(sessions: filteredSessions)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background)
            .navigationTitle("Statistics")
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.Colors.text)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.Colors.surface)
                .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ChartCard: View {
    let title: String
    let data: [(String, Int)]
    @State private var hoveredSegment: String? = nil
    
    // Custom colors for different charts with more vibrant options
    private var chartColors: [Color] {
        switch title {
        case "Time of Day":
            return [
                Color(hex: "#FF9999"),  // Morning - Stronger pink
                Color(hex: "#FFC857"),  // Afternoon - Warmer gold
                Color(hex: "#7EC883"),  // Evening - Richer green
                Color(hex: "#69B7E8")   // Night - Deeper blue
            ]
        case "Volume Levels":
            return [
                Color(hex: "#69B7E8"),  // Glass - Deeper blue
                Color(hex: "#7EC883"),  // Pint - Richer green
                Color(hex: "#FF9999"),  // Gallon - Stronger pink
                Color(hex: "#FFC857")   // Ocean - Warmer gold
            ]
        default:
            return [
                Color(hex: "#FF9999"),  // Stronger pink
                Color(hex: "#7EC883"),  // Richer green
                Color(hex: "#69B7E8"),  // Deeper blue
                Color(hex: "#FFC857")   // Warmer gold
            ]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.Colors.text)
            
            if !data.isEmpty {
                HStack(alignment: .center, spacing: 24) {
                    Chart {
                        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                            SectorMark(
                                angle: .value("Count", item.1),
                                innerRadius: .ratio(0.618),
                                angularInset: 1.5
                            )
                            .cornerRadius(4)
                            .foregroundStyle(chartColors[index % chartColors.count])
                            .opacity(hoveredSegment == nil || hoveredSegment == item.0 ? 1 : 0.3)
                        }
                    }
                    .frame(width: 140, height: 140)
                    .chartBackground { proxy in
                        Color.clear.onTapGesture { location in
                            hoveredSegment = nil
                        }
                    }
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(chartColors[index % chartColors.count])
                                    .frame(width: 8, height: 8)
                                Text("\(item.0) (\(item.1))")
                                    .font(.system(size: 15))
                                    .foregroundColor(AppTheme.Colors.text)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(hoveredSegment == item.0 ? chartColors[index % chartColors.count].opacity(0.15) : Color.clear)
                            )
                            .onHover { isHovered in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    hoveredSegment = isHovered ? item.0 : nil
                                }
                            }
                        }
                    }
                }
            } else {
                Text("No data available")
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(AppTheme.Colors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct KeywordsCard: View {
    let sessions: [CrySession]
    
    private var keywords: [(String, Int)] {
        let words = sessions.compactMap { $0.notes }
            .joined(separator: " ")
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 }
        
        let counts = Dictionary(grouping: words, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(6)
        
        return Array(counts.map { ($0.key, $0.value) })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Common Keywords")
                .font(.headline)
                .foregroundColor(AppTheme.Colors.text)
            
            if !keywords.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(keywords, id: \.0) { keyword in
                        Text(keyword.0)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.Colors.primary.opacity(0.1))
                            .foregroundColor(AppTheme.Colors.primary)
                            .cornerRadius(AppTheme.Layout.cornerRadius)
                    }
                }
            } else {
                Text("No keywords available")
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.Layout.cornerRadius)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, line) in result.lines.enumerated() {
            let y = bounds.minY + result.lineOffsets[index]
            var x = bounds.minX
            
            for item in line {
                let width = item.size.width
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: width, height: item.size.height)
                )
                x += width + spacing
            }
        }
    }
    
    struct FlowResult {
        struct Item {
            let index: Int
            let size: CGSize
        }
        
        var lines: [[Item]] = []
        var lineOffsets: [CGFloat] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentLine: [Item] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var maxLineHeight: CGFloat = 0
            
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && !currentLine.isEmpty {
                    lines.append(currentLine)
                    lineOffsets.append(currentY)
                    currentY += maxLineHeight + spacing
                    currentLine = []
                    currentX = 0
                    maxLineHeight = 0
                }
                
                currentLine.append(Item(index: index, size: size))
                currentX += size.width + spacing
                maxLineHeight = max(maxLineHeight, size.height)
            }
            
            if !currentLine.isEmpty {
                lines.append(currentLine)
                lineOffsets.append(currentY)
                currentY += maxLineHeight
            }
            
            size = CGSize(width: maxWidth, height: currentY)
        }
    }
} 