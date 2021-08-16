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
    var vegetables: [Vegetable] = [
        Vegetable(name: "Tomato", image: nil, emoji: "🍅", modelStatus: .empty),
        Vegetable(name: "Potato", image: nil, emoji: "🥔", modelStatus: .partlyFilled),
        Vegetable(name: "Banana", image: nil, emoji: "🍌", modelStatus: .full),
    ]
    
    private var vegetablesViewModel = VegetableViewModel(cells: [])
    private var vegetableCollectionView = VegetableCollectionView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVegetables()
        configureUI()
        
    }
    
    // MARK: - Selectors
    
    func handleTapVegetable(vegetableID: UUID) {
        guard let index = vegetables.firstIndex(where: {$0.id == vegetableID}) else { return }
        let name: String = vegetables[index].name
        self.showNotification(title: "What do you whant to do with \(name)?",
                              defaultAction: true,
                              defaultActionText: "cancel",
                              rejectAction: true,
                              rejectActionText: "delete") { config, _  in
            switch config {
            case .rejectAction:
                self.handleDeleteVegetable(vegetableID: vegetableID)
            default: break
            }
        }
    }
    
    func handleDeleteVegetable(vegetableID: UUID) {
        guard let index = vegetables.firstIndex(where: {$0.id == vegetableID}) else { return }
        vegetables.remove(at: index)
        configureVegetables()
        debugPrint(vegetablesViewModel.cells)
    }
    
    
    // MARK: - Helper Functions
    
    func configureVegetables() {
        vegetablesViewModel = VegetableViewModel(cells: [])
        vegetablesViewModel = VegetableViewModel(vegetables: vegetables)
        vegetableCollectionView.set(vegatables: vegetablesViewModel.cells)
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
            self.handleTapVegetable(vegetableID: vegetableID!)
            debugPrint("handleVegetableButton \(vegetableID)")
        } else {
            debugPrint("Add model tapped")
        }
        
    }
}
