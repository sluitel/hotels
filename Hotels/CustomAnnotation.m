//
//  CustomAnnotation.m
//  Hotels
//
//  Created by Subash Luitel on 11/20/14.
//  Copyright (c) 2014 Luitel. All rights reserved.
//

#import "CustomAnnotation.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation CustomAnnotation

@synthesize coordinate;
@synthesize hotelName;
@synthesize imageURL;
@synthesize title;
@synthesize subtitle;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
	self = [super init];
	if (self) {
		coordinate = coord;
	}
	return self;
}




@end
