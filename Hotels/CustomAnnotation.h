//
//  CustomAnnotation.h
//  Hotels
//
//  Created by Subash Luitel on 11/20/14.
//  Copyright (c) 2014 Luitel. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotation : MKPlacemark <MKAnnotation>

@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *hotelName;
@property (copy, nonatomic) NSURL *imageURL;

//-(id)initWithHotelName:(NSString *)name location:(CLLocationCoordinate2D)location thumbnailURL:(NSURL *)URL;
//-(MKAnnotationView *)annotationView;

@end
