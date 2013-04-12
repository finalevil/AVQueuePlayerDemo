//
//  darkwingdevAppDelegate.h
//  testplayer
//
//  Created by finalevil on 13/4/10.
//  Copyright (c) 2013年 finalevil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface darkwingdevAppDelegate : UIResponder <UIApplicationDelegate> {

    
}

@property (nonatomic, retain) NSMutableArray *playlistData;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) AVQueuePlayer *queuePlayer;

@end
