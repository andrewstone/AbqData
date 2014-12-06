//
//  MasterViewController.m
//  Abq Data
//
//  Created by Androidicus Maximus on 12/4/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "DataEngine.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)loadJSON {
	NSData *d = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AbqData" ofType:@"json"]];
	NSError *error = nil;
	self.objects = [NSJSONSerialization JSONObjectWithData:d options:0 error:&error];
}

//- (IBAction)testSystem:(id)sender {
//	[[DataEngine dataEngine] performRequest:test completion:^(id dataObject, NSError *error) {
//		if (error == nil) {
//			// we got our data
//			self.objects = dataObject;
//			[self.tableView reloadData];
//		} else {
//			[[DataEngine dataEngine] showError:error];
//		}
//	}];
//}
- (void)awakeFromNib {
	[super awakeFromNib];
	[self loadJSON];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    self.clearsSelectionOnViewWillAppear = NO;
	    self.preferredContentSize = CGSizeMake(320.0, 600.0);
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self loadJSON];

	self.navigationItem.leftBarButtonItem = self.editButtonItem;

//	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//	self.navigationItem.rightBarButtonItem = addButton;
	self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

//- (void)insertNewObject:(id)sender {
//	if (!self.objects) {
//	    self.objects = [[NSMutableArray alloc] init];
//	}
//	[self.objects insertObject:[NSDate date] atIndex:0];
//	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
	    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	    NSDate *object = self.objects[indexPath.row];
	    DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
	    [controller setDetailItem:object];
	    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
	    controller.navigationItem.leftItemsSupplementBackButton = YES;
	}
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	NSDictionary *object = self.objects[indexPath.row];
	cell.textLabel.text = [object valueForKey:@"name"];
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
	    [self.objects removeObjectAtIndex:indexPath.row];
	    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
	    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	}
}

@end
