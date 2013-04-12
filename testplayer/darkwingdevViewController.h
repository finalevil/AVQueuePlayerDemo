//
//  darkwingdevViewController.h
//  testplayer
//
//  Created by finalevil on 13/4/10.
//  Copyright (c) 2013年 finalevil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "darkwingdevAppDelegate.h"

@interface darkwingdevViewController : UIViewController {
    darkwingdevAppDelegate *appDelegate;

}

@property (nonatomic ,retain) IBOutlet UIView *playerView;
@property (nonatomic ,retain) IBOutlet UIButton *btnPlay;
-(IBAction)handlePlay:(id)sender;

@property (nonatomic, retain) IBOutlet UILabel *lblDuration;
@property (nonatomic, retain) IBOutlet UILabel *lblCurrentTime;

@property (nonatomic, retain) IBOutlet UISlider *sliderTimeSeeker;

@end
