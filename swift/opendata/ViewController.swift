//
//  ViewController.swift
//  opendata
//
//  Created by brooks walch on 12/5/14.
//  Copyright (c) 2014 design is casual. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	var publicart: Publicart!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		publicart = Publicart(filename: "Publicart")
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

