//
//  UI_protocols.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 27/02/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import Foundation


/** describe a controller that know how to update UI
 timestamp is used to display last update time if needed
 it is up to the caller to define what to pass
 */
protocol UI_Updatable {
    func updateUI(timestamp:String)
}
