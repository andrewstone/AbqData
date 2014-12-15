//
//  WebViewController.h
//  Abq Data
//
//  Created by Androidicus Maximus on 12/15/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end
