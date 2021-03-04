//
//  databaseManager.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/26/21.
//

import Foundation
import FirebaseDatabase

enum DatabaseError:Error {
    case failedUploadingProfileData
    case failedToFetch
}

class databaseManager {
    
    static let shared = databaseManager()
    public var database: DatabaseReference!
    
    init() {
        database = Database.database(url: "https://the-clinic-5294c-default-rtdb.firebaseio.com/").reference()
    }
    
    //MARK: - functions
    
    // get doctor with mail
    public func getDoctorWithMail (doctorMail : String , completion : @escaping (Result<Doctor,Error>)->Void) {
        
        var currentDoctor : Doctor?
        database.child("DoctorsUsers").observeSingleEvent(of: .value) { (doctorsSnapshot) in
            if let doctorsCollections = doctorsSnapshot.value as? [[String:Any]] {
                
                for doctorCollection in doctorsCollections {
                    let email = doctorCollection["email"] as! String
                    if email.SafeDB() == doctorMail.SafeDB() {
                        currentDoctor = Doctor(firstName: doctorCollection["firstName"] as! String, lastName: doctorCollection["lastName"] as! String, email: doctorCollection["email"] as! String, mobile: doctorCollection["mobile"] as! String, address: doctorCollection["address"] as! String, Specialty: doctorCollection["secialty"] as! String, fees: doctorCollection["fees"] as! String, waiting: doctorCollection["waiting"] as! String, rating: doctorCollection["rating"] as! String, raters: doctorCollection["raters"] as! String, allRating: doctorCollection["allRating"] as! String)
                        break
                    }
                }
                print("get  Doctor successfully")
                completion(.success(currentDoctor!))
                return
            } else {
                print("can't get  Doctor ")
                completion(.failure(DatabaseError.failedToFetch))
            }
        }
    }
    //get all user reservations for current user
    public func getAllUsersReservationsForCurrentDoctor(completion : @escaping (Result<[Reservation],Error>)->Void) {
        var ReservationsArray = [Reservation]()
        let email = UserDefaults.standard.value(forKey: "email") as! String
        database.child("userReservationsForDoctor").child(email.SafeDB()).observeSingleEvent(of: .value) { (userReservationsSnapshot) in
            if let userReservationsCollections = userReservationsSnapshot.value as? [[String : Any]] {
                for userReservationCollection in userReservationsCollections {
                    let reserveModel = Reservation(id: userReservationCollection["id"] as! String, doctorEmail: email, doctorName: "No Name", date: userReservationCollection["date"] as! String, from: userReservationCollection["from"] as! String, to: userReservationCollection["to"] as! String, username: userReservationCollection["userName"] as! String)
                    ReservationsArray.append(reserveModel)
                }
                print("get all user reservations for doctor")
                completion(.success(ReservationsArray))
                return
            } else {
                print("mfesh user reservations for doctor")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
        }
    }
    //delete user reservation
    public func deleteUserReservation ( reservationModel :Reservation,completion : @escaping (Bool)->Void) {
        let currentUserEmail = UserDefaults.standard.value(forKey: "email") as! String
        let id = reservationModel.id
        
        database.child("userReservations").child(currentUserEmail.SafeDB()).observeSingleEvent(of: .value) { (userReservationsSnapshot) in
            var index = 0
            if var userReservationCollections = userReservationsSnapshot.value as? [[String : Any]] {
                for i in (0 ..< userReservationCollections.count) {
                    let reservationCollection = userReservationCollections[i]
                    if reservationCollection["id"] as! String == id {
                        index = i
                        break
                    }
                }
                userReservationCollections.remove(at: index)
                self.database.child("userReservations").child(currentUserEmail.SafeDB()).setValue(userReservationCollections) { (error, _) in
                    if error == nil {
                        print("reservation deleted from users")
                        return
                    } else {
                        print("reservation can'tttt deleted from users")
                        return
                    }
                }
              
            } else {
               print("mfesh reservation fl user yms7ha")
            }
        }
        
        database.child("userReservationsForDoctor").child(reservationModel.doctorEmail.SafeDB()).observeSingleEvent(of: .value) { (doctorReservationsSnapshot) in
            var index = 0
            if var doctorReservationsCollections = doctorReservationsSnapshot.value as? [[String:Any]] {
                for i in (0 ..< doctorReservationsCollections.count) {
                    let doctorReservationCollection = doctorReservationsCollections[i]
                    if doctorReservationCollection["id"] as! String == id {
                        index = i
                        break
                    }
                }
                doctorReservationsCollections.remove(at: index)
                self.database.child("userReservationsForDoctor").child(reservationModel.doctorEmail.SafeDB()).setValue(doctorReservationsCollections) { (error, _) in
                    if error == nil {
                        print("reservation deleted from doctor")
                        completion(true)
                        return
                    } else {
                        print("reservation can'tttt deleted from doctor")
                        completion(false)
                        return
                    }
                }
                
            } else {
                print("mfesh reservation fl doctor yms7ha ")
                completion(false)
                return
            }
        }
        
    }
    //get all user reservation
    public func getCurrentUserReservations (completion : @escaping (Result<[Reservation],Error>)->Void) {
        let email = UserDefaults.standard.value(forKey: "email") as! String
        var ReservationsArray = [Reservation]()
        database.child("userReservations").child(email.SafeDB()).observeSingleEvent(of: .value) { (userReservationsSnapshot) in
            if let userReservationsCollections = userReservationsSnapshot.value as? [[String:Any]] {
                for reservationCollection in userReservationsCollections {
                    let reservation = Reservation(id: reservationCollection["id"] as! String, doctorEmail: reservationCollection["DoctorEmail"] as! String, doctorName: reservationCollection["doctorName"] as! String, date: reservationCollection["Date"] as! String, from: reservationCollection["From"] as! String, to: reservationCollection["To"] as! String, username: "no name")
                    ReservationsArray.append(reservation)
                }
                print("get user reservations")
                completion(.success(ReservationsArray))
                return
                
            }
            else {
                print("no user reservations")
                completion(.failure(DatabaseError.failedToFetch))
            }
        }
    }
    //make user reservtion
    public func makeUserReservation (doctorModel : Doctor ,reservationModel:Reservation,username:String , completion : @escaping (Bool)->Void ) {
        //save reservation to user
        let doctorName = "\(doctorModel.firstName) \(doctorModel.lastName)"
        
        let userReservationCollection = ["username" : username,"id" : reservationModel.id ,"doctorName" : doctorName , "DoctorEmail" : doctorModel.email , "Date" : reservationModel.date , "From" : reservationModel.from , "To" : reservationModel.to ]
        
        let email = UserDefaults.standard.value(forKey: "email") as! String
        
        database.child("userReservations").child(email.SafeDB()).observeSingleEvent(of: .value) { (userReservatinsSnapshot) in
            if var userReservationsCollections = userReservatinsSnapshot.value as? [[String:Any]] {
                //append
                userReservationsCollections.append(userReservationCollection)
                self.database.child("userReservations").child(email.SafeDB()).setValue(userReservationsCollections) { (error, _) in
                    if error == nil {
                        print("user reservation saved to user")
                        completion(true)
                        return
                    } else {
                        print("error in append reservation to user")
                        completion(false)
                        return
                    }
                }
            } else {
                // make array
                self.database.child("userReservations").child(email.SafeDB()).setValue([userReservationCollection]) { (error, _) in
                    if error == nil {
                        print("user reservation saved to user")
                        completion(true)
                        return
                    } else {
                        print("error in append reservation to user")
                        completion(false)
                        return
                    }
                }
            }
        }
        let userReservationsForDoctorCollection = ["id":reservationModel.id ,"userName": username , "date" : reservationModel.date , "from" : reservationModel.from , "to" : reservationModel.to]
        //save reservation to doctor
        database.child("userReservationsForDoctor").child(doctorModel.email.SafeDB()).observeSingleEvent(of: .value) { (userReservationSnapshot) in
            if var userReservationCollections = userReservationSnapshot.value as? [[String:Any]] {
                //append
                userReservationCollections.append(userReservationsForDoctorCollection)
                self.database.child("userReservationsForDoctor").child(doctorModel.email.SafeDB()).setValue(userReservationCollections) { (error, _) in
                    if error == nil {
                        print("saved append to doctor collection")
                        completion(true)
                        return
                    } else {
                        print("error in appending reservation to doctor collection")
                    }
                }
            }
            else {
                //makeArray
                self.database.child("userReservationsForDoctor").child(doctorModel.email.SafeDB()).setValue([userReservationsForDoctorCollection]) { (error, _) in
                    if error == nil {
                        print("saved create reservation to doctor collection")
                        completion(true)
                        return
                    } else {
                        print("error in create reservation to doctor collection")
                    }
                }
            }
        }
    }
    
    //get another doctor reservations
    public func getAnotherDoctorReservations(DoctorModel:Doctor , completion : @escaping (Result<[Reservation],Error>)->Void) {
        var reservationsArray = [Reservation]()
        let email = DoctorModel.email
        database.child("doctorReservations").child(email.SafeDB()).observeSingleEvent(of: .value) { (reservationsSnapshot) in
            if let reservationsCollections = reservationsSnapshot.value as? [[String:Any]] {
                for reservationCollection in reservationsCollections {
                    let reservationModel = Reservation(id: reservationCollection["id"] as! String, doctorEmail: email, doctorName: "no name", date: reservationCollection["date"] as! String, from: reservationCollection["from"] as! String, to: reservationCollection["to"] as! String, username: "no name")
                    reservationsArray.append(reservationModel)
                }
                print("reservation array returned")
                completion(.success(reservationsArray))
                return
            }
            else {
                print("no reservation to return")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
        }
    }
    
    //get currenreservationCollection["date"] as! Stringt doctor reservations
    public func getCurrentDoctorReservations(completion : @escaping (Result<[Reservation],Error>)->Void) {
        var reservationsArray = [Reservation]()
        let email = UserDefaults.standard.value(forKey: "email") as! String
        database.child("doctorReservations").child(email.SafeDB()).observeSingleEvent(of: .value) { (reservationsSnapshot) in
            if let reservationsCollections = reservationsSnapshot.value as? [[String:Any]] {
                for reservationCollection in reservationsCollections {
                    let reservationModel = Reservation(id: reservationCollection["id"] as! String, doctorEmail: email, doctorName: reservationCollection["doctorName"] as! String, date: reservationCollection["date"] as! String, from: reservationCollection["from"] as! String, to: reservationCollection["to"] as! String, username: "no name")
                    reservationsArray.append(reservationModel)
                }
                print("reservation array returned")
                completion(.success(reservationsArray))
                return
            }
            else {
                print("no reservation to return")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
        }
    }
    
    //save Doctor Reservation
    public func saveDoctorReservation(reservatinModel : Reservation, completion : @escaping (Bool)->Void) {
        let reservationCollection = ["id": reservatinModel.id,"doctorName" : reservatinModel.doctorName,"date" : reservatinModel.date , "from" : reservatinModel.from , "to" : reservatinModel.to]
        database.child("doctorReservations").child(reservatinModel.doctorEmail.SafeDB()).observeSingleEvent(of: .value) { (reservationsSnapshot) in
            if var reservationsCollections = reservationsSnapshot.value as? [[String:Any]] {
                //append
                reservationsCollections.append(reservationCollection)
                self.database.child("doctorReservations").child(reservatinModel.doctorEmail.SafeDB()).setValue(reservationsCollections) { (error, _) in
                    if error == nil {
                        print("doctor reservations appended")
                        completion(true)
                        return
                    } else {
                        print("failed to append reservation")
                        completion(false)
                        return
                    }
                }
            }
            else {
                // make array
                self.database.child("doctorReservations").child(reservatinModel.doctorEmail.SafeDB()).setValue([reservationCollection]) { (error, _) in
                    if error == nil {
                        print("doctor reservation created")
                        completion(true)
                        return
                    } else {
                        print("failed to create reservation")
                        completion(false)
                        return
                    }
                }
            }
        }
    }
    //get doctor rates
    public func getDoctorRates(doctorEmail : String ,completion : @escaping (Result<[Rate],Error>)->Void) {
        let docEmail = doctorEmail.SafeDB()
        var rateArray = [Rate]()
        database.child("rates").child(docEmail).observeSingleEvent(of: .value) { (ratesSnapshot) in
            if let ratesCollections = ratesSnapshot.value as? [[String:Any]] {
                for rateCollection in ratesCollections {
                    let rateModel = Rate(userName: rateCollection["username"] as! String , text: rateCollection["text"] as! String, rateNum: rateCollection["rateNum"] as! String)
                    rateArray.append(rateModel)
                }
                print("get rates Successfully")
                completion(.success(rateArray))
            }
            else {
                print("mfesh rates")
                completion(.failure(DatabaseError.failedToFetch))
            }
        }
    }
    
    //get user username
    public func getCurrentUserUsername(completion : @escaping (Result<String,Error>)->Void) {
        let email = UserDefaults.standard.value(forKey: "email") as! String
        database.child("Users").observeSingleEvent(of: .value) { (usersSnapshot) in
            if let usersCollections = usersSnapshot.value as? [[String:Any]] {
                for userCollection in usersCollections {
                    if userCollection["email"] as! String == email.SafeDB() {
                        let firstName = userCollection["firstName"] as! String
                        let lastName = userCollection["lastName"] as! String
                        let name = "\(firstName) \(lastName)"
                        completion(.success(name))
                        return
                    }
                }
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
        }
    }
    //makeDoctorRate
    public func makeRate(doctorEmail : String,rateModel:Rate , completion : @escaping (Bool)->Void) {
        let rateCollection = ["username" : rateModel.userName,"text" : rateModel.text , "rateNum" : rateModel.rateNum]
        database.child("rates").child(doctorEmail.SafeDB()).observeSingleEvent(of: .value) { (ratesSnapshot) in
            if var ratesCollections = ratesSnapshot.value as? [[String:Any]] {
                //append
                ratesCollections.append(rateCollection)
                self.database.child("rates").child(doctorEmail.SafeDB()).setValue(ratesCollections) { (error, _) in
                    if error == nil {
                        print("rate saved!")
//                        completion(true)
//                        return
                    }
                    else {
                        print("error in append rate : \(String(describing: error))")
//                        completion(false)
//                        return
                    }
                }
            }
            else {
                //make array
                self.database.child("rates").child(doctorEmail.SafeDB()).setValue([rateCollection]) { (error, _) in
                    if error == nil {
//                        print("rate saved!")
//                        completion(true)
                        return
                    }
                    else {
                        print("error in append rate : \(String(describing: error))")
//                        completion(false)
//                        return
                    }
                }
            }
        }
        print("doctor email : \(doctorEmail.SafeDB())")
        database.child("DoctorsUsers").observeSingleEvent(of: .value) { (doctorsSnapshot) in
            print("dakhal fl observe")
            var index = 0
            if var doctorCollections = doctorsSnapshot.value as? [[String : Any]] {
                print("dakhal fl if var")
                for i in (0 ..< doctorCollections.count) {
                    let collection = doctorCollections[i]
                    let email = collection["email"] as! String
                    if email == doctorEmail {
                       index = i
                        break
                    }
                }
                var doctorCollection = doctorCollections[index]
                var raters =  Int((doctorCollection["raters"] as! String))
                //let currentRating = Float(doctorCollection["rating"] as! String)
                let newRating = Float(rateModel.rateNum)
                var allRating = Float(doctorCollection["allRating"] as! String)
                //print("arr rating in database before : \(allRating)")
                allRating = allRating! + newRating!
                //print("arr rating in database after : \(allRating)")
                raters = raters! + 1
                let ratingValue = allRating! / Float(raters!)
                doctorCollection["raters"] = String(raters!)
                doctorCollection["rating"] = NSString(format: "%.1f", ratingValue)
                doctorCollection["allRating"] = NSString(format: "%.1f", allRating!)
                doctorCollections[index] = doctorCollection
                self.database.child("DoctorsUsers").setValue(doctorCollections) { (error, _) in
                    if error == nil {
                        print("rate saved")
                        completion(true)
                        return
                    }
                    else {
                        print("rate not saved")
                        completion(false)
                        return
                    }
                }
            }
        }
    }
    
    //get all doctors
    
    public func getAllDoctors(completion : @escaping (Result<[Doctor],Error>)->Void) {
        var DoctorsArray = [Doctor]()
        database.child("DoctorsUsers").observeSingleEvent(of: .value) { (doctorsSnapshot) in
            if let doctorsCollections = doctorsSnapshot.value as? [[String:Any]] {
                for doctorCollection in doctorsCollections {
                    let doctorModel = Doctor(firstName: doctorCollection["firstName"] as! String, lastName: doctorCollection["lastName"] as! String, email: doctorCollection["email"] as! String, mobile: doctorCollection["mobile"] as! String, address: doctorCollection["address"] as! String, Specialty: doctorCollection["secialty"] as! String, fees: doctorCollection["fees"] as! String, waiting: doctorCollection["waiting"] as! String, rating: doctorCollection["rating"] as! String, raters: doctorCollection["raters"] as! String, allRating: doctorCollection["allRating"] as! String)
                    DoctorsArray.append(doctorModel)
                }
                print("doctors array returned")
                completion(.success(DoctorsArray))
            }
            else {
                print("mfesh doctors")
                completion(.failure(DatabaseError.failedToFetch))
            }
        }
    }
    
    //update Doctor Profile
    public func updateDoctorProfile(model:Doctor , completion : @escaping (Bool)->Void) {
        let doctorCollection = ["firstName" : model.firstName , "lastName" : model.lastName , "email" : model.email.SafeDB(), "address" : model.address ,"mobile" : model.mobile,"fees" : model.fees , "rating" : model.rating,"waiting" : model.waiting , "secialty" : model.Specialty]
        let currentEmail = UserDefaults.standard.value(forKey: "email") as! String
        var index = 0
        database.child("DoctorsUsers").observeSingleEvent(of: .value) { (doctorsSnapshot) in
            if var doctorsCollections = doctorsSnapshot.value as? [[String:Any]] {
                for i in ( 0 ..< doctorsCollections.count ) {
                    let collection = doctorsCollections[i]
                    let email = collection["email"] as! String
                    if currentEmail.SafeDB() == email.SafeDB() {
                        index = i
                        break
                    }
                }
                doctorsCollections[index] = doctorCollection
                self.database.child("DoctorsUsers").setValue(doctorsCollections) { (error, _) in
                    if error == nil {
                        print("doctor updated!")
                        completion(true)
                        return
                    } else {
                        print("error in update doctor \(String(describing: error))")
                        completion(false)
                        return
                    }
                }
            }
        }
    }
    
    //get Current Doctor Model
    public func getCurrentDoctor (completion : @escaping (Result<Doctor,Error>)->Void) {
        var currentDoctor:Doctor?

        let currentEmail = UserDefaults.standard.value(forKey: "email") as! String
        database.child("DoctorsUsers").observeSingleEvent(of: .value) { (doctorsSnapshot) in
            if let doctorsCollections = doctorsSnapshot.value as? [[String:Any]] {
                
                for doctorCollection in doctorsCollections {
                    let email = doctorCollection["email"] as! String
                    if email.SafeDB() == currentEmail.SafeDB() {
                        currentDoctor = Doctor(firstName: doctorCollection["firstName"] as! String, lastName: doctorCollection["lastName"] as! String, email: doctorCollection["email"] as! String, mobile: doctorCollection["mobile"] as! String, address: doctorCollection["address"] as! String, Specialty: doctorCollection["secialty"] as! String, fees: doctorCollection["fees"] as! String, waiting: doctorCollection["waiting"] as! String, rating: doctorCollection["rating"] as! String, raters: doctorCollection["raters"] as! String, allRating: doctorCollection["allRating"] as! String)
                        break
                    }
                }
                print("get current Doctor successfully")
                completion(.success(currentDoctor!))
                return
            } else {
                print("can't get current Doctor ")
                completion(.failure(DatabaseError.failedToFetch))
            }
        }
    }
    //get type
    public func DoctorOrUser (email:String , completion : @escaping ( Result<String,Error>)->Void) {
        database.child("Type").child(email.SafeDB()).observeSingleEvent(of: .value) { (typeSnapshot) in
            if let typeCollection = typeSnapshot.value as? [String:String] {
                let type = typeCollection["type"]
                if type == "doctor" {
                    completion(.success("doctor"))
                    return
                } else {
                    completion(.success("user"))
                    return
                }
            } else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
        }
        
    }
    // save doctor or user
    public func SaveDoctorOrUser (email:String , Type : String) {
            database.child("Type").child(email.SafeDB()).setValue(["type":Type])
    }
    //save doctor user
    public func SaveDoctorUser(model:Doctor , completion : @escaping (Bool)->Void) {
        
        let doctorCollection = ["firstName" : model.firstName , "lastName" : model.lastName , "email" : model.email.SafeDB(), "address" : model.address ,"mobile" : model.mobile,"fees" : model.fees , "rating" : model.rating,"waiting" : model.waiting , "secialty" : model.Specialty,"raters" : model.raters , "allRating" : model.allRating]
        
        database.child("DoctorsUsers").observeSingleEvent(of: .value) { (usersSnapshot) in
            if var doctorCollections = usersSnapshot.value as? [[String:String]]
            {
                //append
                doctorCollections.append(doctorCollection)
                self.database.child("DoctorsUsers").setValue(doctorCollections) { (error, _) in
                    if error == nil {
                        print("doctor saved in append")
                        completion(true)
                        return
                    } else {
                        print("error in saving doctors in append \(String(describing: error))")
                        completion(false)
                        return
                    }
                }
            }
            else {
                // make array
                self.database.child("DoctorsUsers").setValue([doctorCollection]) { (error, _) in
                    if error == nil {
                       print("doctor saved in make array")
                        completion(true)
                        return
                    } else {
                        print("error in saving doctor in make array \(String(describing: error))")
                        completion(false)
                        return
                    }
                }
            }
        }
        
    }
    
    //Save user
    public func SaveNewUser(model:User , completion : @escaping (Bool)->Void) {
        
        let userCollection = ["firstName": model.firstName , "lastName" : model.lastName , "email" : model.email.SafeDB() ]
        database.child("Users").observeSingleEvent(of: .value) { (usersSnapshot) in
            if var usersCollections = usersSnapshot.value as? [[String:String]]
            {
                //append
                usersCollections.append(userCollection)
                self.database.child("Users").setValue(usersCollections) { (error, _) in
                    if error == nil {
                        print("user saved in append")
                        completion(true)
                        return
                    } else {
                        print("error in saving user in append \(String(describing: error))")
                        completion(false)
                        return
                    }
                }
            }
            else {
                // make array
                self.database.child("Users").setValue([userCollection]) { (error, _) in
                    if error == nil {
                       print("user saved in make array")
                        completion(true)
                        return
                    } else {
                        print("error in saving user in make array")
                        completion(false)
                        return
                    }
                }
            }
        }
    }
    
    //
}

extension String {
    func SafeDB () -> String{
        var s:String
        s = self.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-").replacingOccurrences(of: ":", with: "-").replacingOccurrences(of: " ", with: "-")
        return s
    }
}
