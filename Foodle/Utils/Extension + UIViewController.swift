//
//  Extension + UIViewController.swift
//  Foodle
//
//  Created by Anton Vlezko on 11.08.2021.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showNotification(title: String, message: String? = nil, textField: Bool? = nil, textFieldPlaceholder: String? = nil, textFieldActionText: String? = nil, defaultAction: Bool? = nil, defaultActionText: String? = nil, rejectAction: Bool? = nil, rejectActionText: String? = nil, completion: @escaping(NotificationConfiguration, String?) -> Void) {
        var textInput: String?
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        if textField == true {
            alert.addTextField { (textField) in
                textField.placeholder = textFieldPlaceholder
            }
            alert.addAction(UIAlertAction(title: textFieldActionText, style: .default, handler: { (_) in
                let textField = alert.textFields![0] // Force unwrapping because we know it exists.
                alert.dismiss(animated: true) {
                    print("Text field: \(String(describing: textField.text))")
                    textInput = textField.text?.lowercased()
                    completion(.textField, textInput)
                }
            }))
        }
        if defaultAction == true {
            alert.addAction(UIAlertAction(title: defaultActionText, style: .default, handler: { (_) in
                alert.dismiss(animated: true)
                completion(.defaultAction, textInput)
            }))
        }
        if rejectAction == true {
            alert.addAction(UIAlertAction(title: rejectActionText, style: .destructive, handler: { (_) in
                alert.dismiss(animated: true)
                completion(.rejectAction, textInput)
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
}
