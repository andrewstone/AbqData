//
//  publicart.swift
//  opendata
//
//  Created by brooks walch on 12/5/14.
//  Copyright (c) 2014 design is casual. All rights reserved.
//

import Foundation

class Publicart {
	
	init(filename: String) {
		
		if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
			
			if let artArray: AnyObject = dictionary["public art"] {
				
				
			
			}
			
		}
		
	}

}
