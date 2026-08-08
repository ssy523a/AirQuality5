import Foundation

// 화면에 표시할 날짜별 대기질 데이터입니다.
struct AirQualityDay: Identifiable {
    let id = UUID()
    let date: Date
    let averagePM25: Double?
    let averagePM10: Double?
    let maxUSAQI: Int?
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

    // Open-Meteo Geocoding API로 도시 이름을 좌표로 바꿉니다.
    func searchCity(named cityName: String) async throws -> CitySearchResult {
        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "name", value: cityName),
            URLQueryItem(name: "count", value: "1"),
            URLQueryItem(name: "language", value: "ko"),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = components?.url else {
            throw AirQualityError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validate(response: response)

        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)

        guard let city = decoded.results?.first else {
            throw AirQualityError.cityNotFound
        }

        return city
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

        var grouped: [Date: [(pm25: Double?, pm10: Double?, aqi: Int?)]] = [:]
        let calendar = Calendar.current

        for index in hourly.time.indices {
            guard let date = formatter.date(from: hourly.time[index]) else {
                continue
            }

            let day = calendar.startOfDay(for: date)
            let pm25 = hourly.pm25[safe: index] ?? nil
            let pm10 = hourly.pm10[safe: index] ?? nil
            let aqi = hourly.usAQI[safe: index] ?? nil

            grouped[day, default: []].append((pm25: pm25, pm10: pm10, aqi: aqi))
        }

        return grouped.keys.sorted().map { day in
            let values = grouped[day, default: []]
            return AirQualityDay(
                date: day,
                averagePM25: average(values.compactMap(\.pm25)),
                averagePM10: average(values.compactMap(\.pm10)),
                maxUSAQI: values.compactMap(\.aqi).max()
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
    case locationUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "요청 주소를 만들 수 없습니다. 잠시 후 다시 시도해 주세요."
        case .networkFailed:
            return "대기질 정보를 가져오지 못했습니다. 인터넷 연결을 확인해 주세요."
        case .cityNotFound:
            return "도시를 찾을 수 없습니다. 도시 이름을 다시 입력해 주세요."
        case .locationUnavailable:
            return "현재 위치를 가져올 수 없습니다. 위치 권한을 확인해 주세요."
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
