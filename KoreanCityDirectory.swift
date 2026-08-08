import Foundation

struct KoreanCityDirectory {
    private static let cities: [CitySearchResult] = [
        city(id: 410001, name: "서울특별시", latitude: 37.5660, longitude: 126.9784, admin1: "서울특별시"),
        city(id: 410002, name: "부산광역시", latitude: 35.1017, longitude: 129.0300, admin1: "부산광역시"),
        city(id: 410003, name: "대구광역시", latitude: 35.8714, longitude: 128.6014, admin1: "대구광역시"),
        city(id: 410004, name: "인천광역시", latitude: 37.4563, longitude: 126.7052, admin1: "인천광역시"),
        city(id: 410005, name: "광주광역시", latitude: 35.1595, longitude: 126.8526, admin1: "광주광역시"),
        city(id: 410006, name: "대전광역시", latitude: 36.3504, longitude: 127.3845, admin1: "대전광역시"),
        city(id: 410007, name: "울산광역시", latitude: 35.5384, longitude: 129.3114, admin1: "울산광역시"),
        city(id: 410008, name: "세종특별자치시", latitude: 36.4800, longitude: 127.2890, admin1: "세종특별자치시"),
        city(id: 410101, name: "수원시", latitude: 37.2911, longitude: 127.0089, admin1: "경기도"),
        city(id: 410102, name: "성남시", latitude: 37.4200, longitude: 127.1265, admin1: "경기도"),
        city(id: 410103, name: "고양시", latitude: 37.6584, longitude: 126.8320, admin1: "경기도"),
        city(id: 410104, name: "용인시", latitude: 37.2411, longitude: 127.1776, admin1: "경기도"),
        city(id: 410105, name: "부천시", latitude: 37.5034, longitude: 126.7660, admin1: "경기도"),
        city(id: 410106, name: "안산시", latitude: 37.3219, longitude: 126.8309, admin1: "경기도"),
        city(id: 410107, name: "안양시", latitude: 37.3943, longitude: 126.9568, admin1: "경기도"),
        city(id: 410108, name: "남양주시", latitude: 37.6360, longitude: 127.2165, admin1: "경기도"),
        city(id: 410109, name: "화성시", latitude: 37.1995, longitude: 126.8312, admin1: "경기도"),
        city(id: 410110, name: "평택시", latitude: 36.9921, longitude: 127.1127, admin1: "경기도"),
        city(id: 410111, name: "의정부시", latitude: 37.7381, longitude: 127.0337, admin1: "경기도"),
        city(id: 410112, name: "시흥시", latitude: 37.3800, longitude: 126.8029, admin1: "경기도"),
        city(id: 410113, name: "파주시", latitude: 37.7599, longitude: 126.7802, admin1: "경기도"),
        city(id: 410114, name: "김포시", latitude: 37.6152, longitude: 126.7156, admin1: "경기도"),
        city(id: 410115, name: "광명시", latitude: 37.4786, longitude: 126.8646, admin1: "경기도"),
        city(id: 410116, name: "광주시", latitude: 37.4294, longitude: 127.2550, admin1: "경기도"),
        city(id: 410117, name: "군포시", latitude: 37.3617, longitude: 126.9352, admin1: "경기도"),
        city(id: 410118, name: "하남시", latitude: 37.5393, longitude: 127.2149, admin1: "경기도"),
        city(id: 410119, name: "오산시", latitude: 37.1498, longitude: 127.0772, admin1: "경기도"),
        city(id: 410120, name: "이천시", latitude: 37.2720, longitude: 127.4350, admin1: "경기도"),
        city(id: 410121, name: "안성시", latitude: 37.0080, longitude: 127.2797, admin1: "경기도"),
        city(id: 410122, name: "구리시", latitude: 37.5943, longitude: 127.1296, admin1: "경기도"),
        city(id: 410123, name: "의왕시", latitude: 37.3447, longitude: 126.9683, admin1: "경기도"),
        city(id: 410124, name: "포천시", latitude: 37.8949, longitude: 127.2003, admin1: "경기도"),
        city(id: 410125, name: "양주시", latitude: 37.7853, longitude: 127.0458, admin1: "경기도"),
        city(id: 410126, name: "동두천시", latitude: 37.9036, longitude: 127.0606, admin1: "경기도"),
        city(id: 410127, name: "과천시", latitude: 37.4292, longitude: 126.9877, admin1: "경기도"),
        city(id: 410201, name: "춘천시", latitude: 37.8813, longitude: 127.7298, admin1: "강원특별자치도"),
        city(id: 410202, name: "원주시", latitude: 37.3422, longitude: 127.9202, admin1: "강원특별자치도"),
        city(id: 410203, name: "강릉시", latitude: 37.7527, longitude: 128.8724, admin1: "강원특별자치도"),
        city(id: 410204, name: "동해시", latitude: 37.5248, longitude: 129.1143, admin1: "강원특별자치도"),
        city(id: 410205, name: "태백시", latitude: 37.1641, longitude: 128.9856, admin1: "강원특별자치도"),
        city(id: 410206, name: "속초시", latitude: 38.2070, longitude: 128.5918, admin1: "강원특별자치도"),
        city(id: 410207, name: "삼척시", latitude: 37.4499, longitude: 129.1652, admin1: "강원특별자치도"),
        city(id: 410301, name: "청주시", latitude: 36.6424, longitude: 127.4890, admin1: "충청북도"),
        city(id: 410302, name: "충주시", latitude: 36.9910, longitude: 127.9259, admin1: "충청북도"),
        city(id: 410303, name: "제천시", latitude: 37.1326, longitude: 128.1910, admin1: "충청북도"),
        city(id: 410401, name: "천안시", latitude: 36.8151, longitude: 127.1139, admin1: "충청남도"),
        city(id: 410402, name: "공주시", latitude: 36.4466, longitude: 127.1190, admin1: "충청남도"),
        city(id: 410403, name: "보령시", latitude: 36.3334, longitude: 126.6129, admin1: "충청남도"),
        city(id: 410404, name: "아산시", latitude: 36.7898, longitude: 127.0018, admin1: "충청남도"),
        city(id: 410405, name: "서산시", latitude: 36.7848, longitude: 126.4503, admin1: "충청남도"),
        city(id: 410406, name: "논산시", latitude: 36.1872, longitude: 127.0988, admin1: "충청남도"),
        city(id: 410407, name: "계룡시", latitude: 36.2746, longitude: 127.2486, admin1: "충청남도"),
        city(id: 410408, name: "당진시", latitude: 36.8897, longitude: 126.6459, admin1: "충청남도"),
        city(id: 410501, name: "전주시", latitude: 35.8242, longitude: 127.1480, admin1: "전북특별자치도"),
        city(id: 410502, name: "군산시", latitude: 35.9677, longitude: 126.7366, admin1: "전북특별자치도"),
        city(id: 410503, name: "익산시", latitude: 35.9483, longitude: 126.9576, admin1: "전북특별자치도"),
        city(id: 410504, name: "정읍시", latitude: 35.5699, longitude: 126.8561, admin1: "전북특별자치도"),
        city(id: 410505, name: "남원시", latitude: 35.4164, longitude: 127.3904, admin1: "전북특별자치도"),
        city(id: 410506, name: "김제시", latitude: 35.8036, longitude: 126.8808, admin1: "전북특별자치도"),
        city(id: 410601, name: "목포시", latitude: 34.8118, longitude: 126.3922, admin1: "전라남도"),
        city(id: 410602, name: "여수시", latitude: 34.7604, longitude: 127.6622, admin1: "전라남도"),
        city(id: 410603, name: "순천시", latitude: 34.9506, longitude: 127.4872, admin1: "전라남도"),
        city(id: 410604, name: "나주시", latitude: 35.0158, longitude: 126.7108, admin1: "전라남도"),
        city(id: 410605, name: "광양시", latitude: 34.9407, longitude: 127.6959, admin1: "전라남도"),
        city(id: 410701, name: "포항시", latitude: 36.0190, longitude: 129.3435, admin1: "경상북도"),
        city(id: 410702, name: "경주시", latitude: 35.8562, longitude: 129.2247, admin1: "경상북도"),
        city(id: 410703, name: "김천시", latitude: 36.1398, longitude: 128.1136, admin1: "경상북도"),
        city(id: 410704, name: "안동시", latitude: 36.5684, longitude: 128.7294, admin1: "경상북도"),
        city(id: 410705, name: "구미시", latitude: 36.1195, longitude: 128.3446, admin1: "경상북도"),
        city(id: 410706, name: "영주시", latitude: 36.8057, longitude: 128.6241, admin1: "경상북도"),
        city(id: 410707, name: "영천시", latitude: 35.9733, longitude: 128.9386, admin1: "경상북도"),
        city(id: 410708, name: "상주시", latitude: 36.4109, longitude: 128.1591, admin1: "경상북도"),
        city(id: 410709, name: "문경시", latitude: 36.5865, longitude: 128.1868, admin1: "경상북도"),
        city(id: 410710, name: "경산시", latitude: 35.8251, longitude: 128.7415, admin1: "경상북도"),
        city(id: 410801, name: "창원시", latitude: 35.2279, longitude: 128.6819, admin1: "경상남도"),
        city(id: 410802, name: "진주시", latitude: 35.1800, longitude: 128.1076, admin1: "경상남도"),
        city(id: 410803, name: "통영시", latitude: 34.8544, longitude: 128.4332, admin1: "경상남도"),
        city(id: 410804, name: "사천시", latitude: 35.0038, longitude: 128.0642, admin1: "경상남도"),
        city(id: 410805, name: "김해시", latitude: 35.2285, longitude: 128.8894, admin1: "경상남도"),
        city(id: 410806, name: "밀양시", latitude: 35.5038, longitude: 128.7465, admin1: "경상남도"),
        city(id: 410807, name: "거제시", latitude: 34.8806, longitude: 128.6211, admin1: "경상남도"),
        city(id: 410808, name: "양산시", latitude: 35.3350, longitude: 129.0372, admin1: "경상남도"),
        city(id: 410901, name: "제주시", latitude: 33.4996, longitude: 126.5312, admin1: "제주특별자치도"),
        city(id: 410902, name: "서귀포시", latitude: 33.2541, longitude: 126.5601, admin1: "제주특별자치도")
    ]

