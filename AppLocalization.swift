import Foundation

struct AppText {
    static var appLanguageCode: String {
        Bundle.main.preferredLocalizations.first ?? Locale.preferredLanguages.first ?? "en"
    }

    static var isKorean: Bool {
        appLanguageCode.hasPrefix("ko")
    }

    static var geocodingLanguageCode: String {
        isKorean ? "ko" : "en"
    }

    private static func text(_ key: String, fallback: String) -> String {
        NSLocalizedString(key, bundle: .main, value: fallback, comment: "")
    }

    static var aboutAirQuality: String { text("aboutAirQuality", fallback: "About AirQuality5") }
    static var appTitle: String { text("appTitle", fallback: "5-Day Air Quality Forecast") }
    static var searchPlaceholder: String { text("searchPlaceholder", fallback: "City name") }
    static var search: String { text("search", fallback: "Search") }
    static var currentLocation: String { text("currentLocation", fallback: "Current Location") }
    static var loading: String { text("loading", fallback: "Loading air quality data...") }
    static var chooseCity: String { text("chooseCity", fallback: "Search for a city") }
    static var chooseSearchResult: String { text("chooseSearchResult", fallback: "Choose a search result") }
    static var enterCityName: String { text("enterCityName", fallback: "Please enter a city name.") }
    static var noSearchResults: String { text("noSearchResults", fallback: "No search results.") }
    static var startupEmptyState: String { text("startupEmptyState", fallback: "Search for a city or use your current location.") }
    static var regionUnavailable: String { text("regionUnavailable", fallback: "Region unavailable") }
    static var fiveDayForecastSection: String { text("fiveDayForecastSection", fallback: "5-Day Forecast") }
    static var todayUSAQI: String { text("todayUSAQI", fallback: "Today US AQI") }
    static var usAQI: String { text("usAQI", fallback: "US AQI") }
    static var fiveDayParticleTrend: String { text("fiveDayParticleTrend", fallback: "5-Day Particulate Trend") }
    static var chartDate: String { text("chartDate", fallback: "Date") }
    static var chartValue: String { text("chartValue", fallback: "Value") }
    static var chartSeries: String { text("chartSeries", fallback: "Series") }
    static var close: String { text("close", fallback: "Close") }
    static var hourlyDataUnavailable: String { text("hourlyDataUnavailable", fallback: "No hourly data is available for this date.") }
    static var selectedHour: String { text("selectedHour", fallback: "Selected Hour") }
    static var hourlyUSAQI: String { text("hourlyUSAQI", fallback: "Hourly US AQI") }
    static var hourlyParticles: String { text("hourlyParticles", fallback: "Hourly Particulate Matter") }
    static var chartTime: String { text("chartTime", fallback: "Time") }
    static var selectedTime: String { text("selectedTime", fallback: "Selected Time") }
    static var particleConcentration: String { text("particleConcentration", fallback: "Concentration μg/m³") }
    static var requestURLFailed: String { text("requestURLFailed", fallback: "The request URL could not be created. Please try again later.") }
    static var networkFailed: String { text("networkFailed", fallback: "Could not load air quality data. Please check your internet connection.") }
    static var locationDenied: String { text("locationDenied", fallback: "Location permission is not available. Please search by city name.") }
    static var locationUnavailable: String { text("locationUnavailable", fallback: "Could not get your current location. Please try again later or search by city name.") }
    static var unknownError: String { text("unknownError", fallback: "An unknown error occurred. Please try again later.") }

    static func aqiStatus(value: Int?) -> String {
        guard let value else {
            return text("aqiNoData", fallback: "No Data")
        }

        switch value {
        case 0...50:
            return text("aqiGood", fallback: "Good")
        case 51...100:
            return text("aqiModerate", fallback: "Moderate")
        case 101...150:
            return text("aqiUnhealthySensitive", fallback: "Unhealthy for Sensitive Groups")
        case 151...200:
            return text("aqiUnhealthy", fallback: "Unhealthy")
        case 201...300:
            return text("aqiVeryUnhealthy", fallback: "Very Unhealthy")
        default:
            return text("aqiHazardous", fallback: "Hazardous")
        }
    }
}
