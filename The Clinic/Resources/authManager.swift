//
//  authManager.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/26/21.
//

import Foundation
import FirebaseAuth

class authManager {
    
    static let shared = authManager()
    
    //MARK: - functions
    
    //register
    public func registerUser(email:String , password:String , completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (_, error) in
            if error == nil {
                print("user registered")
                completion(true)
                return
            } else {
                print("error in creating user \(String(describing: error))")
                completion(false)
                return
            }
        }
    }
    
    //log in
    public func login(email:String , password:String , completion : @escaping (Bool)->Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            if error == nil {
                print("logged in succussefully")
                completion(true)
                return
            } else {
                print("error in logging in")
                completion(false)
                return
            }
        }
    }
    
    //logout
    public func logOut( completion : @escaping (Bool)->Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        }
        catch {
            print("Error on log out")
            completion(false)
        }
    }
    
}
