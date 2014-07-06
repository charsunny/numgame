//
//  NGResultViewController.h
//  numgame
//
//  Created by Sun Xi on 4/29/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADInterstitial.h"
#import "NGGameConfig.h"

@interface NGResultViewController : UIViewController

@property (strong, nonatomic) GADInterstitial* gADInterstitial;

@property (nonatomic) NGGameMode gameMode;

@property (nonatomic) BOOL completed;

@property (nonatomic) BOOL isHighScore;

@property (nonatomic, strong) NSString* score;

@property (nonatomic, strong) NSString* time;

@end
