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
        setLikeIndicator()
        let label = configuredLabel(frame: .init(x: 50, y: mainImageView.frame.height + 10,
                width: 200, height: 50), text: "Add to favourites")
        view.addSubview(label)
    }

    func setLikeIndicator() {
        heartImageView.image = heartImage
        heartImageView.configure(with: .init(x: 10, y: mainImageView.frame.height + 10, width: 50, height: 50))
        view.addSubview(heartImageView)
    }

    func setLabel(frame: CGRect, text: String) {
        let label = UILabel(frame: .init(x: 50, y: mainImageView.frame.height + 10,
                width: 200, height: 50))
        label.text = "Add to favourites"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(label)
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
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }
}