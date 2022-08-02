//
// Created by Ivan Petukhov on 31.07.2022.
//

import UIKit
import CoreData

protocol BreedPhotoDetailBusinessLogic: BaseBusinessLogic {
    func triggerFavouritesStatus()
    var isFavourite: Bool { get }
}

class BreedPhotoDetailInteractor: BreedPhotoDetailBusinessLogic, Contextable {

    let model: BreedPhotoModel

    init(model: BreedPhotoModel) {
        self.model = model
    }

    weak var viewController: BreedPhotoDetailDisplayLogic?

    func load() {
        Task {
            guard let url = URL(string: model.urlString) else { return }
            let image = try await ImageLoader.shared.fetch(.init(url: url))
            await MainActor.run {
                viewController?.displayPhoto(image)
            }
        }

    }

    func triggerFavouritesStatus() {
        if isFavourite {
            removeFromFavourites()
        } else {
            saveToFavourites()
        }
    }

    func saveToFavourites() {
        guard let context = dataContext else {
            assertionFailure()
            return
        }
        let photo = BreedPhoto(context: context)
        photo.urlString = model.urlString
        photo.breed = model.breed
        do {
            try context.save()
        } catch {
            print("Saving error")
        }
    }

    func removeFromFavourites() {
        guard let context = dataContext else {
            assertionFailure()
            return
        }
        guard let object = getFavouriteIfExist() else { return }
        context.delete(object)
        do {
            try context.save()
        } catch {
            print("Saving context error")
        }
    }

    var isFavourite: Bool {
        getFavouriteIfExist() != nil
    }

    func getFavouriteIfExist() -> NSManagedObject? {
        guard let context = dataContext else {
            assertionFailure()
            return nil
        }
        let request = BreedPhoto.fetchRequest()
        request.fetchLimit =  1
        request.predicate = NSPredicate(format: "urlString == %@" , model.urlString)
        do {
            let data = try context.fetch(request)
            return data.first
        } catch {
            return nil
        }
    }

}
