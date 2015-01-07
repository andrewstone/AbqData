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
extern NSString *CoreLocationUpdatedNotification;

@interface DataEngine : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property BOOL locationManagerActive;

+ (DataEngine *)dataEngine;
- (void)performRequest:(NSString *)requestName completion:(SDUICompletionBlock)completionBlock;
- (void)showError:(NSError *)error;

// further parsing of non-JSON types:
- (id)parseXML:(NSData *)d;


// location:
- (CLLocationCoordinate2D)convertWebMercatorToGeographicX:(double)mercX Y:(double)mercY;
- (BOOL)checkLocationManagerAuthorizationStatus;
- (void)determineLocation:(BOOL)activated;

// helpers:
- (NSString *)stringForData:(NSData *)data; // when response not avail
- (NSString *)stringForData:(NSData *)data response:(NSURLResponse *)response;
@end
