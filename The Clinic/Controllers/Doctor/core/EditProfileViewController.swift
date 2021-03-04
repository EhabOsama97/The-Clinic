//
//  EditProfileViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/27/21.
//

import UIKit
import SDWebImage

class EditProfileViewController: UIViewController {

    
    @IBOutlet weak var lastName_textField: UITextField!
    @IBOutlet weak var firstName_textField: UITextField!
    @IBOutlet weak var weating_pickerView: UIPickerView!
    @IBOutlet weak var fees_textField: UITextField!
    @IBOutlet weak var address_textField: UITextField!
    @IBOutlet weak var email_textField: UITextField!
    @IBOutlet weak var mobile_textField: UITextField!
    @IBOutlet weak var profile_imageView: UIImageView!
    
    var waitingArray = ["5 mins","10 mins","15 mins","20 mins","25 mins","30 mins","35 mins","40 mins","45 mins","50 mins","55 mins","60 mins"]
    var choosenWaiting = "5 mins"
    
    var imagePicker = UIImagePickerController()
    
    var DoctorModel: Doctor?{
        didSet {
            DispatchQueue.main.async {
                self.fees_textField.text = self.DoctorModel?.fees
                self.email_textField.text = self.DoctorModel?.email
                self.address_textField.text = self.DoctorModel?.address
                self.mobile_textField.text = self.DoctorModel?.mobile
                self.firstName_textField.text = self.DoctorModel?.firstName
                self.lastName_textField.text = self.DoctorModel?.lastName
                self.choosenWaiting = self.DoctorModel!.waiting
                for i in (0 ..< self.waitingArray.count) {
                    if self.waitingArray[i] == self.DoctorModel?.waiting {
                        
                        self.weating_pickerView.selectRow(i, inComponent: 0, animated: true)
                        break
                    }
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        weating_pickerView.delegate = self
        weating_pickerView.dataSource = self
        adjustProfileImageViewAndTextFields()
        getDoctorModel()

    }
    
    //MARK: - actions
    
    
    @IBAction func change_profile_picture(_ sender: UIButton) {
        didTapChangeProfilePicture()
    }
    
    @IBAction func save_btn_pressed(_ sender: UIButton) {
        
        guard let firstName = firstName_textField.text, !firstName.isEmpty,
              let lastName = lastName_textField.text , !lastName.isEmpty,
              let email = email_textField.text, !email.isEmpty,
              let address = address_textField.text , !address.isEmpty ,
              let mobile = mobile_textField.text , !mobile.isEmpty ,
              let fees = fees_textField.text , !fees.isEmpty else {
            alertUserLoginError(msg: "Please enter all information to create a new account.")
            return
        }
        let Currentemail = UserDefaults.standard.value(forKey: "email") as! String
        let fileName = "\(Currentemail.SafeDB())_profile_picture.png"
        let doctor = Doctor(firstName: firstName, lastName: lastName, email: email, mobile: mobile, address: address, Specialty: DoctorModel!.Specialty, fees: fees, waiting: choosenWaiting, rating:DoctorModel!.rating, raters: DoctorModel!.raters, allRating: DoctorModel!.allRating)
        
        databaseManager.shared.updateDoctorProfile(model: doctor) { (result) in
            if result {
                print("profile updated")
                StorageManager.shared.deleteProfilePicture(fileName: fileName) { (result) in
                    if result {
                        print("profile picture deleted")
                        if let image = self.profile_imageView.image , let data = image.pngData() {
                            StorageManager.shared.uploadProfilePicture(data: data, fileName: fileName) { (result) in
                                switch result {
                                case .success(let urlString) :
                                    print("profile picture uploaded : \(urlString)")
                                    return
                                case .failure(_) :
                                    print("error in upload profile picture")
                                    return
                                }
                            }
                        }
                        
                    } else {
                        print("error in deleting profile picture")
                    }
                }
                self.alertUserLoginError(msg: "Profile Updated!")
            } else {
                print("profile not updated")
                
            }
        }
    }
    
    
    //MARK: - functions
    func adjustProfileImageViewAndTextFields() {
        //imageView
        profile_imageView.layer.borderWidth = 3
        profile_imageView.layer.borderColor = UIColor.white.cgColor
        profile_imageView.layer.cornerRadius = profile_imageView.bounds.height / 2.0
        profile_imageView.layer.masksToBounds = false
        profile_imageView.clipsToBounds = true
        profile_imageView.contentMode = .scaleAspectFill
        
        //textFields
        email_textField.layer.cornerRadius = 10
        fees_textField.layer.cornerRadius = 10
        firstName_textField.layer.cornerRadius = 10
        lastName_textField.layer.cornerRadius = 10
        address_textField.layer.cornerRadius = 10
        mobile_textField.layer.cornerRadius = 10
    }
    
    func getDoctorModel() {
        databaseManager.shared.getCurrentDoctor { (result) in
            switch result {
            case .success(let doctor) :
                self.DoctorModel = doctor
                self.getDoctorProfilePicture()
                return
            case .failure(_) :
                return
            }
        }
    }
    func getDoctorProfilePicture () {
        let email = UserDefaults.standard.value(forKey: "email") as! String
        let fileName = "\(email.SafeDB())_profile_picture.png"
        StorageManager.shared.downloadImage(refrence: fileName) { (result) in
            switch result {
            case .success(let url) :
                
                DispatchQueue.main.async {
                    
                    self.profile_imageView.sd_setImage(with: url, completed: nil)
                }
                
                return
            case .failure(_) :
                return
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


extension EditProfileViewController:UIPickerViewDelegate , UIPickerViewDataSource {
    
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

extension EditProfileViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
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
