//
//  CalendarsTableViewController.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 04/01/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

/**
 Handle the choice of calendars
 */
class CalendarsTableViewController: UITableViewController
{
    var uim = UserInteractionManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("calling uim.refresh")
        uim.refresh()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        uim.didSelectCalendarAt(index: indexPath)
        return  // TODO: pour l'instant, l'édition est désactivé
        if #available(iOS 13, *){
            let viewCtrl = UIHostingController(rootView: MultipleDayly().environmentObject(uim as! UserInteractionManagerIos13))
            self.present(viewCtrl, animated: true)
        }
    }
}


extension CalendarsTableViewController: UI_Updatable{
    @objc
    func triggerUpdateUI( _ notification:Notification){
        DispatchQueue.main.async(execute:{self.updateUI()})
    }
    
    func updateUI(timestamp: String = "") {
        print("reloading tableView with <\(uim.calendars.debugDescription)> calendars")
        self.tableView?.dataSource = uim.calendars
        self.tableView?.reloadData()
    }
}
