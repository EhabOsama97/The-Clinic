//
//  profileViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/27/21.
//

import UIKit
import SDWebImage

class profileViewController: UIViewController {

    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var background_view: UIView!
    @IBOutlet weak var rating_label: UILabel!
    @IBOutlet weak var disease_label: UILabel!
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var profile_imageView: UIImageView!
    
    var DoctorInformationsArray = [String](){
        didSet {
            adjustTableView()
            
        }
    }
    var RatesArray = [Rate](){
        didSet {
            self.table_view.reloadData()
        }
    }
    
    var DoctorModel:Doctor? {
        didSet {
            DoctorInformationsArray.removeAll()
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "star.fill")
            let attachmentString = NSAttributedString(attachment: attachment)
            let string = NSMutableAttributedString(string: DoctorModel!.rating + " ", attributes: [:])
            string.append(attachmentString)
            rating_label.attributedText = string
            name_label.text = "Dr \(DoctorModel!.firstName) \(DoctorModel!.lastName)"
            disease_label.text = DoctorModel?.Specialty
            let address = "Adress : \(DoctorModel!.address)"
            let Mobile = "Mobile : \(DoctorModel!.mobile)"
            let fees = "Fees : \(DoctorModel!.fees)"
            let waiting = "Waiting : \(DoctorModel!.waiting)"
            DoctorInformationsArray.append(address)
            DoctorInformationsArray.append(Mobile)
            DoctorInformationsArray.append(waiting)
            DoctorInformationsArray.append(fees)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh_func), for: .valueChanged)
        table_view.addSubview(refreshControl)
        self.adjustProfileImageView()
        getDoctorModel()
    }
    
    @objc func refresh_func () {
        self.viewDidLoad()
        refreshControl.endRefreshing()
    }
    
    func adjustTableView() {
        table_view.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table_view.register(UINib(nibName: "RatingTableViewCell", bundle: .main), forCellReuseIdentifier: "RatingTableViewCell")
        table_view.delegate = self
        table_view.dataSource = self
        table_view.reloadData()
        
    }
    func adjustProfileImageView() {
        profile_imageView.layer.borderWidth = 3
        profile_imageView.layer.borderColor = UIColor.white.cgColor
        profile_imageView.layer.cornerRadius = profile_imageView.bounds.height / 2.0
        profile_imageView.layer.masksToBounds = false
        profile_imageView.clipsToBounds = true
        profile_imageView.contentMode = .scaleAspectFill
    }
    func getDoctorModel() {
        databaseManager.shared.getCurrentDoctor { (result) in
            switch result {
            case .success(let doctor) :
                self.DoctorModel = doctor
                self.getRates()
                self.getDoctorProfilePicture()
                return
            case .failure(_) :
                return
            }
        }
    }
    func getRates () {
        let email = UserDefaults.standard.value(forKey: "email") as! String
        databaseManager.shared.getDoctorRates(doctorEmail: email.SafeDB()) { (result) in
            switch result {
            case .success(let ratesArr) :
                self.RatesArray = ratesArr
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

}

//MARK: - tableview functions
extension profileViewController:UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Informations"
        } else if section == 1 {
            return "Rates"
        }
        return ""
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return DoctorInformationsArray.count
        } else if section == 1 {
            if RatesArray.count > 0 {
                return RatesArray.count
            } else {
                return 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = DoctorInformationsArray[indexPath.row]
            return cell
        }
        else if indexPath.section == 1 {
            let model = RatesArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "RatingTableViewCell", for: indexPath) as! RatingTableViewCell
            cell.configure(rateModel: model)
            return cell
        }
       
        return UITableViewCell()
    }
    
    
}
