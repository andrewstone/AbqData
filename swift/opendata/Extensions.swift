//
//  Extensions.swift
//  macthree
//
//  Created by brooks walch on 12/5/14.
//  Copyright (c) 2014 design is casual. All rights reserved.
//

import Foundation

extension Dictionary {
	
	static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
		
		if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
			
			var error: NSError?
			let data: NSData? = NSData(contentsOfFile: path, options: NSDataReadingOptions(), error: &error)
			if let data = data {
				
				let dictionary: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: &error)
				
				if let dictionary = dictionary as? Dictionary<String, AnyObject> {
					
					return dictionary
					
				} else {
					
					println("public art file '\(filename)' is not valid JSON: \(error!)")
					return nil
					
				}
				
			} else {
				
				println("Could not load public art file: \(filename), error: \(error!)")
				return nil
				
			}
			
		} else {
			
			println("Could not find public art file: \(filename)")
			return nil
			
		}
		
	}
	
}
