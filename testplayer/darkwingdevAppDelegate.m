//
//  darkwingdevAppDelegate.m
//  testplayer
//
//  Created by finalevil on 13/4/10.
//  Copyright (c) 2013年 finalevil. All rights reserved.
//

#import "darkwingdevAppDelegate.h"
#import "darkwingdevViewController.h"

@implementation darkwingdevAppDelegate

@synthesize queuePlayer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    [[AVAudioSession sharedInstance] setDelegate: self];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    UIImage *navBarImage = [[UIImage imageNamed:@"menubar-left.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 15, 5, 15)];
    
    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    


    
    return YES;
}

- (void)endInterruptionWithFlags:(NSUInteger)flags {

    //check the status, then play
    [queuePlayer play];
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    
    NSLog(@"%@", event);
    
    int currentInx;
    NSMutableArray *tmpPlayListData;
    if (event.type == UIEventTypeRemoteControl) {

        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:                
                NSLog(@"queuePlayer.rate = %f", queuePlayer.rate);
                
                if(queuePlayer.rate != 0)
                    [queuePlayer pause];
                else
                    [queuePlayer play];                
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [queuePlayer seekToTime:queuePlayer.currentItem.duration];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                
                [queuePlayer pause];
                
                currentInx = [self.playlistData indexOfObject:queuePlayer.currentItem];

                tmpPlayListData = [[NSMutableArray alloc] initWithArray:[self.playlistData subarrayWithRange:NSMakeRange(currentInx-1, [self.playlistData count]-(currentInx-1))]];

                NSLog(@"tmpPlayListData count = %d", [tmpPlayListData count]);
                [queuePlayer seekToTime:kCMTimeZero];
                [queuePlayer removeAllItems];
                for (int i=0; i<[tmpPlayListData count]; i++) {
                    [queuePlayer insertItem:[tmpPlayListData objectAtIndex:i] afterItem:nil];
                }

                [queuePlayer seekToTime:kCMTimeZero];
                [queuePlayer play];
                
                break;
                
            default:
                break;
        }

    }
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

-(void)resumePlayback {
//    MainViewController* mainController=self.viewController;
//    if (mainController.player.rate==0&&playerWasPlaying)
//        [mainController play:nil];
    [queuePlayer play];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(resumePlayback) userInfo:nil repeats:NO];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
