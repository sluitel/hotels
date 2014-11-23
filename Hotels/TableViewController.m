//
//  TableViewController.m
//  Hotels
//
//  Created by Subash Luitel on 11/20/14.
//  Copyright (c) 2014 Luitel. All rights reserved.
//

#import "TableViewController.h"
#import "HotelCell.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface TableViewController ()

@property (strong, nonatomic) NSArray *hotels;

@end

@implementation TableViewController

#pragma mark - View Hierarchy

- (void)viewDidLoad {
    [super viewDidLoad];
    
	// Table view Separator Inset
	[self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 60, 0, 0)];
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.hotels.count;
}


#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    HotelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	if (cell == nil) {
		cell = [[HotelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	}
	
    // Configure the cell...
	NSDictionary *hotelDic = [self.hotels objectAtIndex:indexPath.row];
	NSURL *thumbnailURL = [NSURL URLWithString:[hotelDic objectForKey:@"thumbnail"]];
	
	cell.hotelName.text = [hotelDic objectForKey:@"name"];
	[cell.thumbnailView sd_setImageWithURL:thumbnailURL placeholderImage:nil options:SDWebImageContinueInBackground];
    return cell;
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
