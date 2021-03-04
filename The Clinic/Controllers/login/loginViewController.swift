//
//  ViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/25/21.
//

import UIKit
import JGProgressHUD

class loginViewController: UIViewController {

    @IBOutlet weak var password_txtField: UITextField!
    @IBOutlet weak var email_txtField: UITextField!
    let spinner = JGProgressHUD(style: .dark)
    override func viewDidLoad() {
        super.viewDidLoad()
        password_txtField.delegate = self
        password_txtField.textContentType = .oneTimeCode
        print("started")
        adjustTextfields()
    }

    private func adjustTextfields() {
        email_txtField.layer.cornerRadius = 25
        password_txtField.layer.cornerRadius = 25
    }

    
    
    
    @IBAction func login_btn_pressed(_ sender: UIButton) {
        guard let email = email_txtField.text , !email.isEmpty ,
           let pass = password_txtField.text , !pass.isEmpty ,
           pass.count >= 8 else {
            alertUserLoginError(msg: "Please enter all information to create a new account.")
            return
        }
        spinner.show(in: view)
        authManager.shared.login(email: email, password: pass) { (result) in
            if result {
                //save email to user defults
                UserDefaults.standard.setValue(email, forKey: "email")
                // open starting
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let StartingVC = storyBoard.instantiateViewController(identifier: "StartingViewController") as! StartingViewController
                StartingVC.modalPresentationStyle = .fullScreen

                DispatchQueue.main.async {
                    self.present(StartingVC, animated: false, completion: nil)
                }
            } else {
                self.alertUserLoginError(msg: "can't log in")
                self.spinner.dismiss()
            }
        }
        
    }
    
    
    
    
    
    @IBAction func register_btn_pressed(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let doctorAction = UIAlertAction(title: "Register as doctor", style: .default) { (action) in
            print("doctor")
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let doctorRegistrationVC = storyBoard.instantiateViewController(identifier: "DoctorRegisterViewController") as! DoctorRegisterViewController
            doctorRegistrationVC.modalPresentationStyle = .fullScreen
            doctorRegistrationVC.title = "Create Account"
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(doctorRegistrationVC, animated: true)
            }
            
            
        }
        
        let userAction = UIAlertAction(title: "Register as user", style: .default) { (action) in
            print("user")
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let UserRegistrationVC = storyBoard.instantiateViewController(identifier: "UserRegisterViewController") as! UserRegisterViewController
            UserRegistrationVC.modalPresentationStyle = .fullScreen
            UserRegistrationVC.title = "Create Account"
            //self.present(UserRegistrationVC, animated: true, completion: nil)
            self.navigationController?.pushViewController(UserRegistrationVC, animated: true)
            print("final user")
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(doctorAction)
        actionSheet.addAction(userAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
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

extension loginViewController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == self.password_txtField
            && !self.password_txtField.isSecureTextEntry) {
            self.password_txtField.isSecureTextEntry = true
        }
        
        return true
    }
    
}
