import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
final class AirQualityViewModel {
    var searchText = "Seoul"
    var title = AppText.chooseCity
    var forecastDays: [AirQualityDay] = []
    var searchResults: [CitySearchResult] = []
    var isLoading = false
    var errorMessage: String?

    private let service = AirQualityService()
    private let locationManager = LocationManager()

    // 앱 시작 시 현재 위치를 먼저 시도하고, 실패하면 기본 도시 Seoul을 보여줍니다.
    func loadInitialForecast() {
        Task {
            await loadForecastForStartup()
        }
    }

    // 사용자가 입력한 도시 이름으로 검색합니다.
    func searchCity() {
        let cityName = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cityName.isEmpty else {
            errorMessage = AppText.enterCityName
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

    private func loadForecastForStartup() async {
        isLoading = true
        errorMessage = nil
        searchResults = []

        do {
            let coordinate = try await locationManager.requestCurrentLocationIfAuthorized()
            try await loadForecastDataForCurrentLocation(coordinate: coordinate)
        } catch {
            do {
                // 시작 직후 위치를 못 받으면 잠깐 기다린 뒤 권한 요청을 포함해 한 번 더 시도합니다.
                try? await Task.sleep(for: .seconds(3))
                let coordinate = try await locationManager.requestCurrentLocation()
                try await loadForecastDataForCurrentLocation(coordinate: coordinate)
            } catch {
                await loadSeoulFallback()
            }
        }

        isLoading = false
    }

    private func loadForecastDataForCurrentLocation(coordinate: CLLocationCoordinate2D) async throws {
        let days = try await service.fetchFiveDayForecast(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        let placeName = await locationManager.placeName(for: coordinate)
        let locationName = placeName ?? AppText.currentLocation

        title = locationName
        searchText = locationName
        forecastDays = days
    }

    private func loadSeoulFallback() async {
        searchText = "Seoul"

        do {
            let cities = try await service.searchCities(named: "Seoul")
            if let city = cities.first {
                try await loadForecastData(for: city)
            } else {
                throw AirQualityError.noSearchResults
            }
        } catch {
            forecastDays = []
            errorMessage = friendlyMessage(for: error)
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
                title = AppText.chooseSearchResult
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
            try await loadForecastDataForCurrentLocation(coordinate: coordinate)
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

        return AppText.unknownError
    }
}
