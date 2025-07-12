//
//  ViewController.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/7/25.
//

import UIKit

class ViewController: UIViewController {
 
    var background = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        background.backgroundColor = .red
        background.frame = view.bounds
        view.addSubview(background)
    }


}

