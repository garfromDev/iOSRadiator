//
//  CalendarsTableViewController.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 04/01/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import Foundation
import UIKit

class CalendarsTableViewController: UITableViewController {
    let calendars: Calendars
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.calendars = Calendars.fromJson()
    }
}
