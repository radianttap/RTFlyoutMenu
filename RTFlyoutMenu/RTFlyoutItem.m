//
//  RTFlyoutItem.m
//  RTFlyoutMenu
//
//  Created by Aleksandar Vacić on 28.11.12..
//  Copyright (c) 2012. Aleksandar Vacić. All rights reserved.
//

#import "RTFlyoutItem.h"

@interface RTFlyoutItem ()

@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic) NSUInteger index;
@property (nonatomic, copy) UIImage *originalImage;
@property (nonatomic, copy) NSString *originalTitle;

@end

@implementation RTFlyoutItem

+ (id)itemWithImage:(UIImage *)image title:(NSString *)title index:(NSUInteger)index {

//	RTFlyoutItem *item = [[RTFlyoutItem alloc] initWithFrame:CGRectZero];
	RTFlyoutItem *item = [RTFlyoutItem buttonWithType:UIButtonTypeCustom];
	if (item) {
		item.image = image;
		item.title = title;
		item.index = index;
		item.originalImage = image;
		item.originalTitle = title;
		
		[item setupItem];
		item.userInteractionEnabled = YES;
	}

	return item;
}
/*
- (id)initWithFrame:(CGRect)frame {
	
	self = [super initWithFrame:frame];
	if (self) {

	}
	
	return self;
}
*/

- (void)setupItem {

	self.active = NO;
	
	//	look&feel
	[self.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:15.0]];
	self.titleLabel.shadowOffset = CGSizeMake(0, 1);
	self.backgroundColor = [UIColor greenColor];

	if (self.image) {
		[self setImage:self.image forState:UIControlStateNormal];
		CGSize imgSize = self.image.size;
		if ([self.title length] > 0)
			[self setTitleEdgeInsets:UIEdgeInsetsMake(0, imgSize.width+8, 0, 8)];
	}

	if ([self.title length] > 0) {
		[self setTitle:self.title forState:UIControlStateNormal];
	}

	[self resize];
}

- (void)resize {
	[self sizeToFit];
	
	CGRect f = self.frame;
	if (f.size.height < 28) f.size.height = 28;
	self.frame = f;
}

- (void)updateWithChildItem:(RTFlyoutItem *)childItem {
	
	[self setTitle:childItem.title forState:UIControlStateNormal];
	[self setImage:childItem.image forState:UIControlStateNormal];

	[self resize];
}

- (void)resetToOriginal {

	[self setTitle:self.originalTitle forState:UIControlStateNormal];
	[self setImage:self.originalImage forState:UIControlStateNormal];

	[self resize];
}


@end
