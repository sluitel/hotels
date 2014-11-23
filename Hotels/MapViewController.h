//
//  MapViewController.h
//  Hotels
//
//  Created by Subash Luitel on 11/20/14.
//  Copyright (c) 2014 Luitel. All rights reserved.
//

@class CustomMapView;

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SMCalloutView.h"
#import "HotelAnnotation.h"


@interface MapViewController : UIViewController <MKMapViewDelegate, SMCalloutViewDelegate>

@property (nonatomic, strong) CustomMapView *mapView;
@property (nonatomic, strong) SMCalloutView *calloutView;
@property (nonatomic, strong) MKPointAnnotation *annotation;

@property (nonatomic, strong) NSArray *hotels;




@end
