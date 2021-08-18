//
//  DataView.swift
//  Foodle
//
//  Created by Anton Vlezko on 17.08.2021.
//
import Combine
import SwiftUI

struct DataView: View {
    @ObservedObject var imagesByLabel: ImagesByLabel
//    @Binding var labelsArray: [LabelSection]
    var deleteTapped:(String, Int) -> Void
    var takePicture: (Int) -> Void
    var choosePhoto: (Int) -> Void
    
    public var body: some View {
        List {
            ForEach(imagesByLabel.labelsArray.indices, id: \.self) { sectionIndex in
                Section(header: header(index: sectionIndex)) {
                    ForEach(imagesByLabel.labelsArray[sectionIndex].items.indices,
                            id: \.self) { index in
                        imageCell(sectionIndex: sectionIndex, index: index)
                    }
                    .onDelete(perform: { row in
                        guard let rowIndex = row.first else { return }
                        deleteTapped(imagesByLabel.labelsArray[sectionIndex].sectionLabel, rowIndex)
            
                    })
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
    
    private func header(index: Int) -> some View {
        HStack {
            cameraButton(index: index)
            Spacer()
            Text(imagesByLabel.labelsArray[index].sectionLabel)
                .font(.system(size: 32))
            
            Spacer()
            galeryButton(index: index)
        }
        .padding(8)
    }
    
    private func cameraButton(index: Int) -> some View {
        Button(action: {
            takePicture(index)
        },
        label: {
            Image(systemName: "camera")
                .font(.system(size: 32))
                .foregroundColor(.yellow)
        })
    }
    
    private func galeryButton(index: Int) -> some View {
        Button(action: {
            choosePhoto(index)
        },
        label: {
            Image(systemName: "folder")
                .font(.system(size: 32))
                .foregroundColor(.yellow)
        })
    }
    
    private func imageCell(sectionIndex: Int, index: Int) -> some View {
        HStack() {
            Spacer()
            if let image = imagesByLabel.labelsArray[sectionIndex].items[index]
            {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 256)
                    .cornerRadius(10)
            } else {
                Text("File not found")
            }
            Spacer()
        }
    }
}
