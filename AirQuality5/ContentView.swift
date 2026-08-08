import Charts
import SwiftUI

struct ContentView: View {
    @State private var viewModel = AirQualityViewModel()
    @State private var selectedDay: AirQualityDay?

    private var currentDay: AirQualityDay? {
        viewModel.forecastDays.first
    }

    var body: some View {
        VStack(spacing: 0) {
            topArea
            content
        }
        .frame(minWidth: 760, idealWidth: 900, minHeight: 620, idealHeight: 850)
        .background(Color(nsColor: .windowBackgroundColor))
        .task {
            // 앱이 처음 열리면 현재 위치를 먼저 시도하고, 실패하면 Seoul을 보여줍니다.
            viewModel.loadInitialForecast()
        }
        .sheet(item: $selectedDay) { day in
            HourlyDetailView(cityName: viewModel.title, day: day)
        }
    }

    private var topArea: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            searchBar
        }
        .padding(.horizontal, 30)
        .padding(.top, 28)
        .padding(.bottom, 18)
        .background(.regularMaterial)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var header: some View {
        HStack(alignment: .bottom, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Label(AppText.appTitle, systemImage: "aqi.medium")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(viewModel.title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 16)

            if let currentDay {
                CurrentAQIBadge(day: currentDay)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(AppText.searchPlaceholder, text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        viewModel.searchCity()
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.45), lineWidth: 1)
            )

            Button {
                viewModel.searchCity()
            } label: {
                Label(AppText.search, systemImage: "magnifyingglass")
            }
            .keyboardShortcut(.return, modifiers: [])

            Button {
                viewModel.useCurrentLocation()
            } label: {
                Label(AppText.currentLocation, systemImage: "location.fill")
            }
        }
        .disabled(viewModel.isLoading)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            messageView(errorMessage, systemImage: "exclamationmark.triangle", color: .red)
        } else if !viewModel.searchResults.isEmpty {
            searchResultList
        } else if viewModel.forecastDays.isEmpty {
            messageView(AppText.startupEmptyState, systemImage: "magnifyingglass", color: .secondary)
        } else {
            forecastList
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
            Text(AppText.loading)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func messageView(_ message: String, systemImage: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(color)

            Text(message)
                .font(.body)
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var searchResultList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.searchResults) { city in
                    Button {
                        viewModel.selectCity(city)
                    } label: {
                        CitySearchResultRow(city: city)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(30)
        }
    }

    private var forecastList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                sectionHeader(title: AppText.fiveDayForecastSection, systemImage: "calendar")

                LazyVGrid(columns: forecastColumns, spacing: 12) {
                    ForEach(viewModel.forecastDays) { day in
                        ForecastDayButton(day: day) {
                            selectedDay = day
                        }
                    }
                }

                AirQualityTrendChart(days: viewModel.forecastDays)
            }
            .padding(30)
        }
    }

    private var forecastColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 145), spacing: 12)]
    }

    private func sectionHeader(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .foregroundStyle(.secondary)
    }
}

private struct ForecastDayButton: View {
    let day: AirQualityDay
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            AirQualityDayCard(day: day)
                .scaleEffect(isHovering ? 1.015 : 1.0)
                .shadow(color: .black.opacity(isHovering ? 0.10 : 0.04), radius: isHovering ? 8 : 2, y: isHovering ? 4 : 1)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .onHover { hovering in
            isHovering = hovering
        }
        .animation(.easeOut(duration: 0.12), value: isHovering)
    }
}

private struct CurrentAQIBadge: View {
    let day: AirQualityDay

    private var aqiStatus: AQIStatus {
        AQIStatus(value: day.maxUSAQI)
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: aqiStatus.symbolName)
                .font(.title3)
                .foregroundStyle(aqiStatus.foregroundColor)
                .frame(width: 28, height: 28)
                .background(aqiStatus.backgroundColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(AppText.todayUSAQI)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 7) {
                    Text(formattedAQI(day.maxUSAQI))
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()

                    Text(aqiStatus.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(aqiStatus.foregroundColor)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(nsColor: .separatorColor).opacity(0.45), lineWidth: 1)
        )
    }

    private func formattedAQI(_ value: Int?) -> String {
        guard let value else {
            return "-"
        }

        return "\(value)"
    }
}

private struct CitySearchResultRow: View {
    let city: CitySearchResult

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: "mappin.and.ellipse")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 34, height: 34)
                .background(Color.secondary.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(city.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(detailText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(nsColor: .separatorColor).opacity(0.45), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 8))
    }

    private var detailText: String {
        let details = [city.admin1, city.country].compactMap { $0 }
        return details.isEmpty ? AppText.regionUnavailable : details.joined(separator: ", ")
    }
}

private struct AirQualityDayCard: View {
    let day: AirQualityDay

    private var aqiStatus: AQIStatus {
        AQIStatus(value: day.maxUSAQI)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(formattedDate(day.date))
                        .font(.headline)

                    Text(formattedWeekday(day.date))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 4)

