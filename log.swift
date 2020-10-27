//
//  log.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 27/10/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//
// Log system compatible with iOS > 9
// will use print, oslog or Logger accordingly
import Foundation
import os.log
// see https://www.avanderlee.com/workflow/oslog-unified-logging/

@available(iOS 10.0, *)
extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    /// Logs the network access
    @available(iOS 10.0, *)
    static let network = OSLog(subsystem: subsystem, category: "network")
}


@available(iOS 14.0, *)
extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    /// Logs the view cycles like viewDidLoad.
    static let network = Logger(subsystem: subsystem, category: "network")
}


/**
 Universal log device
 
 Use like
 
     Xlogger.logError(message: "bla", error: error)
 */
struct Xlogger {
    static func logError(message msg:String, error err:Error){
        if #available(iOS 14.0, *) {
            Logger.network.error("\(msg) \(err.localizedDescription)")
        }else{
            if #available(iOS 10.0, *) {
                os_log("%{public}@", log:OSLog.network, type:.error, err.localizedDescription)
            } else {
                print("\(msg) \(err.localizedDescription)")
            }
        }
    }
}
