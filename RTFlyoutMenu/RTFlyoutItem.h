//
//  RTFlyoutItem.h
//  RTFlyoutMenu
//
//  Created by Aleksandar Vacić on 28.11.12..
//  Copyright (c) 2012. Aleksandar Vacić. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTFlyoutItem : UIButton

+ (id)itemWithImage:(UIImage *)image title:(NSString *)title index:(NSUInteger)index;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, getter = isActive) BOOL active;

@end
