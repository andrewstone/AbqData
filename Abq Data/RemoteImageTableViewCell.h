//
//  RemoteImageTableViewCell.h
//  Abq Data
//
//  Created by Androidicus Maximus on 12/5/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemoteImageTableViewCell : UITableViewCell
//@property (nonatomic, strong) NSString *url;
- (void)setURL:(NSString *)url;
- (NSString *)url;
@end
