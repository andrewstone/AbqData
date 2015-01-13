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

#import <zlib.h>

#import "DetailViewController.h"
#import "DataEngine.h"
#import "RemoteImageTableViewCell.h"
#import "ArtCardViewController.h"
#import "WebViewController.h"
#import "MapViewController.h"
#import "KMLViewerViewController.h"
#import "ZipFile.h"
#import "ZipReadStream.h"
#import "FileInZipInfo.h"

@interface DetailViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation DetailViewController

- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)section {
	return self.objects.count;
}

#define IS_GOOD(x) ([x isKindOfClass:[NSString class]] && x.length > 0)


- (NSString *)valueFrom:(id)obj key:(NSString *)key {
	NSString *result = nil;
	if ([self useKeyPath:key]) result = [obj valueForKeyPath:key];
	else result = [obj valueForKey:key];
	if (![result isKindOfClass:[NSString class]]) {
		// maybe a number
		if ([result respondsToSelector:@selector(stringValue)])
			result = [(NSNumber *)result stringValue];
	}
	return  result;
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
//	NSString *cellWebURL   = [self.detailItem valueForKey:@"cellWebURL"];
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
		NSString *label = t ? [NSString stringWithFormat:@"%@ ~ %@",s,t] : s;
		cell.detailTextLabel.text = label;
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
	
	if (!url) {
		// for one thing, we might have list to load!
		if ([[self.detailItem valueForKey:@"form"] isEqualToString:@"subset"]) {
		NSString *file = [self.detailItem valueForKey:@"json"];
			if (file) {
				NSString *path = [[NSBundle mainBundle]pathForResource:file ofType:@"json"];
				NSError *error = nil;
				id objs = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:&error];

				[self setupTableView:objs];
			}
		}
		[self.indicator stopAnimating];
		self.textView.text = @"";
		return;
	}
	[[DataEngine dataEngine] performRequest:url completion:^(id dataObject, NSError *error) {
		[self.indicator stopAnimating];
		self.textView.text = @"";
		
		if (error == nil) {
			NSString *form = [self.detailItem valueForKey:@"form"];
			if ([form isEqualToString:@"kmz"]) {
				// andrew - it may actually be a dictionary already!
				if ([dataObject isKindOfClass:[NSDictionary class]]) {
					[self coreLoadKMLString:[dataObject description] resourceFolder:[self nextUniqueTempFolder]];

				} else {
					[self decompressAndLoadKMZ:dataObject];
				}
			} else if ([form isEqualToString:@"dictionary"]) {
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
	mvc.items = [NSMutableArray arrayWithArray:self.objects];
	
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
        NSLog(@"device not playing nice with location service, try again Tuesday");
    }

    // observer for location updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForLocationHasChanged:) name:CoreLocationUpdatedNotification object:nil];

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
	if ([[d valueForKey:@"form"] isEqualToString:@"kmz"]) {
		DetailViewController *dvc = [[DetailViewController alloc] init];
		dvc.detailItem = d;
		[self.navigationController pushViewController:dvc animated:YES];
		
		return;
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

- (NSString *)nextUniqueTempFolder {
	NSError *error;
	NSString *folderName = [NSString stringWithFormat:@"%d",(int)CFAbsoluteTimeGetCurrent()];
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:folderName];
	
	if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error]) {
		NSLog(@"failed to create %@",path);
	}
	
	return path;
}


- (NSString *)kmlContents:(NSData *)inData resourceFolder:(NSString *)folder {
	// this abstracts away the details of a zip file
	ZipFile *kmzFile;
	
	NSString *kmz = @"kmz.zip";
	NSError *error = nil;
	__block NSMutableData *data;
	
	// 1. save inData to a zipFile - it may contain multiple files
	
	NSString *filePath = [folder stringByAppendingPathComponent:kmz];
	if ([inData writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
		
		@try {
			kmzFile = [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip];
			
			[kmzFile.listFileInZipInfos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
			 {
				 FileInZipInfo *info = (FileInZipInfo *)obj;
				 
				 NSString *ext = info.name.pathExtension.lowercaseString;
				 
				 if ([ext isEqualToString:@"kml"]) {
					 [kmzFile locateFileInZip:info.name];
					 
					 ZipReadStream *reader= kmzFile.readCurrentFileInZip;
					 data = [[NSMutableData alloc] initWithLength:info.length];
					 [reader readDataWithBuffer:data];
					 [reader finishedReading];
					 
					 *stop = YES;
				 }
			 }];
		}
		@catch (NSException *exception) {
			NSLog(@"exception, %@", [exception debugDescription]);
		}
		@finally {
			if (kmzFile) {
				[kmzFile close];
			}
		}
		
		if (data) {
			// this is the kml file
			return [[DataEngine dataEngine] stringForData:data];
			
		}
	} // if file is written to disk
	return nil;
}

- (void)coreLoadKMLString:(NSString *)kml resourceFolder:(NSString *)folder {
	
	KMLViewerViewController *kvc = [[KMLViewerViewController alloc]initWithKML:kml resourceFolder:folder];
	
	// so it doesn't get reloaded on NEXT viewDidLoad!
	self.objects = @[kml];
	
	[self.navigationController pushViewController:kvc animated:YES];
}
- (void)decompressAndLoadKMZ:(NSData *)data {

	NSString *folder = [self nextUniqueTempFolder];
	NSString *kml = [self kmlContents:data resourceFolder:folder];
	[self coreLoadKMLString:kml resourceFolder:folder];
}

// The reason this won't work is because KMZ can contain multiple files

//// Method to decompress GZip data from: http://stackoverflow.com/questions/8425012/is-there-a-practical-way-to-compress-nsdata
//- (NSData *)uncompressGZip:(NSData *)compressedData {
//    
//    if ([compressedData length] == 0)
//        return compressedData;
//    
//    NSUInteger full_length = [compressedData length];
//    NSUInteger half_length = [compressedData length] / 2;
//    
//    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
//    BOOL done = NO;
//    int status;
//    
//    z_stream strm;
//    strm.next_in = (Bytef *)[compressedData bytes];
//    strm.avail_in = (unsigned int)[compressedData length];
//    strm.total_out = 0;
//    strm.zalloc = Z_NULL;
//    strm.zfree = Z_NULL;
//    
//    if (inflateInit2(&strm, (15+32)) != Z_OK)
//        return nil;
//    
//    while (!done) {
//        // Make sure we have enough room and reset the lengths.
//        if (strm.total_out >= [decompressed length]) {
//            [decompressed increaseLengthBy: half_length];
//        }
//        strm.next_out = [decompressed mutableBytes] + strm.total_out;
//        strm.avail_out = (unsigned int)([decompressed length] - strm.total_out);
//        
//        // Inflate another chunk.
//        status = inflate (&strm, Z_SYNC_FLUSH);
//        if (status == Z_STREAM_END) {
//            done = YES;
//        } else if (status != Z_OK) {
//            break;
//        }
//    }
//    if (inflateEnd (&strm) != Z_OK)
//        return nil;
//    
//    // Set real length.
//    if (done) {
//        [decompressed setLength: strm.total_out];
//        return [NSData dataWithData: decompressed];
//    } else {
//        return nil;
//    }
//}


#pragma mark - Selector handlers

- (void)handlerForLocationHasChanged:(NSString *)location {
    
    NSLog(@"handlerForLcationHasChanged: %@", location);
    
//    NSValue *value = [note object];
//    CGPoint point = [value pointValue];
//    (or store it as doubles if it's a double...)
    
}


@end

