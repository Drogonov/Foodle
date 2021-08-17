//
//  VegetableCollectionView.swift
//  Foodle
//
//  Created by Anton Vlezko on 10.08.2021.
//

import UIKit

protocol VegetableCollectionViewDelegate: AnyObject {
    func handleStatusButton(vegetableID: UUID?)
    func handleVegetableButton(vegetableID: UUID?)
}

class VegetableCollectionView: UIView {

    // MARK: - Properties
    
    private var vegatables = [VegetableCellViewModel]()
    weak var delegate: VegetableCollectionViewDelegate?
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        
        collectionView.register(VegetableCollectionViewCell.self,
                                forCellWithReuseIdentifier: VegetableCollectionViewCell.reuseId)
        
//        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.layer.masksToBounds = false
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ConfigureUI Functions
    
    private func configureUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        addSubview(collectionView)
        collectionView.anchor(top: self.topAnchor,
                              leading: self.leftAnchor,
                              bottom: self.bottomAnchor,
                              trailing: self.rightAnchor,
                              paddingTop: 16,
                              paddingLeft: 16,
                              paddingBottom: 16,
                              paddingRight: 16)
    }
    
    func set(vegatables: [VegetableCellViewModel]) {
        self.vegatables = vegatables
        collectionView.contentOffset = CGPoint.zero
        collectionView.reloadData()
    }
}

extension VegetableCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if vegatables.isEmpty {
            return 1
        }
        return vegatables.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VegetableCollectionViewCell.reuseId, for: indexPath) as! VegetableCollectionViewCell
        
        cell.delegate = self
        
        if vegatables.count != indexPath.row {
            cell.set(viewModel: vegatables[indexPath.row])
            debugPrint(indexPath.row)
        } else {
            cell.configureButtonCell()
        }
        return cell
    }
}

extension VegetableCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: (collectionView.bounds.width - 20)/2,
                      height: (232 > collectionView.bounds.height/3) ? 232 : (collectionView.bounds.height/3))
    }
}

extension VegetableCollectionView: VegetableCollectionViewCellDelegate {
    func handleStatusButton(vegetableID: UUID?) {
        delegate?.handleStatusButton(vegetableID: vegetableID)
    }
    
    func handleVegetableButton(vegetableID: UUID?) {
        delegate?.handleVegetableButton(vegetableID: vegetableID)
    }
}


