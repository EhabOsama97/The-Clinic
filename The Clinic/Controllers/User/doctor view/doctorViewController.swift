//
//  doctorViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/28/21.
//

import UIKit

class doctorViewController: UIViewController {



    @IBOutlet weak var Doctor_rate_label: UILabel!
    @IBOutlet weak var reserve_btn: UIButton!
    @IBOutlet weak var rate_slider: RateSlider!
    @IBOutlet weak var rate_textField: UITextField!
    @IBOutlet weak var profile_imageView: UIImageView!
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var rate_label: UILabel!
    @IBOutlet weak var background_view: UIView!
    @IBOutlet weak var doctorName_label: UILabel!
    @IBOutlet weak var specialty_label: UILabel!
    
    var doctorEmail:String? {
        didSet {
          
        }
    }
    
    var RatesArray = [Rate](){
        didSet {
            self.table_view.reloadData()
        }
    }
    
    var DoctorInformationsArray = [String]() {
        didSet {
           getDoctorRates()
        }
    }
        
    var doctorModel:Doctor? {
        didSet {
            DoctorInformationsArray.removeAll()
            let address = "Adress : \(doctorModel!.address)"
            let Mobile = "Mobile : \(doctorModel!.mobile)"
            let fees = "Fees : \(doctorModel!.fees)"
            let waiting = "Waiting : \(doctorModel!.waiting)"
            DoctorInformationsArray.append(address)
            DoctorInformationsArray.append(Mobile)
            DoctorInformationsArray.append(waiting)
            DoctorInformationsArray.append(fees)
            
            adjustProfilePictureAndView()
            adjustLabels()
            adjustTableView()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDoctorModel()
  
    }
    
    //MARK: - functions
    func getDoctorModel () {
        databaseManager.shared.getDoctorWithMail(doctorMail: doctorEmail!) { (result) in
            switch result {
            case .success(let Doc) :
                self.doctorModel = Doc
                return
            case .failure(_):
                return
            }
        }
    }
    func adjustProfilePictureAndView () {
        profile_imageView.layer.borderWidth = 3
        profile_imageView.layer.borderColor = UIColor.white.cgColor
        profile_imageView.layer.cornerRadius = profile_imageView.bounds.height / 2.0
        profile_imageView.layer.masksToBounds = false
        profile_imageView.clipsToBounds = true
        profile_imageView.contentMode = .scaleAspectFill
        //reserve btn
        reserve_btn.layer.cornerRadius = 20
        //.......
        let email = doctorEmail?.SafeDB()
        let filename = "\(email!)_profile_picture.png"
        print("filename : \(filename)")
        StorageManager.shared.downloadImage(refrence: filename) { (result) in
            switch result {
            case .success(let url) :
                self.profile_imageView.sd_setImage(with: url, completed: nil)
                return
            case .failure(_) :
                print("cant download profile picture")
                return
            }
        }
    }
    func adjustLabels () {
        doctorName_label.text = "Dr \(doctorModel!.firstName) \(doctorModel!.lastName)"
        specialty_label.text = doctorModel?.Specialty
        rate_label.text = NSString(format: "%.1f", rate_slider.value) as String
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "star.fill")
        let attachmentString = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: doctorModel!.rating + " ", attributes: [:])
        string.append(attachmentString)
        Doctor_rate_label.attributedText = string
    }
    func adjustTableView() {
        table_view.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table_view.register(UINib(nibName: "RatingTableViewCell", bundle: .main), forCellReuseIdentifier: "RatingTableViewCell")
        table_view.delegate = self
        table_view.dataSource = self
        table_view.reloadData()
    }
    
    func getDoctorRates() {
        databaseManager.shared.getDoctorRates(doctorEmail: doctorModel!.email) { (result) in
            switch result {
            case .success(let ratesArr) :
                self.RatesArray = ratesArr
                return
            case .failure(_) :
                return
            }
        }
    }
    
    //MARK: - actions
    
    @IBAction func reserve_btn_pressed(_ sender: UIButton) {
        print("reserve")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let reserveVC = storyboard.instantiateViewController(withIdentifier: "ReserveViewController") as! ReserveViewController
        reserveVC.modalPresentationStyle = .fullScreen
        reserveVC.DoctorModel = doctorModel
        DispatchQueue.main.async {
            //self.present(reserveVC, animated: true, completion: nil)
            self.navigationController?.pushViewController(reserveVC, animated: true)
        }
    }
    
    @IBAction func slider_pressed(_ sender: UISlider) {
        DispatchQueue.main.async {
            self.rate_label.text = NSString(format: "%.1f", self.rate_slider.value) as String
        }
        
    }
    @IBAction func rate_btn_pressed(_ sender: UIButton) {
        databaseManager.shared.getCurrentUserUsername { (result) in
            switch result {
            case .success(let username) :
                let rateModel = Rate(userName: username, text: self.rate_textField.text!, rateNum: NSString(format: "%.1f", self.rate_slider.value) as String)
                databaseManager.shared.makeRate(doctorEmail: self.doctorModel!.email, rateModel: rateModel) { (result) in
                    if result {
                        print("rate Done")
                        
                        //change rate label by new value
                        var rater = Int(self.doctorModel!.raters)
                        rater = rater! + 1
                        var allRating = Float(self.doctorModel!.allRating)
                        //print("all Rating before : \(allRating)")
                        //let currentRate = Float(self.doctorModel!.rating)
                        let newRate = Float(rateModel.rateNum)
                        allRating = allRating! + newRate!
                        let rateValue = allRating! / Float(rater!)
                        //print("Raters : \(rater)")
                        //print("new Rate : \(newRate)")
                        //print("rateValue : \(rateValue)")
                        self.doctorModel?.raters = String(rater!)
                        self.doctorModel?.rating = NSString(format: "%.1f", rateValue) as String
                        self.doctorModel?.allRating = NSString(format: "%.1f", allRating!) as String
                        DispatchQueue.main.async {
                            self.rate_textField.text = ""
                            let attachment = NSTextAttachment()
                            attachment.image = UIImage(systemName: "star.fill")
                            let attachmentString = NSAttributedString(attachment: attachment)
                            let string = NSMutableAttributedString(string: NSString(format: "%.1f", rateValue) as String + " ", attributes: [:])
                            string.append(attachmentString)
                            self.Doctor_rate_label.attributedText = string
                        }
                    
                        //----------------------------
                        self.RatesArray.append(rateModel)
                        self.table_view.reloadData()
                    } else {
                        print("error in making rate")
                    }
                }
                return
            case .failure(_) :
                return
            }
        }
        
        
    }
}

//MARK: - tableViewsFunctions

extension doctorViewController:UITableViewDelegate , UITableViewDataSource {
    
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




