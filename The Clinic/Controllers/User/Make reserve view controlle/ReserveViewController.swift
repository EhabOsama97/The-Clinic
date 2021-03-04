//
//  ReserveViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/28/21.
//

import UIKit

class ReserveViewController: UIViewController {

    @IBOutlet weak var collection_view: UICollectionView!
    var DoctorModel : Doctor?
    var doctorReservationArray = [Reservation](){
        didSet {
            self.collection_view.dataSource = self
            self.collection_view.delegate = self
            self.collection_view.reloadData()
        }
    }
    private let noDoctorsReservationLabel:UILabel = {
        let label = UILabel ()
         label.text = "Doctor didn't specify any reservation time!"
         label.textAlignment = .center
        label.textColor = .white
         label.font = .systemFont(ofSize: 20, weight: .medium)
         label.isHidden = true
         return label
     }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noDoctorsReservationLabel)
        collection_view.register(UINib(nibName: "reservationCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "reservationCollectionViewCell")
        getDoctorReservations()
        title = "Choose Your Interval : "
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noDoctorsReservationLabel.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //change large title color
        for view in self.navigationController?.navigationBar.subviews ?? [] {
            let subviews = view.subviews
            if subviews.count > 0 , let label = subviews[0] as? UILabel {
                label.textColor = .white
            }
        }
    }
    
    //MARK: - functions
    func getDoctorReservations () {
        databaseManager.shared.getAnotherDoctorReservations(DoctorModel: DoctorModel!) { (result) in
            switch result {
            case .success(let resArr ) :
                self.noDoctorsReservationLabel.isHidden = true
                self.doctorReservationArray = resArr
                return
            case .failure(_) :
                self.noDoctorsReservationLabel.isHidden = false
                return
            }
        }
    }
    

}

//MARK: - collecton view functions

extension ReserveViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doctorReservationArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = doctorReservationArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reservationCollectionViewCell", for: indexPath) as! reservationCollectionViewCell
        cell.configure(reservationModel: model)
        //cell.reserve_view.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = doctorReservationArray[indexPath.row]
        
        let alert = UIAlertController(title: "Make Reservation",
                                      message:"Day : \(model.date) , From : \(model.from) , To : \(model.to)",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Make", style: .default, handler: { (UIAlertAction) in
            //let email = UserDefaults.standard.value(forKey: "email") as! String
            databaseManager.shared.getCurrentUserUsername { (result) in
                switch result {
                case .success(let username) :
                    databaseManager.shared.makeUserReservation(doctorModel: self.DoctorModel!, reservationModel: model, username: username) { (resultt) in
                        if resultt {
                            print("user reservation done")
                        } else {
                            print("can't make user reservation")
                        }
                    }
                    return
                case .failure(_) :
                    return
                }
            }

        }))
        
        alert.addAction(UIAlertAction(title: "Cancle",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
