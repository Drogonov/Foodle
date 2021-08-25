//
//  TrainNeuralNetworkVС.swift
//  Foodle
//
//  Created by Anton Vlezko on 18.08.2021.
//

import UIKit
import SwiftUI
import CoreML

/**
 View controller for the "Training Neural Network" screen.
 */

class TrainNeuralNetworkVM: ObservableObject {
    @Inject var settings: Settings
    @Inject var history: History
    
    @Published var learningRateValue: Double = 0
    @Published var dataAugmentationIsOn: Bool = false
    
    @Published var otherButtonsIsDisabled: Bool = false
    @Published var stopButtonIsDisabled: Bool = true
    @Published var statusLabelText: String = "Paused"
    @Published var historyPublished: History = History()
    
//    init() {
//        learningRateValue = log10(settings.learningRate)
//        dataAugmentationIsOn = settings.isAugmentationEnabled
//        historyPublished = history
//    }
    func set() {
        learningRateValue = log10(settings.learningRate)
        dataAugmentationIsOn = settings.isAugmentationEnabled
        historyPublished = history
    }
    
}

class TrainNeuralNetworkVC: UIViewController {
    
    // MARK: - Properties
    @Inject var settings: Settings
    @Inject var history: History
    var model: MLModel
    var trainingDataset: ImageDataset
    var validationDataset: ImageDataset
    var trainer: NeuralNetworkTrainer!
    var isTraining = false
    private var barTitle: String = "Train Neural Network"
    
    @ObservedObject var trainVM = TrainNeuralNetworkVM()
    
    private lazy var controls = TrainNNControlsView(
        trainVM: trainVM,
        oneEpochTapped: {
            self.startTraining(epochs: 1)
        },
        tenEpochTapped: {
            self.startTraining(epochs: 10)
        },
        fiftyEpochTapped: {
            self.startTraining(epochs: 50)
        },
        stopTapped: {
            self.stopTraining()
        },
        learningRateSliderMoved: { value in
            self.settings.learningRate = value
        },
        augmentationSwitchTapped: { value in
            self.settings.isAugmentationEnabled = value
        }
    )
    private lazy var controlsCtrl = UIHostingController(rootView: controls)

    private lazy var graphView = LineGraph(trainVM: trainVM)
    private lazy var graphViewCtrl = UIHostingController(rootView: graphView)

    
    private lazy var tableView = TrainNNTableView(trainVM: trainVM)
    private lazy var tableViewCtrl = UIHostingController(rootView: tableView)
    
    init(trainingDataset: ImageDataset, validationDataset: ImageDataset) {
        self.model = Models.loadTrainedNeuralNetwork()!
        self.trainingDataset = trainingDataset
        self.validationDataset = validationDataset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        trainer = NeuralNetworkTrainer(modelURL: Models.trainedNeuralNetworkURL,
                                       trainingDataset: trainingDataset,
                                       validationDataset: validationDataset,
                                       imageConstraint: imageConstraint(model: model))
        
        
        assert(model.modelDescription.isUpdatable)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    deinit {
        print(self, #function)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print(self, #function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // The user tapped the back button.
        stopTraining()
    }
    
    @objc func appWillResignActive() {
        stopTraining()
    }
    
    func updateButtons() {
        trainVM.otherButtonsIsDisabled = isTraining
        trainVM.stopButtonIsDisabled = !isTraining
    }
    
    func configureUI() {
        configureNavigationBar()
        configureControls()
        configureGraph()
        configureTableView()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = barTitle
    }
    
    func configureControls() {
        addChild(controlsCtrl)
        view.addSubview(controlsCtrl.view)
        controlsCtrl.didMove(toParent: self)
        
        controlsCtrl.view.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.safeAreaLayoutGuide.leftAnchor,
            trailing: view.safeAreaLayoutGuide.rightAnchor, height: 200
        )
    }
    
    func configureGraph() {
        addChild(graphViewCtrl)
        view.addSubview(graphViewCtrl.view)
        graphViewCtrl.didMove(toParent: self)
        graphViewCtrl.view.anchor(
            top: controlsCtrl.view.bottomAnchor,
            leading: view.safeAreaLayoutGuide.leftAnchor,
            trailing: view.safeAreaLayoutGuide.rightAnchor,
            paddingLeft: 16,
            paddingRight: 16,
            height: 200
        )
    }
    
    func configureTableView() {
        addChild(tableViewCtrl)
        view.addSubview(tableViewCtrl.view)
        tableViewCtrl.didMove(toParent: self)
        
        tableViewCtrl.view.anchor(
            top: graphViewCtrl.view.bottomAnchor,
            leading: view.safeAreaLayoutGuide.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.safeAreaLayoutGuide.rightAnchor
        )
    }
}

extension TrainNeuralNetworkVC {
    func startTraining(epochs: Int) {
        guard trainingDataset.count > 0 else {
            trainVM.statusLabelText = "No training images"
            return
        }
        
        isTraining = true
        trainVM.statusLabelText = "Training..."
        updateButtons()
        
        trainer.train(epochs: epochs, learningRate: settings.learningRate, callback: trainingCallback)
    }
    
    func stopTraining() {
        trainer.cancel()
        trainingStopped()
    }
    
    func trainingStopped() {
        isTraining = false
        trainVM.statusLabelText = "Paused"
        updateButtons()
    }
    
    func trainingCallback(callback: NeuralNetworkTrainer.Callback) {
        DispatchQueue.main.async {
            switch callback {
            case let .epochEnd(trainLoss, valLoss, valAcc):
                self.history.addEvent(trainLoss: trainLoss, validationLoss: valLoss, validationAccuracy: valAcc)
                self.trainVM.historyPublished = self.history
                debugPrint("epochEnd")
                
            case .completed(let updatedModel):
                self.trainingStopped()
                
                // Replace our model with the newly trained one.
                self.model = updatedModel
                
            case .error:
                self.trainingStopped()
            }
        }
    }
}

