//
//  TrainNNControlsView.swift
//  Foodle
//
//  Created by Anton Vlezko on 18.08.2021.
//

import SwiftUI

struct TrainNNControlsView: View {
    @Binding var learningRateValue: Double
    @Binding var dataAugmentationIsOn: Bool
    @Binding var statusLabelText: String
    
    @Binding var otherButtonsIsDisabled: Bool
    @Binding var stopButtonIsDisabled: Bool
    
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
            Text(statusLabelText)
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
            .disabled(otherButtonsIsDisabled)
            Button(action: {
                tenEpochTapped()
            },
            label: {
                Text("10 Epoch")
            })
            .disabled(otherButtonsIsDisabled)
            Button(action: {
                fiftyEpochTapped()
            },
            label: {
                Text("50 Epoch")
            })
            .disabled(otherButtonsIsDisabled)
            Button(action: {
                stopTapped()
            },
            label: {
                Text("Stop")
            })
            .disabled(stopButtonIsDisabled)
            Spacer()
        }
    }
    
    private func controls() -> some View {
        let text = "Learning rate \(String(format: "%.3f", learningRateValue).prefix(8))"
        
        return VStack {
            HStack {
                Text(text)
                Slider(value: $learningRateValue,
                       in: 0.001...1.000)
                    .disabled(otherButtonsIsDisabled)
                    .onChange(of: learningRateValue, perform: { value in
                        learningRateSliderMoved(value)
                    })
            }
            Toggle("Data augmentation",
                   isOn: $dataAugmentationIsOn)
                .disabled(otherButtonsIsDisabled)
                .onChange(of: dataAugmentationIsOn, perform: { value in
                    augmentationSwitchTapped(value)
                })
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}
