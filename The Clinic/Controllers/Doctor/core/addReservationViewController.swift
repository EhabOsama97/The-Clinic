//
//  addReservationViewController.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/28/21.
//

import UIKit

class addReservationViewController: UIViewController {

    @IBOutlet weak var date_picker: UIDatePicker!
    @IBOutlet weak var range_datePicker: UIDatePicker!
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Make New Reservation"
        formatter.dateFormat = "yyy-MM-dd HH:mm"
        //navigationController?.navigationBar.prefersLargeTitles = true
          
        adjustDatePicker()
    }
    
    //MARK: - functions
    func adjustDatePicker () {
        date_picker.layer.cornerRadius = 20
        range_datePicker.layer.cornerRadius = 20
        let calender = Calendar(identifier: .gregorian)
        let currentDate = Date()
        var components = DateComponents()
        components.month = 12
        components.year = 1
        components.calendar = calender
        let maxDate = calender.date(byAdding: components, to: currentDate)!
        date_picker.minimumDate = currentDate
        date_picker.maximumDate = maxDate
        
        //range_datePicker.minimumDate = currentDate
    }
    
    //MARK: - actions

    @IBAction func save_btn_pressed(_ sender: UIButton) {
        let fromDate = date_picker.date
        let rangeTime = range_datePicker.countDownDuration
        
        formatter.dateFormat = "yyy-MM-dd"
        let date = formatter.string(from: fromDate)
        
        formatter.dateFormat = "HH:mm"
        let from = formatter.string(from: fromDate)
        
        let to = formatter.string(from: fromDate+rangeTime)
        
        formatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        let doctorEmail = UserDefaults.standard.value(forKey: "email") as! String
        let reservationId = "\(doctorEmail)_\(formatter.string(from: Date()))"

        let reservationModel = Reservation(id: reservationId, doctorEmail: doctorEmail, doctorName: "no name", date: date, from: from, to: to, username: "no name")
        databaseManager.shared.saveDoctorReservation(reservatinModel: reservationModel) { (result) in
            if result {
                print("reservation done")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("error in reservation")
            }
        }
    }
    
}
