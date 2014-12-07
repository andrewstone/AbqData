//
//  ArtCardViewController.m
//  Abq Data
//
//  Created by Andrew Stone on 12/5/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import "ArtCardViewController.h"
#import "RemoteImageTableViewCell.h"
@interface ArtCardViewController ()
@end

@implementation ArtCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.tableView.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// NOT DONE
    return 2;
}
/*
 (lldb) po self.artistDictionary
 {
 attributes =     {
 ADDRESS = "4440 Osuna NE";
 ARTIST = "David Anderson";
 "ART_CODE" = 101;
 "IMAGE_URL" = "http://www.flickr.com/photos/abqpublicart/6831137393/";
 "JPG_URL" = "http://farm8.staticflickr.com/7153/6831137393_fa38634fd7_m.jpg";
 LOCATION = "Osuna Median bet.Jefferson/ W.Frontage Rd";
 OBJECTID = 133901;
 TITLE = "Almond Blossom/Astronomy";
 TYPE = "public sculpture";
 X = "-106.5918383";
 Y = "35.1555";
 YEAR = 1986;
 };
 geometry =     {
 x = "-11865749.1623";
 y = "4185033.103399999";
 };
 }
 */

- (CGFloat)tableView:(UITableView *)t heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 1) return 400.0;
	return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.row == 0) {
		UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
		
		NSString *artist = [self.artistDictionary valueForKeyPath:@"attributes.ARTIST"];
		NSString *s = [self.artistDictionary valueForKeyPath:@"attributes.TITLE"];
		c.textLabel.text = s;
					
		c.detailTextLabel.text = artist;
					   
		
		return c;
	}
	
	if (indexPath.row == 1) {
		RemoteImageTableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
		
		NSString *url = [self.artistDictionary valueForKeyPath:@"attributes.IMAGE_URL"];
		if (url) {
			if([url hasPrefix:@"http://www.flickr.com"]) {
				UITableViewCell *wc = [tableView dequeueReusableCellWithIdentifier:@"WebCell" forIndexPath:indexPath];
				UIWebView *web = wc.contentView.subviews[0];
				if ([web isKindOfClass:[UIWebView class]]) {
					[web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
				}
				return wc;
			}
			
		[c setURL:url];
		return c;
		}
	}
	
    // Configure the cell...
    
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
