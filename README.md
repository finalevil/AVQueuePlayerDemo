AVQueuePlayerDemo
=================

(welcome to visit my blog: http://blog.finalevil.com)

在 AppDelegate 宣告 AVQueuePlayer

###1. include 3 framework

```
CoreMedia.framework for CMTime type
AudioToolbox.framework for AVAudioSession
AVFoundation.framework for AVQueuePlayer
```

###2. for background task
(1)在app_name.plist中加入一個key值

```
     <key>UIBackgroundModes</key>
     <array>
          <string>audio</string>
     </array>
```

(2)add the code in didFinishLaunchingWithOptions

```
[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
[[AVAudioSession sharedInstance] setActive: YES error: nil];
```

(3)當程式進入背景，觸發timer

```
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(resumePlayback) userInfo:nil repeats:NO];
}
```

(4)當播放器進入背景模式，一定會自動停止播放，所以我們必須透過一個timer不斷檢查播放器是否應該要播放，如果應該播放，就執行play的動作。

```
-(void)resumePlayback {
    [queuePlayer play];
}
```

當播放器開始進入背景播放的狀態下，就不會停止，會一直處於此一模式之下。


###3. for play video
(1)add AVPlayerLayer to show video

```
    AVPlayerLayer *playerLayer = [[AVPlayerLayer alloc] init];
    [playerLayer setFrame:self.playerView.frame];
    [playerView.layer addSublayer:playerLayer];
    [playerLayer setPlayer:appDelegate.queuePlayer];
```

(2)add video item to queue

```
    playlistData = [[NSMutableArray alloc] init];   
    for (int i=1; i<=11; i++) {
        NSString *videoPath1 = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", i] ofType:@"mp4"];
        AVPlayerItem *videoItem1 = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:videoPath1]];
        [playlistData addObject:videoItem1];
    }
    appDelegate.queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithArray:playlistData]];   
```

(3)call 

```
[player play];
```

###4. sync UI (ex: slider, lablel for current time, label for duration)
兩種不同狀況，第一種事針對影片與影片間切換後的sync，第二種是針對影片播放過程中的sync
(1)對每一個avplayeritem設定notification 

```
    for (int i=0; i<[playlistData count]; i++) {
       
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[playlistData objectAtIndex:i]];
       
    }
```

因此每當一個影片播放結束就會觸發一次此一事件。
在事件處理中，寫下對應的處理內容。原則上就是取得下一個item(影片)的時間長度，重設slider的max value並將slider歸零。

```
-(void)itemDidFinishPlaying :(NSNotification *)notification {
   
   
    AVPlayerItem *p = [notification object];

    AVPlayerItem *nextItem;
    float timeDuration, timeCurrent;
    for (int i=0; i<[playlistData count]; i++) {
        if ([p isEqual:[playlistData objectAtIndex:i]]) {
           
            if ((i+1) < [playlistData count]) {
                nextItem = [playlistData objectAtIndex:i+1];
                timeDuration = CMTimeGetSeconds(nextItem.duration);
                timeCurrent = CMTimeGetSeconds(nextItem.currentTime);
                break;
               
            }
           
        }
    }
   
    // Will be called when AVPlayer finishes playing playerItem
   

    NSLog(@"%f", timeDuration);
    [sliderTimeSeeker setMaximumValue:timeDuration];
    [sliderTimeSeeker setValue:timeCurrent];

    lblCurrentTime.text = @"0";
    lblDuration.text = [NSString stringWithFormat:@"%d", (int)timeDuration];

    [sliderTimeSeeker setValue:0];

}
```

(2)每隔一段時間檢查一次現在播放的currentTime，並顯示到slider和label上

```
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
```

###5. 當使用者拖拉slider，即會播放對應的影片片段
寫在slider的value change 事件中

```
-(IBAction)handleSliderSeek:(id)sender{

    UISlider *s = (UISlider*)sender;
    [appDelegate.queuePlayer seekToTime:CMTimeMakeWithSeconds(s.value, appDelegate.queuePlayer.currentTime.timescale)];
}
```

###6. loop the playlist
沒有比較好的方式可以做這件事情，所以只好通過一個timer不停地去檢查看看queue中的影片是否都已經播放完畢。
queue count = 0表示播放完畢。我們可以再次將影片列表加入queue中，並且再次呼叫 [player play];

(1)在viewDidLoad中建立一個timer  

```
  [NSTimer scheduledTimerWithTimeInterval:1.0
                target:self
              selector:@selector(checkPlaybackTime:)
              userInfo:nil
               repeats:YES];
```

(2)在處理timer事件的callback function中，檢查影片是否都已經播放完畢。

```
- (void) checkPlaybackTime:(NSTimer *)theTimer{

    if([appDelegate.queuePlayer.items count] == 0){
        [self initPlayer];
        [appDelegate.queuePlayer play];
    }
   
}
```


###7. 當播放器處於background，螢幕上鎖後，雙擊home鍵，可以看到一個簡易的播放控制器，想要透過這個控制器遙控你的播放器的話，必須加上兩個東西。
(1)in AppDelegate 的 didFinishLaunchingWithOptions加入此行，表示開始此app開始接收remote control的event。

```
[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
```


(2)事件觸發後的處理函式。
```
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
   
    NSLog(@"%@", event);
   
    if (event.type == UIEventTypeRemoteControl) {

        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                break;
            default:
                break;
        }

    }
}
```
