//
//  MapViewController.m
//  Abq Data
//
//  Created by Androidicus Maximus on 12/15/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import "MapViewController.h"
#import "DataEngine.h"


@implementation POI
@synthesize coordinate;
@synthesize subtitle;
@synthesize title;

- (id) initWithCoords:(CLLocationCoordinate2D) coords{
	self = [super init];
	if (self != nil) {
		coordinate = coords;
	}
	return self;
}
@end

@interface MapViewController ()

@end

@implementation MapViewController {
	CLLocationCoordinate2D _mapCoordinate;
	BOOL _mapCoordinateSet;
}

- (CLLocationCoordinate2D )coordFromDictionary:(NSDictionary *)dict {
	
	CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(35.1107, -106.61); // backstop
 NSDictionary *geo = [dict valueForKey:@"geometry"];
	
	// it might be packaged as a list of points - grab first:
	id paths = [geo valueForKey:@"paths"];
	if ([paths isKindOfClass:[NSArray class]] && [(NSArray *)paths count] > 0) {
		NSArray *latLong = [paths objectAtIndex:0];
		if ([latLong isKindOfClass:[NSArray class]]) {
			NSArray *realLat = [latLong objectAtIndex:0];
			NSNumber * valueLat = [realLat objectAtIndex:1];
			NSNumber * valueLong = [realLat objectAtIndex:0];
			coord = [[DataEngine dataEngine] convertWebMercatorToGeographicX:[valueLong doubleValue] Y:[valueLat doubleValue]];
		}
	}
	
	return coord;
}

- (NSString *)nameFromDictionary:(NSDictionary *)d {
	return [d description];
}
- (NSString *)subTitleFromDictionary:(NSDictionary *)d {
	return [d description];
}
- (NSArray *)annotations {
	NSMutableArray *a = [NSMutableArray array];
	for (int i = 0; i < self.items.count; i++) {
		POI *poi = [[POI alloc] initWithCoords:[self coordFromDictionary:self.items[i]]];
		poi.title = [self nameFromDictionary:self.items[i]];
		poi.subtitle = [self subTitleFromDictionary:self.items[i]];
		poi.info = self.items[i];
		[a addObject:poi];
	}
	
	return a;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.mapView.delegate = self;
	// center on ABQ:
	[self.mapView setRegion:MKCoordinateRegionMake(_mapCoordinate, MKCoordinateSpanMake(0.2, 0.2))];
	//add annotations:
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		
		[self.mapView addAnnotations:[self annotations]];
		[self.mapView showAnnotations:[self annotations] animated:YES];
	});
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)loc {
//	[CLLocationManager requestAlwaysAuthorization];
	self = [super init];
	_mapCoordinateSet = YES;
	_mapCoordinate = loc;
	return self;
}

- (id)init {
	// CLLocation *location = [[DataEngine dataEngine] currentLocation];
	// Fake for Simulator:
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(35.1107, -106.61);
	self = [self initWithCoordinate:coordinate];
	return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)loc info:(NSMutableDictionary *)info {
	return [self initWithCoordinate:loc info:info modal:NO];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)loc info:(NSMutableDictionary *)info modal:(BOOL)modal {
	self = [super init];
	_mapCoordinateSet = YES;
	_mapCoordinate = loc;
	self.detailItem = info;
	return self;
}


- (void)selectAnnotation:(id <MKAnnotation>) annotation {
	NSArray *old = self.mapView.selectedAnnotations;
	if (old.count){
		
		for (id <MKAnnotation> annote in old)
			[self.mapView deselectAnnotation:annote animated:NO];
	}
	[self.mapView selectAnnotation:annotation animated:YES];
}

- (MKAnnotationView *) mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>) annotation {

	if (annotation == self.mapView.userLocation) return nil;
	
	MKPinAnnotationView *newAnnotation = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation1"];
	if (!newAnnotation)
		newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation1"];
	newAnnotation.pinColor = MKPinAnnotationColorGreen;
	newAnnotation.animatesDrop = YES;
	
	newAnnotation.canShowCallout = YES;
	return newAnnotation;
	
	
}

@end
