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
#import <SDWebImage/UIImageView+WebCache.h>
#import "SMCalloutView.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, SMCalloutViewDelegate>


@end
