//
//  UserSideMenuViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/27/21.
//

import UIKit

protocol userSideMenuDelegation {
    func logoutBtnPressed()
    func reservationBtnPressed()
}

class UserSideMenuViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var name_label: UILabel!
    var delegate:userSideMenuDelegation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentUsername()
        backgroundView.layer.cornerRadius = 20
    }
    
    func getCurrentUsername() {
        databaseManager.shared.getCurrentUserUsername { (result) in
            switch result {
            case .success(let username) :
                DispatchQueue.main.async {
                    self.name_label.text = username
                }
                return
            case .failure(_) :
                return
            }
        }
    }

    //MARK: - actions
    @IBAction func reservation_btn_pressed(_ sender: UIButton) {
        delegate?.reservationBtnPressed()
    }
    
    @IBAction func logout_btn_pressed(_ sender: UIButton) {
        delegate?.logoutBtnPressed()
    }
    
}

