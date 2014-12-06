//
//  DetailViewController.m
//  Abq Data
//
//  Created by Androidicus Maximus on 12/4/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import "DetailViewController.h"
#import "DataEngine.h"
#import "RemoteImageTableViewCell.h"
#import "ArtCardViewController.h"
@interface DetailViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation DetailViewController

- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)section {
	return self.objects.count;
}
#define IS_GOOD(x) ([x isKindOfClass:[NSString class]] && x.length > 0)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *obj = self.objects[indexPath.row];
	RemoteImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"junk"];
	
	if (!cell){
		cell = [[RemoteImageTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"junk"];
	}
	

// for art, this works:
	NSString *url =[obj valueForKeyPath:@"attributes.JPG_URL"];
	if (IS_GOOD(url)) {
		[cell setURL:url];
	}
	NSString *s = [obj valueForKeyPath:@"attributes.TITLE"];
	if (IS_GOOD(s))
		cell.textLabel.text = s;
	else cell.textLabel.text = @"seek other title key";
	
	
	//     "ARTIST": "David Anderson",
	// "ADDRESS": "4440 Osuna NE",

	NSString *artist = [obj valueForKeyPath:@"attributes.ARTIST"];
	NSString *address = [obj valueForKeyPath:@"attributes.ADDRESS"];
	if(IS_GOOD(artist) || IS_GOOD(address)) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ~ %@", artist ? artist : @"", address ? address : @""];
		
	}
	
	
// as we learn the data sets, feel free to pull
// other keys that are useful:
	
	
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

- (void)makeRequest {
	NSString *url = [self.detailItem valueForKey:@"url"];
	[[DataEngine dataEngine] performRequest:url completion:^(id dataObject, NSError *error) {
		if (error == nil) {
			NSString *form = [self.detailItem valueForKey:@"form"];
			if ([form isEqualToString:@"dictionary"]) {
				NSString *key = [self.detailItem valueForKey:@"arrayKey"];
				NSArray *a = [dataObject valueForKey:key];
				[self setupTableView:a];

			} else			[self.textView setText:[dataObject description]];

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
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *d = self.objects[indexPath.row];
	// what you do now depends on kind of data
	// for example, let's deal with art first:
	if ([[self.detailItem valueForKey:@"name"] isEqualToString:@"Public Art"]) {
		[self performSegueWithIdentifier:@"ArtCard" sender:d];
//		ArtCardViewController *acc = [[ArtCardViewController alloc] init];
//		acc.artistDictionary = d;
//		[self.navigationController pushViewController:acc animated:YES];
	} else {
		NSLog(@"Unhandled detail controller - implement for this style of data!");
	}
}

@end
