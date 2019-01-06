//
//  ViewController.swift
//  Radiator
//
//  Created by Alistef on 20/12/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

// pour mixer dynamique, https://stackoverflow.com/questions/18153702/uitableview-mix-of-static-and-dynamic-cells
import UIKit

class MenuTableViewController: UITableViewController {
    let userInteractionManager : UserInteractionManager? = UserInteractionManager(distantFileManager: FTPfileUploader())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

   
    @IBAction func modeDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 2: //calendrier
            userInteractionManager?.userInteraction.overruled.status = false
        case 0,1: //overrule eco ou confort
            userInteractionManager?.userInteraction.overruled.status = true
            userInteractionManager?.userInteraction.setDefaultExpirationDate()
            userInteractionManager?.userInteraction.overruled.overMode = sender.selectedSegmentIndex == 0 ? .eco : .confort
        default:
            break
        }
        userInteractionManager?.update()
    }
    
    
    @IBAction func upDownDidChange(_ sender: UISegmentedControl) {
        userInteractionManager?.userInteraction.userBonus = DatedStatus()
        userInteractionManager?.userInteraction.userDown = DatedStatus()
        switch sender.selectedSegmentIndex {
        case 0: // j'ai chaud
            userInteractionManager?.userInteraction.userDown = DatedStatus.makeTrue()
        case 2: // j'ai froid
            userInteractionManager?.userInteraction.userBonus = DatedStatus.makeTrue()
        default:
            break
        }
        userInteractionManager?.update()
    }

    
}

