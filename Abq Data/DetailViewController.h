//
//  DetailViewController.h
//  Abq Data
//
//  Created by Andrew Stone on 12/4/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DetailViewController : UIViewController


@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSArray *objects;

@end

