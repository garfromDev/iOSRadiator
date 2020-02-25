//
//  MainMenuController.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 20/02/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import Foundation
import UIKit

class MainMenuController: UIViewController {
    let uim = UserInteractionManager.shared
    
    @IBOutlet weak var calendarsChoice: UIView!
    
    // TODO : mecanisme de rafraichissement périodique (ou dans App-delegate?)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        uim.refresh()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "embedCalendarsTableView":
                let ctbc = segue.destination as! CalendarsTableViewController
                _ = NotificationCenter.default.addObserver(ctbc, selector: #selector(CalendarsTableViewController.triggerUpdateUI(_:))
                    , name: UserInteractionManager.updateUInotification,
                      object : nil)
            default:
                break
        }
    }
    
}


extension MainMenuController: UI_Updatable{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // userInteractionManager will trigger UI_Update() upon model change
        _ = NotificationCenter.default.addObserver(self, selector: #selector(triggerUpdateUI(_:))
            , name: UserInteractionManager.updateUInotification, object : nil)
    }
    
    // need @objc because called by NotificationCenter
    @objc
    func triggerUpdateUI( _ notification:Notification){
        DispatchQueue.main.async(execute:{self.updateUI()})
    }
    
    
    /**
     this method update the UI based on userInteractionManager data
     */
    func updateUI(timestamp : String = ""){
        self.calendarsChoice.isUserInteractionEnabled = uim.userInteraction.calendarMode()
    }
    
}
