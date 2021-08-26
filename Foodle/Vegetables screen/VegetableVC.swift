//
//  VegetableVC.swift
//  Foodle
//
//  Created by Anton Vlezko on 10.08.2021.
//

import UIKit

class VegetableVC: UIViewController {
    // MARK: - Properties
    @Inject var labels: Labels
    @Inject var dataset: Dataset
    let barTitle: String = "Vegetable List"
    private var vegetablesViewModel = VegetableViewModel(cells: [])
    private var vegetableCollectionView = VegetableCollectionView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVegetables()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureVegetables()
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
            dataset.trainingDataset.deleteFolder(for: label.labelEmoji)
            dataset.testingDataset.deleteFolder(for: label.labelEmoji)
            configureVegetables()
            debugPrint(vegetablesViewModel.cells)
        }
    }
    
    func handleTapStatusButton(vegetableID: UUID) {
        guard let index = vegetablesViewModel.cells.firstIndex(where: {$0.id == vegetableID}) else { return }
        let label = vegetablesViewModel.cells[index]
        
        let imageCount = dataset.trainingDataset.images(withLabel: String(label.vegetableEmoji!)).count
        let testImageCount = dataset.testingDataset.images(withLabel: String(label.vegetableEmoji!)).count
        
        var title: String
        switch imageCount {
        case let x where x <= 5:
            title = "It is not enought images to train model properly. Model start working fine with trainingDataset 10 (your score \(imageCount)), and testingDataset 5 (your score \(testImageCount))"
        case let x where x <= 10 && x > 5:
            title = "Amount of images could be higher but it is still okay. Model start working fine with trainingDataset 10 (your score \(imageCount)), and testingDataset 5 (your score \(testImageCount))"
        case let x where x > 10:
            title = "Model should work great. Model start working fine with trainingDataset 10 (your score \(imageCount)), and testingDataset 5 (your score \(testImageCount))"
        default: title = "Not enought info smth goes wrong"
        }

        configureStatusLabelNotification(title: title)
        
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
    
    func configureStatusLabelNotification(title: String) {
        self.showNotification(title: title,
                              defaultAction: true,
                              defaultActionText: "Ok") { config, _  in
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
                self.labels.addLabel(label)
                self.dataset.trainingDataset.createFolder(for: label.labelEmoji)
                self.dataset.testingDataset.createFolder(for: label.labelEmoji)
                self.configureVegetables()
            default: break
            }
        }
    }
    
    func setColor() {
        for i in 0..<vegetablesViewModel.cells.count {
            let cell = vegetablesViewModel.cells[i]
            let colorCount = dataset.trainingDataset.images(withLabel: String(cell.vegetableEmoji!)).count
            
            switch colorCount {
            case let x where x <= 5:
                vegetablesViewModel.cells[i].statusButtonColor = .red
            case let x where x <= 10 && x > 5:
                vegetablesViewModel.cells[i].statusButtonColor = .yellow
            case let x where x > 10:
                vegetablesViewModel.cells[i].statusButtonColor =  .green
            default: vegetablesViewModel.cells[i].statusButtonColor = .gray
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func configureVegetables() {
        vegetablesViewModel = VegetableViewModel(cells: [])
        vegetablesViewModel = VegetableViewModel(labels: labels.labelsArray)
        setColor()
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
        guard let id = vegetableID else { return }
        handleTapStatusButton(vegetableID: id)
    }
    
    func handleVegetableButton(vegetableID: UUID?) {
        if vegetableID != nil {
            self.handleTapVegetable(vegetableID: vegetableID!)
        } else {
            self.handleTapAddModel()
        }
    }
}
