//
//  NGAboutViewController.m
//  numgame
//
//  Created by Sun Xi on 5/6/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGGuideViewController.h"
@import MessageUI;

@interface NGGuideViewController ()

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation NGGuideViewController

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
    [_backButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:30]];
    [_titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:40]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)onBack:(UIButton*)sender {
    if ([sender.titleLabel.text isEqualToString:@"play!"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

@end
