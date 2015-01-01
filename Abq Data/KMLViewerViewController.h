
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "KMLParser.h"

@interface KMLViewerViewController : UIViewController {
    IBOutlet MKMapView *map;
    KMLParser *kmlParser;
}

- (id)initWithKMZURL:(NSString *)url;

@end

