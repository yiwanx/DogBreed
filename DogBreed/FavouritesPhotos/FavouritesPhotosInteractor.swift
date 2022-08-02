//
// Created by Ivan Petukhov on 01.08.2022.
//

import Foundation

protocol FavouritesPhotosBusinessLogic: BreedPhotosBusinessLogic {
    var favouriteBreeds: [String] { get }
    func displayWithFilterIfNeeded(with breed: String)
}

class FavouritesPhotosInteractor: FavouritesPhotosBusinessLogic, Contextable {

    var viewController: FavouritesPhotosDisplayLogic?
    private(set) var title: String = "Favourites"

    static let allString = "all"

    var chosenBreed = FavouritesPhotosInteractor.allString

    var models: [BreedPhotoModel] = []
    var filteredModels: [BreedPhotoModel] = []

    var favouriteBreeds: [String] {
        [Self.allString] + Array(Set(models.map { $0.breed }))
    }

    func load() {
        guard let context = dataContext else {
            assertionFailure()
            return
        }
        let request = BreedPhoto.fetchRequest()

        do {
            let data = try context.fetch(request)
            let models = data.compactMap { object -> BreedPhotoModel? in
                guard let urlString = object.urlString, let breed = object.breed else { return nil }
                return BreedPhotoModel(urlString: urlString, breed: breed)
            }
            self.models = models
            displayWithFilterIfNeeded(with: chosenBreed)
            viewController?.favouriteBreeds = favouriteBreeds
        } catch {
            print(error)
        }
    }

    func displayWithFilterIfNeeded(with breed: String) {
        chosenBreed = breed
        if breed == Self.allString {
            viewController?.displayPhotos(models)
            viewController?.favouriteBreeds = favouriteBreeds
        } else {
            filteredModels = models.filter {
                $0.breed == breed
            }
            viewController?.displayPhotos(filteredModels)
            viewController?.favouriteBreeds = favouriteBreeds
        }
    }
}