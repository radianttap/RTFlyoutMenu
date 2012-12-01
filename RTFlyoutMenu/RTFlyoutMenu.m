//
//  RTFlyoutMenu.m
//  RTFlyoutMenu
//
//  Created by Aleksandar Vacić on 27.11.12..
//  Copyright (c) 2012. Aleksandar Vacić. All rights reserved.
//

#import "RTFlyoutMenu.h"
#import "RTFlyoutItem.h"

NSString *const RTFlyoutMenuUIOptionMainButtonSize = @"kRTFlyoutMenuUIOptionMainButtonSize";
NSString *const RTFlyoutMenuUIOptionMainStaticSize = @"kRTFlyoutMenuUIOptionMainStaticSize";
NSString *const RTFlyoutMenuUIOptionMenuMargins = @"kRTFlyoutMenuUIOptionMenuMargins";
NSString *const RTFlyoutMenuUIOptionInnerButtonSize = @"kRTFlyoutMenuUIOptionInnerButtonSize";
NSString *const RTFlyoutMenuUIOptionContentInsets = @"kRTFlyoutMenuUIOptionContentInsets";
NSString *const RTFlyoutMenuUIOptionInterItemSpacing = @"kRTFlyoutMenuUIOptionInterItemSpacing";
NSString *const RTFlyoutMenuUIOptionAnimationDuration = @"kRTFlyoutMenuUIOptionAnimationDuration";


@implementation RTFlyoutMenu

- (id)initWithDelegate:(id <RTFlyoutMenuDelegate>)delegate kind:(RTFlyoutMenuKind)kind position:(RTFlyoutMenuPosition)position unfoldDirection:(RTFlyoutMenuUnfoldDirection)direction options:(NSDictionary *)options {
    if (delegate && [delegate conformsToProtocol:@protocol(RTFlyoutMenuDelegate)]) {
        _delegate = delegate;
		
		[self setupDefaults];
		_position = position;
		_kind = kind;
		_unfoldDirection = direction;
		
		self.items = [NSMutableArray array];
		
		//	process options
		if (options) {
			[options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
				if ([key isEqualToString:RTFlyoutMenuUIOptionMainStaticSize])
					self.menuStaticSize = [obj CGSizeValue];
				else if ([key isEqualToString:RTFlyoutMenuUIOptionInterItemSpacing])
					self.interItemSpacing = (CGFloat)[(NSNumber *)obj floatValue];
			}];
		}

        self = [self initWithFrame:CGRectZero];
		return self;
    }
    
    return nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
    }
    
    return self;
}

- (void)setupDefaults {
	_kind = kRTFlyoutMenuKindHovering;
	_position = kRTFlyoutMenuPositionBottomRight;
	_unfoldDirection = kRTFlyoutMenuUnfoldDirectionLeft;
	_unfolded = NO;
	_submenuOpened = NO;

	_mainButtonSize = CGSizeMake(28, 28);
	_menuHoverSize = CGSizeMake(44, 44);
	_menuStaticSize = CGSizeZero;
	_menuMargins = UIEdgeInsetsMake(5, 5, 5, 5);
	_contentInsets = UIEdgeInsetsMake(5, 5, 5, 5);
	_innerItemSize = CGSizeMake(22, 22);
	_interItemSpacing = 5;
	_animationDuration = .2;
}

- (void)setParentView:(UIView *)view {
    _parentView = view;

}

#pragma mark - Actions

- (void)mainButtonPressed {
    if (!_unfolded) {
        [self unfoldWithAnimationDuration:self.animationDuration];
    } else {
        [self foldWithAnimationDuration:self.animationDuration];
    }
}

- (void)innerButtonPressed:(RTFlyoutItem *)sender {
	NSLog(@"inner Button tap");

    if (sender.parentItem) {
		//	get tapped item text and replace the parent item text
		[sender.parentItem updateWithChildItem:sender];
		
		//	collapse the submenu
		[sender.submenu removeFromSuperview];

	} else {
		//	open submenu
		[self openSubmenuForParentItem:sender unfoldDirection:kRTFlyoutMenuUnfoldDirectionBottom];
		
	}
	
	if (_delegate && [_delegate respondsToSelector:@selector(flyoutMenu:didActivateItemWithIndex:)]) {
//        [_delegate flyoutMenu:self didActivateItemWithIndex:[self.levelOneItems indexOfObject:sender]];
    }

    //	also send NSNotification?
}

