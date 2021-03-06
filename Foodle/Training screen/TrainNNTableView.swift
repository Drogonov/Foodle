//
//  TrainNNTableView.swift
//  Foodle
//
//  Created by Anton Vlezko on 18.08.2021.
//

import SwiftUI

struct TrainNNTableView: View {
    @ObservedObject var trainVM: TrainNeuralNetworkVM
    
    public var body: some View {
        VStack(alignment: .center, spacing: 16)  {
            HStack(spacing: 20) {
                Text("epoch")
                Text("tr.loss")
                Text("val.loss")
                Text("val.acc")
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 26)
            
            ScrollViewReader { scrollView in
                List {
                    ForEach(trainVM.historyPublished.events.indices, id: \.self) { index in
                        Text(trainVM.historyPublished.events[index].displayString)
                            .font(Font(UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)))
                            .padding(.horizontal, 16)
                            .id(index)
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut) {
                        trainVM.set()
                        scrollView.scrollTo(trainVM.historyPublished.events.endIndex - 1)
                    }
                }
                .onChange(of: trainVM.historyPublished.events,
                          perform: { _ in
                            withAnimation(.easeInOut) {
                                scrollView.scrollTo(trainVM.historyPublished.events.endIndex - 1)
                            }
                          })
            }
        }
    }
}

fileprivate extension History.Event {
    var displayString: String {
        var s = String(format: "%5d   ", epoch + 1)
        s += String(String(format: "%6.4f", trainLoss).prefix(6))
        s += "   "
        s += String(String(format: "%6.4f", validationLoss).prefix(6))
        s += "     "
        s += String(String(format: "%5.2f", validationAccuracy * 100).prefix(5))
        return s
    }
}
