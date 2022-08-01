//
// Created by Ivan Petukhov on 31.07.2022.
//

import UIKit

protocol BreedPhotosBusinessLogic: BaseBusinessLogic {
    var breedString: String { get }
}

class BreedPhotosInteractor: BreedPhotosBusinessLogic {
    weak var viewController: BreedPhotosDisplayLogic?
    let breedString: String

    init(breedString: String) {
        self.breedString = breedString
    }

    func load() {
        Task {
            do {
                let data = try await Service.shared.fetchData(from: .breedImages(for: breedString), type: BreedURLStrings.self)
                let models = data.message.compactMap { URL(string: $0) }.map { BreedPhotoModel(imageUrl: $0, breed: breedString)}
                viewController?.displayPhotos(models)
            } catch {
                print(error)
            }
        }
    }
}
