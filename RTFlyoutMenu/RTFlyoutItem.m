//
//  RTFlyoutItem.m
//  RTFlyoutMenu
//
//  Created by Aleksandar Vacić on 28.11.12..
//  Copyright (c) 2012. Aleksandar Vacić. All rights reserved.
//

#import "RTFlyoutItem.h"

@interface RTFlyoutItem ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSUInteger index;

@end

@implementation RTFlyoutItem

+ (id)itemWithImage:(UIImage *)image title:(NSString *)title index:(NSUInteger)index {

//	RTFlyoutItem *item = [[RTFlyoutItem alloc] initWithFrame:CGRectZero];
	RTFlyoutItem *item = [RTFlyoutItem buttonWithType:UIButtonTypeCustom];
	if (item) {
		item.image = image;
		item.title = title;
		item.index = index;
		
		[item setupItem];
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

	if (self.image) {
		[self setImage:self.image forState:UIControlStateNormal];
		CGSize imgSize = self.image.size;
		if ([self.title length] > 0)
			[self setTitleEdgeInsets:UIEdgeInsetsMake(0, imgSize.width+8, 0, 8)];
	}

	if ([self.title length] > 0) {
		[self setTitle:self.title forState:UIControlStateNormal];
	}

	[self sizeToFit];
	
}

@end
