import Charts
import SwiftUI

struct HourlyDetailView: View {
    let cityName: String
    let day: AirQualityDay

    @Environment(\.dismiss) private var dismiss
    @State private var selectedHour: Date?

    private var selectedEntry: HourlyAirQualityEntry? {
        // 그래프에서 선택한 시간이 있으면 가장 가까운 시간 데이터를 찾습니다.
        let target = selectedHour ?? defaultSelectionTime
        return day.hourlyEntries.min { first, second in
            abs(first.time.timeIntervalSince(target)) < abs(second.time.timeIntervalSince(target))
        }
    }

    private var defaultSelectionTime: Date {
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.hour, .minute], from: Date())
        let targetTime = calendar.date(
            bySettingHour: nowComponents.hour ?? 12,
            minute: nowComponents.minute ?? 0,
            second: 0,
            of: day.date
        ) ?? day.date

        // 선택한 날짜가 오늘이 아니어도 현재 시각과 같은 시간대의 데이터를 기본으로 보여줍니다.
        return day.hourlyEntries.min { first, second in
            abs(first.time.timeIntervalSince(targetTime)) < abs(second.time.timeIntervalSince(targetTime))
        }?.time ?? targetTime
    }

    private var hourTickDates: [Date] {
        let calendar = Calendar.current
        return stride(from: 0, through: 21, by: 3).compactMap { hour in
            calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day.date)
        }
    }

    private var chartStartDate: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: day.date) ?? day.date
    }

    private var chartEndDate: Date {
        Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: day.date) ?? day.date
    }

    private var aqiChartUpperBound: Double {
        PollutantType.usAQI.chartUpperBound(for: day.hourlyEntries.compactMap { entry in
            entry.usAQI.map(Double.init)
        })
    }

    private var visibleAQIBands: [AirQualityBand] {
        PollutantType.usAQI.visibleBands(upTo: aqiChartUpperBound)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            if day.hourlyEntries.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        selectedHourInfo
                        aqiChart
                        hourlyPollutantChart(title: AppText.hourlyPM25, pollutant: .pm25)
                        hourlyPollutantChart(title: AppText.hourlyPM10, pollutant: .pm10)
                    }
                    .padding(.bottom, 4)
                }
            }
        }
        .padding(24)
        .frame(minWidth: 700, minHeight: 550)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            selectedHour = selectedEntry?.time ?? defaultSelectionTime
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(cityName)
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                HStack(spacing: 8) {
                    Label(formattedDate(day.date), systemImage: "calendar")
                    Text(formattedWeekday(day.date))
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Label(AppText.close, systemImage: "xmark")
            }
            .keyboardShortcut(.cancelAction)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(AppText.hourlyDataUnavailable)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var selectedHourInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(AppText.selectedHour, systemImage: "clock")
                .font(.headline)

            HStack(alignment: .firstTextBaseline, spacing: 18) {
                Text(formattedHour(selectedEntry?.time ?? defaultSelectionTime))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()

                valueColumn(title: AppText.usAQI, value: formattedAQI(selectedEntry?.usAQI))
                valueColumn(title: "PM2.5", value: formattedParticle(selectedEntry?.pm25))
                valueColumn(title: "PM10", value: formattedParticle(selectedEntry?.pm10))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(nsColor: .separatorColor).opacity(0.45), lineWidth: 1)
        )
    }

    private var aqiChart: some View {
        chartContainer(title: AppText.hourlyUSAQI, unit: AppText.usAQI, systemImage: "aqi.medium") {
            Chart {
                ForEach(visibleAQIBands) { band in
                    // AQI 단계별 배경을 먼저 그려 선 그래프가 위에 보이도록 합니다.
                    RectangleMark(
                        xStart: .value(AppText.chartTime, chartStartDate),
                        xEnd: .value(AppText.chartTime, chartEndDate),
                        yStart: .value(AppText.usAQI, band.lower),
                        yEnd: .value(AppText.usAQI, band.upper)
                    )
                    .foregroundStyle(band.color.opacity(0.12))
                    .annotation(position: .overlay, alignment: .trailing) {
                        bandLabel(band.title)
                    }
                }

                ForEach(day.hourlyEntries) { entry in
                    if let aqi = entry.usAQI {
                        LineMark(
                            x: .value(AppText.chartTime, entry.time),
                            y: .value(AppText.usAQI, Double(aqi))
                        )
                        .foregroundStyle(PollutantType.usAQI.lineColor)
                        .lineStyle(StrokeStyle(lineWidth: PollutantType.usAQI.lineWidth))

                        PointMark(
                            x: .value(AppText.chartTime, entry.time),
                            y: .value(AppText.usAQI, Double(aqi))
                        )
                        .foregroundStyle(PollutantType.usAQI.lineColor)
                    }
                }

                if let selectedEntry {
                    RuleMark(x: .value(AppText.selectedTime, selectedEntry.time))
                        .foregroundStyle(Color.secondary.opacity(0.55))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
            }
            .chartXSelection(value: $selectedHour)
            .chartXScale(domain: chartStartDate...chartEndDate)
            .chartYScale(domain: 0...aqiChartUpperBound)
            .chartXAxis { hourAxisMarks }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.secondary.opacity(0.22))
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .frame(height: 190)
        }
    }

    private func hourlyPollutantChart(title: String, pollutant: PollutantType) -> some View {
        let values = day.hourlyEntries.compactMap { entry in
            pollutantValue(for: entry, pollutant: pollutant)
        }
        let upperBound = pollutant.chartUpperBound(for: values)
        let visibleBands = pollutant.visibleBands(upTo: upperBound)

        return chartContainer(title: title, unit: "μg/m³", systemImage: "chart.xyaxis.line") {
            Chart {
                ForEach(visibleBands) { band in
                    RectangleMark(
                        xStart: .value(AppText.chartTime, chartStartDate),
                        xEnd: .value(AppText.chartTime, chartEndDate),
                        yStart: .value(AppText.particleConcentration, band.lower),
                        yEnd: .value(AppText.particleConcentration, band.upper)
                    )
                    .foregroundStyle(band.color.opacity(0.11))
                    .annotation(position: .overlay, alignment: .trailing) {
                        bandLabel(band.title)
                    }

                    RuleMark(y: .value(AppText.particleConcentration, band.upper))
                        .foregroundStyle(band.color.opacity(0.18))
                        .lineStyle(StrokeStyle(lineWidth: 0.5))
                }

                ForEach(day.hourlyEntries) { entry in
                    if let value = pollutantValue(for: entry, pollutant: pollutant) {
                        LineMark(
                            x: .value(AppText.chartTime, entry.time),
                            y: .value(AppText.particleConcentration, value)
                        )
                        .foregroundStyle(pollutant.lineColor)
                        .lineStyle(StrokeStyle(lineWidth: pollutant.lineWidth))

                        PointMark(
                            x: .value(AppText.chartTime, entry.time),
                            y: .value(AppText.particleConcentration, value)
                        )
                        .foregroundStyle(pollutant.lineColor)
                    }
                }

                if let selectedEntry {
                    RuleMark(x: .value(AppText.selectedTime, selectedEntry.time))
                        .foregroundStyle(Color.secondary.opacity(0.55))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
            }
            .chartXSelection(value: $selectedHour)
            .chartXScale(domain: chartStartDate...chartEndDate)
            .chartYScale(domain: 0...upperBound)
            .chartXAxis { hourAxisMarks }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.secondary.opacity(0.22))
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .frame(height: 190)
        }
    }

    private var hourAxisMarks: some AxisContent {
        AxisMarks(values: hourTickDates) { value in
            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                .foregroundStyle(Color.secondary.opacity(0.22))
            AxisTick()
            AxisValueLabel {
                if let date = value.as(Date.self) {
                    Text(formattedHour(date))
                }
            }
        }
    }

    private func chartContainer<Content: View>(title: String, unit: String, systemImage: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Label(title, systemImage: systemImage)
                    .font(.headline)

                UnitBadge(text: unit)
            }

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(nsColor: .separatorColor).opacity(0.45), lineWidth: 1)
        )
    }

    private func bandLabel(_ title: String) -> some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(Color.primary.opacity(0.72))
            .lineLimit(1)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(.thinMaterial.opacity(0.7))
            .clipShape(Capsule())
    }

    private func pollutantValue(for entry: HourlyAirQualityEntry, pollutant: PollutantType) -> Double? {
        switch pollutant {
        case .pm25:
            return entry.pm25
        case .pm10:
            return entry.pm10
        case .usAQI:
            return entry.usAQI.map(Double.init)
        }
    }

    private func valueColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
                .monospacedDigit()
        }
        .frame(minWidth: 94, alignment: .leading)
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

    private func formattedHour(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("HHmm")
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

        return String(format: "%.1f μg/m³", value)
    }
}
