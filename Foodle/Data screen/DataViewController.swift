//
//  DataViewController.swift
//  Foodle
//
//  Created by Anton Vlezko on 16.08.2021.
//

import UIKit
import SwiftUI

/**
 View controller for the "Training Data" and "Testing Data" screens.
 */
class DataViewController: UIViewController {
    
    // MARK: - Properties
    @Inject var labels: Labels
    @ObservedObject private var imagesByLabel: ImagesByLabel
    private var barTitle: String
        
    // MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    init(barTitle: String, imagesByLabel: ImagesByLabel) {
        self.barTitle = barTitle
        self.imagesByLabel = imagesByLabel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print(#function)
    }
    
    // MARK: - Helper Functions
    
    func configureUI() {
        configureNavigationBar()
        configureData()
    }
    
    func configureNavigationBar() {
        navigationItem.title = barTitle
    }
    
    func configureData() {
        let dataView = DataView(
            imagesByLabel: imagesByLabel,
//            labelsArray: $imagesByLabel.labelsArray,
            deleteTapped: { label, index in
                self.deleteRow(sectionLabel: label, index: index)
            },
            takePicture: { section in
                self.takePicture(section: section)
            },
            choosePhoto: { section in
                self.choosePhoto(section: section)
            }
        )
        
        let dataCtrl = UIHostingController(rootView: dataView)
        addChild(dataCtrl)
        view.addSubview(dataCtrl.view)
        dataCtrl.didMove(toParent: self)
        
        dataCtrl.view.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.safeAreaLayoutGuide.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.safeAreaLayoutGuide.rightAnchor
        )
    }
    
    func deleteRow(sectionLabel: String, index: Int) {
        imagesByLabel.removeImage(for: sectionLabel, at: index)
    }
    
    // MARK: - Choosing photos
    
    var pickPhotoForSection = 0
    
    func takePicture(section: Int) {
        pickPhotoForSection = section
        presentPhotoPicker(sourceType: .camera)
    }
    
    func choosePhoto(section: Int) {
        pickPhotoForSection = section
        presentPhotoPicker(sourceType: .photoLibrary)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension DataViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // Grab the image.
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        
        // Add the image to the data model.
        let label = labels.labelsArray[pickPhotoForSection]
        imagesByLabel.addImage(image, for: label.labelEmoji)
    }
}
