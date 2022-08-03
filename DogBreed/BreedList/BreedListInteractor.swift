//
// Created by Ivan Petukhov on 30.07.2022.
//

import Foundation

protocol BreedListBusinessLogic: BaseBusinessLogic {

}

class BreedListInteractor: BreedListBusinessLogic {

    weak var viewController: BreedListDisplayLogic?

    func load() {
        Task {
            do {
                let data = try await Service.shared.fetchData(from: .allBreedsList, type: BreedList.self)
                viewController?.display(data.breedList)
            } catch {
                viewController?.displayError(error)
            }
        }
    }

}