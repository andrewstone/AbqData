
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "KMLParser.h"

@interface KMLViewerViewController : UIViewController {
    IBOutlet MKMapView *map;
    KMLParser *kmlParser;
}

@property (nonatomic, strong) NSURL *loadedURL;

@property (nonatomic, strong) NSString *loadedFolder;
@property (nonatomic, strong) NSString *kml;

@property (nonatomic, strong) NSData *kmlData;

- (id)initWithKML:(NSString *)url resourceFolder:(NSString *)resources;

// move processing of GZIP'd data inside this class perhaps:
- (id)initWithKMLData:(NSData *)d;

@end

