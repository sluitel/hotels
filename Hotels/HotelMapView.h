//
//  HotelMapView.h
//  Hotels
//
//  Created by Subash Luitel on 11/22/14.
//  Copyright (c) 2014 Luitel. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "SMCalloutView.h"

@interface HotelMapView : MKMapView

@property (nonatomic, strong) SMCalloutView *calloutView;


@end

@interface MKMapView (UIGestureRecognizer)

// this tells the compiler that MKMapView actually implements this method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

@end