                Image(systemName: aqiStatus.symbolName)
                    .font(.headline)
                    .foregroundStyle(aqiStatus.foregroundColor)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(AppText.usAQI)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(formattedAQI(day.maxUSAQI))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(aqiStatus.foregroundColor)
                    .monospacedDigit()
                    .lineLimit(1)
            }

            Text(aqiStatus.title)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .foregroundStyle(aqiStatus.foregroundColor)
                .background(aqiStatus.backgroundColor)
                .clipShape(Capsule())

            Divider()

            HStack(spacing: 10) {
                valueBlock(title: "PM2.5", value: formattedParticle(day.averagePM25))
                valueBlock(title: "PM10", value: formattedParticle(day.averagePM10))
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, minHeight: 205, alignment: .topLeading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(aqiStatus.foregroundColor.opacity(0.22), lineWidth: 1)
        )
    }

    private func valueBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.callout)
                .fontWeight(.semibold)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("Md")
        return formatter.string(from: date)
    }

    private func formattedWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    private func formattedAQI(_ value: Int?) -> String {
        guard let value else {
            return "-"
        }

        return "\(value)"
    }

    private func formattedParticle(_ value: Double?) -> String {
        guard let value else {
            return "-"
        }

        return String(format: "%.1f", value)
    }
}

private struct AirQualityTrendChart: View {
    let days: [AirQualityDay]

    private var chartPoints: [AirQualityChartPoint] {
        days.flatMap { day in
            var points: [AirQualityChartPoint] = []

            if let pm25 = day.averagePM25 {
                points.append(AirQualityChartPoint(date: day.date, pollutant: "PM2.5", value: pm25))
            }

            if let pm10 = day.averagePM10 {
                points.append(AirQualityChartPoint(date: day.date, pollutant: "PM10", value: pm10))
            }

            return points
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.xyaxis.line")
                    .foregroundStyle(.secondary)
                Text(AppText.fiveDayParticleTrend)
                    .font(.headline)
            }

            Chart(chartPoints) { point in
                LineMark(
                    x: .value(AppText.chartDate, point.date),
                    y: .value(AppText.chartValue, point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(by: .value(AppText.chartSeries, point.pollutant))
                .symbol(by: .value(AppText.chartSeries, point.pollutant))

                PointMark(
                    x: .value(AppText.chartDate, point.date),
                    y: .value(AppText.chartValue, point.value)
                )
                .foregroundStyle(by: .value(AppText.chartSeries, point.pollutant))
            }
            .chartForegroundStyleScale([
                "PM2.5": Color.blue,
                "PM10": Color.orange
            ])
            .chartLegend(position: .bottom, alignment: .leading)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.secondary.opacity(0.22))
                    AxisTick()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            VStack(spacing: 2) {
                                Text(chartDateLabel(date))
                                Text(chartWeekdayLabel(date))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.secondary.opacity(0.22))
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .frame(height: 250)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(nsColor: .separatorColor).opacity(0.45), lineWidth: 1)
        )
    }

    private func chartDateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    private func chartWeekdayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

private struct AirQualityChartPoint: Identifiable {
    let date: Date
    let pollutant: String
    let value: Double

    var id: String {
        "\(pollutant)-\(date.timeIntervalSince1970)"
    }
}

private struct AQIStatus {
    let title: String
    let symbolName: String
    let foregroundColor: Color
    let backgroundColor: Color

    init(value: Int?) {
        guard let value else {
            title = AppText.aqiStatus(value: nil)
            symbolName = "questionmark.circle"
            foregroundColor = .secondary
            backgroundColor = Color.secondary.opacity(0.12)
            return
        }

        switch value {
        case 0...50:
            title = AppText.aqiStatus(value: value)
            symbolName = "checkmark.circle.fill"
            foregroundColor = .green
            backgroundColor = Color.green.opacity(0.16)
        case 51...100:
            title = AppText.aqiStatus(value: value)
            symbolName = "minus.circle.fill"
            foregroundColor = .yellow
            backgroundColor = Color.yellow.opacity(0.18)
        case 101...150:
            title = AppText.aqiStatus(value: value)
            symbolName = "exclamationmark.circle.fill"
            foregroundColor = .orange
            backgroundColor = Color.orange.opacity(0.16)
        case 151...200:
            title = AppText.aqiStatus(value: value)
            symbolName = "exclamationmark.triangle.fill"
            foregroundColor = .red
            backgroundColor = Color.red.opacity(0.14)
        case 201...300:
            title = AppText.aqiStatus(value: value)
            symbolName = "xmark.octagon.fill"
            foregroundColor = .purple
            backgroundColor = Color.purple.opacity(0.14)
        default:
            title = AppText.aqiStatus(value: value)
            symbolName = "xmark.octagon.fill"
            foregroundColor = .pink
            backgroundColor = Color.pink.opacity(0.14)
        }
    }
}

#Preview {
    ContentView()
}
