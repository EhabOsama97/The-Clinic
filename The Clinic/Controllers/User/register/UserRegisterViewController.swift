//
//  UserRegisterViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/25/21.
//

import UIKit
import JGProgressHUD

class UserRegisterViewController: UIViewController {

    let spinner = JGProgressHUD(style: .dark)
    @IBOutlet weak var password_txtField: UITextField!
    @IBOutlet weak var email_txtField: UITextField!
    @IBOutlet weak var firstName_txtField: UITextField!
    
    @IBOutlet weak var lastName_txtField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        password_txtField.delegate = self
        password_txtField.textContentType = .oneTimeCode
        firstName_txtField.layer.cornerRadius = 20
        lastName_txtField.layer.cornerRadius = 20
        email_txtField.layer.cornerRadius = 20
        password_txtField.layer.cornerRadius = 20
    }
    
    @IBAction func register_btn_Pressed(_ sender: UIButton) {
        
        guard let firstName = firstName_txtField.text, !firstName.isEmpty,
              let lastName = lastName_txtField.text , !lastName.isEmpty,
              let email = email_txtField.text, !email.isEmpty,
              let password = password_txtField.text , !password.isEmpty, password.count >= 8 else {
            alertUserLoginError(msg: "Please enter all information to create a new account.")
            return
        }
        spinner.show(in: view)
        let userModel = User(firstName: firstName, lastName: lastName, email: email)
        authManager.shared.registerUser(email: email, password: password) { (result) in
            if result {
                
                databaseManager.shared.SaveNewUser(model: userModel) { (result) in
                    if result {
                        print("user saved")
                        // dismiss
                        databaseManager.shared.SaveDoctorOrUser(email: email.SafeDB(), Type: "user")
                        self.spinner.dismiss()
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        
                    }
                }
                
            } else {
                self.spinner.dismiss()
                self.alertUserLoginError(msg: "Email exists")
            }
        }
        
    }
    
    
    func alertUserLoginError(msg :String) {
        let alert = UIAlertController(title: "",
                                      message: msg,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }

}


extension UserRegisterViewController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == self.password_txtField
            && !self.password_txtField.isSecureTextEntry) {
            self.password_txtField.isSecureTextEntry = true
        }
        
        return true
    }
    
}
