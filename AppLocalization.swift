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

    static var aboutAirQuality: String {
        NSLocalizedString("aboutAirQuality", bundle: .main, value: "About AirQuality5", comment: "")
    }

    static var appTitle: String {
        NSLocalizedString("appTitle", bundle: .main, value: "5-Day Air Quality Forecast", comment: "")
    }

    static var searchPlaceholder: String {
        NSLocalizedString("searchPlaceholder", bundle: .main, value: "City name", comment: "")
    }

    static var search: String {
        NSLocalizedString("search", bundle: .main, value: "Search", comment: "")
    }

    static var currentLocation: String {
        NSLocalizedString("currentLocation", bundle: .main, value: "Current Location", comment: "")
    }

    static var loading: String {
        NSLocalizedString("loading", bundle: .main, value: "Loading air quality data...", comment: "")
    }

    static var chooseCity: String {
        NSLocalizedString("chooseCity", bundle: .main, value: "Search for a city", comment: "")
    }

    static var chooseSearchResult: String {
        NSLocalizedString("chooseSearchResult", bundle: .main, value: "Choose a search result", comment: "")
    }

    static var enterCityName: String {
        NSLocalizedString("enterCityName", bundle: .main, value: "Please enter a city name.", comment: "")
    }

    static var noSearchResults: String {
        NSLocalizedString("noSearchResults", bundle: .main, value: "No search results.", comment: "")
    }

    static var startupEmptyState: String {
        NSLocalizedString("startupEmptyState", bundle: .main, value: "Search for a city or use your current location.", comment: "")
    }

    static var regionUnavailable: String {
        NSLocalizedString("regionUnavailable", bundle: .main, value: "Region unavailable", comment: "")
    }

    static var fiveDayForecastSection: String {
        NSLocalizedString("fiveDayForecastSection", bundle: .main, value: "5-Day Forecast", comment: "")
    }

    static var todayUSAQI: String {
        NSLocalizedString("todayUSAQI", bundle: .main, value: "Today US AQI", comment: "")
    }

    static var usAQI: String {
        NSLocalizedString("usAQI", bundle: .main, value: "US AQI", comment: "")
    }

    static var dataSource: String {
        NSLocalizedString("dataSource", bundle: .main, value: "Data source: Open-Meteo Air Quality API · Air quality categories: EPA AQI", comment: "")
    }

    static var fiveDayParticleTrend: String {
        NSLocalizedString("fiveDayParticleTrend", bundle: .main, value: "5-Day Particulate Trend", comment: "")
    }

    static var fiveDayPM25Forecast: String {
        NSLocalizedString("fiveDayPM25Forecast", bundle: .main, value: "5-Day PM2.5 Forecast", comment: "")
    }

    static var fiveDayPM10Forecast: String {
        NSLocalizedString("fiveDayPM10Forecast", bundle: .main, value: "5-Day PM10 Forecast", comment: "")
    }

    static var hourlyPM25: String {
        NSLocalizedString("hourlyPM25", bundle: .main, value: "Hourly PM2.5", comment: "")
    }

    static var hourlyPM10: String {
        NSLocalizedString("hourlyPM10", bundle: .main, value: "Hourly PM10", comment: "")
    }

    static var chartDate: String {
        NSLocalizedString("chartDate", bundle: .main, value: "Date", comment: "")
    }

    static var chartValue: String {
        NSLocalizedString("chartValue", bundle: .main, value: "Value", comment: "")
    }

    static var chartSeries: String {
        NSLocalizedString("chartSeries", bundle: .main, value: "Series", comment: "")
    }

    static var close: String {
        NSLocalizedString("close", bundle: .main, value: "Close", comment: "")
    }

    static var hourlyDataUnavailable: String {
        NSLocalizedString("hourlyDataUnavailable", bundle: .main, value: "No hourly data is available for this date.", comment: "")
    }

    static var selectedHour: String {
        NSLocalizedString("selectedHour", bundle: .main, value: "Selected Hour", comment: "")
    }

    static var hourlyUSAQI: String {
        NSLocalizedString("hourlyUSAQI", bundle: .main, value: "Hourly US AQI", comment: "")
    }

    static var hourlyParticles: String {
        NSLocalizedString("hourlyParticles", bundle: .main, value: "Hourly Particulate Matter", comment: "")
    }

    static var chartTime: String {
        NSLocalizedString("chartTime", bundle: .main, value: "Time", comment: "")
    }

    static var selectedTime: String {
        NSLocalizedString("selectedTime", bundle: .main, value: "Selected Time", comment: "")
    }

    static var particleConcentration: String {
        NSLocalizedString("particleConcentration", bundle: .main, value: "Concentration μg/m³", comment: "")
    }

    static var requestURLFailed: String {
        NSLocalizedString("requestURLFailed", bundle: .main, value: "The request URL could not be created. Please try again later.", comment: "")
    }

    static var networkFailed: String {
        NSLocalizedString("networkFailed", bundle: .main, value: "Could not load air quality data. Please check your internet connection.", comment: "")
    }

    static var locationDenied: String {
        NSLocalizedString("locationDenied", bundle: .main, value: "Location permission is not available. Please search by city name.", comment: "")
    }

    static var locationUnavailable: String {
        NSLocalizedString("locationUnavailable", bundle: .main, value: "Could not get your current location. Please try again later or search by city name.", comment: "")
    }

    static var unknownError: String {
        NSLocalizedString("unknownError", bundle: .main, value: "An unknown error occurred. Please try again later.", comment: "")
    }

    static func aqiStatus(value: Int?) -> String {
        guard let value else {
            return NSLocalizedString("aqiNoData", bundle: .main, value: "No Data", comment: "")
        }

        switch value {
        case 0...50:
            return NSLocalizedString("aqiGood", bundle: .main, value: "Good", comment: "")
        case 51...100:
            return NSLocalizedString("aqiModerate", bundle: .main, value: "Moderate", comment: "")
        case 101...150:
            return NSLocalizedString("aqiUnhealthySensitive", bundle: .main, value: "Unhealthy for Sensitive Groups", comment: "")
        case 151...200:
            return NSLocalizedString("aqiUnhealthy", bundle: .main, value: "Unhealthy", comment: "")
        case 201...300:
            return NSLocalizedString("aqiVeryUnhealthy", bundle: .main, value: "Very Unhealthy", comment: "")
        default:
            return NSLocalizedString("aqiHazardous", bundle: .main, value: "Hazardous", comment: "")
        }
    }
}
