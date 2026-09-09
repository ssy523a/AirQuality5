# AirQuality5 코드 설명서

이 문서는 AirQuality5 앱의 소스 코드를 처음 보는 사람이 전체 구조를 이해하기 쉽도록 정리한 설명서입니다. 앱의 동작을 바꾸는 파일이 아니라, 코드 이해를 돕기 위한 문서입니다.

## 앱이 하는 일

AirQuality5는 macOS용 대기질 예보 앱입니다.

주요 기능은 다음과 같습니다.

- 현재 Mac의 위치를 가져와 대기질 예보 표시
- 도시 이름 검색으로 원하는 지역 선택
- 오늘을 포함한 5일간의 대기질 예보 표시
- 날짜별 카드 표시
- PM2.5, PM10, US AQI 표시
- 5일 변화 그래프 표시
- 날짜 카드를 클릭하면 시간별 상세 그래프 표시
- 한국어와 영어 자동 대응

## 전체 데이터 흐름

앱의 기본 흐름은 다음 순서로 볼 수 있습니다.

1. 앱이 실행됩니다.
2. `ContentView`가 화면을 보여줍니다.
3. `AirQualityViewModel`이 현재 위치 또는 기본 도시 데이터를 불러옵니다.
4. 현재 위치가 필요하면 `LocationManager`가 Core Location을 사용합니다.
5. 도시 검색이 필요하면 `AirQualityService`가 Open-Meteo Geocoding API를 호출합니다.
6. 대기질 데이터가 필요하면 `AirQualityService`가 Open-Meteo Air Quality API를 호출합니다.
7. 시간별 데이터를 날짜별로 묶어 5일 예보 데이터로 만듭니다.
8. `ContentView`가 날짜별 카드와 5일 그래프를 표시합니다.
9. 날짜 카드를 클릭하면 `HourlyDetailView`가 시간별 상세 그래프를 표시합니다.

## 파일별 역할

### AirQuality5App.swift

앱의 시작점입니다.

SwiftUI 앱은 보통 `@main`이 붙은 파일에서 시작합니다. 이 파일에서는 첫 화면으로 `ContentView`를 띄우고, 창의 기본 크기와 About 창 정보를 설정합니다.

### ContentView.swift

메인 화면을 담당합니다.

이 파일에서 보여주는 주요 UI는 다음과 같습니다.

- 앱 제목
- 현재 선택된 도시 이름
- 자료 출처 문구
- 도시 검색창
- 현재 위치 버튼
- 5일 예보 카드
- PM2.5 5일 그래프
- PM10 5일 그래프

사용자가 날짜 카드를 클릭하면 `HourlyDetailView`를 sheet 형태로 엽니다.

### HourlyDetailView.swift

날짜별 상세 화면을 담당합니다.

메인 화면의 날짜 카드를 클릭하면 이 화면이 열립니다. 새 API 요청을 하지 않고, 이미 받아온 시간별 데이터를 재사용합니다.

상세 화면에는 다음 그래프가 있습니다.

- 시간별 US AQI
- 시간별 PM2.5
- 시간별 PM10

그래프 위를 마우스로 선택하면 선택한 시간의 AQI, PM2.5, PM10 값을 확인할 수 있습니다.

### AirQualityViewModel.swift

화면과 데이터 사이를 연결하는 파일입니다.

SwiftUI 화면은 직접 네트워크 요청이나 위치 요청을 처리하기보다, ViewModel에 일을 맡깁니다. 이 파일은 앱의 현재 상태를 관리합니다.

예를 들면 다음 상태를 가지고 있습니다.

- 검색어
- 현재 선택된 도시 이름
- 5일 예보 데이터
- 검색 결과 목록
- 로딩 중인지 여부
- 오류 메시지

### AirQualityService.swift

Open-Meteo API와 통신하는 파일입니다.

이 파일의 역할은 크게 두 가지입니다.

1. 도시 검색
   Open-Meteo Geocoding API의 `/v1/search`를 사용합니다.

2. 대기질 예보 가져오기
   Open-Meteo Air Quality API의 `/v1/air-quality`를 사용합니다.

대기질 API에서는 시간별 데이터를 가져옵니다.

- `pm2_5`
- `pm10`
- `us_aqi`

가져온 시간별 데이터는 날짜별로 묶어서 다음 대표값으로 변환합니다.

- PM2.5: 하루 평균
- PM10: 하루 평균
- US AQI: 하루 중 가장 높은 값

API에서 `null` 값이 와도 앱이 종료되지 않도록 Optional 값을 안전하게 처리합니다.

### LocationManager.swift

현재 위치 기능을 담당합니다.

Core Location을 사용해서 Mac의 현재 위도와 경도를 가져옵니다. 위치 권한이 없거나 위치를 가져오지 못하는 경우 앱이 종료되지 않고 오류 메시지를 보여주도록 설계되어 있습니다.

현재 위치의 이름을 표시하기 위해 가능한 경우 역지오코딩도 수행합니다.

