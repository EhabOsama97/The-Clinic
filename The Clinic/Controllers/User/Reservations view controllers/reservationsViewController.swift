//
//  reservationsViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 3/1/21.
//

import UIKit

class reservationsViewController: UIViewController {

    @IBOutlet weak var table_view: UITableView!
    var userReservationsArray = [Reservation]() {
        didSet {
            table_view.delegate = self
            table_view.dataSource = self
            table_view.reloadData()
        }
    }
    private let noUsersReservationsLabel:UILabel = {
       let label = UILabel ()
        label.text = "You don't have Any Reservations."
        label.textAlignment = .center
        label.textColor = UIColor(named: "clinic")
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Your Reservations"
        view.addSubview(noUsersReservationsLabel)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        //change large title color
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        table_view.register(UINib(nibName: "userReservationTableViewCell", bundle: .main), forCellReuseIdentifier: "userReservationTableViewCell")
        getAllUserReservations()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noUsersReservationsLabel.frame = table_view.bounds
    }
    
    func getAllUserReservations () {
        databaseManager.shared.getCurrentUserReservations { (result) in
            switch result {
            case .success(let resARR) :
                self.noUsersReservationsLabel.isHidden = true
                self.userReservationsArray = resARR
                return
            case .failure(_) :
                self.noUsersReservationsLabel.isHidden = false
                return
            }
        }
    }


}

//MARK: - tableview functions
extension reservationsViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userReservationsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = userReservationsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "userReservationTableViewCell", for: indexPath) as! userReservationTableViewCell
        cell.delegate = self
        cell.indexx = indexPath.row
        cell.configure(rservationModel: model)
        return cell
    }
    
}

//MARK: - reservation delegate functions
extension reservationsViewController : userReservationCellDelegate {
    
    func cancelBtnPressed(reservModel: Reservation, index: Int) {
        
        let alert = UIAlertController(title: "",
                                      message:"Delete This Reservation ?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (UIAlertAction) in
            
            
            databaseManager.shared.deleteUserReservation(reservationModel: reservModel) { (result) in
                if result {
                    self.userReservationsArray.remove(at: index)
                    self.table_view.reloadData()
                    print("Succeedd")
                } else {
                    print("failed to delete reservation")
                }
            }
        
        }))
        
        alert.addAction(UIAlertAction(title: "Cancle",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    
}

}
