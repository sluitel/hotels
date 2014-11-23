//
//  HotelAnnotation.h
//  Hotels
//
//  Created by Subash Luitel on 11/23/14.
//  Copyright (c) 2014 Luitel. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface HotelAnnotation : MKPointAnnotation

@property (nonatomic, copy) NSString *hotelName;
@property (nonatomic, copy) NSURL *thumbnailURL;

@end
