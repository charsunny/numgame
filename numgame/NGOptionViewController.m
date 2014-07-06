//
//  NGOptionViewController.m
//  numgame
//
//  Created by Sun Xi on 4/28/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGOptionViewController.h"
#import "GADBannerView.h"
#import "NGGameConfig.h"
@import Social;
@import StoreKit;

@interface NGOptionViewController ()<SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *soundButton;

@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@property (weak, nonatomic) IBOutlet UIButton *rateButton;

@property (weak, nonatomic) IBOutlet UIButton *aboutButton;

@property (weak, nonatomic) IBOutlet GADBannerView* gADBannerView;

@end

@implementation NGOptionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_gADBannerView setAdUnitID:@"a1535f4e3f36f4b"];
    _gADBannerView.rootViewController = self;
    [self.view addSubview:_gADBannerView];
    [_gADBannerView loadRequest:[GADRequest request]];
    [_backButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:30]];
    [_soundButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:44]];
    [_removeButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:44]];
    [_rateButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:44]];
    [_aboutButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:44]];
    NSString* sound = [[NGGameConfig sharedGameConfig] sound]?:@"J";
    [_soundButton setTitle:sound forState:UIControlStateNormal];
    [_titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:40]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onResume:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        if([_soundButton.titleLabel.text isEqualToString:@"J"]) {
            [_soundButton setTitle:@"K" forState:UIControlStateNormal];
            [[NGGameConfig sharedGameConfig] setSound:@"K"];
        } else {
            [_soundButton setTitle:@"J" forState:UIControlStateNormal];
            [[NGGameConfig sharedGameConfig] setSound:@"J"];
        }
    } else if([sender isEqual:_rateButton]) {
        SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
        storeProductViewContorller.delegate = self;
        [storeProductViewContorller loadProductWithParameters:
         @{SKStoreProductParameterITunesItemIdentifier : @"870428896"} completionBlock:^(BOOL result, NSError *error) {
             if(error){
                 [[[UIAlertView alloc] initWithTitle:@"Tips" message:@"cannot connect to iTunes Store" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
             }else{
                 //模态弹出appstore
                 [self presentViewController:storeProductViewContorller animated:YES completion:nil];
             }
         }];
    }
    
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
