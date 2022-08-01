//
// Created by Ivan Petukhov on 30.07.2022.
//

import Foundation

extension URL {
    static let allBreedsList = URL(string: "https://dog.ceo/api/breeds/list/")!
    static func breedImages(for breed: String) -> Self {
        URL(string: "https://dog.ceo/api/breed/\(breed)/images")!
    }
}
