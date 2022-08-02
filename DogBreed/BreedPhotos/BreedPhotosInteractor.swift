//
// Created by Ivan Petukhov on 31.07.2022.
//

import UIKit

protocol BreedPhotosBusinessLogic: BaseBusinessLogic {
    var title: String { get }
}

class BreedPhotosInteractor: BreedPhotosBusinessLogic {
    weak var viewController: BreedPhotosDisplayLogic?
    let title: String

    init(breedString: String) {
        self.title = breedString
    }

    func load() {
        Task {
            do {
                let data = try await Service.shared.fetchData(from: .breedImages(for: title), type: BreedURLStrings.self)
                let models = data.message.map { BreedPhotoModel(urlString: $0, breed: title)}
                viewController?.displayPhotos(models)
            } catch {
                print(error)
            }
        }
    }
}
