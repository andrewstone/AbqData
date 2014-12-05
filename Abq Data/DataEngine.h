//
//  DataEngine.h
//  Abq Data
//
//  Created by Androidicus Maximus on 12/4/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SDUICompletionBlock)(id dataObject, NSError *error);

extern NSString *const SDWebServiceError;

@interface DataEngine : NSObject
+ (DataEngine *)dataEngine;
- (void)performRequest:(NSString *)requestName completion:(SDUICompletionBlock)completionBlock;

- (void)showError:(NSError *)error;


@end
