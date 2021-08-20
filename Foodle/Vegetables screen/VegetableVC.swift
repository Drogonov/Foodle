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
        guard let index = vegetablesViewModel.cells.firstIndex(where: {$0.id == vegetableID}) else { return }
        let label = vegetablesViewModel.cells[index]
        if labels.builtinLabels.contains(where: { $0.labelEmoji.first == label.vegetableEmoji }) {
            configureStandartNotification(vegetableID: vegetableID, name: label.vegetableName)
        } else {
            configureDeleteNotification(vegetableID: vegetableID, name: label.vegetableName)
        }
    }
    
    func handleDeleteVegetable(vegetableID: UUID) {
        guard let index = vegetablesViewModel.cells.firstIndex(where: {$0.id == vegetableID}) else { return }
        let cell = vegetablesViewModel.cells[index]
        if let emoji = vegetablesViewModel.cells[index].vegetableEmoji {
            let label = Label(labelEmoji: String(emoji), labelName: cell.vegetableName)
            labels.deleteLabel(label)
            trainingDataset.createFolder(for: label.labelEmoji)
            testingDataset.createFolder(for: label.labelEmoji)
            configureVegetables()
            debugPrint(vegetablesViewModel.cells)
        }
    }
    
    func configureDeleteNotification(vegetableID: UUID, name: String) {
        self.showNotification(title: "What do you whant to do with \(name)?",
                              defaultAction: true,
                              defaultActionText: "Cancel",
                              rejectAction: true,
                              rejectActionText: "Delete") { config, _  in
            switch config {
            case .rejectAction:
                self.handleDeleteVegetable(vegetableID: vegetableID)
            default: break
            }
        }
    }
    
    func configureStandartNotification(vegetableID: UUID, name: String) {
        self.showNotification(title: "What do you whant to do with \(name)?",
                              defaultAction: true,
                              defaultActionText: "Cancel") { config, _  in
            switch config {
            default: break
            }
        }
    }
    
    func handleTapAddModel() {
        self.configureAddModelAlert(
            title: "Whant to add new model?",
            message: "Pls enter both fields",
            textFieldNamePlaceholder: "Enter Name",
            textFieldEmojiPlaceholder: "Enter Emoji",
            textFieldActionText: "Save",
            rejectActionText: "Cancel") { config, vagetableName, vegetableEmoji in
            switch config {
            case .textField:
                guard vagetableName != nil, vegetableEmoji != nil else { return }
                let emoji: String.Element = vegetableEmoji!.first!
                let label = Label(labelEmoji: String(emoji), labelName: vagetableName!)
                labels.addLabel(label)
                trainingDataset.createFolder(for: label.labelEmoji)
                testingDataset.createFolder(for: label.labelEmoji)
                self.configureVegetables()
            default: break
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func configureVegetables() {
        vegetablesViewModel = VegetableViewModel(cells: [])
        vegetablesViewModel = VegetableViewModel(labels: labels.labelsArray)
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
        configureVegetables()
    }
}

extension VegetableVC: VegetableCollectionViewDelegate {
    func handleStatusButton(vegetableID: UUID?) {
        debugPrint("handleStatusButton with id \(vegetableID)")
    }
    
    func handleVegetableButton(vegetableID: UUID?) {
        if vegetableID != nil {
            self.handleTapVegetable(vegetableID: vegetableID!)
        } else {
            self.handleTapAddModel()
        }
    }
}
