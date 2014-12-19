//
//  DetailViewController.m
//  Abq Data
//
//  Created by Andrew Stone on 12/4/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//
// Public Art - JSON Dictionary
// Free WiFi - XML
// Film Locations - JSON Dictionary
// Top Paid CABQ Employees - XML
// Voting Locations - JSON Dictionary

#import "DetailViewController.h"
#import "DataEngine.h"
#import "RemoteImageTableViewCell.h"
#import "ArtCardViewController.h"
#import "WebViewController.h"
#import "MapViewController.h"


@interface DetailViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation DetailViewController

- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)section {
	return self.objects.count;
}

#define IS_GOOD(x) ([x isKindOfClass:[NSString class]] && x.length > 0)


- (NSString *)valueFrom:(id)obj key:(NSString *)key {
	if ([self useKeyPath:key]) return [obj valueForKeyPath:key];
	else return [obj valueForKey:key];
}


// this could be modular or subclassable:

- (void)subclassMods:(RemoteImageTableViewCell *)cell object:(id)obj {
//	if ([[self.detailItem valueForKey:@"name"] isEqualToString:@"Public Art"]) {
//		
//		NSString *artist = [obj valueForKeyPath:@"attributes.ARTIST"];
//		NSString *address = [obj valueForKeyPath:@"attributes.ADDRESS"];
//		if(IS_GOOD(artist) || IS_GOOD(address)) {
//			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ~ %@", artist ? artist : @"", address ? address : @""];
//		}
//	}
}

static NSNumberFormatter *numberFormatter = nil;
+ (void)initialize {
	numberFormatter = [[NSNumberFormatter alloc] init];
	numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *obj = self.objects[indexPath.row];
	RemoteImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"junk"];
	
	// select valueForKeyPaths to use depending on the data set (from AbqData.json)
	NSString *cellIconURL   = [self.detailItem valueForKey:@"cellIconURL"];
	NSString *cellWebURL   = [self.detailItem valueForKey:@"cellWebURL"];
	NSString *cellTitle     = [self.detailItem valueForKey:@"cellTextLabel"];
	NSString *cellDetail1   = [self.detailItem valueForKey:@"cellDetail1"];
	NSString *cellDetail2   = [self.detailItem valueForKey:@"cellDetail2"];
	
	if (!cell){
		UITableViewCellStyle style = IS_GOOD(cellDetail1) ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
		cell = [[RemoteImageTableViewCell alloc] initWithStyle:style reuseIdentifier:@"junk"];
	}
	
	// we should really massage data but
	NSString *rowKey = [self.detailItem valueForKey:@"rowKey"];
	if (rowKey) {
		id value = [obj valueForKey:rowKey];
		if ([value isKindOfClass:[NSArray class]]) {
			NSArray *a = (NSArray *)value;
			// we'll have to map correctly but
			NSUInteger count = a.count;
			if (count > 0) cell.textLabel.text = a[0];
			NSMutableString *detail = [NSMutableString stringWithString:@""];
			
			if (count > 1) {
				detail = [NSMutableString stringWithString:a[1]];
				
				if (count > 2) {
					for (int i = 2; i < count - 1; i++) {
						[detail appendFormat:@" %@",a[i]];
					}
				}
				NSString *amount = [a lastObject];
				if ([amount floatValue] == 0)
					amount = [a objectAtIndex:a.count -3];
				
				cell.textLabel.text = [NSString stringWithFormat:@"%@    %@",a[0],[numberFormatter stringFromNumber:[NSNumber numberWithFloat:[amount floatValue]]]];
				
			}
			cell.detailTextLabel.text = detail;
			return cell;
		}
	}
	
	NSString *url =[self valueFrom:obj key:cellIconURL];
	if (IS_GOOD(url)) {
		[cell setURL:url];
	}
	
	NSString *s = [self valueFrom:obj key:cellTitle];
	if (IS_GOOD(s))
		cell.textLabel.text = s;
	else if (cell.textLabel.text.length == 0)
		cell.textLabel.text = @"add title key to 'cellTextLabel' value in AbqData.json";
	
	if ((s = [self valueFrom:obj key:cellDetail1])) {
		NSString *t = [self valueFrom:obj key:cellDetail2];
		cell.detailTextLabel.text = t ? [NSString stringWithFormat:@"%@ ~ %@",s,t] : s;
	}
	
	[self subclassMods:cell object:(id)obj];
	
	return cell;
}

