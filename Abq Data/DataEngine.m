//
//  DataEngine.m
//  Abq Data
//
//  Created by Andrew Stone on 12/4/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import "DataEngine.h"
#import <UIKit/UIKit.h>
#import "XMLDictionary.h"

NSString *CoreLocationUpdatedNotification = @"CoreLocationUpdatedNotification";

@implementation DataEngine

+ (DataEngine *)dataEngine {
	static DataEngine *_dataEngine = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_dataEngine = [[DataEngine alloc] init];
	});
	return _dataEngine;
}

- (id)nukeNulls:(id)d {
	if ([d isKindOfClass:[NSArray class]]) {
		for (id dd in d) [self nukeNulls:dd];
	} else if ([d isKindOfClass:[NSDictionary class]]) {
		NSArray *allKeys = [d allKeys];
		for (NSString *key in allKeys) {
			id val = [d valueForKey:key];
			if (val == [NSNull null]) [d removeObjectForKey:key];
			else if ([val isKindOfClass:[NSArray class]] || [val isKindOfClass:[NSDictionary class]]) [self nukeNulls:val];
		}
	}
	return d;
}

- (NSDictionary *)itemsFromExcelXML:(NSDictionary *)excelWorksheet {
	NSArray *a = [excelWorksheet valueForKey:@"Worksheet"];
	if (a && a.count > 0) {
		NSDictionary *table = [[a objectAtIndex:0] valueForKey:@"Table"];
		NSArray *row = [table valueForKey:@"Row"];
		NSMutableArray *actual = [NSMutableArray array];
		for (int i = 1; i < row.count;i++) {    // we skip over item 0:
			NSDictionary *d = [row objectAtIndex:i];
			NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
			[actual addObject:newDict];
			NSArray *cell = [d valueForKey:@"Cell"];
			NSDictionary *data = [[cell objectAtIndex:0] valueForKey:@"Data"];
			[newDict setObject:[data valueForKey:@"__text"] forKey:@"name"];
			data = [[cell objectAtIndex:1] valueForKey:@"Data"];
			if ([data valueForKey:@"__text"])
				[newDict setObject:[data valueForKey:@"__text"] forKey:@"ADDRESS"];
			NSDictionary *latDict = [[cell objectAtIndex:3] valueForKey:@"Data"];
			NSDictionary *longDict = [[cell objectAtIndex:4] valueForKey:@"Data"];
			double lattitude = [[latDict valueForKey:@"__text"] doubleValue];
			double longitude = [[longDict valueForKey:@"__text"] doubleValue];
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:@[[NSNumber numberWithDouble:lattitude],[NSNumber numberWithDouble:longitude] ] forKeys:@[@"latitude",@"longitude"]];
			[newDict setObject:dict forKey:@"latlong"];
			
		}
		return [NSDictionary dictionaryWithObject:actual forKey:@"data"];
	}
	return excelWorksheet;   // fail?
}

