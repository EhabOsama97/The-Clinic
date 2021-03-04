//
//  ChooseSpecialtyViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/26/21.
//

import UIKit

struct specialty {
    let name:String
    var choosen:Bool
    var image:UIImage
}
class ChooseSpecialtyViewController: UIViewController {

    var Specialties = [specialty]()
    var choosenSpecialty:specialty?
    @IBOutlet weak var table_View: UITableView!
    
    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        adjustSpecialtiesArray()
        table_View.delegate = self
        table_View.dataSource = self
        table_View.register(UINib(nibName: "SpecialtycellTableViewCell", bundle: .main), forCellReuseIdentifier: "SpecialtycellTableViewCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(Save))
    }

    //MARK: - functions
    @objc func Save () {
        if let choosen = choosenSpecialty {
            DoctorRegisterViewController.choosenSpecialty = choosen.name
            self.navigationController?.popViewController(animated: true)
        } else {
            alertUserLoginError(msg: "No Choosen Specialty !")
        }
        
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

extension ChooseSpecialtyViewController:UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Specialties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = Specialties[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialtycellTableViewCell" , for: indexPath) as! SpecialtycellTableViewCell
        cell.Configure(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        for i in (0..<Specialties.count)  {
            Specialties[i].choosen = false
        }
        Specialties[indexPath.row].choosen = true
        choosenSpecialty = Specialties[indexPath.row]
        tableView.reloadData()
    }
    
}
