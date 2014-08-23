//
//  NGAboutViewController.m
//  numgame
//
//  Created by Sun Xi on 5/6/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGGuideViewController.h"
@import MessageUI;

@interface NGGuideViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;


@end

@implementation NGGuideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _scrollView.delegate = self;
    [_playButton setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _scrollView.contentSize = CGSizeMake(4*_scrollView.frame.size.width, _scrollView.frame.size.height);
    for (int i = 0; i < 4; i++) {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*_scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
        imageView.backgroundColor = [UIColor colorWithRed:rand()%255/255.0 green:rand()%255/255.0 blue:rand()%255/255.0 alpha:1.0f];
        [_scrollView addSubview:imageView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x/scrollView.frame.size.width;
    [_pageControl setCurrentPage:page];
    if (page == 3) {
        [_playButton setHidden:NO];
    } else {
        [_playButton setHidden:YES];
    }
}

- (IBAction)pageControlValueChanged:(UIPageControl*)sender {
    int page = sender.currentPage;
    [_scrollView setContentOffset:CGPointMake(page*_scrollView.frame.size.width, 0)];
    if (page == 3) {
        [_playButton setHidden:NO];
    } else {
        [_playButton setHidden:YES];
    }
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
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
