//
//  NGOptionViewController.m
//  numgame
//
//  Created by Sun Xi on 4/28/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGOptionViewController.h"
#import "NGGameConfig.h"
#import "NGPlayer.h"
#import <pop/pop.h>
@import Social;
@import StoreKit;

@interface NGOptionViewController ()<SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *soundButton;

@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@property (weak, nonatomic) IBOutlet UIButton *rateButton;

@property (weak, nonatomic) IBOutlet UIButton *aboutButton;

@end

@implementation NGOptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_backButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:30]];
    [_soundButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:44]];
    [_removeButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:44]];
    [_rateButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:44]];
    [_aboutButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:44]];
    NSString* sound = [[NGGameConfig sharedGameConfig] sound]?:@"K";
    [_soundButton setTitle:sound forState:UIControlStateNormal];
    [_titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:40]];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Option Screen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onResume:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -- IBAction -- 

- (IBAction)onClickButton:(UIButton*)sender {
    if ([sender isEqual:_soundButton]) {
        if([_soundButton.titleLabel.text isEqualToString:@"K"]) {
            [_soundButton setTitle:@"L" forState:UIControlStateNormal];
            [[NGGameConfig sharedGameConfig] setSound:@"L"];
        } else {
            [_soundButton setTitle:@"K" forState:UIControlStateNormal];
            [[NGGameConfig sharedGameConfig] setSound:@"K"];
        }
    } else if([sender isEqual:_rateButton]) {
        SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
        storeProductViewContorller.delegate = self;
        [self presentViewController:storeProductViewContorller animated:YES completion:nil];
        [storeProductViewContorller loadProductWithParameters:
         @{SKStoreProductParameterITunesItemIdentifier : @"908971537"} completionBlock:^(BOOL result, NSError *error) {
             if(error){
                 [[[UIAlertView alloc] initWithTitle:@"Tips" message:@"cannot connect to iTunes Store" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
             }
         }];
    }
    
    [[NGPlayer player] playSoundFXnamed:@"item_click.mp3" Loop:NO];
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(3.f, 3.f)];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    scaleAnimation.springBounciness = 18.0f;
    [sender.layer pop_addAnimation:scaleAnimation forKey:@"scoreScaleSpring"];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
