//
//  VegetableCollectionViewCell.swift
//  Foodle
//
//  Created by Anton Vlezko on 10.08.2021.
//

import UIKit

protocol VegetableCellViewModel {
    var id: UUID { get }
    var statusButtonColor: UIColor { get }
    var vegetableImage: UIImage? { get }
    var vegetableName: String { get }
}

protocol VegetableCollectionViewCellDelegate: AnyObject {
    func handleStatusButton(vegetableID: UUID?)
    func handleVegetableButton(vegetableID: UUID?)
}

class VegetableCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    weak var delegate: VegetableCollectionViewCellDelegate?
    static let reuseId = "VegetableCollectionViewCell"
    private var vegetableID: UUID? = nil
    
    private let vegetableStatusButtonSize: CGFloat = 32
    private let vegetableImageViewSize: CGFloat = 120
    
    private let vegetableStatusButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.masksToBounds = true
        return button
    }()
    
    private let vegetableImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentMode = .scaleAspectFit
        button.backgroundColor = .systemBackground
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.borderWidth = 2
        return button
    }()
    
    private var vegetableNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleStatusButton() {
        delegate?.handleStatusButton(vegetableID: vegetableID)
    }
    
    @objc func handleVegetableButton() {
        delegate?.handleVegetableButton(vegetableID: vegetableID)
    }
    
    // MARK: - Helper Functions
    
    private func configureUI() {
        addSubview(vegetableStatusButton)
        vegetableStatusButton.anchor(
            top: self.topAnchor,
            paddingTop: 16,
            width: vegetableStatusButtonSize,
            height: vegetableStatusButtonSize
        )
        vegetableStatusButton.centerX(inView: self)
        vegetableStatusButton.layer.cornerRadius = vegetableStatusButtonSize / 2
        vegetableStatusButton.addTarget(self,
                                        action: #selector(handleStatusButton),
                                        for: .touchUpInside)
        vegetableStatusButton.addShadow()
        
        addSubview(vegetableImageButton)
        vegetableImageButton.anchor(
            top: vegetableStatusButton.bottomAnchor,
            paddingTop: 16,
            width: vegetableImageViewSize,
            height: vegetableImageViewSize
        )
        vegetableImageButton.centerX(inView: self)
        vegetableImageButton.layer.cornerRadius = vegetableImageViewSize / 2
        vegetableImageButton.addTarget(self,
                                       action: #selector(handleVegetableButton),
                                       for: .touchUpInside)
        
        addSubview(vegetableNameLabel)
        vegetableNameLabel.anchor(
            top: vegetableImageButton.bottomAnchor,
            leading: self.leftAnchor,
            trailing: self.rightAnchor,
            paddingTop: 16,
            paddingLeft: 16,
            paddingBottom: 16,
            paddingRight: 16
        )
        
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 10
    }
    
    // MARK: - Set
    
    func set(viewModel: VegetableCellViewModel) {
        let optImage = viewModel.vegetableImage?.withRenderingMode(.alwaysOriginal)
        let image = UIImage(named: "Logo_tomato")
        vegetableStatusButton.backgroundColor = viewModel.statusButtonColor
        vegetableImageButton.setImage(optImage ?? image, for: .normal)
        vegetableNameLabel.text = viewModel.vegetableName
        vegetableID = viewModel.id
    }
    
    func configureButtonCell() {
        vegetableImageButton.setImage(#imageLiteral(resourceName: "Plus_icon").withRenderingMode(.alwaysOriginal), for: .normal)
        vegetableImageButton.backgroundColor = .gray
        vegetableNameLabel.text = "Add model"
    }
}
