import UIKit
import SwiftUI

/**
 A simple animated line graph. Shows the training loss.
 */
struct LineGraph: View {
    @ObservedObject var trainVM: TrainNeuralNetworkVM
    @State private var end = CGFloat.zero
    
    public var body: some View {
        let trainLoss = trainVM.historyPublished.events.map { $0.trainLoss }
        
        GeometryReader { geometry in
            LineChartShape(data: trainLoss)
                .trim(from: 0, to: end)
                .stroke(Color(UIColor.systemYellow),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .animation(.easeInOut)
        }
        .onAppear {
            withAnimation(.easeInOut) {
                self.end = 1
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct LineChartShape: Shape {
    var data: [Double]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = Double(rect.width)
        let height = Double(rect.height)
        
        guard data.count > 1 else {
            return path
        }
        
        let maxY = data.max() ?? 0
        let offsetX = 10.0
        let offsetY = 10.0
        let scaleX = (width  - offsetX*2) / Double(data.count - 1)
        let scaleY = (height - offsetY*2) / (maxY + 1e-5)
        
        let point = CGPoint(x: offsetX, y: height - (offsetY + data[0] * scaleY))
        path.move(to: point)
        
        for i in 1..<data.count {
            let point = CGPoint(x: offsetX + Double(i)*scaleX, y: height - (offsetY + data[i] * scaleY))
            path.addLine(to: point)
        }
        
        return path
    }
}
