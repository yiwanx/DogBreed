//
// Created by Ivan Petukhov on 31.07.2022.
//

import Foundation

class BreedPhotoDetailInteractor: BaseBusinessLogic {

    let url: URL

    init(url: URL) {
        self.url = url
    }

    weak var viewController: BreedPhotoDetailDisplayLogic?

    func load() {
        Task {
            let image = try await ImageLoader.shared.fetch(url)
            await MainActor.run {
                viewController?.displayPhoto(image)
            }
        }

    }
}
