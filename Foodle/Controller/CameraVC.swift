//
//  CameraVC.swift
//  Foodle
//
//  Created by Anton Vlezko on 10.08.2021.
//

import UIKit

class CameraVC: UIViewController {
    // MARK: - Properties
    
    let barTitle: String = "Camera"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

    }
    
    // MARK: - Helper Functions
    
    func configureUI() {
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.systemRed
        navigationItem.title = barTitle
    }
}
