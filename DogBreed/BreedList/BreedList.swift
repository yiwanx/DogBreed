//
// Created by Ivan Petukhov on 30.07.2022.
//

import Foundation

struct BreedList: Decodable {
    let breedList: [String]
    let status: String

    enum CodingKeys: String, CodingKey, Hashable {
        case breedList = "message"
        case status = "status"
    }

}