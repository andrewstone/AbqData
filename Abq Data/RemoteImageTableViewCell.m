//
//  RemoteImageTableViewCell.m
//  Abq Data
//
//  Created by Androidicus Maximus on 12/5/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import "RemoteImageTableViewCell.h"
static NSCache *cache;

@implementation RemoteImageTableViewCell {
	NSString *_url;
}
+ (void)initialize {
	cache = [[NSCache alloc] init];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (NSString *)url {
	return _url;
}

- (void)setURL:(NSString *)path {
	_url = [path copy];

	UIImage *cached = [cache objectForKey:_url];

	self.imageView.image = cached ? cached :[UIImage imageNamed:@"notLoadedArt"];

	if (!cached) {
		[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
			if (connectionError == nil && data.length) {
				NSString *this = [[response URL]absoluteString];
				// cache even if scrolled off:
				UIImage *i = [UIImage imageWithData:data];
				if (i)[cache setObject:i forKey:this];
				// only set if it's ours:
				if ([this isEqualToString:_url]) {
					self.imageView.image = i;
				}
			}
		}
		 ];
	}
}


@end
