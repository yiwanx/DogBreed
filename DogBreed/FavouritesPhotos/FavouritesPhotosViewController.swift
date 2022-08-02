//
// Created by Ivan Petukhov on 01.08.2022.
//

import UIKit

protocol FavouritesPhotosDisplayLogic: BreedPhotosDisplayLogic {
    var favouriteBreeds: [String] { get set }
}

class FavouritesPhotosViewController: BreedPhotosViewController, FavouritesPhotosDisplayLogic {
    var favouriteBreeds: [String] = []
    var stackView: UIStackView!
    var label: UILabel!
    var searchButton: UIButton!

    var favouritesInteractor: FavouritesPhotosBusinessLogic? {
        interactor as? FavouritesPhotosBusinessLogic
    }

    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        label = configuredLabel(frame: .zero, text: "Search By Breed")
        searchButton = .systemButton(with: .init(systemName: "magnifyingglass.circle")!, target: self, action: #selector(searchTapped))
        [label, searchButton].forEach { view in
            stackView.addArrangedSubview(view)
        }
        view.addSubview(stackView)
    }

    /// Overriding in order to change constraints and add a toolbar.
    override func setupConstraints() {
        [gridCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
         gridCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
         gridCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
         gridCollectionView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
         stackView.topAnchor.constraint(equalTo: gridCollectionView.bottomAnchor),
         stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
         stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
         stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
         stackView.heightAnchor.constraint(equalToConstant: 50)
        ].forEach { $0.isActive = true }
    }

    @objc func searchTapped() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: view.frame.width, height: view.frame.height / 2 )
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: view.frame.height / 2 - 100))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        let chooseBreedAlert = UIAlertController(title: "Choose breed", message: "", preferredStyle: UIAlertController.Style.alert)
        chooseBreedAlert.setValue(vc, forKey: "contentViewController")
        chooseBreedAlert.addAction(UIAlertAction(title: "Done", style: .default) { [weak pickerView, weak favouritesInteractor] _ in
            guard let index = pickerView?.selectedRow(inComponent: 0) else { return }
            favouritesInteractor?.displayWithFilterIfNeeded(with: self.favouriteBreeds[index])
        })
        chooseBreedAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(chooseBreedAlert, animated: true)
    }

}

extension FavouritesPhotosViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        favouritesInteractor?.favouriteBreeds.count ?? 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        favouriteBreeds[row]
    }
}