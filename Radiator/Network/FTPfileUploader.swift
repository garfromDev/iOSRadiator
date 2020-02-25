//
//  FTPfileUploader.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 01/01/2019.
//  Copyright © 2019 garfromDev. All rights reserved.
//

import Foundation
import FilesProvider

// voir https://github.com/amosavian/FileProvider/blob/master/Sources/FTPFileProvider.swift
//enum DataOperationResult{
//    case success(data:Data)
//    case failure(error:Error)
//}
typealias DataOperationResult = Result<Data,Error>

typealias DataCompletionHandler = (_ result:DataOperationResult)->Void


/** describe an object capable of pushing / retrieving file from distant system */
protocol DistantFileManager{
    func push(data:Data, fileName:String, completion:@escaping DataCompletionHandler)
    func pull(fileName:String, completion:@escaping DataCompletionHandler)
    func copyItem(path: String, to toPath: String, overwrite: Bool, completionHandler: @escaping DataCompletionHandler)
}


struct FTPfileUploader : DistantFileManager {
    func copyItem(path: String, to toPath: String, overwrite: Bool, completionHandler: @escaping (DataOperationResult) -> Void) {
        print("copying \(path) to \(toPath)")
        let ftp = FTPfileUploader.prepareFtp()
        ftp.copyItem(path: path, to: toPath, overwrite: overwrite) {
            err in
            if let error = err { completionHandler(Result.failure(error)) }
            completionHandler(Result.success(Data()))
        }
    }
    

    static func prepareFtp() -> FTPFileProvider{
        let cred = URLCredential(user: "fromontaline@orange.fr", password: "orange3310", persistence: .forSession)
        let ftp = FTPFileProvider(baseURL: URL(string: "ftpes://perso-ftp.orange.fr/Applications/Radiator")!, mode: .passive, credential: cred, cache: nil)!
        ftp.serverTrustPolicy = .disableEvaluation
        return ftp
    }
    
    func push(data: Data, fileName: String, completion:@escaping DataCompletionHandler) {
        print("pushing file to ftp...")
        let ftp = FTPfileUploader.prepareFtp()
        ftp.writeContents(path: fileName, contents: data, overwrite: true) {
            err in
            if let error = err { completion(Result.failure(error)) }
            completion(Result.success(Data()))
        }
    }
    
    
    func pull(fileName: String, completion: @escaping DataCompletionHandler){
        let ftp = FTPfileUploader.prepareFtp()
        print("FTP fileuploader pulling \(fileName)")
        ftp.contents(path: fileName) {
            contents, error in
            print("FTP fileuploader got pulling response for \(fileName)")
            if let contents = contents {
                print("FTP fileuploader sucess  for \(fileName)")
                completion(.success(contents))
            }else{
                print("FTP fileuploader error for \(fileName) :" + "\(String(describing:error?.localizedDescription)) -" +
                    "\(String(describing:(error as NSError?)?.localizedRecoverySuggestion))" +
                    "\(String(describing:(error as NSError?)?.localizedFailureReason))")
                completion(.failure(error!))
            }
        }
    }
    
}

