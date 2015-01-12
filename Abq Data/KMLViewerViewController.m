
#import "KMLViewerViewController.h"
#import "KMLParser.h"

@implementation KMLViewerViewController


- (id)initWithKML:(NSString *)kml resourceFolder:(NSString *)resources {
	self = [super init];
	self.loadedFolder = resources;
	self.kml = kml;
	return self;
}

- (id)initWithKMLData:(NSData *) data{
	self = [super init];
	self.kmlData = data;
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// load what we have:
	
	if (self.kmlData) [self loadKMLData:self.kmlData];
	else if (self.kml) [self loadKMLData:[self.kml dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
	else if (self.loadedURL) {
		// we'd make request and deal with it here instead of DetailVC
	}
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(mapOptionsAction:)];
}

- (void)loadKMLData:(NSData *)data {
	kmlParser = [[KMLParser alloc] initWithData:data];
    [kmlParser parseKML];
	
	
    // Add all of the MKOverlay objects parsed from the KML file to the map.
    NSArray *overlays = [kmlParser overlays];
    [map addOverlays:overlays];
    
    // Add all of the MKAnnotation objects parsed from the KML file to the map.
    NSArray *annotations = [kmlParser points];
    [map addAnnotations:annotations];
	
	// NADA!
	if (overlays.count == 0 && annotations.count == 0) {
		CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(35.1107, -106.61); // backstop
		[map setRegion:MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.3, 0.3))];
		return;
	}
    
    // Walk the list of overlays and annotations and create a MKMapRect that
    // bounds all of them and store it into flyTo.
    MKMapRect flyTo = MKMapRectNull;
    for (id <MKOverlay> overlay in overlays) {
        if (MKMapRectIsNull(flyTo)) {
            flyTo = [overlay boundingMapRect];
        } else {
            flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
        }
    }
    
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
    }
    
    // Position the map so that all overlays and annotations are visible on screen.
    map.visibleMapRect = flyTo;
}


- (void)viewDidUnload
{
    kmlParser = nil;
    [super viewDidUnload];
}

#pragma mark MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    return [kmlParser viewForOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return [kmlParser viewForAnnotation:annotation];
}

// andrew
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex > 0) map.mapType = buttonIndex-1;
}

- (void)mapOptionsAction:(id)sender {
	UIAlertView *a = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Street", nil), NSLocalizedString(@"Satellite", nil), NSLocalizedString(@"Hybrid", nil), nil];
	[a show];
}


@end
