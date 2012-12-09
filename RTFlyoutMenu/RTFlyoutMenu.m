//
//  RTFlyoutMenu.m
//  RTFlyoutMenu
//
//  Created by Aleksandar Vacić on 27.11.12..
//  Copyright (c) 2012. Aleksandar Vacić. All rights reserved.
//

#import "RTFlyoutMenu.h"
#import "RTFlyoutItem.h"

NSString *const RTFlyoutMenuUIOptionMenuMargins = @"kRTFlyoutMenuUIOptionMenuMargins";
NSString *const RTFlyoutMenuUIOptionInnerItemSize = @"kRTFlyoutMenuUIOptionInnerItemSize";
NSString *const RTFlyoutMenuUIOptionContentInsets = @"kRTFlyoutMenuUIOptionContentInsets";
NSString *const RTFlyoutMenuUIOptionAnimationDuration = @"kRTFlyoutMenuUIOptionAnimationDuration";


@implementation RTFlyoutMenu

#pragma mark - Init

- (id)initWithDelegate:(id <RTFlyoutMenuDelegate>)delegate dataSource:(id <RTFlyoutMenuDataSource>)dataSource position:(RTFlyoutMenuPosition)position options:(NSDictionary *)options {
    if (delegate && [delegate conformsToProtocol:@protocol(RTFlyoutMenuDelegate)]) {
        _delegate = delegate;
        _dataSource = dataSource;
		
		[self setupDefaults];

		_position = position;
		switch (position) {
			case kRTFlyoutMenuPositionTop:
				_unfoldDirection = kRTFlyoutMenuUnfoldDirectionBottom;
				break;
				
			case kRTFlyoutMenuPositionBottom:
				_unfoldDirection = kRTFlyoutMenuUnfoldDirectionTop;
				break;
				
			default:
				_unfoldDirection = kRTFlyoutMenuUnfoldDirectionBottom;
				break;
		}
		
		//	process options
		if (options) {
			[options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
				if ([key isEqualToString:RTFlyoutMenuUIOptionContentInsets])
					self.contentInsets = [obj UIEdgeInsetsValue];
				else if ([key isEqualToString:RTFlyoutMenuUIOptionAnimationDuration])
					self.animationDuration = (CGFloat)[(NSNumber *)obj floatValue];
				else if ([key isEqualToString:RTFlyoutMenuUIOptionInnerItemSize])
					self.innerItemSize = [obj CGSizeValue];
				else if ([key isEqualToString:RTFlyoutMenuUIOptionMenuMargins])
					self.menuMargins = [obj UIEdgeInsetsValue];
			}];
		}
		
        self = [self initWithFrame:CGRectZero];
		
		[self fetchData];
		[self renderMainMenu];
		
		return self;
    }
    
    return nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {}
    
    return self;
}

- (void)setupDefaults {
	//	behavior
	_position = kRTFlyoutMenuPositionTop;
	_unfoldDirection = kRTFlyoutMenuUnfoldDirectionBottom;
	_indexOfOpenSubmenu = -1;

	//	look & feel
	_menuMargins = UIEdgeInsetsMake(5, 5, 5, 5);
	_contentInsets = UIEdgeInsetsMake(5, 5, 5, 5);
	_innerItemSize = CGSizeMake(22, 22);
	_mainItemInsets = UIEdgeInsetsMake(4, 8, 4, 8);
	_subItemInsets = UIEdgeInsetsMake(4, 8, 4, 8);
	_animationDuration = .2;
	
	//	data
	_numberOfMainItems = 0;
	_mainItemTitles = [NSMutableArray array];
	_subItemTitles = [NSMutableArray array];
	
	//	rendered
	_mainItems = nil;
	_mainItemFrames = nil;
	_submenus = nil;
}


#pragma mark - Data source

