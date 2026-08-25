import SwiftUI

// 미국 EPA AQI 기준의 그래프 배경 구간을 한 곳에서 관리합니다.
// PM2.5와 PM10은 서로 다른 농도 breakpoint를 사용합니다.
enum PollutantType {
    case usAQI
    case pm25
    case pm10

    var displayName: String {
        switch self {
        case .usAQI:
            return AppText.usAQI
        case .pm25:
            return "PM2.5"
        case .pm10:
            return "PM10"
        }
    }

    var unitLabel: String {
        switch self {
        case .usAQI:
            return AppText.usAQI
        case .pm25, .pm10:
            return AppText.particleConcentration
        }
    }

    var lineColor: Color {
        switch self {
        case .usAQI:
            return .purple
        case .pm25:
            return .blue
        case .pm10:
            return .orange
        }
    }

    var lineWidth: Double {
        switch self {
        case .pm25:
            return 2.0
        case .usAQI, .pm10:
            return 2.6
        }
    }

    var bands: [AirQualityBand] {
        switch self {
        case .usAQI:
            return [
                AirQualityBand(lower: 0, upper: 50, title: AppText.aqiStatus(value: 25), color: .green),
                AirQualityBand(lower: 50, upper: 100, title: AppText.aqiStatus(value: 75), color: .yellow),
                AirQualityBand(lower: 100, upper: 150, title: AppText.aqiStatus(value: 125), color: .orange),
                AirQualityBand(lower: 150, upper: 200, title: AppText.aqiStatus(value: 175), color: .red),
                AirQualityBand(lower: 200, upper: 300, title: AppText.aqiStatus(value: 250), color: .purple),
                AirQualityBand(lower: 300, upper: 500, title: AppText.aqiStatus(value: 350), color: Color(red: 0.45, green: 0.05, blue: 0.16))
            ]
        case .pm25:
            return [
                AirQualityBand(lower: 0.0, upper: 9.0, title: AppText.aqiStatus(value: 25), color: .green),
                AirQualityBand(lower: 9.1, upper: 35.4, title: AppText.aqiStatus(value: 75), color: .yellow),
                AirQualityBand(lower: 35.5, upper: 55.4, title: AppText.aqiStatus(value: 125), color: .orange),
                AirQualityBand(lower: 55.5, upper: 125.4, title: AppText.aqiStatus(value: 175), color: .red),
                AirQualityBand(lower: 125.5, upper: 225.4, title: AppText.aqiStatus(value: 250), color: .purple),
                AirQualityBand(lower: 225.5, upper: 325.4, title: AppText.aqiStatus(value: 350), color: Color(red: 0.45, green: 0.05, blue: 0.16))
            ]
        case .pm10:
            return [
                AirQualityBand(lower: 0, upper: 54, title: AppText.aqiStatus(value: 25), color: .green),
                AirQualityBand(lower: 55, upper: 154, title: AppText.aqiStatus(value: 75), color: .yellow),
                AirQualityBand(lower: 155, upper: 254, title: AppText.aqiStatus(value: 125), color: .orange),
                AirQualityBand(lower: 255, upper: 354, title: AppText.aqiStatus(value: 175), color: .red),
                AirQualityBand(lower: 355, upper: 424, title: AppText.aqiStatus(value: 250), color: .purple),
                AirQualityBand(lower: 425, upper: 604, title: AppText.aqiStatus(value: 350), color: Color(red: 0.45, green: 0.05, blue: 0.16))
            ]
        }
    }

    func chartUpperBound(for values: [Double]) -> Double {
        let maxValue = values.max() ?? bands.first?.upper ?? 50
        let paddedMax = maxValue * 1.12

        if let matchingBand = bands.first(where: { paddedMax <= $0.upper }) {
            return matchingBand.upper
        }

        return max(paddedMax, maxValue + 10)
    }

    func visibleBands(upTo upperBound: Double) -> [AirQualityBand] {
        bands.compactMap { band in
            guard band.lower < upperBound else {
                return nil
            }

            return AirQualityBand(
                lower: band.lower,
                upper: min(band.upper, upperBound),
                title: band.title,
                color: band.color
            )
        }
    }
}

struct AirQualityBand: Identifiable {
    let lower: Double
    let upper: Double
    let title: String
    let color: Color

    var id: String {
        "\(lower)-\(upper)-\(title)"
    }

    var midpoint: Double {
        (lower + upper) / 2
    }
}
