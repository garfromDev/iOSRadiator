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
    var calendars: Calendars?
    let uim = UserInteractionManager.shared
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.calendars = uim.calendars
        self.tableView.dataSource = calendars
    }
    
}


extension CalendarsTableViewController: UI_Updatable {
    func updateUI(timestamp: String) {
        self.tableView?.reloadData()
    }
}
