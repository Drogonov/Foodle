//
//  VegetableVC.swift
//  Foodle
//
//  Created by Anton Vlezko on 10.08.2021.
//

import UIKit

class VegetableVC: UIViewController {
    // MARK: - Properties
    
    let barTitle: String = "Vegetable List"
    let vegetables: [Vegetable] = [
        Vegetable(name: "Tomato", image: UIImage(named: "vegImage"), modelStatus: .empty),
        Vegetable(name: "Potato", image: UIImage(named: "vegImage"), modelStatus: .partlyFilled),
        Vegetable(name: "Banana", image: UIImage(named: "vegImage"), modelStatus: .full),
        Vegetable(name: "Tomato", image: UIImage(named: "vegImage"), modelStatus: .empty),
        Vegetable(name: "Potato", image: UIImage(named: "vegImage"), modelStatus: .partlyFilled),
        Vegetable(name: "Banana", image: UIImage(named: "vegImage"), modelStatus: .full)
    ]
    
    private var vegetablesViewModel = VegetableViewModel(cells: [])
    private var vegetableCollectionView = VegetableCollectionView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVegetables()
        configureUI()
        
    }
    
    // MARK: - Helper Functions
    
    func configureVegetables() {
        vegetablesViewModel = VegetableViewModel(vegetables: vegetables)
    }
    
    func configureUI() {
        configureNavigationBar()
        configureCollectionView()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.systemRed
        navigationItem.title = barTitle
    }
    
    func configureCollectionView() {
        vegetableCollectionView.delegate = self
        
        view.addSubview(vegetableCollectionView)
        vegetableCollectionView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.safeAreaLayoutGuide.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.safeAreaLayoutGuide.rightAnchor
        )
        vegetableCollectionView.set(vegatables: vegetablesViewModel.cells)
    }
}

extension VegetableVC: VegetableCollectionViewDelegate {
    func handleStatusButton(vegetableID: UUID?) {
        debugPrint("handleStatusButton with id \(vegetableID)")
    }
    
    func handleVegetableButton(vegetableID: UUID?) {
        if vegetableID != nil {
            debugPrint("handleVegetableButton \(vegetableID)")
        } else {
            debugPrint("Add model tapped")
        }
        
    }
}
