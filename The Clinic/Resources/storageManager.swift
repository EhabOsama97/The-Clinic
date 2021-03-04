//
//  storageManager.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/26/21.
//


import FirebaseStorage
import Photos
import SDWebImage
import FirebaseAuth

public enum StorageManageError: Error {
    case failedtoDownload
    case failedToUpload
    case failedToGetDownloadUrl
}

public class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    //MARK: - functions
    
    public func uploadProfilePicture ( data : Data , fileName : String , completion : @escaping (Result<String,Error>) -> Void) {
        
        storage.child("DoctorsProfileImages/\(fileName)").putData(data, metadata: nil) { (metadata, error) in
            guard error == nil else {
                //failed
                print("failed to upload profile data to storage")
                completion(.failure(error!))
                return
            }
            self.storage.child("DoctorsProfileImages/\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(error!))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned : \(urlString)")
                completion(.success(urlString))
            }
            
        }
        
    }
    
    public func deleteProfilePicture (fileName:String , completion: @escaping (Bool) -> Void) {
        storage.child("DoctorsProfileImages/\(fileName)").delete { error in
            if (error == nil) {
                completion(true)
                return
                
            }
            else {
                print("deleted error ...... \(String(describing: error))")
                completion(false)
                return
                
            }
        }
    }
    
    
    public func downloadImage (refrence :String , completion: @escaping (Result<URL,StorageManageError>)->Void) {
        storage.child("DoctorsProfileImages").child(refrence).downloadURL { (url, error) in
            guard let url = url , error == nil else  {
                completion(.failure(.failedtoDownload))
                return
            }
            completion(.success(url))
        }
    }
    

}
