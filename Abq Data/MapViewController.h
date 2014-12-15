//
//  MapViewController.h
//  Abq Data
//
//  Created by Androidicus Maximus on 12/15/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,weak)IBOutlet MKMapView *mapView;

@end
