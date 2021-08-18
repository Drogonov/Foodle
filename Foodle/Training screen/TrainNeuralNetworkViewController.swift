import UIKit
import SwiftUI
import CoreML

/**
 View controller for the "Training Neural Network" screen.
 */
class TrainNeuralNetworkViewController: UIViewController {
    
    // MARK: - Properties
    var model: MLModel!
    var trainingDataset: ImageDataset!
    var validationDataset: ImageDataset!
    var trainer: NeuralNetworkTrainer!
    var isTraining = false
    
    
    var graphView = GraphView()
    private var barTitle: String = "Train Neural Network"
    
    @State var learningRateValue: Double = log10(settings.learningRate)
    @State var dataAugmentationIsOn: Bool = settings.isAugmentationEnabled
    
    @State var otherButtonsIsDisabled: Bool = false
    @State var stopButtonIsDisabled: Bool = true
    @State var statusLabelText: String = "Paused"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        trainer = NeuralNetworkTrainer(modelURL: Models.trainedNeuralNetworkURL,
                                       trainingDataset: trainingDataset,
                                       validationDataset: validationDataset,
                                       imageConstraint: imageConstraint(model: model))
        
        assert(model.modelDescription.isUpdatable)
        //print(model.modelDescription.trainingInputDescriptionsByName)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        graphView.update()
    }
    
    @objc func appWillResignActive() {
        stopTraining()
    }
    
    func updateButtons() {
        otherButtonsIsDisabled = isTraining
        stopButtonIsDisabled = !isTraining
    }
    
    func configureUI() {
        configureNavigationBar()
        configureControls()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = barTitle
    }
    
    func configureControls() {
        let controls = TrainNNControlsView(
            learningRateValue: $learningRateValue,
            dataAugmentationIsOn: $dataAugmentationIsOn,
            statusLabelText: $statusLabelText,

            otherButtonsIsDisabled: $otherButtonsIsDisabled,
            stopButtonIsDisabled: $stopButtonIsDisabled,
            
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
                settings.learningRate = pow(10, Double(value))
            },
            augmentationSwitchTapped: { value in
                settings.isAugmentationEnabled = value
            }
        )
        
        let controlsCtrl = UIHostingController(rootView: controls)
        addChild(controlsCtrl)
        view.addSubview(controlsCtrl.view)
        controlsCtrl.didMove(toParent: self)
        
        controlsCtrl.view.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.safeAreaLayoutGuide.leftAnchor,
            trailing: view.safeAreaLayoutGuide.rightAnchor, height: 200
        )
        
        view.addSubview(graphView)
        graphView.anchor(
            top: controlsCtrl.view.bottomAnchor,
            leading: view.safeAreaLayoutGuide.leftAnchor,
            trailing: view.safeAreaLayoutGuide.rightAnchor,
            paddingLeft: 16,
            paddingRight: 16,
            height: 200
        )
        
        graphView.backgroundColor = .secondarySystemBackground
        graphView.layer.cornerRadius = 10
        
        let tableView = TrainNNTableView(history: history)
        
        let tableViewCtrl = UIHostingController(rootView: tableView)
        addChild(tableViewCtrl)
        view.addSubview(tableViewCtrl.view)
        tableViewCtrl.didMove(toParent: self)
        
        tableViewCtrl.view.anchor(
            top: graphView.bottomAnchor,
            leading: view.safeAreaLayoutGuide.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.safeAreaLayoutGuide.rightAnchor
        )
    }
}

extension TrainNeuralNetworkViewController {
    func startTraining(epochs: Int) {
        guard trainingDataset.count > 0 else {
            statusLabelText = "No training images"
            return
        }
        
        isTraining = true
        statusLabelText = "Training..."
        updateButtons()
        
        trainer.train(epochs: epochs, learningRate: settings.learningRate, callback: trainingCallback)
    }
    
    func stopTraining() {
        trainer.cancel()
        trainingStopped()
    }
    
    func trainingStopped() {
        isTraining = false
        statusLabelText = "Paused"
        updateButtons()
    }
    
    func trainingCallback(callback: NeuralNetworkTrainer.Callback) {
        DispatchQueue.main.async {
            switch callback {
            case let .epochEnd(trainLoss, valLoss, valAcc):
                history.addEvent(trainLoss: trainLoss, validationLoss: valLoss, validationAccuracy: valAcc)
                self.graphView.update()
                
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
