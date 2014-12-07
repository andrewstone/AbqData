//
//  ArtCardViewController.h
//  Abq Data
//
//  Created by Andrew Stone on 12/5/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class RemoteImageTableViewCell;

@interface ArtCardViewController : UIViewController

@property (nonatomic, strong) NSDictionary *artistDictionary;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;


@end
