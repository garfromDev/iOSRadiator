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

struct DatedData{
    let lastChangeDate: Date
    let data: Data
   
}
extension DatedData {
    init(data: Data){ //by default, data are considered as fresh one
        self.init(lastChangeDate: Date(),
                  data : data)
    }
}


protocol Dated {
    var  lastChangeDate : Date  {get}
    func datedData(data: Data) -> DatedData
}

extension Dated{
    func  datedData(data: Data) -> DatedData {
        return DatedData(lastChangeDate: lastChangeDate,
                         data: data)
    }
}

protocol JsonDated: Dated & jsonEncodable {
    func datedJson()->DatedData
}
extension JsonDated{
    func datedJson() -> DatedData {
        return self.datedData(data: self.toJson())
    }
}


/** describe an object capable of pushing / retrieving file from distant system */
protocol DistantFileManager{
    func push(data:DatedData, fileName:String, completion:@escaping DataCompletionHandler)
    func pull(fileName:String, completion:@escaping DataCompletionHandler)
    func copyItem(path: String, to toPath: String, overwrite: Bool, completionHandler: @escaping DataCompletionHandler)
}

enum FtpError: Error {
    case ftpUnreachableError
}

struct FTPfileUploader : DistantFileManager {
    func copyItem(path: String, to toPath: String, overwrite: Bool, completionHandler: @escaping (DataOperationResult) -> Void) {
        print("copying \(path) to \(toPath)")
        let ftp = FTPfileUploader.prepareFtp()!  // TODO: mettre un guard
        ftp.copyItem(path: path, to: toPath, overwrite: overwrite) {
            err in
            if let error = err { completionHandler(Result.failure(error)) }
            completionHandler(Result.success(Data()))
        }
    }
    

    static func prepareFtp() -> FTPFileProvider?{
        let user = ProcessInfo.processInfo.environment["FTP_USER"] ?? ""
        let password = ProcessInfo.processInfo.environment["FTP_PASSWORD"] ?? ""
        let url = ProcessInfo.processInfo.environment["FTP_URL"] ?? ""
        let cred = URLCredential(user: user, password: password, persistence: .forSession)
        guard let ftp = FTPFileProvider(baseURL: URL(string: url)!, mode: .passive, credential: cred, cache: nil) else {
            return nil
        }
        ftp.serverTrustPolicy = .disableEvaluation
        return ftp
    }
    
    func push(data: DatedData, fileName: String, completion:@escaping DataCompletionHandler) {
        print("pushing file to ftp...")
        guard let ftp = FTPfileUploader.prepareFtp() else
            {
            completion(Result.failure(FtpError.ftpUnreachableError))
            return
            }
        // TODO: check date of distant file to not overwrite
        //        let distantDate = serverDateKey
        ftp.attributesOfItem(path: fileName){ (f:FileObject?, err:Error?) in
            if let distantDate = f?.modifiedDate, distantDate >= data.lastChangeDate {
                print("\(fileName) not pushed, distant date \(distantDate) > last change  date \(data.lastChangeDate)")
                completion(Result.success(data.data))  //we consider as a success and allow further processing
            }else{ // no distant date, or it is in the past
                ftp.writeContents(path: fileName, contents: data.data, overwrite: true) {
                    err in
                    if let error = err { completion(Result.failure(error)) }
                    completion(Result.success(Data()))
                }
            }
        }
    }
    
    func pull(fileName: String, completion: @escaping DataCompletionHandler){
        let ftp = FTPfileUploader.prepareFtp()!  // TODO: mettre un guard
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