- (void)performRequest:(NSString *)requestName completion:(SDUICompletionBlock)completionBlock {
	
	// let's assume the url is ready to go
	NSURL *url = [NSURL URLWithString:requestName];
	// NSURLRequestReloadIgnoringCacheData
	
	[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url  /*cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30*/] queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *urlresponse, NSData *data, NSError *connectionError)
	 {
		 
		 // check response
		 NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlresponse;
		 
		 if (connectionError == nil && data.length) {
			 
			 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
				 if (response.statusCode < 400) {
					 NSError *jsonError = nil;
					 id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves						error:&jsonError];
					 
					 // to avoid trouble later, remove NSNull's:
					 json = [self nukeNulls:json];
					 

					 
					 // one last change to see if this is a redirect:
					 if (json == nil) {
						 NSString *s = [self stringForData:data response:response];
						 // The page returns <HEAD>stuff url</HEAD>
						 // We'll encourage the city to do a REDIRECT
						 /*
						  <meta http-equiv="Refresh"
						  content="20; URL=http://data.cabq.gov/X...Y">
						  */
						 
						 NSScanner *scan = [NSScanner scannerWithString:s];
						 NSString *value;
						 if ([scan scanUpToString:@"url=" intoString:NULL] && [scan scanString:@"url=" intoString:NULL]&& [scan scanUpToString:@"\">" intoString:&value]) {
							 
							 dispatch_async(dispatch_get_main_queue(), ^{
								 //                                    NSLog(@"2nd response: %@", value);
								 [[DataEngine dataEngine] performRequest:value completion:completionBlock];
							 });
							 return;
							 
						 }

					 
					 // Only offered in XML datasets like top 250 paid employees
					 // note: WiFi spots XML is not being caught here
					 if (!json) {
						 json = [[self parseXML:data] copy];
						 jsonError = nil;
						 
						 // here, we deal with a XML HEAD response and recursively call performRequest:
						 // this first one comes from Free Wifi:
						 NSString *s = nil;
						 if ([json isKindOfClass:[NSDictionary class]] && [[json valueForKey:@"__name"]isEqualToString:@"HEAD"] && (s = [json valueForKeyPath:@"meta._content"])!= nil) {
							 ;
							 NSScanner *scan = [NSScanner scannerWithString:s];
							 NSString *value;
							 if ([scan scanUpToString:@"url=" intoString:NULL] && [scan scanString:@"url=" intoString:NULL]&& [scan scanUpToString:@"\">" intoString:&value]) {
								 
								 dispatch_async(dispatch_get_main_queue(), ^{
									 //                                    NSLog(@"2nd response: %@", value);
									 [[DataEngine dataEngine] performRequest:value completion:completionBlock];
								 });
								 return;
								 
							 }
							 
						 }
						 
						 // OK we have XML - is it a worksheet from EXCEL?
						 if ([json isKindOfClass:[NSDictionary class]] && [json valueForKey:@"ExcelWorkbook"]!= nil) {
							 json = [self itemsFromExcelXML:json];
						 }
					 }
					 
					 
					 }
					 
					 // actually this method is quite simple - just call the block!
					 dispatch_async(dispatch_get_main_queue(), ^{
						 completionBlock(json,jsonError);
					 });
					 return;
				 }
			 });
			 return;
		 }
		 // connection failed:
		 dispatch_async(dispatch_get_main_queue(), ^{
			 completionBlock(nil,connectionError);
		 });
	 }];
}

- (void)showError:(NSError *)error {
	// ignore or alert user as required:
	UIAlertView *a = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Trouble",nil)message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
	[a show];
}

- (NSString *)stringForData:(NSData *)data response:(NSURLResponse *)response {
	if (!data || data.length == 0) return nil;
	
	NSString *encodingName = [response textEncodingName];
	CFStringEncoding encoding = kCFStringEncodingInvalidId;
	if (encodingName != nil)
		encoding = CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)encodingName);
	if (encoding == kCFStringEncodingInvalidId)
		encoding = kCFStringEncodingWindowsLatin1;
	CFStringRef cfString = CFStringCreateFromExternalRepresentation(kCFAllocatorDefault, (__bridge CFDataRef)data, encoding);
	if (cfString == NULL) { // The specified encoding didn't work, let's try Windows Latin 1
		cfString = CFStringCreateFromExternalRepresentation(kCFAllocatorDefault, (__bridge CFDataRef)data, kCFStringEncodingWindowsLatin1);
		if (cfString == NULL) {
			return nil;
		}
	}
	NSString *string = (NSString *)objc_retainedObject(cfString);
	return string;
}

- (id)parseXML:(NSData *)data {
	{
		
		NSDictionary *d = [[XMLDictionaryParser sharedInstance] dictionaryWithData:data];
		return d;
	}
	return nil;
}

