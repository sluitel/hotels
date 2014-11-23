//
//  HotelCell.m
//  Hotels
//
//  Created by Subash Luitel on 11/20/14.
//  Copyright (c) 2014 Luitel. All rights reserved.
//

#import "HotelCell.h"

@implementation HotelCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.hotelName.textAlignment = NSTextAlignmentLeft;
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