### KoreanCityDirectory.swift

한국어 도시 검색을 보완하는 파일입니다.

Open-Meteo Geocoding API가 일부 한국어 도시명을 잘 찾지 못할 수 있습니다. 그래서 `수원시`, `하남시`, `삼척시` 같은 한국어 도시명을 앱 내부 목록에서 먼저 찾도록 도와줍니다.

영문 검색은 기존 Open-Meteo 검색을 그대로 사용합니다.

### AirQualityChartBands.swift

그래프의 대기질 구간 기준을 관리하는 파일입니다.

PM2.5, PM10, US AQI 그래프의 배경 색상 구간이 이 파일에 정리되어 있습니다.

PM2.5와 PM10은 서로 다른 농도 기준을 사용합니다. 현재 앱은 미국 EPA AQI 기준의 breakpoint를 사용합니다.

색상 의미는 다음과 같습니다.

- 좋음: 초록
- 보통: 노랑
- 민감군 나쁨: 주황
- 나쁨: 빨강
- 매우 나쁨: 보라
- 위험: 자주색 계열

### AppLocalization.swift

앱에서 사용하는 문구를 관리하는 파일입니다.

화면에 표시되는 문구를 직접 여러 곳에 흩어놓지 않고, `AppText`라는 구조체에 모아두었습니다. 앱의 언어가 한국어이면 한국어 문구를, 영어이면 영어 문구를 사용합니다.

### Localizable.xcstrings

한국어와 영어 번역 문구가 들어 있는 String Catalog 파일입니다.

`AppLocalization.swift`에서 사용하는 key의 실제 번역값이 이 파일에 들어 있습니다.

### Info.plist

앱 설정 정보가 들어 있는 파일입니다.

위치 권한 설명 문구, 앱이 지원하는 언어 같은 설정이 포함됩니다.

### en.lproj / ko.lproj

Info.plist 안의 권한 설명 문구를 영어와 한국어로 표시하기 위한 localization 파일입니다.

## API 설명

### Open-Meteo Air Quality API

대기질 예보 데이터를 가져오는 API입니다.

현재 앱은 다음 값을 요청합니다.

- PM2.5
- PM10
- US AQI

요청 옵션은 다음과 같습니다.

- `forecast_days=5`
- `timezone=auto`

`timezone=auto`를 사용하면 선택한 지역의 시간대에 맞춰 시간별 데이터가 내려옵니다.

### Open-Meteo Geocoding API

도시 이름을 위도와 경도로 바꾸기 위해 사용하는 API입니다.

예를 들어 사용자가 `Tokyo`나 `Seoul`을 검색하면, 해당 도시의 위도와 경도를 받아옵니다. 이후 이 좌표를 사용해 대기질 예보를 가져옵니다.

## SwiftUI에서 중요한 개념

### View

화면에 보이는 UI 조각입니다.

`ContentView`, `HourlyDetailView`, 예보 카드, 그래프 영역 등이 모두 View입니다.

### State

화면이 기억해야 하는 값입니다.

예를 들어 선택한 날짜, 검색어, 로딩 상태 같은 값이 바뀌면 SwiftUI가 화면을 다시 그립니다.

### sheet

macOS에서 팝업처럼 새 화면을 띄우는 SwiftUI 기능입니다.

이 앱에서는 날짜 카드를 클릭했을 때 상세 화면을 띄우는 데 사용합니다.

### Optional

값이 있을 수도 있고 없을 수도 있다는 뜻입니다.

API에서 `null` 값이 올 수 있기 때문에 PM2.5, PM10, US AQI 값은 Optional로 안전하게 처리합니다.

## 그래프 기준

앱의 그래프는 Apple Swift Charts를 사용합니다.

PM2.5와 PM10 그래프에는 대기질 등급별 배경 색상이 표시됩니다. 이 배경 구간은 `AirQualityChartBands.swift`에서 관리합니다.

Y축 범위는 실제 데이터만 딱 맞춰 자르지 않고, 현재 값이 속한 대기질 구간이 자연스럽게 보이도록 약간 넓게 잡습니다.

## 오류 처리

네트워크 오류, 위치 권한 거부, 검색 결과 없음 같은 상황이 발생해도 앱이 종료되지 않도록 구성되어 있습니다.

오류가 발생하면 사용자가 이해할 수 있는 문장을 화면에 표시합니다.

## 코드를 볼 때 추천 순서

처음 코드를 읽는다면 다음 순서로 보는 것이 좋습니다.

1. `AirQuality5App.swift`
2. `ContentView.swift`
3. `AirQualityViewModel.swift`
4. `AirQualityService.swift`
5. `LocationManager.swift`
6. `HourlyDetailView.swift`
7. `AirQualityChartBands.swift`
8. `AppLocalization.swift`

이 순서로 보면 앱이 시작해서 데이터를 가져오고 화면에 표시되는 흐름을 따라가기 쉽습니다.
