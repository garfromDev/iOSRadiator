//
//  ViewController.swift
//  Radiator
//
//  Created by Alistef on 20/12/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

import UIKit
import FilesProvider

/** handle the main static table view , choice of heating mode  and adjustement */
class MenuTableViewController: UITableViewController  {

    weak var userInteractionManager : UserInteractionManager? = UserInteractionManager.shared
    
    /** index for the Segmented Selector to choose heating mode */
    enum ModeSelectorIndex:Int {
        case eco = 0
        case confort = 1
        case calendar = 2
    }

    /** index for the Segmented Selector to choose adjustement */
    enum BonusSelectorIndex:Int{
        case hot = 0
        case ok = 1
        case cold = 2
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI(timestamp: "déclenché par viewDidAppear le \(Date().description(with: .current))")
    }
    
    
    @IBOutlet weak var modeChoiceSelector: UISegmentedControl!
    @IBOutlet weak var bonusSelector: UISegmentedControl!
    @IBOutlet weak var timestampLabel: UILabel!
    
    /** choice of heating mode */
    @IBAction func modeDidChange(_ sender: UISegmentedControl) {
        switch ModeSelectorIndex(rawValue: sender.selectedSegmentIndex)! {
        case .calendar: //calendrier
            userInteractionManager?.userInteraction.overruled.status = false
        case .eco, .confort: //overrule eco ou confort
            userInteractionManager?.userInteraction.setOverruleMode(sender.selectedSegmentIndex == 0 ? .eco : .confort)
        }
        userInteractionManager?.pushUpdate()
    }
    
    /** choice of adjustement */
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

extension MenuTableViewController: UI_Updatable{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // userInteractionManager will trigger UI_Update() upon model change
        _ = NotificationCenter.default.addObserver(self, selector: #selector(triggerUpdateUI(_:))
            , name: UserInteractionManager.updateUInotification,
            object : nil)
    }
    
    // need @objc because called by NotificationCenter
    @objc
    func triggerUpdateUI( _ notification:Notification){
        DispatchQueue.main.async(execute:{self.updateUI()})
    }
    
    
    /**
    this method update the UI based on userInteractionManager data
    */
    func updateUI(timestamp : String = Date().description(with: .current)){
        guard let uim = userInteractionManager?.userInteraction else {return}
        print("update UI with userInteraction : \(uim)")
        // -- The Heating Mode Selector
        if uim.calendarMode(){
            self.modeChoiceSelector.selectedSegmentIndex = ModeSelectorIndex.calendar.rawValue
        }else if uim.ecoMode(){
            self.modeChoiceSelector.selectedSegmentIndex = ModeSelectorIndex.eco.rawValue
        }else if uim.confortMode(){
            self.modeChoiceSelector.selectedSegmentIndex = ModeSelectorIndex.confort.rawValue
        }
        
        // disable adjustement if heating mode eco
        self.bonusSelector.isEnabled = !uim.ecoMode()
        
        // the Adjustment Selector
        if uim.userDownActive(){
            self.bonusSelector.selectedSegmentIndex = BonusSelectorIndex.hot.rawValue
        }else if uim.userBonusActive(){
            self.bonusSelector.selectedSegmentIndex = BonusSelectorIndex.cold.rawValue
        }else{
            self.bonusSelector.selectedSegmentIndex = BonusSelectorIndex.ok.rawValue
        }
        
        self.timestampLabel.text = timestamp
    }
}




