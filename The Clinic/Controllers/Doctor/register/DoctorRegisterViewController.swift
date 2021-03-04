//
//  DoctorRegisterViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/25/21.
//

import UIKit
import JGProgressHUD

class DoctorRegisterViewController: UIViewController {

    @IBOutlet weak var waiting_pickerView: UIPickerView!
    @IBOutlet weak var fees_textField: UITextField!
    @IBOutlet weak var profile_imageView: UIImageView!
    @IBOutlet weak var firstName_txtField: UITextField!
    @IBOutlet weak var lastName_txtField: UITextField!
    
    @IBOutlet weak var address_txtField: UITextField!
    @IBOutlet weak var email_txtField: UITextField!
    @IBOutlet weak var password_txtField: UITextField!
    @IBOutlet weak var Mobile_txtField: UITextField!
    var imagePicker = UIImagePickerController()
    static var choosenSpecialty:String?
    var spinner = JGProgressHUD(style: .dark)
    
    var waitingArray = ["5 mins","10 mins","15 mins","20 mins","25 mins","30 mins","35 mins","40 mins","45 mins","50 mins","55 mins","60 mins"]
    var choosenWaiting = "5 mins"
    override func viewDidLoad() {
        super.viewDidLoad()

        password_txtField.delegate = self
        password_txtField.textContentType = .oneTimeCode
        delegation()
        // Do any additional setup after loading the view.
        adjustProfileImageView()
        adjustTextFields()
        
    }
    
    //MARK: - functions
    private func delegation() {
        imagePicker.delegate = self
        waiting_pickerView.delegate = self
    }
    private func adjustProfileImageView() {
        profile_imageView.layer.borderWidth = 5
        profile_imageView.layer.masksToBounds = false
        profile_imageView.layer.borderColor = UIColor.white.cgColor
        profile_imageView.layer.cornerRadius = 20
        profile_imageView.clipsToBounds = true
    }
    private func adjustTextFields() {
        firstName_txtField.layer.cornerRadius = 20
        lastName_txtField.layer.cornerRadius = 20
        email_txtField.layer.cornerRadius = 20
        password_txtField.layer.cornerRadius = 20
        Mobile_txtField.layer.cornerRadius = 20
        address_txtField.layer.cornerRadius = 20
        fees_textField.layer.cornerRadius = 20
    }

    //MARK: - actions
    
    @IBAction func choose_btn_pressed(_ sender: UIButton) {
        didTapChangeProfilePicture()
    }
    
    @IBAction func choose_medical_specialty_pressed(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let chooseSpecialtyVC = storyBoard.instantiateViewController(identifier: "ChooseSpecialtyViewController") as! ChooseSpecialtyViewController
        chooseSpecialtyVC.modalPresentationStyle = .fullScreen
        chooseSpecialtyVC.title = "Choose Medical Specialty"
        self.navigationController?.pushViewController(chooseSpecialtyVC, animated: true)
        //present(chooseSpecialtyVC, animated: true )
        print("pushed")
    }
    
    @IBAction func register_btn_pressed(_ sender: UIButton) {
        
        guard let firstName = firstName_txtField.text, !firstName.isEmpty,
              let lastName = lastName_txtField.text , !lastName.isEmpty,
              let email = email_txtField.text, !email.isEmpty,
              let address = address_txtField.text , !address.isEmpty ,
              let mobile = Mobile_txtField.text , !mobile.isEmpty ,
              let fees = fees_textField.text , !fees.isEmpty,
              let password = password_txtField.text , !password.isEmpty, password.count >= 8 else {
            alertUserLoginError(msg: "Please enter all information to create a new account.")
            return
        }
        
        if DoctorRegisterViewController.choosenSpecialty != nil {
            spinner.show(in: view)
            
            let doctorModel = Doctor(firstName: firstName, lastName: lastName, email: email, mobile: mobile, address: address, Specialty: DoctorRegisterViewController.choosenSpecialty!,fees: fees, waiting: choosenWaiting, rating: "0", raters: "0", allRating: "0")
            
            authManager.shared.registerUser(email: email, password: password) { (result) in
                if result {
                    print("doctor user created")
                    databaseManager.shared.SaveDoctorUser(model: doctorModel) { (result) in
                        if result {
                            print("doctor saved in view")
                            databaseManager.shared.SaveDoctorOrUser(email: email.SafeDB(), Type: "doctor")
                            self.spinner.dismiss()
                            if let image = self.profile_imageView.image , let data = image.pngData() {
                                let filename = "\(email.SafeDB())_profile_picture.png"
                                StorageManager.shared.uploadProfilePicture(data: data, fileName: filename) { (result) in
                                    switch result {
                                    case .success(let urlString) :
                                        print("profile image uploaded : \(urlString)")
                                        return
                                    case .failure(_) :
                                        print("error in uploading profile picture in view controller")
                                        return
                                    }
                                }
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                        else {
                            print("cant save doctor in view")
                        }
                    }

                } else {
                    print("cant create doctor user")
                }
            }
            
        } else {
            alertUserLoginError(msg: "Please Choose Your Medical Specality .")
            return
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



extension DoctorRegisterViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    private func didTapChangeProfilePicture () {
        
        
        let alertController = UIAlertController(title: "Profile Picture", message: "Choose Profile Picture", preferredStyle: .alert)
        let TakePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { (UIAlertAction) in
            
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let ChooseFromLibraryAction = UIAlertAction(title: "Choose from Library", style: .default) { (UIAlertAction) in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }

        let CancleAction = UIAlertAction(title: "Cancle", style: .default) { (UIAlertAction) in
        }
        
        alertController.addAction(TakePhotoAction)
        alertController.addAction(ChooseFromLibraryAction)
        alertController.addAction(CancleAction)
        present(alertController, animated: true, completion: nil)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("infoooo ..... \(info)")
        let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.profile_imageView.image = image
            }
        }

        dismiss(animated: true, completion: nil)
    }
    
}

extension DoctorRegisterViewController:UIPickerViewDelegate , UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return waitingArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return waitingArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        choosenWaiting = waitingArray[row]
    }
    
    
}

extension DoctorRegisterViewController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == self.password_txtField
            && !self.password_txtField.isSecureTextEntry) {
            self.password_txtField.isSecureTextEntry = true
        }
        
        return true
    }
    
}
