//
//  ViewController.swift
//  Radiator
//
//  Created by Alistef on 20/12/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

// pour mixer dynamique, https://stackoverflow.com/questions/18153702/uitableview-mix-of-static-and-dynamic-cells
import UIKit
import FilesProvider

/** describe a controller that know how to update UI
 timestamp is used to display last update time if needed
 it is up to the caller to define what to pass
 */
protocol UI_Updatable {
    func updateUI(timestamp:String)
}

extension UIViewController {
     /// The visible view controller from a given view controller
     var updatableViewController: UI_Updatable? {
         if let navigationController = self as? UINavigationController {
            if let cont = navigationController.topViewController?.updatableViewController {
                return cont
            }
         } else if let tabBarController = self as? UITabBarController {
            if let cont = tabBarController.selectedViewController?.updatableViewController {
                return cont
            }
         } else if let presentedViewController = presentedViewController as? UI_Updatable {
            return presentedViewController
         } else if let cont = self as? UI_Updatable{
             return cont
         }
        return nil
     }
 }

/** handle the main static table view */
class MenuTableViewController: UITableViewController, UserInteractionCapable, UI_Updatable {

    let userInteractionManager : UserInteractionManager? = UserInteractionManager(distantFileManager: FTPfileUploader())
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // userInteractionManager will trigger UI_Update() upon model change
        userInteractionManager?.observer = self as UI_Updatable
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

extension MenuTableViewController{
    /**
    this method update the UI based on userInteractionManager data
    */
    func updateUI(timestamp : String = ""){
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


// protocol to work with FTP file provider
extension MenuTableViewController: FileProviderDelegate
{
    func fileproviderFailed(_ fileProvider: FileProviderOperations, operation: FileOperationType, error: Error) {
        let msg = "\(operation.actionDescription) from \(operation.source) to \(operation.destination ?? "") failed"
        print(msg)
        let alertController = UIAlertController(title: "Radiator", message: msg, preferredStyle: .alert)
        self.present(alertController, animated:true)
    }
    
    func fileproviderSucceed(_ fileProvider: FileProviderOperations, operation: FileOperationType){
    }
    
    func fileproviderProgress(_ fileProvider: FileProviderOperations, operation: FileOperationType, progress: Float) {
    }
}


