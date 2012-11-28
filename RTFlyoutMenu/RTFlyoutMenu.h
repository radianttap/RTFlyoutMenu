//
//  RTFlyoutMenu.h
//  RTFlyoutMenu
//
//  Created by Aleksandar Vacić on 27.11.12..
//  Copyright (c) 2012. Aleksandar Vacić. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
	kRTFlyoutMenuKindStatic,			//	subview of some other view, will scroll as usual
	kRTFlyoutMenuKindHovering			//	hovers above and is constantly visible on its position, regardless of other content scroll
} RTFlyoutMenuKind;



//	towards what edge will main menu unfold
//	this is ignored for kRTFlyoutMenuKindStatic
typedef enum {
	kRTFlyoutMenuUnfoldDirectionTop,
	kRTFlyoutMenuUnfoldDirectionLeft,
	kRTFlyoutMenuUnfoldDirectionBottom,
	kRTFlyoutMenuUnfoldDirectionRight
} RTFlyoutMenuUnfoldDirection;



//	position where to place the main menu button, inside given parent view
//	this is ignored for kRTFlyoutMenuKindStatic
typedef enum {
	kRTFlyoutMenuPositionTop,			//	top center, for static menus
//	kRTFlyoutMenuPositionLeft,			//	left center, for static menus - this is vertically laid-out main menu
	kRTFlyoutMenuPositionBottom,		//	bottom center, for static menus
//	kRTFlyoutMenuPositionRight,			//	right center, for static menus - this is vertically laid-out main menu
	kRTFlyoutMenuPositionTopLeft,		//	for hover menus
	kRTFlyoutMenuPositionTopRight,		//	for hover menus
	kRTFlyoutMenuPositionBottomRight,	//	for hover menus
	kRTFlyoutMenuPositionBottomLeft		//	for hover menus
} RTFlyoutMenuPosition;



//	##	visual options (these are keys for Options dictionary)

//	size for main button, used with kRTFlyoutMenuKindHovering, ignored with kRTFlyoutMenuKindStatic
extern NSString *const RTFlyoutMenuUIOptionMainButtonSize;
//	size for unfolded main menu, used with kRTFlyoutMenuKindStatic, ignored with kRTFlyoutMenuKindHovering
extern NSString *const RTFlyoutMenuUIOptionMainStaticSize;
//	menu margins
extern NSString *const RTFlyoutMenuUIOptionMenuMargins;
//	inner button size
extern NSString *const RTFlyoutMenuUIOptionInnerButtonSize;
//	menu content padding
extern NSString *const RTFlyoutMenuUIOptionContentInsets;
//
extern NSString *const RTFlyoutMenuUIOptionInterItemSpacing;
//	
extern NSString *const RTFlyoutMenuUIOptionAnimationDuration;



@class RTFlyoutItem;
@protocol RTFlyoutMenuDelegate;
@interface RTFlyoutMenu : UIView

//	##	properties
@property (nonatomic, weak) UIView *parentView;

@property (nonatomic, weak, readonly) id<RTFlyoutMenuDelegate> delegate;
@property (nonatomic, readonly) RTFlyoutMenuKind kind;
@property (nonatomic, readonly) RTFlyoutMenuPosition position;
@property (nonatomic, readonly) RTFlyoutMenuUnfoldDirection unfoldDirection;
@property (nonatomic, readonly) BOOL unfolded;
@property (nonatomic, strong, readonly) UIView *contentView;


@property (nonatomic, strong) NSMutableArray *items;

//	##	methods
- (id)initWithDelegate:(id <RTFlyoutMenuDelegate>)delegate kind:(RTFlyoutMenuKind)kind position:(RTFlyoutMenuPosition)position unfoldDirection:(RTFlyoutMenuUnfoldDirection)direction options:(NSDictionary *)options;

- (RTFlyoutItem *)addItemWithImage:(UIImage *)image parentItem:(RTFlyoutItem *)parentItem;
- (RTFlyoutItem *)addItemWithTitle:(NSString *)title parentItem:(RTFlyoutItem *)parentItem;
//- (RTFlyoutItem *)addItemWithImage:(UIImage *)image title:(NSString *)title parentItem:(RTFlyoutItem *)parentItem;
//
//- (RTFlyoutItem *)insertItemWithImage:(UIImage *)image atIndex:(NSInteger)index parentItem:(RTFlyoutItem *)parentItem;
//- (RTFlyoutItem *)insertItemWithTitle:(NSString *)title atIndex:(NSInteger)index parentItem:(RTFlyoutItem *)parentItem;
//- (RTFlyoutItem *)insertItemWithImage:(UIImage *)image title:(NSString *)title atIndex:(NSInteger)index parentItem:(RTFlyoutItem *)parentItem;
@end






@protocol RTFlyoutMenuDelegate <NSObject>

@optional
- (void)flyoutMenu:(RTFlyoutMenu *)flyoutMenu didActivateItemWithIndex:(NSInteger)index;
- (void)flyoutMenuDidFold:(RTFlyoutMenu *)flyoutMenu;
- (void)flyoutMenuDidUnfold:(RTFlyoutMenu *)flyoutMenu;

@end



//	##	private API

@interface RTFlyoutMenu ()

//	options
@property (nonatomic) CGSize mainButtonSize;
@property (nonatomic) CGSize menuHoverSize;
@property (nonatomic) CGSize menuStaticSize;
@property (nonatomic) UIEdgeInsets menuMargins;
@property (nonatomic) CGSize innerItemSize;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) CGFloat interItemSpacing;
@property (nonatomic) CGFloat animationDuration;

//	local
@property (nonatomic, weak) id<RTFlyoutMenuDelegate> delegate;
@property (nonatomic, readwrite) RTFlyoutMenuKind kind;
@property (nonatomic, readwrite) RTFlyoutMenuPosition position;
@property (nonatomic, readwrite) RTFlyoutMenuUnfoldDirection unfoldDirection;
@property (nonatomic, readwrite) BOOL unfolded;
@property (nonatomic, strong, readwrite) UIView *contentView;

@property (nonatomic, strong) UIButton *mainButton;
@property (nonatomic, strong) UIImageView *mainBackgroundImageView;

/*
- (void)setupMainButton;
- (void)setupContentView;
- (void)mainButtonPressed;
- (void)innerButtonPressed:(id)sender;
- (void)unfoldWithAnimationDuration:(float)duration;
- (void)foldWithAnimationDuration:(float)duration;
- (CGRect)createFoldedMainFrameForPosition:(RTFlyoutMenuPosition)position;
- (CGRect)createUnfoldedMainFrameForPosition:(RTFlyoutMenuPosition)position;
- (CGRect)createFoldedContentViewFrameForPosition:(RTFlyoutMenuPosition)position;
- (CGRect)createUnfoldedContentViewFrameForPosition:(RTFlyoutMenuPosition)position;
 */
@end