- (void)fetchData {

	if ([self.dataSource respondsToSelector:@selector(numberOfMainItemsInFlyoutMenu:)]) {
		self.numberOfMainItems = [self.dataSource numberOfMainItemsInFlyoutMenu:self];

		_mainItems = [NSMutableArray arrayWithCapacity:self.numberOfMainItems];
		_mainItemFrames = [NSMutableArray arrayWithCapacity:self.numberOfMainItems];
		_submenus = [NSMutableDictionary dictionaryWithCapacity:self.numberOfMainItems];
	}

	if ([self.dataSource respondsToSelector:@selector(flyoutMenu:titleForMainItem:)]) {
		for (NSUInteger i = 0; i < self.numberOfMainItems; i++) {
			NSString *t = [self.dataSource flyoutMenu:self titleForMainItem:i];
			if ([t length] == 0) t = @"";
			[self.mainItemTitles addObject:t];
		}
	}
	
	if ([self.dataSource respondsToSelector:@selector(flyoutMenu:numberOfItemsInSubmenu:)] && [self.dataSource respondsToSelector:@selector(flyoutMenu:titleForSubItem:inMainItem:)]) {

		for (NSUInteger i = 0; i < self.numberOfMainItems; i++) {
			NSUInteger numberOfSubItems = [self.dataSource flyoutMenu:self numberOfItemsInSubmenu:i];
			NSMutableArray *a = [NSMutableArray array];
			for (NSUInteger j = 0; j < numberOfSubItems; j++) {
				NSString *t = [self.dataSource flyoutMenu:self titleForSubItem:j inMainItem:i];
				if ([t length] == 0) t = @"";
				[a addObject:t];
			}
			[self.subItemTitles addObject:a];
		}
	}
	
}


#pragma mark - Rendering

