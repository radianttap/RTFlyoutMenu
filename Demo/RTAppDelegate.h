//
//  RTAppDelegate.h
//  RTFlyoutMenu
//
//  Created by Aleksandar Vacić on 27.11.12..
//  Copyright (c) 2012. Aleksandar Vacić. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTViewController;

@interface RTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RTViewController *viewController;

@end
