//
// Created by Ivan Petukhov on 31.07.2022.
//

import UIKit

protocol BreedPhotoDetailDisplayLogic: class {
    func displayPhoto(_ image: UIImage)
}

protocol BreedPhotoDetailDelegate: AnyObject {
    func reloadCollection()
}

class BreedPhotoDetailViewController: UIViewController, BreedPhotoDetailDisplayLogic {

    var interactor: BreedPhotoDetailBusinessLogic?

    var mainImageView: UIImageView!
    var heartImageView: UIImageView!

    weak var delegate: BreedPhotoDetailDelegate?

    var heartImage: UIImage? {
        interactor?.isFavourite ?? false ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
    }

    lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 2
        recognizer.addTarget(self, action: #selector(onTap))
        return recognizer
    }()

    lazy var heartImageGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 1
        recognizer.addTarget(self, action: #selector(onTap))
        return recognizer
    }()

    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
        mainImageView = UIImageView()
        mainImageView.addGestureRecognizer(doubleTapGestureRecognizer)
        mainImageView.isUserInteractionEnabled = true
        heartImageView = UIImageView()
        heartImageView.addGestureRecognizer(heartImageGestureRecognizer)
        heartImageView.isUserInteractionEnabled = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        interactor?.load()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// Reloading the collection when go back from this screen.
        delegate?.reloadCollection()
    }

    func displayPhoto(_ image: UIImage) {
        mainImageView.image = image
        let width = view.frame.width
        let height = (image.size.height / image.size.width) * view.frame.width
        mainImageView.configure(with: .init(x: 0, y: 0, width: width, height: height))
        view.addSubview(mainImageView)
        addLikeStack()
    }

    func addLikeStack() {
        let stack = UIStackView()
        stack.distribution = .fillProportionally
        heartImageView.image = heartImage
        heartImageView.configure(with: .init(origin: .zero, size: .init(width: 50, height: 50)))
        let label = configuredLabel(frame: .init(origin: .zero, size: .init(width: 300, height: 50)), text: "Add to favourites")
        stack.addArrangedSubview(heartImageView)
        stack.addArrangedSubview(label)
        stack.frame = .init(x: 10, y: mainImageView.frame.height + 10, width: view.frame.width, height: 50)
        view.addSubview(stack)
    }

    func updateLikeIndicator() {
        heartImageView.image = heartImage
    }

    @objc func onTap() {
        interactor?.triggerFavouritesStatus()
        updateLikeIndicator()
    }
}

extension UIImageView {
    func configure(with frame: CGRect) {
        self.frame = frame
        contentMode = .scaleAspectFit
    }
}

extension UIViewController {
    func configuredLabel(frame: CGRect, text: String) -> UILabel {
        let label = UILabel(frame: frame)
        label.text = text
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }
}