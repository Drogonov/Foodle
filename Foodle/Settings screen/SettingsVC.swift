//
//  SettingsVC.swift
//  Foodle
//
//  Created by Anton Vlezko on 16.08.2021.
//

import UIKit
import SwiftUI

class SettingsVC: UIViewController {
    // MARK: - Properties
    let barTitle: String = "Settings"
    
    let menu = [
        SettingsMenuSection(
            sectionName: "Dataset",
            items: [SettingsMenuItem(itemName: "Training Data",
                                     settingsType: .router(router: .trainingData)),
                    SettingsMenuItem(itemName: "Testing Data",
                                     settingsType: .router(router: .testingData)),
                    SettingsMenuItem(itemName: "Load Built-in Dataset",
                                     itemColor: Color(.systemYellow),
                                     settingsType: .button(type: .loadDataSet))]
        ),
        SettingsMenuSection(
            sectionName: "Neural Network",
            items: [SettingsMenuItem(itemName: "Train",
                                     settingsType: .router(router: .train)),
                    SettingsMenuItem(itemName: "Evaluate",
                                     settingsType: .router(router: .evaluate)),
                    SettingsMenuItem(itemName: "Keep Training in Background",
                                     settingsType: .toogle),
                    SettingsMenuItem(itemName: "Reset to Empty Model",
                                     itemColor: Color(.systemYellow),
                                     settingsType: .button(type: .resetToEmpty)),
                    SettingsMenuItem(itemName: "Reset to Turi Create Model",
                                     itemColor: Color(.systemYellow),
                                     settingsType: .button(type: .resetToTuri))]
        )
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    // MARK: - Routers
    
    func routeTo(router: Router) {
        switch router {
        case .trainingData:
            trainingDataTapped()
        case .testingData:
            testingDataTapped()
        case .train:
            trainTapped()
        case .evaluate:
            evaluateTapped()
        }
    }
    
    @objc func trainingDataTapped() {
        let trainingImagesByLabel = ImagesByLabel(dataset: Globals.shared.trainingDataset)
        let trainingDataVC = DataViewController(barTitle: "Training Data",
                                                imagesByLabel: trainingImagesByLabel)
        navigationController?.pushViewController(trainingDataVC, animated: true)
    }
    
    @objc func testingDataTapped() {
        let testingImagesByLabel = ImagesByLabel(dataset: Globals.shared.testingDataset)
        let testingDataVC = DataViewController(barTitle: "Testing Data",
                                               imagesByLabel: testingImagesByLabel)
        navigationController?.pushViewController(testingDataVC, animated: true)
    }
    
    @objc func trainTapped() {
        let trainVC = TrainNeuralNetworkViewController()
        trainVC.model = Models.loadTrainedNeuralNetwork()
        trainVC.trainingDataset = Globals.shared.trainingDataset
        trainVC.validationDataset = Globals.shared.testingDataset
        navigationController?.pushViewController(trainVC, animated: true)
    }
    
    @objc func evaluateTapped() {
        let model = Models.loadTrainedNeuralNetwork()
        let dataSet = Globals.shared.testingDataset
        let evaluateVC = EvaluateViewController(model: model!, dataset: dataSet)
        navigationController?.pushViewController(evaluateVC, animated: true)
    }
    
    // MARK: - Selectors
    
    func buttonTapped(type: SettingsButtonType) {
        switch type {
        case .loadDataSet:
            loadDataSet()
        case .resetToEmpty:
            resetToEmpty()
        case .resetToTuri:
            resetToTuri()
        }
    }
    
    @objc func loadDataSet() {
        Globals.shared.trainingDataset.copyBuiltInImages()
        Globals.shared.testingDataset.copyBuiltInImages()
    }
    
    @objc func resetToEmpty() {
        Models.deleteTrainedNeuralNetwork()
        Models.copyEmptyNeuralNetwork()
        history.delete()
    }
    
    @objc func resetToTuri() {
        Models.deleteTrainedNeuralNetwork()
        Models.copyTuriNeuralNetwork()
        history.delete()
    }
    
    @objc func backgroundTrainingSwitchTapped(value: Bool) {
        settings.isBackgroundTrainingEnabled = value
    }
    
    
    // MARK: - Helper Functions
    
    func configureUI() {
        configureNavigationBar()
        configureSettings()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.systemYellow
        navigationItem.title = barTitle
    }
    
    func configureSettings() {
        let settingsView = SettingsView(
            menu: menu,
            buttonTapped: { type in
                self.buttonTapped(type: type)
            },
            routerTapped: { router in
                self.routeTo(router: router)
            },
            backgroundTrainingEnabled: { value in
                self.backgroundTrainingSwitchTapped(value: value)
            }
        )
        
        let settingsCtrl = UIHostingController(rootView: settingsView)
        addChild(settingsCtrl)
        view.addSubview(settingsCtrl.view)
        
        settingsCtrl.view.anchor(
            top: view.topAnchor,
            leading: view.safeAreaLayoutGuide.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.safeAreaLayoutGuide.rightAnchor
        )
    }
}
