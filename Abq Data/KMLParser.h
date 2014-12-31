/*
     File: KMLParser.h
 Abstract: 
 Implements a limited KML parser.
 The following KML types are supported:
         Style,
         LineString,
         Point,
         Polygon,
         Placemark.
      All other types are ignored
 
*/

#import <MapKit/MapKit.h>

@class KMLPlacemark;
@class KMLStyle;

@interface KMLParser : NSObject <NSXMLParserDelegate> {
    NSMutableDictionary *_styles;
    NSMutableArray *_placemarks;
    
    KMLPlacemark *_placemark;
    KMLStyle *_style;
    
    NSXMLParser *_xmlParser;
}

- (id)initWithURL:(NSURL *)url;
- (void)parseKML;

@property (nonatomic, readonly) NSArray *overlays;
@property (nonatomic, readonly) NSArray *points;

- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point;
- (MKOverlayView *)viewForOverlay:(id <MKOverlay>)overlay;

@end
