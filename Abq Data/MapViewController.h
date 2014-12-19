//
//  MapViewController.h
//  Abq Data
//
//  Created by Androidicus Maximus on 12/15/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface POI : NSObject <MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,strong) id info;

- (id) initWithCoords:(CLLocationCoordinate2D) coords;
@end



@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) id detailItem;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,weak)IBOutlet MKMapView *mapView;

- (id)init; // use's ABQ's lat/long
- (id)initWithCoordinate:(CLLocationCoordinate2D)loc;
- (id)initWithCoordinate:(CLLocationCoordinate2D)loc info:(NSMutableDictionary *)info;
- (id)initWithCoordinate:(CLLocationCoordinate2D)loc info:(NSMutableDictionary *)info modal:(BOOL)modal;

@end
