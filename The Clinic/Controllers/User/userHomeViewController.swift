//
//  userHomeViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/26/21.
//

import UIKit
import SideMenu

class userHomeViewController: UIViewController, UINavigationControllerDelegate {

    var refreshControl = UIRefreshControl()
    var Specialties = [specialty]()
    var doctorFetch = false
    @IBOutlet weak var collection_view: UICollectionView!
    
    @IBOutlet weak var table_view: UITableView!
    
    private var SideMenu:SideMenuNavigationController?
    
    var allDoctors = [Doctor](){
        didSet {
            filterChoosenDoctors()
        }
    }
    var chosenDoctorsArray = [Doctor](){
        didSet {
            table_view.delegate = self
            table_view.dataSource = self
            DispatchQueue.main.async {
                self.table_view.reloadData()
            }
            
        }
    }
    var chosenSpacilty : String? {
        didSet {
            if doctorFetch {
                filterChoosenDoctors()
            }
            else {
            getDoctors()
                doctorFetch = true
            }
        }
    }
    
    private let noDoctorsLabel:UILabel = {
       let label = UILabel ()
        label.text = "No Doctors!"
        label.textAlignment = .center
        label.textColor = UIColor(named: "clinic")
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("userView")
        let chosen = chosenSpacilty
        chosenSpacilty = chosen
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh_func), for: .valueChanged)
        table_view.addSubview(refreshControl)
        view.addSubview(noDoctorsLabel)
        adjustSideMenu()
        delecationAndRegister()
        adjustSpecialtiesArray()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noDoctorsLabel.frame = view.bounds
    }
    //MARK: - functions
    @objc func refresh_func () {
        doctorFetch = false
        self.viewDidLoad()
        refreshControl.endRefreshing()
    }
    func getDoctors() {
        databaseManager.shared.getAllDoctors { (result) in
            switch result {
            case .success(let doctors) :
                self.allDoctors = doctors
                return
            case .failure(_) :
                print("no doctors to return.")
                return
            }
        }
    }
    
    func filterChoosenDoctors () {
        chosenDoctorsArray.removeAll()
        noDoctorsLabel.isHidden = false
        for doctor in allDoctors {
            if doctor.Specialty == chosenSpacilty {
                chosenDoctorsArray.append(doctor)
                noDoctorsLabel.isHidden = true
            }
        }
    }
    
    func adjustSideMenu() {
        //SideMenu
        let menuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "UserSideMenuViewController") as! UserSideMenuViewController
        menuVC.delegate = self
        SideMenu = SideMenuNavigationController(rootViewController: menuVC)
        SideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = SideMenu
        SideMenu?.menuWidth = 300
        SideMenu?.delegate = self
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        //-------------------------
    }
    
    
    func delecationAndRegister()  {
        collection_view.delegate = self
        collection_view.dataSource = self
        collection_view.register(UINib(nibName: "SpecialtyCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "SpecialtyCollectionViewCell")
        table_view.register(UINib(nibName: "DoctorTableViewCell", bundle: .main), forCellReuseIdentifier: "DoctorTableViewCell")
    }
    
    private func adjustSpecialtiesArray () {
        Specialties.append(specialty(name: "Colon", choosen: false, image: UIImage(named: "colon")!))
        Specialties.append(specialty(name: "Heart disease", choosen: false, image: UIImage(named: "alb")!))
        Specialties.append(specialty(name: "Gastroenterology", choosen: false, image: UIImage(named: "gastrointestinal")!))
        Specialties.append(specialty(name: "Dermatologists", choosen: false, image: UIImage(named: "tagmel")!))
        Specialties.append(specialty(name: "Emergency Medicine", choosen: false, image: UIImage(named: "emergencyCare")!))
        Specialties.append(specialty(name: "hematology", choosen: false, image: UIImage(named: "blood")!))
        Specialties.append(specialty(name: "Infectious", choosen: false, image: UIImage(named: "virus")!))
        Specialties.append(specialty(name: "Nephrologists", choosen: false, image: UIImage(named: "physician")!))
        Specialties.append(specialty(name: "Gynecology", choosen: false, image: UIImage(named: "baby")!))
        Specialties.append(specialty(name: "Otolaryngology", choosen: false, image: UIImage(named: "earNose")!))
        Specialties.append(specialty(name: "Pediatrici", choosen: false, image: UIImage(named: "atfal")!))
        Specialties.append(specialty(name: "plastic surgeon", choosen: false, image: UIImage(named: "tagmel")!))
    }
    
    //MARK: - actions
    @IBAction func side_menu_btn_pressed(_ sender: UIBarButtonItem) {
        present(SideMenu!, animated: true, completion: nil)
    }
    
}

//MARK: - collection views functions

extension userHomeViewController : UICollectionViewDataSource , UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Specialties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = Specialties[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpecialtyCollectionViewCell", for: indexPath) as! SpecialtyCollectionViewCell
        cell.Configure(model: model)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = Specialties[indexPath.row]
        chosenSpacilty = model.name
    }
    
}

//MARK: - tableview functions

extension userHomeViewController : UITableViewDelegate , UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chosenDoctorsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = chosenDoctorsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorTableViewCell", for: indexPath) as! DoctorTableViewCell
        cell.configure(model: model)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = chosenDoctorsArray[indexPath.row]
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let DoctorVC = storyBoard.instantiateViewController(identifier: "doctorViewController") as! doctorViewController
        DoctorVC.modalPresentationStyle = .fullScreen
        DoctorVC.doctorEmail = model.email
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(DoctorVC, animated: true)
        }
    }
    

}

//MARK: - side menu delegation function
extension userHomeViewController:userSideMenuDelegation {
    
    func reservationBtnPressed() {
        print("reservations")
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let resrvationsVC = storyBoard.instantiateViewController(identifier: "reservationsViewController") as! reservationsViewController
        
        resrvationsVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.SideMenu?.dismiss(animated: true, completion: nil)
            self.navigationController?.pushViewController(resrvationsVC, animated: true)
        }
    }
    
    func logoutBtnPressed() {
        
        print("logged out")
        let alert = UIAlertController(title: "",
                                      message:"Are you sure to logout?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancle",
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (UIAlertAction) in
            
            authManager.shared.logOut { (secceed) in
                if secceed {
                    UserDefaults.standard.set(nil, forKey: "email")
                    UserDefaults.standard.setValue(nil, forKey: "type")

                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let LoginVC = storyBoard.instantiateViewController(identifier: "loginViewController") as! loginViewController
                    let mavigationControllerr = UINavigationController(rootViewController: LoginVC)
                    mavigationControllerr.modalPresentationStyle = .fullScreen
                    mavigationControllerr.navigationBar.tintColor = .white
                    mavigationControllerr.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                    mavigationControllerr.navigationBar.barTintColor = UIColor(named: "clinic")
                    DispatchQueue.main.async {
                        self.present(mavigationControllerr, animated: false, completion: nil)
                    }                }
                else {
                    
                }
            }

        }))
        SideMenu?.dismiss(animated: true, completion: nil)
        present(alert, animated: true, completion: nil)
    }
    
    
}
