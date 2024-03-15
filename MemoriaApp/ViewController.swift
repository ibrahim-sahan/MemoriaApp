//
//  ViewController.swift
//  MemoriaApp
//
//  Created by İbrahim Şahan on 14.03.2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
    }

    @objc func addButtonClicked() {
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    
}

