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

//@property (nonatomic, strong) RTFlyoutMenu *brMenu;
//@property (nonatomic, strong) RTFlyoutMenu *tlMenu;
@property (nonatomic, strong) RTFlyoutMenu *topMenu;

@property (weak, nonatomic) IBOutlet UIView *menuContainerView;

@end

@implementation RTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.


}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
/*
    RTFlyoutMenu *m1 = [[RTFlyoutMenu alloc] initWithDelegate:self kind:kRTFlyoutMenuKindHovering position:kRTFlyoutMenuPositionBottomRight unfoldDirection:kRTFlyoutMenuUnfoldDirectionLeft options:nil];
	self.brMenu = m1;
    [self.brMenu setParentView:[self view]];
    [self.brMenu addItemWithImage:[UIImage imageNamed:@"rw-button.png"]];
    [self.brMenu addItemWithImage:[UIImage imageNamed:@"rw-button.png"]];
    [self.brMenu addItemWithImage:[UIImage imageNamed:@"rw-button.png"]];
    [self.brMenu addItemWithImage:[UIImage imageNamed:@"rw-button.png"]];
	
    RTFlyoutMenu *m2 = [[RTFlyoutMenu alloc] initWithDelegate:self kind:kRTFlyoutMenuKindHovering position:kRTFlyoutMenuPositionTopLeft unfoldDirection:kRTFlyoutMenuUnfoldDirectionRight options:nil];
	self.tlMenu = m2;
    [self.tlMenu setParentView:[self view]];
    [self.tlMenu addItemWithImage:[UIImage imageNamed:@"rw-button.png"]];
    [self.tlMenu addItemWithImage:[UIImage imageNamed:@"rw-button.png"]];
*/
	BOOL iPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
	if (iPad) {
		NSDictionary *options = @{
			RTFlyoutMenuUIOptionMainStaticSize: [NSValue valueWithCGSize:CGSizeMake(0, 44)],
			RTFlyoutMenuUIOptionInterItemSpacing: @20.0f
		};
		RTFlyoutMenu *m = [[RTFlyoutMenu alloc] initWithDelegate:self kind:kRTFlyoutMenuKindStatic position:kRTFlyoutMenuPositionTop unfoldDirection:kRTFlyoutMenuUnfoldDirectionBottom options:options];
		self.topMenu = m;
		[self.topMenu setParentView:self.menuContainerView];
		
		//	look & feel
//		NSDictionary *lf = @{
//			UITextAttributeFont : [UIFont fontWithName:@"AvenirNext-DemiBold" size:15.0],
//		};
//		[[UILabel appearanceWhenContainedIn:[RTFlyoutItem class], nil] setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:15.0]];
//		[[RTFlyoutItem appearance] setTitleTextAttributes:lf forState:UIControlStateNormal];
		[[RTFlyoutItem appearanceWhenContainedIn:[self.menuContainerView class], nil] setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[[RTFlyoutItem appearanceWhenContainedIn:[self.menuContainerView class], nil] setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];

		{
			RTFlyoutItem *mainItem = [self.topMenu addItemWithTitle:@"Store" parentItem:nil];
			[self.topMenu addItemWithTitle:@"New additions" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"Shop Mac" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"Shop iPad" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"Shop iPhone" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"Shop iPod" parentItem:mainItem];
		}

		{
			RTFlyoutItem *mainItem = [self.topMenu addItemWithTitle:@"Mac" parentItem:nil];
			[self.topMenu addItemWithTitle:@"MacBook Air" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"MacBook Pro" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"Mac mini" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"iMac" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"Mac Pro" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"OS X Mountain Lion" parentItem:mainItem];
		}
		
		{
			RTFlyoutItem *mainItem = [self.topMenu addItemWithTitle:@"iPod" parentItem:nil];
			[self.topMenu addItemWithTitle:@"iPod shuffle" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"iPod nano" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"iPod touch" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"iPod classic" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"Apple TV" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"Accessories" parentItem:mainItem];
		}
		
		{
			RTFlyoutItem *mainItem = [self.topMenu addItemWithTitle:@"iPhone" parentItem:nil];
			[self.topMenu addItemWithTitle:@"iPhone 5" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"Compare models" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"App Store" parentItem:mainItem];
		}
		
		{
			RTFlyoutItem *mainItem = [self.topMenu addItemWithTitle:@"iPad" parentItem:nil];
			[self.topMenu addItemWithTitle:@"iPad with Retina display" parentItem:mainItem];
			[self.topMenu addItemWithTitle:@"iPad mini" parentItem:mainItem];
		}
		
		{
			(void)[self.topMenu addItemWithTitle:@"iTunes" parentItem:nil];
		}
		
		[self.topMenu setupAll];
	}
	
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - RTFlyoutMenuDelegate

- (void)flyoutMenu:(RTFlyoutMenu *)flyoutMenu didActivateItemWithIndex:(NSInteger)index {
    NSLog(@"Tap on inner item with index: %d", index);
}

- (void)flyoutMenuDidUnfold:(RTFlyoutMenu *)flyoutMenu {
    NSLog(@"menu unfolded");
}

- (void)flyoutMenuDidFold:(RTFlyoutMenu *)flyoutMenu {
    NSLog(@"menu folder");
}


@end
