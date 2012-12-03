//
//  RTFlyoutItem.h
//  RTFlyoutMenu
//
//  Created by Aleksandar Vacić on 28.11.12..
//  Copyright (c) 2012. Aleksandar Vacić. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTFlyoutItem : UIButton

//@property (nonatomic, getter = isActive) BOOL active;
@property (nonatomic) NSUInteger mainItemIndex;
@property (nonatomic) NSUInteger subItemIndex;

@end
