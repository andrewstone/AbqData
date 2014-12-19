//
//  RemoteImageTableViewCell.h
//  Abq Data
//
//  Created by Andrew Stone on 12/5/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemoteImageTableViewCell : UITableViewCell
//@property (nonatomic, strong) NSString *url;
@property (nonatomic, readonly)BOOL displaysOnlyInWebView;
@property (nonatomic, strong)UIWebView *webView;

- (void)setURL:(NSString *)url;
- (NSString *)url;
@end
