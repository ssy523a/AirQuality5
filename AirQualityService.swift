import Foundation

// 화면에 표시할 날짜별 대기질 데이터입니다.
struct AirQualityDay: Identifiable {
    let id = UUID()
    let date: Date
    let averagePM25: Double?
    let averagePM10: Double?
    let maxUSAQI: Int?
    let hourlyEntries: [HourlyAirQualityEntry]
}

// 상세 화면에서 사용할 시간별 대기질 데이터입니다.
struct HourlyAirQualityEntry: Identifiable {
    let time: Date
    let pm25: Double?
    let pm10: Double?
    let usAQI: Int?

    var id: Date {
        time
    }
}

// 도시 검색 결과 한 개를 표현합니다.
struct CitySearchResult: Identifiable, Decodable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?

    var displayName: String {
        [name, admin1, country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

struct AirQualityService {
    private let session: URLSession = .shared

    // 한국어 도시명은 로컬 목록에서 먼저 찾고, 없으면 Open-Meteo Geocoding API로 검색합니다.
    func searchCities(named cityName: String) async throws -> [CitySearchResult] {
        let localResults = KoreanCityDirectory.search(cityName)

        if !localResults.isEmpty {
            return localResults
        }

        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "name", value: cityName),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: AppText.geocodingLanguageCode),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = components?.url else {
            throw AirQualityError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validate(response: response)

        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        return decoded.results ?? []
    }

    // Open-Meteo Air Quality API에서 시간별 데이터를 받은 뒤 날짜별 대표값으로 묶습니다.
    func fetchFiveDayForecast(latitude: Double, longitude: Double) async throws -> [AirQualityDay] {
        var components = URLComponents(string: "https://air-quality-api.open-meteo.com/v1/air-quality")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "hourly", value: "pm2_5,pm10,us_aqi"),
            URLQueryItem(name: "forecast_days", value: "5"),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        guard let url = components?.url else {
            throw AirQualityError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validate(response: response)

        let decoded = try JSONDecoder().decode(AirQualityResponse.self, from: data)
        return groupHourlyDataByDay(decoded.hourly)
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AirQualityError.networkFailed
        }
    }

    private func groupHourlyDataByDay(_ hourly: HourlyAirQuality) -> [AirQualityDay] {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"

        var grouped: [Date: [HourlyAirQualityEntry]] = [:]
        let calendar = Calendar.current

        for index in hourly.time.indices {
            guard let date = formatter.date(from: hourly.time[index]) else {
                continue
            }

            let day = calendar.startOfDay(for: date)
            let entry = HourlyAirQualityEntry(
                time: date,
                pm25: hourly.pm25[safe: index] ?? nil,
                pm10: hourly.pm10[safe: index] ?? nil,
                usAQI: hourly.usAQI[safe: index] ?? nil
            )

            grouped[day, default: []].append(entry)
        }

        return grouped.keys.sorted().map { day in
            let entries = grouped[day, default: []].sorted { $0.time < $1.time }
            return AirQualityDay(
                date: day,
                averagePM25: average(entries.compactMap(\.pm25)),
                averagePM10: average(entries.compactMap(\.pm10)),
                maxUSAQI: entries.compactMap(\.usAQI).max(),
                hourlyEntries: entries
            )
        }
    }

    private func average(_ values: [Double]) -> Double? {
        guard !values.isEmpty else {
            return nil
        }

        return values.reduce(0, +) / Double(values.count)
    }
}

// API나 앱에서 발생할 수 있는 오류를 사용자가 이해하기 쉬운 문장으로 바꿉니다.
enum AirQualityError: LocalizedError {
    case invalidURL
    case networkFailed
    case cityNotFound
    case noSearchResults
    case locationDenied
    case locationUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return AppText.requestURLFailed
        case .networkFailed:
            return AppText.networkFailed
        case .cityNotFound, .noSearchResults:
            return AppText.noSearchResults
        case .locationDenied:
            return AppText.locationDenied
        case .locationUnavailable:
            return AppText.locationUnavailable
        }
    }
}

private struct GeocodingResponse: Decodable {
    let results: [CitySearchResult]?
}

private struct AirQualityResponse: Decodable {
    let hourly: HourlyAirQuality
}

private struct HourlyAirQuality: Decodable {
    let time: [String]
    let pm25: [Double?]
    let pm10: [Double?]
    let usAQI: [Int?]

    enum CodingKeys: String, CodingKey {
        case time
        case pm25 = "pm2_5"
        case pm10
        case usAQI = "us_aqi"
    }
}

private extension Array {
    // 배열 범위를 벗어나면 nil을 돌려주어 앱이 종료되지 않게 합니다.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