#pragma mark - 
- (void)unfoldWithAnimationDuration:(CGFloat)duration {
    [UIView animateWithDuration:duration animations:^{
        CGRect newFrame = [self createUnfoldedMainFrameForPosition:_position];
        [self setFrame:newFrame];
        [_mainBackgroundImageView setAlpha:.9f];
        
        CGAffineTransform xform = CGAffineTransformIdentity;
		switch (self.position) {
			case kRTFlyoutMenuPositionBottomRight:
			case kRTFlyoutMenuPositionTopRight:
				xform = CGAffineTransformMakeRotation(-M_PI_2);
				break;
				
			case kRTFlyoutMenuPositionBottomLeft:
			case kRTFlyoutMenuPositionTopLeft:
				xform = CGAffineTransformMakeRotation(M_PI_2);
				break;
				
			default:
				break;
		}
        [_mainButton setTransform:xform];
        
        _unfolded = YES;
    } completion:^(BOOL finished) {
        [_mainButton setBackgroundImage:[UIImage imageNamed:@"main-button-left.png"] forState:UIControlStateNormal];
        
        if (_delegate && [_delegate respondsToSelector:@selector(flyoutMenuDidUnfold:)]) {
            [_delegate flyoutMenuDidUnfold:self];
        }
        
		//	also send NSNotification?
    }];
}

- (void)foldWithAnimationDuration:(CGFloat)duration {
    [UIView animateWithDuration:duration animations:^{
        CGRect newFrame = [self createFoldedMainFrameForPosition:_position];
        [self setFrame:newFrame];
        [_contentView setFrame:[self createFoldedContentViewFrameForPosition:_position]];
        [_mainBackgroundImageView setAlpha:0.0f];
        
        CGAffineTransform xform = CGAffineTransformMakeRotation(0);
        [_mainButton setTransform:xform];
        
        _unfolded = NO;
    } completion:^(BOOL finished) {
        [_mainButton setBackgroundImage:[UIImage imageNamed:@"main-button-up.png"] forState:UIControlStateNormal];
        
        if (_delegate && [_delegate respondsToSelector:@selector(flyoutMenuDidFold:)]) {
            [_delegate flyoutMenuDidFold:self];
        }
        
		//	also send NSNotification?
    }];
}

#pragma mark -

- (RTFlyoutItem *)addItemWithImage:(UIImage *)image parentItem:(RTFlyoutItem *)parentItem {
	
	NSUInteger itemIndex = 0;
	if (parentItem) {
		itemIndex = [parentItem.items count];
	} else {
		itemIndex = [self.items count];
	}

	RTFlyoutItem *i = [RTFlyoutItem itemWithImage:image title:nil index:itemIndex];
	
	if (parentItem) {
		i.parentItem = parentItem;
		[parentItem.items addObject:i];
	} else {
		i.parentItem = nil;
		[self.items addObject:i];
	}
	
	return i;
}

- (RTFlyoutItem *)addItemWithTitle:(NSString *)title parentItem:(RTFlyoutItem *)parentItem {
	
	NSUInteger itemIndex = 0;
	if (parentItem) {
		itemIndex = [parentItem.items count];
	} else {
		itemIndex = [self.items count];
	}
	
	RTFlyoutItem *i = [RTFlyoutItem itemWithImage:nil title:title index:itemIndex];
	
	if (parentItem) {
		i.parentItem = parentItem;
		[parentItem.items addObject:i];
	} else {
		i.parentItem = nil;
		[self.items addObject:i];
	}

	return i;
}


#pragma mark - Setup frames and views

