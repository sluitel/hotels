//
//  MapViewController.m
//  Hotels
//
//  Created by Subash Luitel on 11/20/14.
//  Copyright (c) 2014 Luitel. All rights reserved.
//
//	We need a custom subclass of MKMapView in order to allow touches on UIControls in custom callout view.

#import "MapViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>


#pragma mark - Custom Map View Interface

@interface CustomMapView : MKMapView
@property (nonatomic, strong) SMCalloutView *calloutView;
@end


#pragma mark - MKMapView(UIGestureRecognizer)

@interface MKMapView (UIGestureRecognizer)

// this tells the compiler that MKMapView actually implements this method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

@end

#pragma mark - Custom Map View Implementation

@implementation CustomMapView

// Override UIGesture Delegate Methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if ([touch.view isKindOfClass:[UIControl class]])
		return NO;
	else
		return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}

// Allow touches to be sent to calloutview.
// some discussion of why we need to override this: https://github.com/nfarina/calloutview/pull/9
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	UIView *customCalloutView = [self.calloutView hitTest:[self.calloutView convertPoint:point fromView:self] withEvent:event];
	if (customCalloutView) return customCalloutView;
	
	return [super hitTest:point withEvent:event];
}

@end

#pragma mark - MapViewController Implementation

@implementation MapViewController

#pragma mark - View Hierarchy

- (void)viewDidLoad {
    [super viewDidLoad];
	
	calloutCount = 0;
	
	// Create a custom map view
	self.mapView = [[CustomMapView alloc] initWithFrame:self.view.bounds];
	self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.mapView.delegate = self;
	[self.view addSubview:self.mapView];
	
	// Set the map area to show city of chicago
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(41.894500000000001, -87.624300000000005), 1000, 1000);
	[self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
	
	[self addAnnotations];
	
	// create custom callout view
	self.calloutView = [SMCalloutView platformCalloutView];
	self.calloutView.delegate = self;
	[self.view addSubview:self.calloutView];
	
	// tell custom map view about the callout so it can send it touches
	self.mapView.calloutView = self.calloutView;
}


#pragma mark - MKMapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	
	// create a proper annotation view
	MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PinAnnotationID"];
	
	view.canShowCallout = NO;
	
	return view;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView {
	
	if (mapView == self.mapView) {
		
		HotelAnnotation *annotation = (HotelAnnotation *)annotationView.annotation;
		
		UIImageView *hotelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.calloutView.frame.size.height, self.calloutView.frame.size.height)];
		[hotelImageView setBackgroundColor:[UIColor grayColor]];
		[hotelImageView sd_setImageWithURL:annotation.thumbnailURL];
		self.calloutView.leftAccessoryView = hotelImageView;
		
		self.calloutView.title = annotation.hotelName;
		self.calloutView.calloutOffset = annotationView.calloutOffset;
		
		
		// iOS 7 only: Apply view controller's edge insets to the allowable area in which the callout can be displayed.
		if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
			self.calloutView.constrainedInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
		
		[self.calloutView presentCalloutFromRect:annotationView.bounds inView:annotationView constrainedToView:self.view animated:YES];
	}
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	
	[self.calloutView dismissCalloutAnimated:YES];
}

#pragma mark - SMCalloutView Delegate

- (NSTimeInterval)calloutView:(SMCalloutView *)calloutView delayForRepositionWithSize:(CGSize)offset {
	
	// When the callout is being asked to present in a way where it or its target will be partially offscreen, it asks us
	// if we'd like to reposition our surface first so the callout is completely visible. Here we scroll the map into view,
	// but it takes some math because we have to deal in lon/lat instead of the given offset in pixels.
	
	CLLocationCoordinate2D coordinate = self.mapView.centerCoordinate;
	
	// where's the center coordinate in terms of our view?
	CGPoint center = [self.mapView convertCoordinate:coordinate toPointToView:self.view];
	
	// move it by the requested offset
	center.x -= offset.width;
	center.y -= offset.height;
	
	// and translate it back into map coordinates
	coordinate = [self.mapView convertPoint:center toCoordinateFromView:self.view];
	
	// move the map!
	[self.mapView setCenterCoordinate:coordinate animated:YES];
	
	// tell the callout to wait for a while while we scroll (we assume the scroll delay for MKMapView matches UIScrollView)
	return kSMCalloutViewRepositionDelayForUIScrollView;
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Annotations

// Create placemark for hotels and show it on the map
-(void)addAnnotations {
	NSMutableArray *annotations = [NSMutableArray array];
	
	for (int i = 0; i<self.hotels.count; i++) {
		NSDictionary *dictionary = [[NSDictionary alloc] initWithDictionary:[self.hotels objectAtIndex:i]];
		double latitude = [[dictionary objectForKey:@"latitude"] doubleValue];
		double longitude = [[dictionary objectForKey:@"longitude"] doubleValue];
		
		// Add an annotation
		HotelAnnotation *point = [HotelAnnotation new];
		point.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		point.hotelName = [dictionary objectForKeyedSubscript:@"name"];
		point.thumbnailURL = [NSURL URLWithString:[dictionary objectForKeyedSubscript:@"thumbnail"]];
		[annotations addObject:point];
	}
	[self.mapView addAnnotations:annotations];
}



#pragma mark - Hotel Data
-(NSArray *)hotels {
	if (!_hotels) {
		// Get data from hotels.json file
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"hotels" ofType:@"json"];
		NSData *data = [NSData dataWithContentsOfFile:filePath];
		NSDictionary *hotelDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		NSError *error = nil;
		
		if (!hotelDictionary) {
			NSLog(@"Error parsing JSON: %@", error);
			_hotels = [[NSArray alloc] init];
		}
		else {
			
			_hotels = [[NSArray alloc] initWithArray:[hotelDictionary objectForKey:@"hotels"]];
		}
	}
	return _hotels;
}



@end
