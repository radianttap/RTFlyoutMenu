//
//  RTViewController.m
//  RTFlyoutMenu
//
//  Created by Aleksandar Vacić on 27.11.12..
//  Copyright (c) 2012. Aleksandar Vacić. All rights reserved.
//

#import "RTViewController.h"
#import "RTFlyoutItem.h"

@interface RTViewController ()

@property (weak, nonatomic) IBOutlet UIView *menuContainerView;

@property (nonatomic) NSArray *mainItems;
@property (nonatomic) NSArray *subItems;

@end

@implementation RTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	self.mainItems = @[@"Store", @"Mac", @"iPod", @"iPhone", @"iPad", @"iTunes"];
	self.subItems = @[
		@[@"New additions", @"Shop Mac", @"Shop iPad", @"Shop iPhone", @"Shop iPod"],
		@[@"MacBook Air", @"MacBook Pro", @"Mac mini", @"iMac", @"Mac Pro", @"OS X Mountain Lion"],
		@[@"iPod shuffle", @"iPod nano", @"iPod touch", @"iPod classic", @"Apple TV", @"Accessories"],
		@[@"iPhone 5", @"Compare models", @"App Store"],
		@[@"iPad with Retina display", @"iPad mini"],
		@[]
	];
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	NSDictionary *options = @{
		RTFlyoutMenuUIOptionInnerItemSize: [NSValue valueWithCGSize:CGSizeMake(22, 22)]
	};
	RTFlyoutMenu *m = [[RTFlyoutMenu alloc] initWithDelegate:self dataSource:self position:kRTFlyoutMenuPositionTop options:options];
	m.canvasView = self.view;

	CGRect mf = m.frame;
	CGRect cf = self.menuContainerView.bounds;

	//	center menu in container view
	CGFloat newOriginX = (cf.size.width - mf.size.width) / 2;
	CGFloat newOriginY = (cf.size.height - mf.size.height) / 2;
	if (newOriginX > 0) mf.origin.x = newOriginX;
	if (newOriginY > 0) mf.origin.y = newOriginY;
	m.frame = mf;

//	m.backgroundColor = [UIColor redColor];
	[self.menuContainerView addSubview:m];

	//	look & feel
	[[RTFlyoutItem appearanceWhenContainedIn:[self.menuContainerView class], nil] setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[[RTFlyoutItem appearanceWhenContainedIn:[self.menuContainerView class], nil] setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - RTFlyoutMenuDataSource

- (NSUInteger)numberOfMainItemsInFlyoutMenu:(RTFlyoutMenu *)flyoutMenu {
	return 6;
}

- (NSString *)flyoutMenu:(RTFlyoutMenu *)flyoutMenu titleForMainItem:(NSUInteger)mainItemIndex {
	if (mainItemIndex >= [self.mainItems count]) return nil;

	return [self.mainItems objectAtIndex:mainItemIndex];
}

- (NSUInteger)flyoutMenu:(RTFlyoutMenu *)flyoutMenu numberOfItemsInSubmenu:(NSUInteger)mainItemIndex {
	if (mainItemIndex >= [self.mainItems count]) return 0;

	return [[self.subItems objectAtIndex:mainItemIndex] count];
}

- (NSString *)flyoutMenu:(RTFlyoutMenu *)flyoutMenu titleForSubItem:(NSUInteger)subItemIndex inMainItem:(NSUInteger)mainItemIndex {
	if (mainItemIndex >= [self.mainItems count]) return nil;
	if (subItemIndex >= [[self.subItems objectAtIndex:mainItemIndex] count]) return nil;

	return [[self.subItems objectAtIndex:mainItemIndex] objectAtIndex:subItemIndex];
}


#pragma mark - RTFlyoutMenuDelegate

- (void)flyoutMenu:(RTFlyoutMenu *)flyoutMenu didSelectMainItemWithIndex:(NSInteger)index {
    NSLog(@"Tap on main item: %d", index);
}

- (void)flyoutMenu:(RTFlyoutMenu *)flyoutMenu didSelectSubItemWithIndex:(NSInteger)subIndex mainMenuItemIndex:(NSInteger)mainIndex {
    NSLog(@"Tap on main/sub index: %d / %d", mainIndex, subIndex);
}

@end