- (void)setupAll {
	
	//	options processing
	if (self.kind == kRTFlyoutMenuKindHovering) {
		
	} else if (self.kind == kRTFlyoutMenuKindStatic) {
		//	if some dimension is passed as 0, that means it should take the whole available space
		
	}
	
    
	CGRect frame = CGRectZero;
	
	if (self.kind == kRTFlyoutMenuKindHovering) {
		frame = [self createFoldedMainFrameForPosition:_position];
	} else if (self.kind == kRTFlyoutMenuKindStatic) {
		frame = [self createUnfoldedMainFrameForPosition:_position];
	}
    [self setFrame:frame];
    [self setClipsToBounds:YES];
    
	if (self.kind == kRTFlyoutMenuKindHovering) {
		[self setupMainButton];
		[self addSubview:_mainButton];
	} else if (self.kind == kRTFlyoutMenuKindStatic) {
		_mainButton = nil;
	}
    
	UIImage *resizedBgImage = [[UIImage imageNamed:@"mainBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 5, 23, 5)];
    _mainBackgroundImageView = [[UIImageView alloc] initWithImage:resizedBgImage];
	_mainBackgroundImageView.frame = (CGRect){.size=self.bounds.size};
	_mainBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_mainBackgroundImageView];
    [self sendSubviewToBack:_mainBackgroundImageView];
    [_mainBackgroundImageView setAlpha:0.0f];
    
    [self setupContentView];
    [self addSubview:_contentView];
	
	[self addItemsToContentView:nil];
	
	if (self.kind == kRTFlyoutMenuKindStatic) {
		[self unfoldWithAnimationDuration:0];
	}
	
	//	setup springs and struts
	switch (self.position) {
		case kRTFlyoutMenuPositionTop:
			self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
			break;
			
		case kRTFlyoutMenuPositionBottom:
			self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
			break;
			
		case kRTFlyoutMenuPositionTopLeft:
			self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
			break;
			
		case kRTFlyoutMenuPositionTopRight:
			self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
			break;
			
		case kRTFlyoutMenuPositionBottomLeft:
			self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
			break;
			
		case kRTFlyoutMenuPositionBottomRight:
			self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
			break;
			
		default:
			break;
	}
	
//	_contentView.backgroundColor = [UIColor redColor];
	
    [self.parentView addSubview:self];
	
}

#pragma mark - Main button + menu

- (void)setupMainButton {
    CGFloat x = (self.menuHoverSize.width - self.mainButtonSize.width) / 2;
    CGFloat y = (self.menuHoverSize.height - self.mainButtonSize.height) / 2;
    
    _mainButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, self.mainButtonSize.width, self.mainButtonSize.height)];
    [_mainButton setBackgroundImage:[UIImage imageNamed:@"main-button-up.png"] forState:UIControlStateNormal];
	switch (self.position) {
		case kRTFlyoutMenuPositionBottomRight:
		case kRTFlyoutMenuPositionTopRight:
			[_mainButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
			break;
			
		case kRTFlyoutMenuPositionBottomLeft:
		case kRTFlyoutMenuPositionTopLeft:
			[_mainButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
			break;
			
		default:
			[_mainButton setAutoresizingMask:UIViewAutoresizingNone];
			break;
	}
    [_mainButton addTarget:self action:@selector(mainButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (CGRect)createFoldedMainFrameForPosition:(RTFlyoutMenuPosition)position {
    CGRect frame;
	
    switch (position) {
        case kRTFlyoutMenuPositionBottomRight:
            frame = CGRectMake([_parentView bounds].size.width - (self.menuHoverSize.width + self.menuMargins.right), [_parentView bounds].size.height - (self.menuHoverSize.height + self.menuMargins.bottom), self.menuHoverSize.width, self.menuHoverSize.height);
            break;
        case kRTFlyoutMenuPositionBottomLeft:
            frame = CGRectMake(self.menuMargins.left, [_parentView bounds].size.height - (self.menuHoverSize.height + self.menuMargins.bottom), self.menuHoverSize.width, self.menuHoverSize.height);
            break;
        case kRTFlyoutMenuPositionTopRight:
            frame = CGRectMake([_parentView bounds].size.width - (self.menuHoverSize.width + self.menuMargins.right), self.menuMargins.top, self.menuHoverSize.width, self.menuHoverSize.height);
            break;
        case kRTFlyoutMenuPositionTopLeft:
            frame = CGRectMake(self.menuMargins.left, self.menuMargins.top, self.menuHoverSize.width, self.menuHoverSize.height);
            break;
        default:
            frame = CGRectZero;
            break;
    }
	
    return frame;
}

- (CGRect)createUnfoldedMainFrameForPosition:(RTFlyoutMenuPosition)position {
    CGRect frame;
	
    switch (position) {
        case kRTFlyoutMenuPositionBottomRight:
        case kRTFlyoutMenuPositionBottomLeft:
            frame = CGRectMake(self.menuMargins.left, [[self superview] bounds].size.height - (self.menuHoverSize.height + self.menuMargins.bottom), [[self superview] bounds].size.width - self.menuMargins.left - self.menuMargins.right, self.menuHoverSize.height);
            break;
			
        case kRTFlyoutMenuPositionTopRight:
        case kRTFlyoutMenuPositionTopLeft:
            frame = CGRectMake(self.menuMargins.left, self.menuMargins.top, [[self superview] bounds].size.width - self.menuMargins.left - self.menuMargins.right, self.menuHoverSize.height);
            break;
			
        case kRTFlyoutMenuPositionBottom:
            frame = CGRectMake(self.menuMargins.left, [_parentView bounds].size.height - (self.menuHoverSize.height + self.menuMargins.bottom), [_parentView bounds].size.width - self.menuMargins.left - self.menuMargins.right, self.menuHoverSize.height);
            break;
			
        case kRTFlyoutMenuPositionTop: {
			CGSize allItemsSize = [self calculateSizeToFitAllItemsOf:nil];
			CGFloat availableWidth = [_parentView bounds].size.width - self.menuMargins.left - self.menuMargins.right;
            frame = CGRectMake(self.menuMargins.left + (availableWidth - allItemsSize.width)/2, self.menuMargins.top, allItemsSize.width, self.menuStaticSize.height);
            break;
		}
			
        default:
            frame = CGRectZero;
            break;
    }
	
    return frame;
}

#pragma mark - Content for the main menu

- (void)setupContentView {
	CGRect f = CGRectZero;
	if (self.kind == kRTFlyoutMenuKindHovering) {
		f = [self createFoldedContentViewFrameForPosition:_position];
	} else if (self.kind == kRTFlyoutMenuKindStatic) {
		f = [self createUnfoldedContentViewFrameForPosition:_position];
	}
    _contentView = [[UIView alloc] initWithFrame:f];
//    [_contentView setClipsToBounds:YES];
    [_contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}

- (CGRect)createFoldedContentViewFrameForPosition:(RTFlyoutMenuPosition)position {
    CGRect frame = CGRectZero;
	if (self.kind == kRTFlyoutMenuKindHovering) {
		switch (position) {
			case kRTFlyoutMenuPositionBottomRight:
			case kRTFlyoutMenuPositionTopRight:
				frame = CGRectMake([self bounds].origin.x, [self bounds].origin.y, 0, self.menuHoverSize.height);
				break;
				
			case kRTFlyoutMenuPositionBottomLeft:
			case kRTFlyoutMenuPositionTopLeft:
				frame = CGRectMake([self bounds].origin.x + self.menuHoverSize.width, [self bounds].origin.y, 0, self.menuHoverSize.height);
				break;
				
			default:
				break;
		}
	} else if (self.kind == kRTFlyoutMenuKindStatic) {
		frame = CGRectMake([self bounds].origin.x, [self bounds].origin.y, 0, self.menuHoverSize.height);
	}
    
    return frame;
}

- (CGRect)createUnfoldedContentViewFrameForPosition:(RTFlyoutMenuPosition)position {
    CGRect frame = CGRectZero;
	if (self.kind == kRTFlyoutMenuKindHovering) {
		switch (position) {
			case kRTFlyoutMenuPositionBottomRight:
			case kRTFlyoutMenuPositionTopRight:
				frame = CGRectMake([self bounds].origin.x, [self bounds].origin.y, [self bounds].size.width - self.menuHoverSize.width, self.menuHoverSize.height);
				break;
				
			case kRTFlyoutMenuPositionBottomLeft:
			case kRTFlyoutMenuPositionTopLeft:
				frame = CGRectMake([self bounds].origin.x + self.menuHoverSize.width, [self bounds].origin.y, [self bounds].size.width - self.menuHoverSize.width, self.menuHoverSize.height);
				break;
				
			default:
				break;
		}
	} else if (self.kind == kRTFlyoutMenuKindStatic) {
		switch (position) {
			case kRTFlyoutMenuPositionTop:
				frame = CGRectMake([self bounds].origin.x, [self bounds].origin.y, (self.menuStaticSize.width) ? self.menuStaticSize.width : [self bounds].size.width, self.menuStaticSize.height);
				break;
				
			default:
				break;
		}
	}

    return frame;
}

- (void)addItemsToContentView:(RTFlyoutItem *)parentItem {
	
	NSArray *allItems = (parentItem) ? parentItem.items : self.items;
	__block CGFloat currentX = self.contentInsets.left;
	[allItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		RTFlyoutItem *i = (RTFlyoutItem *)obj;

		if (idx > 0) currentX += self.interItemSpacing;
		CGRect f = i.frame;
		f.origin.x = currentX;
		f.origin.y = self.contentInsets.top;
		i.frame = f;
		
		currentX += f.size.width;

		[i setAutoresizingMask:UIViewAutoresizingNone];
		[i addTarget:self action:@selector(innerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

		[_contentView addSubview:i];
	}];
	
}

- (CGSize)calculateSizeToFitAllItemsOf:(RTFlyoutItem *)parentItem {
	
	__block CGSize s = CGSizeZero;
	
	NSArray *allItems = (parentItem) ? parentItem.items : self.items;
	[allItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		RTFlyoutItem *i = (RTFlyoutItem *)obj;
		if (i.bounds.size.height > s.height) s.height = i.bounds.size.height;
		if (idx > 0) s.width += self.interItemSpacing;
		s.width += i.bounds.size.width;
	}];
	
	s.height += self.contentInsets.top + self.contentInsets.bottom;
	s.width += self.contentInsets.left + self.contentInsets.right;
	
	return s;
}


#pragma mark - Submenu 

- (void)openSubmenuForParentItem:(RTFlyoutItem *)parentItem unfoldDirection:(RTFlyoutMenuUnfoldDirection)unfoldDirection {

	if (!parentItem.submenu) {
		//	make view
		CGRect frame = [self createUnfoldedSubmenuFrameForParentItem:parentItem unfoldDirection:unfoldDirection];
		UIView *submenuView = [[UIView alloc] initWithFrame:frame];
		
		//	render background
		UIImage *resizedBgImage = [[UIImage imageNamed:@"submenuBackground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 4, 7, 4)];
		UIImageView *subBackgroundImageView = [[UIImageView alloc] initWithImage:resizedBgImage];
		subBackgroundImageView.frame = (CGRect){.size=frame.size};
		subBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[submenuView addSubview:_mainBackgroundImageView];
		[submenuView sendSubviewToBack:_mainBackgroundImageView];
		
		//	add items
		NSArray *allItems = parentItem.items;
		__block CGFloat currentY = 8;
		[allItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			RTFlyoutItem *i = (RTFlyoutItem *)obj;
			
			CGRect f = i.frame;
			f.origin.x = 4;
			f.origin.y = currentY;
			i.frame = f;
			
			currentY += f.size.height;
			
			[i setAutoresizingMask:UIViewAutoresizingNone];
			[i addTarget:self action:@selector(innerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			
			[submenuView addSubview:i];
		}];
		
		parentItem.submenu = submenuView;
	}
	
	[self addSubview:parentItem.submenu];
}

- (CGRect)createUnfoldedSubmenuFrameForParentItem:(RTFlyoutItem *)parentItem unfoldDirection:(RTFlyoutMenuUnfoldDirection)unfoldDirection {
    CGRect frame;
	
	CGRect parentItemFrame = parentItem.frame;
	NSUInteger numberOfItems = [parentItem.items count];
	
    switch (unfoldDirection) {
        case kRTFlyoutMenuUnfoldDirectionBottom: {
            frame = CGRectMake(parentItemFrame.origin.x, parentItemFrame.origin.y + parentItemFrame.size.height-10, 200, numberOfItems*44+10);
            break;
		}
			
        default:
            frame = CGRectZero;
            break;
    }
	
    return frame;
}

@end
