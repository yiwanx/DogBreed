//
// Created by Ivan Petukhov on 30.07.2022.
//

import UIKit

protocol BreedPhotosDisplayLogic: BreedPhotoDetailDelegate, AnyObject {
    func displayPhotos(_ models: [BreedPhotoModel])
}

class BreedPhotosViewController: UIViewController, BreedPhotosDisplayLogic {

    var interactor: BreedPhotosBusinessLogic?
    var gridCollectionView: UICollectionView!

    var models: [BreedPhotoModel] = []

    var firstTime = true

    private var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let sideLength = UIScreen.main.bounds.size.width / 3 - 1
        layout.itemSize = CGSize(width: sideLength, height: sideLength)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .vertical
        return layout
    }()

    func setGridCollectionView() -> UICollectionView {
        var gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        gridCollectionView.register(PhotoCollectionCell.self, forCellWithReuseIdentifier: PhotoCollectionCell.reuseId)
        gridCollectionView.delegate = self
        gridCollectionView.dataSource = self
        gridCollectionView.prefetchDataSource = self
        return gridCollectionView
    }

    override func loadView() {
        super.loadView()
        gridCollectionView = setGridCollectionView()
        view.addSubview(gridCollectionView)
        gridCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        title = interactor?.title.capitalized
        interactor?.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !firstTime {
            interactor?.load()
        }
        firstTime = false
    }

    func setupConstraints() {
        gridCollectionView.setupConstraints(with: view)
    }

    func displayPhotos(_ models: [BreedPhotoModel]) {
        /// If models are the same, the ignoring the call
        guard self.models != models else { return }
        self.models = models
        DispatchQueue.main.async { [weak gridCollectionView] in
            gridCollectionView?.reloadData()
        }
    }

    func routeToDetailedPhoto(_ model: BreedPhotoModel) {
        let vc = BreedPhotoDetailViewController()
        let interactor = BreedPhotoDetailInteractor(model: model)
        vc.interactor = interactor
        vc.delegate = self
        interactor.viewController = vc
        DispatchQueue.main.async { [weak navigationController, weak interactor] in
            navigationController?.present(vc, animated: true)
        }
    }

    func reloadCollection() {
        interactor?.load()
    }
}

extension BreedPhotosViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        routeToDetailedPhoto(model)
    }
}

extension BreedPhotosViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        for indexPath in indexPaths {
            let model = models[indexPath.row]
            Task {
                guard let url = URL(string: model.urlString) else {
                    throw URLError.isNotURL
                }
                do {
                    try await ImageLoader.shared.preFetch(url)
                } catch {
                    throw error
                }
            }
        }
    }
}

extension BreedPhotosViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.reuseId, for: indexPath)
                as? PhotoCollectionCell, indexPath.row < models.count  else { return .init() }
        let model = models[indexPath.row]
        Task { () -> _ in
            guard let url = URL(string: model.urlString) else {
                throw URLError.isNotURL
            }
            let image = try await ImageLoader.shared.fetch(url)
            await MainActor.run {
                cell.imageView.image = image
                cell.imageView.contentMode = .scaleAspectFill
            }
        }
        return cell
    }
}