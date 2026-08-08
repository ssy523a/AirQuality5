import CoreLocation
import Foundation
import MapKit

final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    // Mac의 현재 위치를 한 번만 요청합니다. 권한이 아직 없으면 macOS 권한 창을 띄웁니다.
    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
        try await requestCurrentLocation(shouldRequestPermission: true)
    }

    // 앱 시작 시에는 권한 창을 띄우지 않고, 이미 허용된 경우에만 현재 위치를 사용합니다.
    func requestCurrentLocationIfAuthorized() async throws -> CLLocationCoordinate2D {
        try await requestCurrentLocation(shouldRequestPermission: false)
    }

    private func requestCurrentLocation(shouldRequestPermission: Bool) async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { continuation in
            if self.continuation != nil {
                finish(with: .failure(AirQualityError.locationUnavailable))
            }

            self.continuation = continuation

            // 위치 콜백이 오지 않는 경우에도 로딩이 무한히 이어지지 않도록 안전장치를 둡니다.
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
                self?.finish(with: .failure(AirQualityError.locationUnavailable))
            }

            switch manager.authorizationStatus {
            case .notDetermined:
                if shouldRequestPermission {
                    manager.requestWhenInUseAuthorization()
                } else {
                    finish(with: .failure(AirQualityError.locationUnavailable))
                }
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
            case .denied, .restricted:
                finish(with: .failure(AirQualityError.locationDenied))
            @unknown default:
                finish(with: .failure(AirQualityError.locationUnavailable))
            }
        }
    }

    // 좌표를 사람이 읽을 수 있는 지명으로 바꿉니다. 실패해도 앱 흐름은 계속되어야 하므로 nil을 돌려줍니다.
    func placeName(for coordinate: CLLocationCoordinate2D) async -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        guard let request = MKReverseGeocodingRequest(location: location) else {
            return nil
        }

        request.preferredLocale = Locale.current

        guard let mapItem = try? await request.mapItems.first else {
            return nil
        }

        if let cityName = mapItem.addressRepresentations?.cityWithContext(.automatic) {
            return cityName
        }

        return mapItem.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            finish(with: .failure(AirQualityError.locationDenied))
        case .notDetermined:
            break
        @unknown default:
            finish(with: .failure(AirQualityError.locationUnavailable))
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            finish(with: .failure(AirQualityError.locationUnavailable))
            return
        }

        finish(with: .success(location.coordinate))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(with: .failure(AirQualityError.locationUnavailable))
    }

    private func finish(with result: Result<CLLocationCoordinate2D, Error>) {
        guard let continuation else {
            return
        }

        self.continuation = nil

        switch result {
        case .success(let coordinate):
            continuation.resume(returning: coordinate)
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}
