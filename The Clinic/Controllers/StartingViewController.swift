//
//  StartingViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/26/21.
//

import UIKit
import FirebaseAuth

class StartingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("didload")
        // Do any additional setup after loading the view.
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("did appear")
//                do {
//                 try Auth.auth().signOut()
//                    } catch {
//                        print("m3rfsh y3ml log out")
//
//                    }
        CheckAuthStatus()
        //checkType()
    }

    private func CheckAuthStatus() {
        // check Auth status
        if Auth.auth().currentUser == nil {
            //Show Sign in
            print("Dkhal fl nillll...............")
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let LoginVC = storyBoard.instantiateViewController(identifier: "loginViewController") as! loginViewController
            //LoginVC.modalPresentationStyle = .fullScreen
            let mavigationControllerr = UINavigationController(rootViewController: LoginVC)
            mavigationControllerr.modalPresentationStyle = .fullScreen
            mavigationControllerr.navigationBar.tintColor = .white
            mavigationControllerr.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            mavigationControllerr.navigationBar.barTintColor = UIColor(named: "clinic")
            DispatchQueue.main.async {
                self.present(mavigationControllerr, animated: false, completion: nil)
            }
        } else {
            checkType()
        }
        
    }
    private func checkType () {
        let email = UserDefaults.standard.value(forKey: "email") as! String
        print("email : \(email.SafeDB())")
        databaseManager.shared.DoctorOrUser(email: (email.SafeDB())) { (result) in
            switch result {
            case .success(let type) :
                if type == "doctor" {
                    //open doctor view
                    UserDefaults.standard.setValue(type, forKey: "type")
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let doctorHomeVC = storyBoard.instantiateViewController(identifier: "doctorHomeViewController") as! doctorHomeViewController
                    let mavigationControllerr = UINavigationController(rootViewController: doctorHomeVC)
                    mavigationControllerr.modalPresentationStyle = .fullScreen
                    mavigationControllerr.navigationBar.tintColor = .white
                    mavigationControllerr.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                    mavigationControllerr.navigationBar.barTintColor = UIColor(named: "clinic")
                    DispatchQueue.main.async {
                        self.present(mavigationControllerr, animated: false, completion: nil)
                    }
                    
                }
                else {
                    //open user view
                    UserDefaults.standard.setValue(type, forKey: "type")
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let userHomeVC = storyBoard.instantiateViewController(identifier: "userHomeViewController") as! userHomeViewController
                    let mavigationControllerr = UINavigationController(rootViewController: userHomeVC)
                    mavigationControllerr.modalPresentationStyle = .fullScreen
                    mavigationControllerr.navigationBar.tintColor = .white
                    mavigationControllerr.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                    mavigationControllerr.navigationBar.barTintColor = UIColor(named: "clinic")
                    DispatchQueue.main.async {
                        self.present(mavigationControllerr, animated: false, completion: nil)
                    }
                }
                return
            case .failure(let error) :
                print("error in getting type \(error)")
            }
        }
    }

}
