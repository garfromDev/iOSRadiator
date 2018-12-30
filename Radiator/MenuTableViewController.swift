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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

   
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
                print("will selectRow \(indexPath.row) at section \(indexPath.section)")
        if indexPath.section == 0 {
            if let sel =  tableView.indexPathForSelectedRow, sel == indexPath {
                print("already selected")
                tableView.deselectRow(at: indexPath, animated: true)
                return nil}
            return indexPath
        }else{
            return nil
        }
    }
    
}

