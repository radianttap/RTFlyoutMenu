//
//  RTFlyoutMenu.h
//  RTFlyoutMenu
//
//  Created by Aleksandar Vacić on 27.11.12..
//  Copyright (c) 2012. Aleksandar Vacić. All rights reserved.
//

#import <UIKit/UIKit.h>


//	main menu position
typedef enum {
	kRTFlyoutMenuPositionTop,		//	unfold-direction will be towards bottom
	kRTFlyoutMenuPositionBottom		//	unfold-direction will be towards top
} RTFlyoutMenuPosition;



//	towards what edge will submenu unfold
//	this is implicitly chosen based on main menu position
typedef enum {
	kRTFlyoutMenuUnfoldDirectionTop,
	kRTFlyoutMenuUnfoldDirectionBottom
} RTFlyoutMenuUnfoldDirection;



//	##	VISUAL OPTIONS (these are keys for Options dictionary)
//	menu margins
extern NSString *const RTFlyoutMenuUIOptionMenuMargins;
//	inner button size
extern NSString *const RTFlyoutMenuUIOptionInnerItemSize;
//	menu content padding
extern NSString *const RTFlyoutMenuUIOptionContentInsets;
//	how long will fold/unfold last
extern NSString *const RTFlyoutMenuUIOptionAnimationDuration;



@class RTFlyoutItem;
@protocol RTFlyoutMenuDelegate, RTFlyoutMenuDataSource;
@interface RTFlyoutMenu : UIView

//	##	properties
@property (nonatomic, weak) id<RTFlyoutMenuDelegate> delegate;
@property (nonatomic, weak) id<RTFlyoutMenuDataSource> dataSource;

@property (nonatomic, readonly) RTFlyoutMenuPosition position;
@property (nonatomic, readonly) RTFlyoutMenuUnfoldDirection unfoldDirection;

//	##	methods
- (id)initWithDelegate:(id <RTFlyoutMenuDelegate>)delegate dataSource:(id <RTFlyoutMenuDataSource>)dataSource position:(RTFlyoutMenuPosition)position options:(NSDictionary *)options;

- (void)reloadData;

@end






@protocol RTFlyoutMenuDelegate <NSObject>

@optional
- (void)flyoutMenu:(RTFlyoutMenu *)flyoutMenu didSelectMainItemWithIndex:(NSInteger)index;
- (void)flyoutMenu:(RTFlyoutMenu *)flyoutMenu didSelectSubItemWithIndex:(NSInteger)subIndex mainMenuItemIndex:(NSInteger)mainIndex;

@end



@protocol RTFlyoutMenuDataSource <NSObject>

- (NSUInteger)numberOfMainItemsInFlyoutMenu:(RTFlyoutMenu *)flyoutMenu;
- (NSString *)flyoutMenu:(RTFlyoutMenu *)flyoutMenu titleForMainItem:(NSUInteger)mainItemIndex;
- (NSUInteger)flyoutMenu:(RTFlyoutMenu *)flyoutMenu numberOfItemsInSubmenu:(NSUInteger)mainItemIndex;
- (NSString *)flyoutMenu:(RTFlyoutMenu *)flyoutMenu titleForSubItem:(NSUInteger)subItemIndex inMainItem:(NSUInteger)mainItemIndex;

@end


//	##	private API

@interface RTFlyoutMenu ()

//	options
@property (nonatomic) UIEdgeInsets menuMargins;
@property (nonatomic) CGSize innerItemSize;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) UIEdgeInsets mainItemInsets;
@property (nonatomic) UIEdgeInsets subItemInsets;
@property (nonatomic) CGFloat interItemSpacing;
@property (nonatomic) CGFloat animationDuration;

//	local
@property (nonatomic, readwrite) RTFlyoutMenuPosition position;
@property (nonatomic, readwrite) RTFlyoutMenuUnfoldDirection unfoldDirection;

//	rendering
@property (nonatomic, strong) NSMutableDictionary *submenus;
@property (nonatomic, strong) NSMutableArray *mainItems;
@property (nonatomic, strong) NSMutableArray *mainItemFrames;
@property (nonatomic) NSInteger indexOfOpenSubmenu;

//	from dataSource
@property (nonatomic) NSUInteger numberOfMainItems;
@property (nonatomic, strong) NSMutableArray *mainItemTitles;
@property (nonatomic, strong) NSMutableArray *subItemTitles;

@end

