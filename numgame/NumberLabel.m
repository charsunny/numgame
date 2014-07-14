//
//  NumberLabel.m
//  numgame
//
//  Created by apple on 14-7-13.
//  Copyright (c) 2014年 Sun Xi. All rights reserved.
//

#import "NumberLabel.h"


@interface NumberLabel ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong)NumberLabelTouched numberLabelTouchedBlock;
@property (nonatomic, strong) UITapGestureRecognizer * tapGesture;
@end

@implementation NumberLabel




-(id)initWithNumber:(int)number CallBack:(NumberLabelTouched)block{

    self = [super initWithFrame:CGRectMake(0, 0, 40, 40)];
    if (self) {
    
        NSString * text = [NSString stringWithFormat:@"%d",number];
        self.text = text;
        self.font = [UIFont fontWithName: NUM_FONT size:30];
        self.textAlignment =  NSTextAlignmentCenter;
       
        if (block != nil) {
            _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleActionForNumberTapGesture:)];
            
            [self addGestureRecognizer:_tapGesture];
            [_tapGesture setDelegate:self];
            self.numberLabelTouchedBlock = block;
        }
      
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor blackColor];
        
    }
    return self;
}


-(void)handleActionForNumberTapGesture:(UIGestureRecognizer*)gesture{

    if (gesture.state == UIGestureRecognizerStateRecognized && gesture.numberOfTouches ==1) {
        
        self.numberLabelTouchedBlock(self.text.intValue);
        
    }
  
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{


}
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{


    return YES;
}



@end
