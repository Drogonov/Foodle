//
//  TrainNNControlsView.swift
//  Foodle
//
//  Created by Anton Vlezko on 18.08.2021.
//

import SwiftUI

struct TrainNNControlsView: View {
    @ObservedObject var trainVM: TrainNeuralNetworkVM

    var oneEpochTapped:() -> Void
    var tenEpochTapped:() -> Void
    var fiftyEpochTapped:() -> Void
    var stopTapped:() -> Void
    var learningRateSliderMoved:(Double) -> Void
    var augmentationSwitchTapped:(Bool) -> Void
    
    
    public var body: some View {
        VStack(spacing: 16) {
            epochButtons()
            controls()
            Text(trainVM.statusLabelText)
        }
        .padding(16)
    }
    
    private func epochButtons() -> some View {
        HStack(spacing: 20) {
            Spacer()
            Button(action: {
                oneEpochTapped()
            },
            label: {
                Text("1 Epoch")
            })
            .disabled(trainVM.otherButtonsIsDisabled)
            Button(action: {
                tenEpochTapped()
            },
            label: {
                Text("10 Epoch")
            })
            .disabled(trainVM.otherButtonsIsDisabled)
            Button(action: {
                fiftyEpochTapped()
            },
            label: {
                Text("50 Epoch")
            })
            .disabled(trainVM.otherButtonsIsDisabled)
            Button(action: {
                stopTapped()
            },
            label: {
                Text("Stop")
            })
            .disabled(trainVM.stopButtonIsDisabled)
            Spacer()
        }
    }
    
    private func controls() -> some View {
        VStack {
            HStack {
                Text("Learning rate ")
                Text(String(format: "%.3f", trainVM.learningRateValue).prefix(8))
                Slider(value: $trainVM.learningRateValue,
                       in: 0.001...1.000)
                    .disabled(trainVM.otherButtonsIsDisabled)
                    .onChange(of: trainVM.learningRateValue, perform: { value in
                        learningRateSliderMoved(value)
                    })
            }
            Toggle("Data augmentation",
                   isOn: $trainVM.dataAugmentationIsOn)
                .disabled(trainVM.otherButtonsIsDisabled)
                .onChange(of: trainVM.dataAugmentationIsOn, perform: { value in
                    augmentationSwitchTapped(value)
                })
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}
