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

    private var particlePoints: [HourlyParticlePoint] {
        day.hourlyEntries.flatMap { entry in
            var points: [HourlyParticlePoint] = []

            if let pm25 = entry.pm25 {
                points.append(HourlyParticlePoint(time: entry.time, pollutant: "PM2.5", value: pm25))
            }

            if let pm10 = entry.pm10 {
                points.append(HourlyParticlePoint(time: entry.time, pollutant: "PM10", value: pm10))
            }

            return points
        }
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
                        particleChart
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
        chartContainer(title: AppText.hourlyUSAQI, systemImage: "aqi.medium") {
            Chart {
                ForEach(day.hourlyEntries) { entry in
                    if let aqi = entry.usAQI {
                        LineMark(
                            x: .value(AppText.chartTime, entry.time),
                            y: .value(AppText.usAQI, aqi)
                        )
                        .foregroundStyle(Color.purple)

                        PointMark(
                            x: .value(AppText.chartTime, entry.time),
                            y: .value(AppText.usAQI, aqi)
                        )
                        .foregroundStyle(Color.purple)
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
            .chartXAxis { hourAxisMarks }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.secondary.opacity(0.22))
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .frame(height: 190)
        }
    }

    private var particleChart: some View {
        chartContainer(title: AppText.hourlyParticles, systemImage: "chart.xyaxis.line") {
            Chart {
                ForEach(particlePoints) { point in
                    LineMark(
                        x: .value(AppText.chartTime, point.time),
                        y: .value(AppText.particleConcentration, point.value)
                    )
                    .foregroundStyle(by: .value(AppText.chartSeries, point.pollutant))

                    PointMark(
                        x: .value(AppText.chartTime, point.time),
                        y: .value(AppText.particleConcentration, point.value)
                    )
                    .foregroundStyle(by: .value(AppText.chartSeries, point.pollutant))
                }

                if let selectedEntry {
                    RuleMark(x: .value(AppText.selectedTime, selectedEntry.time))
                        .foregroundStyle(Color.secondary.opacity(0.55))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
            }
            .chartXSelection(value: $selectedHour)
            .chartXScale(domain: chartStartDate...chartEndDate)
            .chartForegroundStyleScale([
                "PM2.5": Color.blue,
                "PM10": Color.orange
            ])
            .chartLegend(position: .bottom, alignment: .leading)
            .chartXAxis { hourAxisMarks }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.secondary.opacity(0.22))
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .frame(height: 210)
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

    private func chartContainer<Content: View>(title: String, systemImage: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)

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

private struct HourlyParticlePoint: Identifiable {
    let time: Date
    let pollutant: String
    let value: Double

    var id: String {
        "\(pollutant)-\(time.timeIntervalSince1970)"
    }
}
