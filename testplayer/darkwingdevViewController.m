//
//  darkwingdevViewController.m
//  testplayer
//
//  Created by finalevil on 13/4/10.
//  Copyright (c) 2013年 finalevil. All rights reserved.
//

#import "darkwingdevViewController.h"
#define VIDEO_NUM 11

@interface darkwingdevViewController ()

@end

@implementation darkwingdevViewController

@synthesize playerView, btnPlay, sliderTimeSeeker;
@synthesize lblCurrentTime,lblDuration;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    appDelegate = (darkwingdevAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    [self becomeFirstResponder];

    
    self.navigationItem.title = @"預設播放清單";
    
    [self initPlayer];
    
    [self customLeftButton];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                target:self
              selector:@selector(checkPlaybackTime:)
              userInfo:nil
               repeats:YES];
    
    [appDelegate.queuePlayer play];
    
}


//- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
//    
//    NSLog(@"%@", event);
//    
//    if (event.type == UIEventTypeRemoteControl) {
//        
//        switch (event.subtype) {
//            case UIEventSubtypeRemoteControlTogglePlayPause:
//                [appDelegate.queuePlayer pause];
//                break;
//            case UIEventSubtypeRemoteControlNextTrack:
//                [appDelegate.queuePlayer pause];
//                break;
//            default:
//                break;
//        }
//        
//    }
//}

-(void)itemDidFinishPlaying :(NSNotification *)notification {
    
    
    AVPlayerItem *p = [notification object];

    
    int currentInx = [appDelegate.playlistData indexOfObject:p];
    
    float timeDuration, timeCurrent;
    if ((currentInx+1) < [appDelegate.playlistData count]) {
        AVPlayerItem *nextItem = [appDelegate.playlistData objectAtIndex:currentInx+1];;
        timeDuration = CMTimeGetSeconds(nextItem.duration);
        timeCurrent = CMTimeGetSeconds(nextItem.currentTime);
        
    }else{
    
        timeDuration = 0;
        timeCurrent = 0;
        
    }

    
    
//    for (int i=0; i<[appDelegate.playlistData count]; i++) {
//        if ([p isEqual:[appDelegate.playlistData objectAtIndex:i]]) {
//            
//            if ((i+1) < [appDelegate.playlistData count]) {
//                nextItem = [appDelegate.playlistData objectAtIndex:i+1];
//                timeDuration = CMTimeGetSeconds(nextItem.duration);
//                timeCurrent = CMTimeGetSeconds(nextItem.currentTime);
//                break;
//                
//            }
//            
//        }
//    }
    
    // Will be called when AVPlayer finishes playing playerItem
    

    NSLog(@"%f", timeDuration);
    [sliderTimeSeeker setMaximumValue:timeDuration];
    [sliderTimeSeeker setValue:timeCurrent];

    lblCurrentTime.text = @"0";
    lblDuration.text = [NSString stringWithFormat:@"%d", (int)timeDuration];

    [sliderTimeSeeker setValue:0];
    
}

-(IBAction)handleSliderSeek:(id)sender{

    UISlider *s = (UISlider*)sender;
    [appDelegate.queuePlayer seekToTime:CMTimeMakeWithSeconds(s.value, appDelegate.queuePlayer.currentTime.timescale)];
}


- (void) checkPlaybackTime:(NSTimer *)theTimer{

    if([appDelegate.queuePlayer.items count] == 0){
        [self initPlayer];
        [appDelegate.queuePlayer play];
    }
    
}

//- (void) checkPlaybackTime:(NSTimer *)theTimer
//{
//    float seconds = CMTimeGetSeconds(appDelegate.queuePlayer.currentItem.currentTime);
//
//
//    lblCurrentTime.text = [NSString stringWithFormat:@"%d", (int)seconds];
//    
//    
//    CMTime endTime = CMTimeConvertScale (appDelegate.queuePlayer.currentItem.asset.duration, appDelegate.queuePlayer.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
//    if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
//        NSLog(@"%f", CMTimeGetSeconds(appDelegate.queuePlayer.currentItem.currentTime));
//        sliderTimeSeeker.value = CMTimeGetSeconds(appDelegate.queuePlayer.currentItem.currentTime);
//        
//    };
//
//}


