//
//  ViewController.swift
//  Radiator
//
//  Created by Alistef on 20/12/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

// pour mixer dynamique, https://stackoverflow.com/questions/18153702/uitableview-mix-of-static-and-dynamic-cells
import UIKit


class MenuTableViewController: UITableViewController, UserInteractionCapable {

    let userInteractionManager : UserInteractionManager? = UserInteractionManager(distantFileManager: FTPfileUploader())
    
    enum ModeSelectorIndex:Int {
        case eco = 0
        case confort = 1
        case calendar = 2
    }

    enum BonusSelectorIndex:Int{
        case hot = 0
        case ok = 1
        case cold = 2
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBOutlet weak var modeChoiceSelector: UISegmentedControl!
    @IBOutlet weak var bonusSelector: UISegmentedControl!
    
    
    @IBAction func modeDidChange(_ sender: UISegmentedControl) {
        switch ModeSelectorIndex(rawValue: sender.selectedSegmentIndex)! {
        case .calendar: //calendrier
            userInteractionManager?.userInteraction.overruled.status = false
        case .eco, .confort: //overrule eco ou confort
            userInteractionManager?.userInteraction.setOverruleMode(sender.selectedSegmentIndex == 0 ? .eco : .confort)
        }
        userInteractionManager?.pushUpdate()
    }
    
    
    @IBAction func upDownDidChange(_ sender: UISegmentedControl) {
        userInteractionManager?.userInteraction.userBonus = DatedStatus()
        userInteractionManager?.userInteraction.userDown = DatedStatus()
        switch BonusSelectorIndex(rawValue:sender.selectedSegmentIndex)! {
        case .hot: // j'ai chaud
            userInteractionManager?.userInteraction.userDown = DatedStatus.makeTrue()
        case .cold: // j'ai froid
            userInteractionManager?.userInteraction.userBonus = DatedStatus.makeTrue()
        default:
            break
        }
        userInteractionManager?.pushUpdate()
    }

    
}

extension MenuTableViewController{
    /**
    this method update the UI based on userInteractionManager data
    */
    func updateUI(){
        guard let uim = userInteractionManager?.userInteraction else {return}
        
        // -- The Heating Mode Selector
        if uim.calendarMode(){
            self.modeChoiceSelector.selectedSegmentIndex = ModeSelectorIndex.calendar.rawValue
        }else if uim.ecoMode(){
            self.modeChoiceSelector.selectedSegmentIndex = ModeSelectorIndex.eco.rawValue
        }else if uim.confortMode(){
            self.modeChoiceSelector.selectedSegmentIndex = ModeSelectorIndex.confort.rawValue
        }
        
        // the Adjustment Selector
        if uim.userDownActive(){
            self.bonusSelector.selectedSegmentIndex = BonusSelectorIndex.hot.rawValue
        }else if uim.userBonusActive(){
            self.bonusSelector.selectedSegmentIndex = BonusSelectorIndex.cold.rawValue
        }else{
            self.bonusSelector.selectedSegmentIndex = BonusSelectorIndex.ok.rawValue
        }
    }
}