- (void)renderMainMenu {
	
	UIFont *buttonFont = [UIFont fontWithName:@"AvenirNext-DemiBold" size:15.0];
	CGFloat currentX = self.contentInsets.left, currentY = self.contentInsets.top, itemHeight = 0;

	for (NSString *mainTitle in self.mainItemTitles) {
		CGSize titleTextSize = [mainTitle sizeWithFont:buttonFont constrainedToSize:CGSizeMake(1000, 1000)];
		if (titleTextSize.height < self.innerItemSize.height) titleTextSize.height = self.innerItemSize.height;

		RTFlyoutItem *btn = [RTFlyoutItem buttonWithType:UIButtonTypeCustom];
		btn.mainItemIndex = [self.mainItemTitles indexOfObject:mainTitle];
		btn.subItemIndex = -1;
		[btn setFrame:CGRectMake(currentX, currentY, titleTextSize.width + self.mainItemInsets.left + self.mainItemInsets.right, titleTextSize.height + self.mainItemInsets.top + self.mainItemInsets.bottom)];
		[btn setTitleEdgeInsets:self.mainItemInsets];
		[btn.titleLabel setFont:buttonFont];
		[btn setBackgroundColor:[UIColor clearColor]];
		[btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[btn setTitle:mainTitle forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		currentX += btn.bounds.size.width;
		if (itemHeight < btn.bounds.size.height) itemHeight = btn.bounds.size.height;
		
//		[btn setBackgroundColor:[UIColor greenColor]];
		[self addSubview:btn];
		[self.mainItems addObject:btn];
		[self.mainItemFrames addObject:[NSValue valueWithCGRect:btn.frame]];
	}

	CGRect f = self.frame;
	f.size = CGSizeMake(currentX + self.contentInsets.right, itemHeight + self.contentInsets.top + self.contentInsets.bottom);
	self.frame = f;

	//	render background image
	UIImage *resizedBgImage = [[UIImage imageNamed:@"mainBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 5, 23, 5)];
    UIImageView *mainBackgroundImageView = [[UIImageView alloc] initWithImage:resizedBgImage];
	mainBackgroundImageView.frame = (CGRect){.size=self.bounds.size};
	mainBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:mainBackgroundImageView];
    [self sendSubviewToBack:mainBackgroundImageView];

}

- (UIView *)renderSubmenuAtIndex:(NSUInteger)index {
	
	UIView *sv = nil;
	
	if ([self.submenus objectForKey:@(index)]) {
		sv = [self.submenus objectForKey:@(index)];

	} else {
		UIFont *buttonFont = [UIFont fontWithName:@"AvenirNext-DemiBold" size:15.0];
		CGRect mainItemFrame = [[self.mainItemFrames objectAtIndex:index] CGRectValue];
		
		CGFloat currentX = self.contentInsets.left, currentY = self.contentInsets.top, itemWidth = 0;
		sv = [[UIView alloc] initWithFrame:CGRectZero];
		sv.clipsToBounds = YES;
		
		NSArray *subtitles = [self.subItemTitles objectAtIndex:index];
		
		if ([subtitles count] == 0) return sv;
		
		for (NSString *subTitle in subtitles) {
			CGSize titleTextSize = [subTitle sizeWithFont:buttonFont constrainedToSize:CGSizeMake(1000, 1000)];
			if (titleTextSize.height < self.innerItemSize.height) titleTextSize.height = self.innerItemSize.height;
			
			RTFlyoutItem *btn = [RTFlyoutItem buttonWithType:UIButtonTypeCustom];
			btn.mainItemIndex = index;
			btn.subItemIndex = [subtitles indexOfObject:subTitle];
			[btn setFrame:CGRectMake(currentX, currentY, titleTextSize.width + self.subItemInsets.left + self.subItemInsets.right, titleTextSize.height + self.subItemInsets.top + self.subItemInsets.bottom)];
			[btn setTitleEdgeInsets:self.subItemInsets];
			[btn.titleLabel setFont:buttonFont];
			[btn setBackgroundColor:[UIColor clearColor]];
			[btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
			[btn setTitle:subTitle forState:UIControlStateNormal];
			[btn addTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];
			
			currentY += btn.bounds.size.height;
			if (itemWidth < btn.bounds.size.width) itemWidth = btn.bounds.size.width;
			
//			[btn setBackgroundColor:[UIColor greenColor]];
			[sv addSubview:btn];
		}
		
		CGRect f = sv.frame;
		f.origin = CGPointMake(mainItemFrame.origin.x, mainItemFrame.origin.y + mainItemFrame.size.height - self.contentInsets.bottom);
		f.origin.y = 0;
		f.size = CGSizeMake(itemWidth + self.contentInsets.left + self.contentInsets.right, currentY + self.contentInsets.bottom);
		CGFloat diff = self.bounds.size.width - (f.origin.x + f.size.width);
		if (diff < 0) f.origin.x += diff;
		sv.frame = f;
		
		//	render background image
		UIImage *resizedBgImage = [[UIImage imageNamed:@"submenuBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(24, 5, 25, 5)];
		UIImageView *bgImageView = [[UIImageView alloc] initWithImage:resizedBgImage];
		bgImageView.frame = (CGRect){.size=sv.bounds.size};
		bgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[sv addSubview:bgImageView];
		[sv sendSubviewToBack:bgImageView];
		
		[self.submenus setObject:sv forKey:@(index)];
	}

	return sv;
}

- (void)updateMainItem:(RTFlyoutItem *)item withTitle:(NSString *)newTitle {
	
	UIFont *buttonFont = item.titleLabel.font;
	CGSize titleTextSize = [newTitle sizeWithFont:buttonFont constrainedToSize:CGSizeMake(1000, 1000)];
	if (titleTextSize.height < self.innerItemSize.height) titleTextSize.height = self.innerItemSize.height;

	//	re-calculate main item frames, find the difference between old and new frame size for tapped item
	NSInteger itemIndex = [self.mainItems indexOfObject:item];
	CGRect oldItemFrame = [[self.mainItemFrames objectAtIndex:itemIndex] CGRectValue];
	CGSize newFrameSize = CGSizeMake(titleTextSize.width + self.mainItemInsets.left + self.mainItemInsets.right, titleTextSize.height + self.mainItemInsets.top + self.mainItemInsets.bottom);
	
	CGFloat diff = newFrameSize.width - oldItemFrame.size.width;
	if (diff == 0) return;

	//	update menu frame
	CGRect menuFrame = self.frame;
	menuFrame.origin.x -= diff;
	menuFrame.size.width += diff;
	
	//	update tapped item
	CGRect f = oldItemFrame;
	f.size = newFrameSize;
	[self.mainItemFrames replaceObjectAtIndex:itemIndex withObject:[NSValue valueWithCGRect:f]];
	
	//	update items after the tapped one
	NSUInteger framesCount = [self.mainItemFrames count];
	for (NSInteger i = itemIndex+1; i < framesCount; i++) {
		CGRect fi = [[self.mainItemFrames objectAtIndex:i] CGRectValue];
		fi.origin.x += diff;
		[self.mainItemFrames replaceObjectAtIndex:i withObject:[NSValue valueWithCGRect:fi]];
	}
	
	//	animate the change
	[UIView animateWithDuration:self.animationDuration animations:^{
		self.frame = menuFrame;
		for (NSInteger i = itemIndex; i < framesCount; i++) {
			CGRect fi = [[self.mainItemFrames objectAtIndex:i] CGRectValue];
			[(RTFlyoutItem *)[self.mainItems objectAtIndex:i] setFrame:fi];
		}
		
	} completion:^(BOOL finished) {
		[item setTitle:newTitle forState:UIControlStateNormal];
	}];

}


#pragma mark - Actions

- (void)itemTapped:(RTFlyoutItem *)sender {
	NSLog(@"inner Button tap");
	
	BOOL isMainItem = (sender.subItemIndex == -1);
	//	if main item, then open/close that particular submenu
	if (isMainItem) {
		
		if (_indexOfOpenSubmenu == sender.mainItemIndex) {
			//	close this submenu
			UIView *sv = [self renderSubmenuAtIndex:sender.mainItemIndex];
			CGRect f = sv.frame, forig = f;
			f.size = CGSizeMake(f.size.width, 0);
			[UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationCurveEaseIn animations:^{
				sv.frame = f;
			} completion:^(BOOL finished) {
				[sv removeFromSuperview];
				sv.frame = forig;
			}];

			//	mark that nothing is open
			_indexOfOpenSubmenu = -1;
			
		} else if (_indexOfOpenSubmenu > -1) {
			//	close previously submenu
			{
				UIView *sv = [self renderSubmenuAtIndex:self.indexOfOpenSubmenu];
				CGRect f = sv.frame, forig = f;
				f.size = CGSizeMake(f.size.width, 0);
				[UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationCurveEaseIn animations:^{
					sv.frame = f;
				} completion:^(BOOL finished) {
					[sv removeFromSuperview];
					sv.frame = forig;
				}];
			}
			
			//	open tapped submenu
			{
				UIView *sv = [self renderSubmenuAtIndex:sender.mainItemIndex];
				CGRect f = sv.frame, ffinal = f;
				f.size = CGSizeMake(f.size.width, 0);
				sv.frame = f;
				[self addSubview:sv];
				[UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationCurveEaseIn animations:^{
					sv.frame = ffinal;
				} completion:nil];
			}
			
			//	mark as open
			_indexOfOpenSubmenu = sender.mainItemIndex;

		} else {
			//	open this submenu
			{
				UIView *sv = [self renderSubmenuAtIndex:sender.mainItemIndex];
				CGRect f = sv.frame, ffinal = f;
				f.size = CGSizeMake(f.size.width, 0);
				sv.frame = f;
				[self addSubview:sv];
				[UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationCurveEaseIn animations:^{
					sv.frame = ffinal;
				} completion:nil];
			}
			
			//	mark as open
			_indexOfOpenSubmenu = sender.mainItemIndex;
			
		}

	} else {
		//	if subitem, then update main item text
		RTFlyoutItem *mainBtn = [self.mainItems objectAtIndex:sender.mainItemIndex];
		NSString *subTitle = [sender titleForState:UIControlStateNormal];
		[self updateMainItem:mainBtn withTitle:subTitle];

		//	and close the submenu
		{
			UIView *sv = [self renderSubmenuAtIndex:self.indexOfOpenSubmenu];
			CGRect f = sv.frame, forig = f;
			f.size = CGSizeMake(f.size.width, 0);
			[UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationCurveEaseIn animations:^{
				sv.frame = f;
			} completion:^(BOOL finished) {
				[sv removeFromSuperview];
				sv.frame = forig;
			}];
		}
		
		_indexOfOpenSubmenu = -1;
	}
	
	//	inform delegate
	if (isMainItem && [self.delegate respondsToSelector:@selector(flyoutMenu:didSelectMainItemWithIndex:)]) {
		[self.delegate flyoutMenu:self didSelectMainItemWithIndex:sender.mainItemIndex];
	} else if ([self.delegate respondsToSelector:@selector(flyoutMenu:didSelectSubItemWithIndex:mainMenuItemIndex:)]) {
		[self.delegate flyoutMenu:self didSelectSubItemWithIndex:sender.subItemIndex mainMenuItemIndex:sender.mainItemIndex];
	}
	
}

- (void)reloadData {
	
	//	reset
	[self.submenus removeAllObjects];
	[self.mainItemFrames removeAllObjects];
	[self.mainItemTitles removeAllObjects];
	[self.subItemTitles removeAllObjects];
	self.numberOfMainItems = 0;
	self.indexOfOpenSubmenu = -1;

	//	get data
	[self fetchData];

	//	remove menu
	[self removeFromSuperview];
	self.frame = CGRectZero;
	
	//	re-render
	[self renderMainMenu];
	
}

@end
