//
//  NGGameUtil.m
//  numgame
//
//  Created by Lanston Peng on 7/21/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGGameUtil.h"

@implementation NGGameUtil

+ (UIImage *) screenshot:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
