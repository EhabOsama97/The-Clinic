//
//  doctorMuneViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/27/21.
//

import UIKit

protocol DoctorMenuViewControllerDelegate {
    func ProfileButtonPressed()
    func SettingButtonPressed()
    func EditProfileuttonPressed()
    func logoutButtonPressed()
    func privacyButtenPressed()
}

class doctorMuneViewController: UIViewController {

    @IBOutlet weak var disease_label: UILabel!
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var image_view: UIImageView!
    @IBOutlet weak var bacground_view: UIView!
    var delegate:DoctorMenuViewControllerDelegate?
    var DoctorModel:Doctor? {
        didSet {
            DispatchQueue.main.async {
                self.disease_label.text = self.DoctorModel?.Specialty
                self.name_label.text = "Dr \(self.DoctorModel!.firstName) \(self.DoctorModel!.lastName)"
            }
               
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        adjustProfilePicture()
        getDoctorModel()
        
    }
    func adjustProfilePicture () {
        //adjust photo
        image_view.layer.borderWidth = 3
        image_view.layer.borderColor = UIColor.white.cgColor
        image_view.layer.cornerRadius = image_view.bounds.height / 2.0
        image_view.layer.masksToBounds = false
        image_view.clipsToBounds = true
        image_view.contentMode = .scaleAspectFill
        
        //adjust view
        bacground_view.layer.cornerRadius = 20
        
    }
    
    //MARK: - functions
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
                    
                    self.image_view.sd_setImage(with: url, completed: nil)
                }
                
                return
            case .failure(_) :
                return
            }
        }
        
    }
    
    
    //MARK: - actions
    @IBAction func logOut_btn_pressed(_ sender: UIButton) {
        delegate?.logoutButtonPressed()
    }
    
    @IBAction func profile_btn_pressed(_ sender: UIButton) {
        print("delegate.profile")
        delegate?.ProfileButtonPressed()
    }
    @IBAction func editProfile_btn_pressed(_ sender: UIButton) {
        print("delegate.editprofile")
        delegate?.EditProfileuttonPressed()
    }
    @IBAction func refresh_geasture_tapped(_ sender: UITapGestureRecognizer) {
        self.viewDidLoad()
    }
    
}
