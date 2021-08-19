//
//  MainTabVC.swift
//  Foodle
//
//  Created by Anton Vlezko on 10.08.2021.
//

import UIKit

class MainTabVC: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Properties
    private lazy var settingsCollectionVC = SettingsVC()
    private lazy var vegetableCollectionVC = VegetableVC()
    private lazy var cameraVC = CameraVC()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        Models.copyEmptyNearestNeighbors()
        Models.copyEmptyNeuralNetwork()
        
        configureUI()
    }
    
    // MARK: - Helper Functions
    
    func configureUI() {
        configureViewControllers()
        view.backgroundColor = .systemBackground
    }
    
    // function to create view controllers that exist within tab bar controller
    func configureViewControllers() {
        let settingsNavController = constructNavController(
            unselectedImage: UIImage().systemImage(withSystemName: "gearshape"),
            selectedImage: UIImage().systemImage(withSystemName: "gearshape.fill"),
            rootViewController: settingsCollectionVC
        )
        
        let vegetableNavController = constructNavController(
            unselectedImage: UIImage().systemImage(withSystemName: "leaf"),
            selectedImage: UIImage().systemImage(withSystemName: "leaf.fill"),
            rootViewController: vegetableCollectionVC
        )
        
        let cameraNavController = constructNavController(
            unselectedImage: UIImage().systemImage(withSystemName: "camera"),
            selectedImage: UIImage().systemImage(withSystemName: "camera.fill"),
            rootViewController: cameraVC
        )
        
        viewControllers = [settingsNavController, vegetableNavController, cameraNavController]
        selectedIndex = 1
        tabBar.tintColor = .label
    }
    
    // construct navigation controllers
    func constructNavController(unselectedImage: UIImage,
                                selectedImage: UIImage,
                                navControllerName: String? = nil,
                                rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.tabBarItem.title = navControllerName ?? ""
        navController.navigationBar.tintColor = .label
        return navController
    }
}