-(void)customLeftButton{
    
    //設定navigation的rightbuton
    UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.bounds = CGRectMake(0, 0, 35.0, 28.0);
    [rightButton setImage:[UIImage imageNamed:@"navbar-button.png"]
                 forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(popPage) forControlEvents:UIControlEventTouchUpInside];
    
    [rightButton.layer setZPosition:1];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.leftBarButtonItem = rightBarButton;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}   

-(IBAction)handlePlay:(id)sender{
    
//    [self initPlayer];
    
    if ([btnPlay.titleLabel.text isEqualToString:@"Pause"]) {
        [btnPlay setTitle:@"Play" forState:UIControlStateNormal];
        [appDelegate.queuePlayer pause];
        
    }else{
        [btnPlay setTitle:@"Pause" forState:UIControlStateNormal];
        [appDelegate.queuePlayer play];
    }
    
    
}

-(void) initPlayer{

    
    AVPlayerLayer *playerLayer = [[AVPlayerLayer alloc] init];
    [playerLayer setFrame:self.playerView.frame];
    [playerView.layer addSublayer:playerLayer];
    
    appDelegate.playlistData = [[NSMutableArray alloc] init];    
    for (int i=1; i<=VIDEO_NUM; i++) {
        NSString *videoPath1 = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", i] ofType:@"mp4"];
        AVPlayerItem *videoItem1 = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:videoPath1]];
        [appDelegate.playlistData addObject:videoItem1];
    }

	
    
    for (int i=0; i<[appDelegate.playlistData count]; i++) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[appDelegate.playlistData objectAtIndex:i]];
        
    }
    

    appDelegate.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithArray:appDelegate.playlistData]];
    
    [playerLayer setPlayer:appDelegate.queuePlayer];
    
    
    NSLog(@"currentTime = %f", CMTimeGetSeconds(appDelegate.queuePlayer.currentItem.currentTime)/60);
    NSLog(@"duration = %f", CMTimeGetSeconds(appDelegate.queuePlayer.currentItem.duration)/60);
    
    float timeDuration = CMTimeGetSeconds(appDelegate.queuePlayer.currentItem.duration);
    float timeCurrent = CMTimeGetSeconds(appDelegate.queuePlayer.currentItem.currentTime);
    
    [sliderTimeSeeker setMaximumValue:timeDuration];
    [sliderTimeSeeker setValue:timeCurrent];
    
    
    lblDuration.text = [NSString stringWithFormat:@"%d", (int)timeDuration];
    lblCurrentTime.text = [NSString stringWithFormat:@"%d", (int)timeCurrent];
    
    //每隔一段時間檢查一次現在播放的currentTime，並顯示到slider和label上
    CMTime interval = CMTimeMake(3000, 1000);
    [appDelegate.queuePlayer addPeriodicTimeObserverForInterval:interval queue:dispatch_get_current_queue() usingBlock:^(CMTime time) {
        
        float seconds = CMTimeGetSeconds(appDelegate.queuePlayer.currentItem.currentTime);
        lblCurrentTime.text = [NSString stringWithFormat:@"%d", (int)seconds];
        
        CMTime endTime = CMTimeConvertScale (appDelegate.queuePlayer.currentItem.asset.duration, appDelegate.queuePlayer.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
            NSLog(@"%f", CMTimeGetSeconds(appDelegate.queuePlayer.currentItem.currentTime));
            sliderTimeSeeker.value = CMTimeGetSeconds(appDelegate.queuePlayer.currentItem.currentTime);
            
        };
        
    }];

}



@end
