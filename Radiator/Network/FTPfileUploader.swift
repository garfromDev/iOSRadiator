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
enum DataOperationResult{
    case success(data:Data)
    case failure(error:Error)
}

typealias DataCompletionHandler = (_ result:DataOperationResult)->Void


struct FTPfileUploader : DistantFileManager {
    
    static func prepareFtp() -> FTPFileProvider{
        let cred = URLCredential(user: "fromontaline@orange.fr", password: "orange3310", persistence: .forSession)
        let ftp = FTPFileProvider(baseURL: URL(string: "ftpes://perso-ftp.orange.fr/Applications/Radiator")!, mode: .passive, credential: cred, cache: nil)!
        ftp.serverTrustPolicy = .disableEvaluation
        return ftp
    }
    
    func push(data: Data, fileName: String) {
        print("pushing file to ftp...")
        let ftp = FTPfileUploader.prepareFtp()
        ftp.writeContents(path: fileName, contents: data, overwrite: true) { (err : Error?) in
            print(err?.localizedDescription ?? "FTP push completed")
            // error is nil if succesfull
        }
    }
    
    
    func pull(fileName: String, completion: @escaping DataCompletionHandler){
        let ftp = FTPfileUploader.prepareFtp()
        ftp.contents(path: fileName) {
            contents, error in
            if let contents = contents {
                completion(.success(data:contents))
            }else{
                completion(.failure(error:error!))
            }
        }
    }
        
    /* trick from https://medium.com/@michaellong/how-to-chain-api-calls-using-swift-5s-new-result-type-and-gcd-56025b51033c
    to transform async into sync call.
     */
    func pullSync(filename: String) -> DataOperationResult {
        var pullResult: DataOperationResult
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .utility).async{
            self.pull(fileName: filename) {result in
                pullResult = result
                semaphore.signal()
            }
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return pullResult
    }
    
}

