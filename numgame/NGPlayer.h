//
//  NGPlayer.h
//  numgame
//
//  Created by Sun Xi on 8/14/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NGPlayer : NSObject

+ (instancetype) player;

-(void) playSoundFXnamed:(NSString*)vSFXName Loop:(BOOL) vLoop;

@end
