//
//  MapViewController.m
//  Hotels
//
//  Created by Subash Luitel on 11/20/14.
//  Copyright (c) 2014 Luitel. All rights reserved.
//

#import "MapViewController.h"
#import "CustomAnnotation.h"
#import "WYPopoverController.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface MapViewController ()

@end

// We need a custom subclass of MKMapView in order to allow touches on UIControls in our custom callout view.
@interface CustomMapView : MKMapView
@property (nonatomic, strong) SMCalloutView *calloutView;
@end


//
// Custom Map View
//
// We need to subclass MKMapView in order to present an SMCalloutView that contains interactive
// elements.
//

@interface MKMapView (UIGestureRecognizer)

// this tells the compiler that MKMapView actually implements this method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

@end

@implementation CustomMapView

// override UIGestureRecognizer's delegate method so we can prevent MKMapView's recognizer from firing
// when we interact with UIControl subclasses inside our callout view.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if ([touch.view isKindOfClass:[UIControl class]])
		return NO;
	else
		return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}

// Allow touches to be sent to our calloutview.
// See this for some discussion of why we need to override this: https://github.com/nfarina/calloutview/pull/9
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	UIView *calloutMaybe = [self.calloutView hitTest:[self.calloutView convertPoint:point fromView:self] withEvent:event];
	if (calloutMaybe) return calloutMaybe;
	
	return [super hitTest:point withEvent:event];
}

@end



@implementation MapViewController


#pragma mark - View Hierarchy

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.annotation = [MKPointAnnotation new];
	self.annotation.coordinate = (CLLocationCoordinate2D){28.388154, -80.604200};
	self.annotation.title = @"Cape Canaveral";
	self.annotation.subtitle = @"Launchpad";
	
	self.mapView = [[CustomMapView alloc] initWithFrame:self.view.bounds];
	self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.mapView.delegate = self;
	[self.mapView addAnnotation:self.annotation];
	[self.view addSubview:self.mapView];
	
	// Set the map area to show city of chicago
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(41.894500000000001, -87.624300000000005), 1000, 1000);
	[self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
	
	//[self addAnnotations];
	
	// create our custom callout view
	self.calloutView = [SMCalloutView platformCalloutView];
	self.calloutView.delegate = self;
	[self.view addSubview:self.calloutView];

	
	// tell our custom map view about the callout so it can send it touches
	self.mapView.calloutView = self.calloutView;
}


//
// MKMapView delegate methods
//

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	
	// create a proper annotation view, be lazy and don't use the reuse identifier
	MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@""];
	
	// create a disclosure button for map kit
	UIButton *disclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[disclosure addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disclosureTapped)]];
	view.rightCalloutAccessoryView = disclosure;
	
	// if we're using SMCalloutView, we don't want MKMapView to create its own callout!
	if (annotation == self.annotation)
		view.canShowCallout = NO;
	else
		view.canShowCallout = YES;
	
	return view;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView {
	
	if (mapView == self.mapView) {
		
		// apply the MKAnnotationView's basic properties
		self.calloutView.title = annotationView.annotation.title;
		self.calloutView.subtitle = annotationView.annotation.subtitle;
		
		// Apply the MKAnnotationView's desired calloutOffset (from the top-middle of the view)
		self.calloutView.calloutOffset = annotationView.calloutOffset;
		
		// create a disclosure button for comparison
		UIButton *disclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[disclosure addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disclosureTapped)]];
		self.calloutView.rightAccessoryView = disclosure;
		
		// iOS 7 only: Apply our view controller's edge insets to the allowable area in which the callout can be displayed.
		if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
			self.calloutView.constrainedInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
		
		// This does all the magic.
		[self.calloutView presentCalloutFromRect:annotationView.bounds inView:annotationView constrainedToView:self.view animated:YES];
	}
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	
	[self.calloutView dismissCalloutAnimated:YES];
}

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

- (void)disclosureTapped {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tap!" message:@"You tapped the disclosure button."
												   delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
	[alert show];
}











#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Create placemark for hotels and show it on the map
-(void)addAnnotations {
	NSMutableArray *annotations = [NSMutableArray array];
	
	for (int i = 0; i<self.hotels.count; i++) {
		NSDictionary *dictionary = [[NSDictionary alloc] initWithDictionary:[self.hotels objectAtIndex:i]];
		double latitude = [[dictionary objectForKey:@"latitude"] doubleValue];
		double longitude = [[dictionary objectForKey:@"longitude"] doubleValue];
		
		// Add an annotation
		CustomAnnotation *point = [[CustomAnnotation alloc] initWithLocation:CLLocationCoordinate2DMake(latitude, longitude)];
		point.imageURL = [dictionary objectForKey:@"thumbnail"];
		
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
