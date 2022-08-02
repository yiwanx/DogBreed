//
// Created by Ivan Petukhov on 31.07.2022.
//

import Foundation

struct BreedPhotoModel: Equatable {
    let urlString: String
    let breed: String

    static func ==(lhs: BreedPhotoModel, rhs: BreedPhotoModel) -> Bool {
        if lhs.urlString != rhs.urlString {
            return false
        }
        if lhs.breed != rhs.breed {
            return false
        }
        return true
    }

}
