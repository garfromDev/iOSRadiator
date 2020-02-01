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


struct FTPfileUploader : DistantFileManager {
    
    var defaultErrorHandler = { (err : Error?) in
        print(err?.localizedDescription ?? "FTP push completed")
        // error is nil if succesfull
    }
    static func prepareFtp() -> FTPFileProvider{
        let cred = URLCredential(user: "fromontaline@orange.fr", password: "orange3310", persistence: .forSession)
        let ftp = FTPFileProvider(baseURL: URL(string: "ftpes://perso-ftp.orange.fr/Applications/Radiator")!, mode: .passive, credential: cred, cache: nil)!
        ftp.serverTrustPolicy = .disableEvaluation
        return ftp
    }
    
    init(){
        
    }
    init(errorHandler: @escaping(Error?)->Void){
        self.defaultErrorHandler = errorHandler
    }
    
    
    func push(data: Data, fileName: String) {
        print("pushing file to ftp...")
        let ftp = FTPfileUploader.prepareFtp()
        ftp.writeContents(path: fileName, contents: data, overwrite: true, completionHandler: defaultErrorHandler)
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
        
    /* trick from https://medium.com/@michaellong/how-to-chain-api-calls-using-swift-5s-new-result-type-and-gcd-56025b51033c
    to transform async into sync call.
     */
    func pullSync(fileName: String) -> DataOperationResult {
        var pullResult : DataOperationResult?
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .utility).async{
            self.pull(fileName: fileName) {result in
                pullResult = result
                semaphore.signal()
            }
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return pullResult!
    }
    
}

