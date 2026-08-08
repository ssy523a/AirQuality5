import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
final class AirQualityViewModel {
    var searchText = "Seoul"
    var title = "도시를 검색해 주세요"
    var forecastDays: [AirQualityDay] = []
    var searchResults: [CitySearchResult] = []
    var isLoading = false
    var errorMessage: String?

    private let service = AirQualityService()
    private let locationManager = LocationManager()

    // 사용자가 입력한 도시 이름으로 검색합니다.
    func searchCity() {
        let cityName = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cityName.isEmpty else {
            errorMessage = "도시 이름을 입력해 주세요."
            searchResults = []
            return
        }

        Task {
            await searchCities(named: cityName)
        }
    }

    // 검색 결과 목록에서 사용자가 도시를 선택했을 때 실행됩니다.
    func selectCity(_ city: CitySearchResult) {
        Task {
            await loadForecast(for: city)
        }
    }

    // 현재 위치 버튼을 눌렀을 때 실행됩니다.
    func useCurrentLocation() {
        Task {
            await loadForecastForCurrentLocation()
        }
    }

    private func searchCities(named cityName: String) async {
        await runLoadingTask(clearSearchResults: true) {
            let cities = try await service.searchCities(named: cityName)

            guard !cities.isEmpty else {
                throw AirQualityError.noSearchResults
            }

            if cities.count == 1, let city = cities.first {
                try await loadForecastData(for: city)
            } else {
                // 여러 결과가 있으면 바로 예보를 가져오지 않고 사용자가 고르게 합니다.
                title = "검색 결과를 선택해 주세요"
                forecastDays = []
                searchResults = cities
            }
        }
    }

    private func loadForecast(for city: CitySearchResult) async {
        await runLoadingTask(clearSearchResults: false) {
            try await loadForecastData(for: city)
            searchResults = []
        }
    }

    private func loadForecastData(for city: CitySearchResult) async throws {
        let days = try await service.fetchFiveDayForecast(
            latitude: city.latitude,
            longitude: city.longitude
        )

        title = city.displayName
        forecastDays = days
    }

    private func loadForecastForCurrentLocation() async {
        await runLoadingTask(clearSearchResults: true) {
            let coordinate = try await locationManager.requestCurrentLocation()
            let days = try await service.fetchFiveDayForecast(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            let placeName = await locationManager.placeName(for: coordinate)

            // 지명을 찾을 수 있으면 지명을 보여주고, 실패하면 기본 문구를 보여줍니다.
            title = placeName ?? "현재 위치"
            forecastDays = days
        }
    }

    private func runLoadingTask(clearSearchResults: Bool, _ operation: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil

        if clearSearchResults {
            searchResults = []
        }

        do {
            try await operation()
        } catch {
            forecastDays = []
            errorMessage = friendlyMessage(for: error)
        }

        isLoading = false
    }

    private func friendlyMessage(for error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let message = localizedError.errorDescription {
            return message
        }

        return "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해 주세요."
    }
}
