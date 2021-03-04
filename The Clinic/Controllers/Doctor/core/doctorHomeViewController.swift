//
//  doctorHomeViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/26/21.
//

import UIKit
import SideMenu
import FirebaseAuth


class doctorHomeViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var data_picker: UIDatePicker!
    
    @IBOutlet weak var reserve_collectionView: UICollectionView!
    @IBOutlet weak var reserve_tableView: UITableView!
    
    private var SideMenu:SideMenuNavigationController?
    
    var CurrentDoctorreservationsArray = [Reservation]() {
        didSet {
            DispatchQueue.main.async {
                print("dkhal fl did set")
                self.reserve_collectionView.delegate = self
                self.reserve_collectionView.dataSource = self
                self.reserve_collectionView.reloadData()
                
            }
           
        }
    }
    var UserReservationsForCurrentUser = [Reservation]() {
        didSet {
            DispatchQueue.main.async {
                print("dkhal f tableview did set")
                self.filterUserReservations()
                
            }
        }
    }
    var filterdUserReservations = [Reservation]() {
        didSet {
            DispatchQueue.main.async {
                print("dakhal fl filter did set")
                self.reserve_tableView.delegate = self
                self.reserve_tableView.dataSource = self
                self.reserve_tableView.reloadData()
            }
        }
    }
    
    private let noReservationsLabel:UILabel = {
       let label = UILabel ()
        label.text = "No Reservations! .. add One to get patients ."
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.isHidden = true
        return label
    }()
    private let noUsersReservationsLabel:UILabel = {
       let label = UILabel ()
        label.text = "No patient reservations on this day."
        label.textAlignment = .center
        label.textColor = UIColor(named: "clinic")
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.isHidden = true
        return label
    }()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("didloaaaaaaaadd")
        title = "Your Reservations Intervals"
        //self.navigationController?.navigationBar.prefersLargeTitles = true
        data_picker.minimumDate = Date()
        reserve_tableView.register(UINib(nibName: "userReservationForDoctorTableViewCell", bundle: .main), forCellReuseIdentifier: "userReservationForDoctorTableViewCell")
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh_func), for: .valueChanged)
        reserve_tableView.addSubview(refreshControl)
        
        view.addSubview(noReservationsLabel)
        view.addSubview(noUsersReservationsLabel)
        delecationAndRegister()
        adjustSideMenu()
        getCurrentDoctorReservations()
        getUserReservationsForCurrentDoctor()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noUsersReservationsLabel.frame = view.bounds
        noReservationsLabel.frame = CGRect(x: reserve_collectionView.bounds.minX, y: reserve_collectionView.bounds.maxY-25, width: reserve_collectionView.bounds.width, height: reserve_collectionView.bounds.height)
        //noReservationsLabel.bounds = reserve_collectionView.bounds
    }
    
    //MARK: - functions
    @objc func refresh_func () {
        self.viewDidLoad()
        refreshControl.endRefreshing()
    }


    func filterUserReservations () {
        filterdUserReservations.removeAll()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd"
        let date = data_picker.date
        for reservation in UserReservationsForCurrentUser {
            if reservation.date == formatter.string(from: date) {
                filterdUserReservations.append(reservation)
            }
        }
        if filterdUserReservations.count > 0 {
            noUsersReservationsLabel.isHidden = true
        } else {
            noUsersReservationsLabel.isHidden = false
        }
    }
    func getUserReservationsForCurrentDoctor() {
        databaseManager.shared.getAllUsersReservationsForCurrentDoctor { (result) in
            self.UserReservationsForCurrentUser.removeAll()
            switch result {
            case .success(let resArr) :
                self.UserReservationsForCurrentUser = resArr
                return
            case .failure(_) :
                return
            }
        }
    }
    func getCurrentDoctorReservations() {
        databaseManager.shared.getCurrentDoctorReservations { (result) in
            switch result {
            case .success(let resArr) :
                self.CurrentDoctorreservationsArray = resArr
                self.noReservationsLabel.isHidden = true
                print("current reservations : \(self.CurrentDoctorreservationsArray)")
                return
            case .failure(_) :
                self.noReservationsLabel.isHidden = false
                return
            }
        }
    }
    
    func adjustSideMenu() {
        //SideMenu
        let menuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "doctorMuneViewController") as! doctorMuneViewController
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
        reserve_collectionView.delegate = self
        reserve_collectionView.dataSource = self
        reserve_collectionView.register(UINib(nibName: "reservationCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "reservationCollectionViewCell")
        //table_view.register(UINib(nibName: "DoctorTableViewCell", bundle: .main), forCellReuseIdentifier: "DoctorTableViewCell")
    }
    //MARK: - actions
    
    @IBAction func date_picker_value_changed(_ sender: UIDatePicker) {
        filterUserReservations()
    }
    
    @IBAction func Add_reserve_time_btn_pressed(_ sender: UIBarButtonItem) {
        print("add reservation")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addReservationVC = storyboard.instantiateViewController(identifier: "addReservationViewController") as? addReservationViewController
        addReservationVC?.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            //self.present(addReservationVC!, animated: true, completion: nil)
            self.navigationController?.pushViewController(addReservationVC!, animated: true)
        }
    }
    
    @IBAction func side_menu_btn_pressed(_ sender: UIBarButtonItem) {
        present(SideMenu!, animated: true, completion: nil)
    }
}


//MARK: - collectionview functions
extension doctorHomeViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CurrentDoctorreservationsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = CurrentDoctorreservationsArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reservationCollectionViewCell", for: indexPath) as! reservationCollectionViewCell
        cell.configure(reservationModel: model)
        cell.reserve_view.isHidden = true
        return cell
    }
    
    
}

//MARK: - sideMenu delegation extension
extension doctorHomeViewController:DoctorMenuViewControllerDelegate {
    func EditProfileuttonPressed() {
        print("edit profile pressed")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let EditProfileVC = storyBoard.instantiateViewController(identifier: "EditProfileViewController") as! EditProfileViewController
        EditProfileVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.SideMenu?.dismiss(animated: true, completion: nil)
            self.navigationController?.pushViewController(EditProfileVC, animated: true)
        }

    }
    
    func ProfileButtonPressed() {
        print("profile btn pressed")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let ProfileVC = storyBoard.instantiateViewController(identifier: "profileViewController") as! profileViewController
        ProfileVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.SideMenu?.dismiss(animated: true, completion: nil)
            self.navigationController?.pushViewController(ProfileVC, animated: true)
        }
        
    }
    
    func SettingButtonPressed() {
        
    }
    
    func logoutButtonPressed() {
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
    
    func privacyButtenPressed() {
        
    }
    
    
}

//MARK: - tableview functions
extension doctorHomeViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterdUserReservations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "userReservationForDoctorTableViewCell", for: indexPath) as! userReservationForDoctorTableViewCell
        let model = filterdUserReservations[indexPath.row]
        cell.configure(reservationModel: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136
    }
    
}