    static func search(_ query: String) -> [CitySearchResult] {
        let normalizedQuery = normalize(query)

        guard !normalizedQuery.isEmpty else {
            return []
        }

        let matches = cities.filter { city in
            let names = searchNames(for: city)
            return names.contains { $0.hasPrefix(normalizedQuery) || $0.contains(normalizedQuery) }
        }

        return Array(matches.prefix(10))
    }

    private static func searchNames(for city: CitySearchResult) -> [String] {
        let baseName = normalize(city.name)
        let nameWithoutSuffix = baseName.removingCitySuffix()
        let adminName = normalize(city.admin1 ?? "")

        return [baseName, nameWithoutSuffix, "\(adminName)\(baseName)", "\(adminName)\(nameWithoutSuffix)"]
    }

    private static func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .lowercased()
    }

    private static func city(id: Int, name: String, latitude: Double, longitude: Double, admin1: String) -> CitySearchResult {
        CitySearchResult(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            country: "대한민국",
            admin1: admin1
        )
    }
}

private extension String {
    func removingCitySuffix() -> String {
        if hasSuffix("특별자치시") {
            return String(dropLast(5))
        }

        if hasSuffix("특별시") || hasSuffix("광역시") {
            return String(dropLast(3))
        }

        if hasSuffix("시") {
            return String(dropLast(1))
        }

        return self
    }
}
