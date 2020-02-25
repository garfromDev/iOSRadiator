//
//  CalendarsTableViewController.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 04/01/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import Foundation
import UIKit

class CalendarsTableViewController: UITableViewController
{
    var uim = UserInteractionManager.shared
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        uim.didSelectCalendarAt(index: indexPath)
    }
}


extension CalendarsTableViewController: UI_Updatable{
    @objc
    func triggerUpdateUI( _ notification:Notification){
        DispatchQueue.main.async(execute:{self.updateUI()})
    }
    
    func updateUI(timestamp: String = "") {
        self.tableView?.dataSource = uim.calendars
        self.tableView?.reloadData()
    }
}
