//
//  models.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/26/21.
//

    
    struct User {
        let firstName:String
        let lastName:String
        let email:String
    }

    struct Doctor {
        let firstName:String
        let lastName:String
        let email:String
        let mobile:String
        let address:String
        let Specialty:String
        let fees:String
        let waiting:String
        var rating:String
        var raters:String
        var allRating:String
    }

struct Rate {
    let userName:String
    let text:String
    let rateNum:String
}

struct Reservation {
    let id:String
    let doctorEmail : String
    let doctorName:String
    let date:String
    let from:String
    let to:String
    let username:String
}
