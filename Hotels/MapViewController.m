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
#import "PopupViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface MapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *hotels;
@property (nonatomic, strong) WYPopoverController *annotationPopover;
@property (nonatomic, retain, readonly) PopupViewController *popUp;


@end

@implementation MapViewController
@synthesize popUp = _popUp;

#pragma mark - View Hierarchy

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.annotationPopover.popoverContentSize = CGSizeMake(200, 80.0);
	
	// Check for ios 8
	if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
		[self.locationManager requestWhenInUseAuthorization];
	}
	self.mapView.delegate = self;
	
	// Set the map area to show city of chicago
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(41.894500000000001, -87.624300000000005), 1000, 1000);
	[self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
	
	[self addAnnotations];

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
//		CustomAnnotation *placemark = [[CustomAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
//		[placemark setHotelName:[dictionary objectForKey:@"name"]];
//		[placemark setImageURL:[NSURL URLWithString:[dictionary objectForKey:@"thumbnail"]]];
//		[annotations addObject:placemark];
		
		// Add an annotation
		MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
		point.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		point.title = [dictionary objectForKey:@"name"];
		point.subtitle = [dictionary objectForKey:@"name"];
		
		//[self.mapView addAnnotation:point];
		[annotations addObject:point];
	}
	[self.mapView addAnnotations:annotations];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
//	if (![annotation isKindOfClass:[CustomAnnotation class]])
//		return nil;
	
	MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
																	   reuseIdentifier:@"CustomAnnotationView"];
	annotationView.canShowCallout = YES;
	[annotationView sizeToFit];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Test"]];
	//[imageView setFrame:annotationView.leftCalloutAccessoryView.frame];
	[imageView setClipsToBounds:YES];
	annotationView.leftCalloutAccessoryView = imageView;
	
	return annotationView;
}



//Animate the pins.. Source:http://stackoverflow.com/a/7045872/1271826
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView *annotationView;
	
	for (annotationView in views) {
		// Check if current annotation is inside visible map rect, else go to next one
		MKMapPoint point =  MKMapPointForCoordinate(annotationView.annotation.coordinate);
		if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
			continue;
		}
		
		CGRect endFrame = annotationView.frame;
		
		// Move annotation out of view
		annotationView.frame = CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y - self.view.frame.size.height, annotationView.frame.size.width, annotationView.frame.size.height);
		
		// Animate drop
		[UIView animateWithDuration:0.4
							  delay:0.04*[views indexOfObject:annotationView]
							options:UIViewAnimationOptionCurveLinear
						 animations:^{
							 
							 annotationView.frame = endFrame;
							 
							 // Animate squash
						 }
						 completion:^(BOOL finished){
							 if (finished) {
								 [UIView animateWithDuration:0.05
												  animations:^{
													  annotationView.transform = CGAffineTransformMakeScale(1.0, 0.8);
													  
												  }
												  completion:^(BOOL finished){
													  if (finished) {
														  [UIView animateWithDuration:0.1 animations:^{
															  annotationView.transform = CGAffineTransformIdentity;
														  }];
													  }
												  }];
				}
			}];
	}
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	
	if ([view.annotation isKindOfClass:[CustomAnnotation class]])
	{
		CustomAnnotation *annotation = (CustomAnnotation *)view.annotation;
		[self.popUp.hotelName setText:annotation.hotelName];
		[self.popUp.imageView sd_setImageWithURL:annotation.imageURL];
		
		[self.annotationPopover presentPopoverFromRect:view.frame inView:self.view permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
	}
}

-(PopupViewController *)popUp {
	if (!_popUp) {
		UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
		_popUp = [storyboad instantiateViewControllerWithIdentifier:@"PopUpViewControllerID"];
	}
	return _popUp;
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
