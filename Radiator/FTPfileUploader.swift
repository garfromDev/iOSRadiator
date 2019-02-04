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
    private let ftp : FTPFileProvider
    
    init(){
        let cred = URLCredential(user: "fromontaline@orange.fr", password: "orange3310", persistence: .forSession)
        ftp = FTPFileProvider(baseURL: URL(string: "ftp://perso-ftp.orange.fr/Applications/Radiator")!, mode: .default, credential: cred, cache: nil)!
        ftp.serverTrustPolicy = .disableEvaluation
    }
    
    
    func push(data: Data, fileName: String) {
        print("pushing file to ftp...")
        ftp.writeContents(path: fileName, contents: data, overwrite: true) { (err : Error?) in
            print(err?.localizedDescription)
        }
    }
    
    
    func pull(fileName: String, completion: @escaping DataCompletionHandler){
        ftp.contents(path: "sample.txt") {
            contents, error in
            if let contents = contents {
                completion(.success(data:contents))
            }else{
                completion(.failure(error:error!))
            }
        }
    }
        
        
}