// converts Web Mercator (102100/3857) X/Y to WGS84 Geographic (Lat/Long) coordinates
- (CLLocationCoordinate2D)convertWebMercatorToGeographicX:(double)mercX Y:(double)mercY {
    // define earth
    const double earthRadius = 6378137.0;
    // handle out of range
    if (fabs(mercX) < 180 && fabs(mercY) < 90)
        return kCLLocationCoordinate2DInvalid;
    // this handles the north and south pole nearing infinite Mercator conditions
    if ((fabs(mercX) > 20037508.3427892) || (fabs(mercY) > 20037508.3427892)) {
        return kCLLocationCoordinate2DInvalid;
    }
    // math for conversion
    double num1 = (mercX / earthRadius) * 180.0 / M_PI;
    double num2 = floor(((num1 + 180.0) / 360.0));
    double num3 = num1 - (num2 * 360.0);
    double num4 = ((M_PI_2 - (2.0 * atan(exp((-1.0 * mercY) / earthRadius)))) * 180 / M_PI);
    // set the return
    CLLocationDegrees lattitude = num4;
    CLLocationDegrees longitude = num3;
    CLLocationCoordinate2D geoLocation = CLLocationCoordinate2DMake(lattitude, longitude);
    return geoLocation;
}

#pragma mark - CLLocationManagerDelegates

// didUpdateToLocation is deprecated, replaced with didUpdateToLocations with an array
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // get last location from array
    CLLocation *newLocation = [locations lastObject];
    self.currentLocation = newLocation;
    // stop updating
    [self.locationManager stopUpdatingLocation];
    NSLog(@"didUpdateLocations: %@", self.currentLocation);
    // notify any observers, Earthly or otherwise
    [[NSNotificationCenter defaultCenter] postNotificationName: CoreLocationUpdatedNotification object:newLocation];
    
}

// failed to get location.  Alert the user.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location Manager didFailWithError: %@", error);
}

#pragma mark - Location Helper Methods
// [CLLocationManager requestWhenInUseAuthorization]
// location manager authorization status check
- (BOOL)checkLocationManagerAuthorizationStatus {
    // check first if hardware supports
    if ([CLLocationManager locationServicesEnabled]) {
        // Check user's authorization status for this service.  kCLAuthorizationStatusAuthorized was deprecated in iOS 8 (xCode 6).  Replaced with StatusDenied instead.
        if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)) {
            return FALSE;
        } else {
            return TRUE;
        }
        
    } else {
        NSLog(@"checkLocationManagerAuthorizationStatus: locationServicesEnabled: FALSE");
    }
    return FALSE;
}

// activate or deactivate location service
- (void)determineLocation:(BOOL)activated {
    // 'activated' drives the process on/off
    if (activated) {
        // check if user disabled the service
        if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)) {
            NSLog(@"Location Service Denied or Restricted");
            self.locationManagerActive = NO;
            return;
        }
        // check device capability before alloc/init which can cause exception if device not capable
        if (![CLLocationManager locationServicesEnabled]) {
            NSLog(@"Location Service Disabled");
            self.locationManagerActive = NO;
            
        } else {
            // let's activate, but first check if it's already active
            if (self.locationManager) {
                // already allocated and initialized, just activate
                [self.locationManager startMonitoringSignificantLocationChanges];
                
            } else {
                
                // Initial creation of locationManager object and startMonitoring
                self.locationManager = [[CLLocationManager alloc] init];
				// iOS 8 requires this
				if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
					[self.locationManager performSelector:@selector(requestWhenInUseAuthorization)];
                self.locationManager.delegate = self;
                self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
                self.locationManager.distanceFilter = kCLDistanceFilterNone;
                [self.locationManager startUpdatingLocation];
            }
            self.locationManagerActive = YES;
        }
    } else {
        // shut her down
        if ([CLLocationManager locationServicesEnabled]) {
            
            if (self.locationManager) {
                [self.locationManager stopUpdatingLocation];
                self.locationManagerActive = NO;
                self.locationManager = nil;
            }
        }
    }
}


@end

// Notes: For Chris' reference on SDUICompletionBlock http://stackoverflow.com/questions/23033707/nsoperation-setcompletionblock
