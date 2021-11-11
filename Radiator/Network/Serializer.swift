//
//  Serializer.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 27/02/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import Foundation
import os

protocol SerialFileAction {
    func pull(filename: FileName, handler: @escaping DataCompletionHandler)
    func push(data: DatedData, filename: String, handler: @escaping DataCompletionHandler)
}

/**
 Handle pull, push, copy request using queue and semaphore to make sure only one connexion at the same time to distant file manager
 */
class Serializer: SerialFileAction {
    private let dfAccessSemaphore = DispatchSemaphore(value: 1) // first wait will bring gown to zero, blocking further wait
    private let sendRequestQueue = DispatchQueue(label:"sendRequestQueue", qos: .userInitiated)
    private let handleCallbackQueue = DispatchQueue(label:"handleCallbackQueue", qos: .userInitiated)
    private let distantFileManager : DistantFileManager
    private let log : OSLog!
    private static let defaultErrorHandler: DataCompletionHandler = { result in
        //TODO: que faire si echec?, on rollback et pousse update que si OK? Pour l'instant on se contente de signaler une erreur
        if case .failure(let err) = result {
            NotificationCenter.default.post(Notification(name:UserInteractionManager.distantFileErrorNotification, userInfo: ["error": err]))
        }
    }
    
    
    func pull(filename: FileName, handler: @escaping DataCompletionHandler) {
        print("serializer sending request to sendRequestQueue for pulling \(filename)")
        sendRequestQueue.async {
            // first wait that any opened ftp Operation is finished
            print("serializer waiting semaphore for pulling \(filename)")
            if self.dfAccessSemaphore.wait(timeout: .now() + DispatchTimeInterval.seconds(20)) == .success {
                print("serializer sending request to handleCallbackQueue for pulling \(filename)")
                self.handleCallbackQueue.async(){
                    //treatment done on other serial queue, because sendRequestQueue may be bloqued by wait()
                    print("serializer actually pulling \(filename)")
                    self.distantFileManager.pull(fileName: filename){
                        (result:DataOperationResult) in
                        print("serializer finished pulling \(filename), release semaphore")
                        handler(result)
                        self.dfAccessSemaphore.signal() // release access for next operation
                    } //end of pull callback
                } // end of handleCallBack operation
            }
        } // end of waiting queue operation
    } //end of function
    
    
    func push(data: DatedData, filename: String, handler: @escaping DataCompletionHandler = {_ in }) {
        sendRequestQueue.async {
            // first wait that any opened ftp Operation is finished
            print("serializer waiting semaphore for pushing \(filename)")
            if self.dfAccessSemaphore.wait(timeout: .now() + DispatchTimeInterval.seconds(40)) == .success {
                self.handleCallbackQueue.async(){
                    //treatment done on other serial queue, because sendRequestQueue may be bloqued by wait()
                    self.distantFileManager.push(data: data, fileName: filename){
                        (result:DataOperationResult) in
                        print("serializer finished pushing \(filename), release semaphore")
                        self.dfAccessSemaphore.signal() // release access for next operation
                        handler(result)
                    } //end of pull callback
                } // end of handleCallBack operation
            } // do nothing in case of timeout
        } // end of waiting queue operation
    }
    
    func copyItem(path: String, to toPath: String, completionHandler: @escaping DataCompletionHandler = Serializer.defaultErrorHandler){
        sendRequestQueue.async {
            // first wait that any opened ftp Operation is finished
            if self.dfAccessSemaphore.wait(timeout: .now() + DispatchTimeInterval.seconds(20)) == .success {
                self.handleCallbackQueue.async(){
                    //treatment done on other serial queue, because sendRequestQueue may be bloqued by wait()
                    self.distantFileManager.copyItem(path: path, to: toPath, overwrite: true){
                        (result:DataOperationResult) in
                        self.dfAccessSemaphore.signal() // release access for next operation
                        print("copying \(path) to \(toPath) with result \(result)")
                        completionHandler(result)
                    } //end of pull callback
                } // end of handleCallBack operation
            }
        } // end of waiting queue operation
    }
    
    func performSerialAction(action: @escaping ()->Void){
        sendRequestQueue.async {
            // first wait that any opened ftp Operation is finished
            print("serializer waiting semaphore for performing serial action ")
            if self.dfAccessSemaphore.wait(timeout: .now() + DispatchTimeInterval.seconds(40)) == .success {
                self.handleCallbackQueue.async(){
                    action()
                    self.dfAccessSemaphore.signal()
                }
            }
        }
    }
    
    init(distantFileManager: DistantFileManager){
        self.distantFileManager = distantFileManager
        if #available(iOS 10.0, *) {
            log = OSLog.init(subsystem: "fr.garfromdev.radiator", category: "UserInteractionManager")
        }else{
            log = nil
        }
    }
}

