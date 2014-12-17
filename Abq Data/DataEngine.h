//
//  DataEngine.h
//  Abq Data
//
//  Created by Andrew Stone on 12/4/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^SDUICompletionBlock)(id dataObject, NSError *error);

extern NSString *const SDWebServiceError;

@interface DataEngine : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property BOOL locationManagerActive;

+ (DataEngine *)dataEngine;
- (void)performRequest:(NSString *)requestName completion:(SDUICompletionBlock)completionBlock;

- (void)showError:(NSError *)error;
- (id)parseXML:(NSData *)d;
- (CLLocationCoordinate2D)convertWebMercatorToGeographicX:(double)mercX Y:(double)mercY;
- (BOOL)checkLocationManagerAuthorizationStatus;
- (void)determineLocation:(BOOL)activated;

@end
