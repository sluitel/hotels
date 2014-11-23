//
//  CustomAnnotation.h
//  Hotels
//
//  Created by Subash Luitel on 11/20/14.
//  Copyright (c) 2014 Luitel. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *hotelName;
@property (copy, nonatomic) NSURL *imageURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;


@end
