//
// Created by Ivan Petukhov on 31.07.2022.
//

import UIKit

protocol BreedPhotoDetailDisplayLogic: class {
    func displayPhoto(_ image: UIImage)
}

class BreedPhotoDetailViewController: UIViewController, BreedPhotoDetailDisplayLogic {

    var interactor: BaseBusinessLogic?

    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 2
        recognizer.addTarget(self, action: #selector(onTap))
        return recognizer
    }()

    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        view.addGestureRecognizer(doubleTapGesture)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        interactor?.load()
    }

    func displayPhoto(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        let width = view.frame.width
        let height = (image.size.height / image.size.width) * view.frame.width
        imageView.frame = .init(x: 0, y: 0, width: width, height: height)
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
    }

    @objc func onTap() {
//        interactor?.addToFavourites
    }
}