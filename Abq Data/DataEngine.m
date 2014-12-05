//
//  DataEngine.m
//  Abq Data
//
//  Created by Androidicus Maximus on 12/4/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import "DataEngine.h"
#import <UIKit/UIKit.h>
@implementation DataEngine

+ (DataEngine *)dataEngine {
	static DataEngine *_dataEngine = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_dataEngine = [[DataEngine alloc] init];
	});
	return _dataEngine;
}

- (void)performRequest:(NSString *)requestName completion:(SDUICompletionBlock)completionBlock {
	
// let's assume the url is ready to go
	NSURL *url = [NSURL URLWithString:requestName];
	// NSURLRequestReloadIgnoringCacheData

	[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url  /*cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30*/] queue:[NSOperationQueue mainQueue]
	    completionHandler:^(NSURLResponse *urlresponse, NSData *data, NSError *connectionError) {
			
// check response
			NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlresponse;
			
			if (connectionError == nil && data.length) {
				
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
					if (response.statusCode < 400) {
						NSError *jsonError = nil;
						NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0						error:&jsonError];
						
						if (json == nil) {
							NSString *s = [self stringForData:data response:response];
							// a damn redirect???
							NSLog(s);
							NSScanner *scan = [NSScanner scannerWithString:s];
							NSString *value;
							if ([scan scanUpToString:@";url=" intoString:NULL] && [scan scanString:@";url=" intoString:NULL]&& [scan scanUpToString:@"\">" intoString:&value]) {
								NSLog(value);
								
								dispatch_async(dispatch_get_main_queue(), ^{
									
									[[DataEngine dataEngine] performRequest:value completion:completionBlock];
								});
								return;
								
							}
							
						}
						
						dispatch_async(dispatch_get_main_queue(), ^{
							completionBlock(json,jsonError);
						});
						return;
					}
				});
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


@end
