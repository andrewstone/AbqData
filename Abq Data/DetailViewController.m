//
//  DetailViewController.m
//  Abq Data
//
//  Created by Androidicus Maximus on 12/4/14.
//  Copyright (c) 2014 Stone. All rights reserved.
//

#import "DetailViewController.h"
#import "DataEngine.h"

@interface DetailViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation DetailViewController

- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)section {
	return self.objects.count;
}
#define IS_GOOD(x) ([x isKindOfClass:[NSString class]] && x.length > 0)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"junk"];
	
	if (!cell){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"junk"];
	}
	
	
	NSString *s = [self.objects[indexPath.row] valueForKeyPath:@"attributes.TITLE"];
	if (IS_GOOD(s))
		cell.textLabel.text = s;
	else cell.textLabel.text = @"WTF";
	
	
	return cell;
}

- (void)setupTableView:(NSArray *)data {
	self.objects = [data copy];
	self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
	[self.view addSubview:self.tableView];
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
//				[self.textView setText:[a description]];

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
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self makeRequest];
	});
	
}
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
