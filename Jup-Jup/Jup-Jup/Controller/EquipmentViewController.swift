//
//  EquipmentViewController.swift
//  Jup-Jup
//
//  Created by 조주혁 on 2021/01/08.
//

import UIKit

class EquipmentViewController: UIViewController {

    
    @IBOutlet weak var rentalCount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    @IBAction func countStepper(_ sender: UIStepper) {
        rentalCount.text = "대여 수량: \(Int(sender.value))개"
    }
    
   

}