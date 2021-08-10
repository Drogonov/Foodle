//
//  Extensions.swift
//  Foodle
//
//  Created by Anton Vlezko on 10.08.2021.
//

import UIKit

extension UIImage {
    func systemImage(withSystemName systemName: String) -> UIImage {
        let image = UIImage(systemName: systemName) ?? UIImage(systemName: "questionmark.circle")!
        return image
    }
}