- (NSArray *)objectsSortedByProximityToHere:(NSArray *)objects {
	// TODO: sort according to user's location

	
	return objects;
}

- (void)setupTableView:(NSArray *)data {
	
	self.objects = [self objectsSortedByProximityToHere:data];
	
	self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
	[self.view addSubview:self.tableView];
	self.tableView.rowHeight = 80.0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.scrollsToTop = YES;

	self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + 20.0, 0.0, 0.0, 0.0);
	[self.tableView reloadData];
}

- (BOOL)useKeyPath:(NSString *)s {
	NSRange r;
	return ((r = [s rangeOfString:@"."]).location != NSNotFound);
}

- (void)makeRequest {
	NSString *url = [self.detailItem valueForKey:@"url"];
	[[DataEngine dataEngine] performRequest:url completion:^(id dataObject, NSError *error) {
		if (error == nil) {
			NSString *form = [self.detailItem valueForKey:@"form"];
			if ([form isEqualToString:@"dictionary"]) {
				NSString *key = [self.detailItem valueForKey:@"arrayKey"];
				NSArray *a = dataObject;
				if ([self useKeyPath:key])
					a = [dataObject valueForKeyPath:key];
				else if (key)
					a = [dataObject valueForKey:key];
				[self setupTableView:a];
			} else [self.textView setText:[dataObject description]];

		} else {
			[[DataEngine dataEngine] showError:error];
		}
	}];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
	if (_detailItem != newDetailItem) {
	    _detailItem = newDetailItem;
	        
	    // Update the view.
	    [self configureView];
	}
}

- (void)configureView {
	// Update the user interface for the detail item.
	if (self.detailItem) {
	    self.title = [self.detailItem valueForKey:@"name"];
		
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.objects.count == 0)
		[self makeRequest];
	
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender  {
	if ([segue.identifier isEqualToString:@"ArtCard"]) {
		ArtCardViewController *ac = segue.destinationViewController;
		ac.artistDictionary = sender;
	}
}

- (IBAction)loadMap:(id)sender {
	// Segues are still foreign to me - here's what's underneath
	MapViewController *mvc = [[MapViewController alloc] init];
	mvc.detailItem = self.detailItem;
	mvc.items = self.objects;
	
	[self.navigationController pushViewController:mvc animated:YES];
}
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(loadMap:)];
    // TODO: Remove this location testing code block before shipping
    BOOL deviceReadyForLocation = [[DataEngine dataEngine] checkLocationManagerAuthorizationStatus];
    if (deviceReadyForLocation) {
        NSLog(@"device ready to determine location");
        [[DataEngine dataEngine] determineLocation:YES];
    } else {
        NSLog(@"device not supporting location service right now, try again Tuesday");
    }
    
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *d = self.objects[indexPath.row];
	NSString *key = [self.detailItem valueForKey:@"cellWebURL"];
	if (key) {
		NSString *s = [self valueFrom:d key:key];
		if (s) {
			// let's load a web page
			WebViewController *wc = [[WebViewController alloc] init];
			wc.urlString = s;
			[self.navigationController pushViewController:wc animated:YES];
			return;
		}
	}
	// what you do now depends on kind of data
	// for example, let's deal with art first:
	if ([[self.detailItem valueForKey:@"name"] isEqualToString:@"Public Art"]) {
		[self performSegueWithIdentifier:@"ArtCard" sender:d];
    } else if ([[self.detailItem valueForKey:@"name"] isEqualToString:@"Free Wifi"]) {
        NSLog(@"implement Wifi detail controller!");
    } else if ([[self.detailItem valueForKey:@"name"] isEqualToString:@"Film Locations"]) {
        NSLog(@"implement Film Locations detail controller!");
    } else if ([[self.detailItem valueForKey:@"name"] isEqualToString:@"Top Paid CABQ Employees"]) {
        NSLog(@"implement Top Paid CABQ Employees detail controller!");
    } else if ([[self.detailItem valueForKey:@"name"] isEqualToString:@"Voting Locations"]) {
        NSLog(@"implement Voting Locations detail controller!");
    } else {
		NSLog(@"Unhandled detail controller - implement for this style of data!");
	}
}



@end

