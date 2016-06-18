//
//  record_audio_testViewController.m
//  record_audio_test
//
//  Created by jinhu zhang on 11-1-5.
//  Copyright 2011 no. All rights reserved.
//

#import "RecordAudio.h"
#import "sys/utsname.h"

enum {
    UIDeviceResolution_Unknown           = 0,
    UIDeviceResolution_iPhoneStandard    = 1,    // iPhone 1,3,3GS Standard Display  (320x480px)
    UIDeviceResolution_iPhoneRetina4     = 2,    // iPhone 4,4S Retina Display 3.5"  (640x960px)
    UIDeviceResolution_iPhoneRetina5     = 3,    // iPhone 5 Retina Display 4"       (640x1136px)
    UIDeviceResolution_iPadStandard      = 4,    // iPad 1,2,mini Standard Display   (1024x768px)
    UIDeviceResolution_iPadRetina        = 5     // iPad 3 Retina Display            (2048x1536px)
}; typedef NSUInteger UIDeviceResolution;

@interface UIDevice (Resolutions)

- (UIDeviceResolution)resolution;

NSString *NSStringFromResolution(UIDeviceResolution resolution);

@end


@implementation UIDevice (Resolutions)

- (UIDeviceResolution)resolution
{
    UIDeviceResolution resolution = UIDeviceResolution_Unknown;
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat scale = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
    CGFloat pixelHeight = (CGRectGetHeight(mainScreen.bounds) * scale);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if (scale == 2.0f) {
            if (pixelHeight == 960.0f)
                resolution = UIDeviceResolution_iPhoneRetina4;
            else if (pixelHeight == 1136.0f)
                resolution = UIDeviceResolution_iPhoneRetina5;
            
        } else if (scale == 1.0f && pixelHeight == 480.0f)
            resolution = UIDeviceResolution_iPhoneStandard;
        
    } else {
        if (scale == 2.0f && pixelHeight == 2048.0f) {
            resolution = UIDeviceResolution_iPadRetina;
            
        } else if (scale == 1.0f && pixelHeight == 1024.0f) {
            resolution = UIDeviceResolution_iPadStandard;
        }
    }
    
    return resolution;
}

@end










@implementation RecordAudio

@synthesize m_pLongMusicPlayer, m_mergeDone, startTime, duration;

- (id) init
{
    self = [super init];
    if (self) {
    }
    return self;
}

// 播放音樂
- (void) playMusic:(NSString*)mp3
{
    // 背景音樂檔案路徑
    NSURL *musicURL = [NSURL fileURLWithPath:mp3];
	m_pLongMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    //[m_pLongMusicPlayer prepareToPlay];
    [m_pLongMusicPlayer setVolume: 0.3];    // 音樂音量
    [m_pLongMusicPlayer play];

    // 動態歌詞的起始時間
    startTime = CFAbsoluteTimeGetCurrent();

    // 音樂時間長度
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
    duration = (float)songAsset.duration.value / (float)songAsset.duration.timescale;
    NSLog(@"duration(%f)", duration);
}

// 停止音樂
- (void)stopMusic
{
    [m_pLongMusicPlayer stop];
}

// 開始合成
- (void) merge2wav:(NSString *)mp3 withRecord:(NSString *)path1
{
    NSLog( @"合成 錄音 與 背景音樂");

    m_mergeDone = NO;

    // 背景音樂檔案路徑
    NSURL *musicURL = [NSURL fileURLWithPath: mp3];
	NSString* path2 = [musicURL path];

    // 輸出檔案路徑
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *outputFileURL = [[tmpDirURL URLByAppendingPathComponent:@"output"] URLByAppendingPathExtension:@"m4a"];
    NSString* path3 = [outputFileURL path];

    AVMutableComposition *composition = [AVMutableComposition composition];
    audioMixParams = [[NSMutableArray alloc] initWithObjects:nil];

    // 人聲
    NSString *URLPath1 = path1;
    NSURL *assetURL1 = [NSURL fileURLWithPath:URLPath1];
    [self setUpAndAddAudioAtPath:assetURL1 toComposition:composition with:[NSURL URLWithString:@""] offset:CMTimeMake(0, 44100) setVolume:1.0f ];

    // 音樂
    NSString *URLPath2 = path2;
    NSURL *assetURL2 = [NSURL fileURLWithPath:URLPath2];
    //[self setUpAndAddAudioAtPath:assetURL2 toComposition:composition with:assetURL1 offset:CMTimeMake(0, 44100)];
    //[self setUpAndAddAudioAtPath:assetURL2 toComposition:composition with:assetURL1 offset:CMTimeMake(44100/10, 44100) setVolume:0.8f ];

    float musicVolume = 0.3f;

    // 取得裝置代號
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if( [deviceString rangeOfString:@"iPhone3"].length > 0 )
    {
        //standard iphone 3GS and lower
        [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition with:assetURL1 offset:CMTimeMake(44100/8.7, 44100) setVolume:musicVolume ];
    }
    else if( [deviceString rangeOfString:@"iPhone4"].length > 0 )
    {
        //iphone 4 & 4S
        [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition with:assetURL1 offset:CMTimeMake(44100/10, 44100) setVolume:musicVolume ];//ipodtouch4(44100/5.6)
    }
    else if( [deviceString rangeOfString:@"iPhone5"].length > 0 )
    {
        //iphone 5
        [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition with:assetURL1 offset:CMTimeMake(44100/10, 44100) setVolume:musicVolume ];
    }
    else if( [deviceString rangeOfString:@"iPad1"].length > 0 )
    {
        //ipad 1
        [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition with:assetURL1 offset:CMTimeMake(44100/10, 44100) setVolume:musicVolume ];
    }
    else if( [deviceString rangeOfString:@"iPad2"].length > 0 )
    {
        //ipad 2
        [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition with:assetURL1 offset:CMTimeMake(44100/10, 44100) setVolume:musicVolume ];
    }
    else if( [deviceString rangeOfString:@"iPad3"].length > 0 )
    {
        //ipad 3
        [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition with:assetURL1 offset:CMTimeMake(44100/10, 44100) setVolume:musicVolume ];
    }
    else if( [deviceString rangeOfString:@"iPad4"].length > 0 )
    {
        //ipad 4
        [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition with:assetURL1 offset:CMTimeMake(44100/10, 44100) setVolume:musicVolume ];
    }
    else if( [deviceString rangeOfString:@"iPod4"].length > 0 )
    {
        //ipod 4
        [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition with:assetURL1 offset:CMTimeMake(44100/8.7, 44100) setVolume:musicVolume ];
    }
    else if( [deviceString rangeOfString:@"iPod5"].length > 0 )
    {
        //ipod 5
        [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition with:assetURL1 offset:CMTimeMake(44100/10, 44100) setVolume:musicVolume ];
    }
    else
    {
        //unknow device - you got me!
        [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition with:assetURL1 offset:CMTimeMake(0, 44100) setVolume:musicVolume ];
    }

    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = [NSArray arrayWithArray:audioMixParams];

    //If you need to query what formats you can export to, here's a way to find out
    NSLog (@"compatible presets for songAsset: %@", [AVAssetExportSession exportPresetsCompatibleWithAsset:composition]);

    /*
     AVAssetExportPresetAppleM4A,
     AVAssetExportPreset960x540,
     AVAssetExportPresetLowQuality,
     AVAssetExportPresetMediumQuality,
     AVAssetExportPreset640x480,
     AVAssetExportPresetHighestQuality,
     AVAssetExportPreset1280x720
     */
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset: composition
                                      presetName: AVAssetExportPresetAppleM4A];

    exporter.audioMix = audioMix;
    exporter.outputFileType = @"com.apple.m4a-audio";
    NSString *exportFile = path3;

    // set up export
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:exportFile error:nil];

    NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
    exporter.outputURL = exportURL;

    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exporter.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed:      NSLog (@"AVAssetExportSessionStatusFailed: %@", exporter.error);        break;
            case AVAssetExportSessionStatusCompleted:   NSLog (@"AVAssetExportSessionStatusCompleted"); [self merge2wavDone];   break;
            case AVAssetExportSessionStatusUnknown:     NSLog (@"AVAssetExportSessionStatusUnknown");                           break;
            case AVAssetExportSessionStatusExporting:   NSLog (@"AVAssetExportSessionStatusExporting");                         break;
            case AVAssetExportSessionStatusCancelled:   NSLog (@"AVAssetExportSessionStatusCancelled");                         break;
            case AVAssetExportSessionStatusWaiting:     NSLog (@"AVAssetExportSessionStatusWaiting");                           break;
            default:                                    NSLog (@"didn't get export status");                                    break;
        }
    }];
}

// 合成設定
- (void) setUpAndAddAudioAtPath:(NSURL*)assetURL toComposition:(AVMutableComposition *)composition with:(NSURL*)recordURL offset:(CMTime)offset setVolume:(float)volume
{
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    AVMutableCompositionTrack *track = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    //AVAssetTrack *sourceAudioTrack = [[songAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    NSArray *a = [songAsset tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *sourceAudioTrack = nil;
    if( [a count] > 0 ) {
        sourceAudioTrack = [a objectAtIndex:0];
    }

    NSError *error2 = nil;
    CMTime myStartTime = CMTimeMakeWithSeconds(0, 1);
    CMTime trackDuration;

    if( [recordURL isEqual: [NSURL URLWithString:@""]] ) {

        trackDuration = songAsset.duration;
    } else {

        AVURLAsset *recordAsset = [AVURLAsset URLAssetWithURL:recordURL options:nil];
        trackDuration = recordAsset.duration;
    }
    NSLog(@"myStartTime(%lld)(%d) trackDuration(%lld)(%d)", myStartTime.value, myStartTime.timescale, trackDuration.value, trackDuration.timescale);

    CMTimeRange tRange = CMTimeRangeMake(myStartTime, trackDuration);

    //Set Volume
    AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];

    [trackMix setVolume:volume atTime:myStartTime];

    [audioMixParams addObject:trackMix];

    //Insert audio into track
    [track insertTimeRange:tRange ofTrack:sourceAudioTrack atTime:offset  error:&error2];
}

// 合成ok
- (void) merge2wavDone
{
    NSLog (@"合成ok");
    m_mergeDone = YES;
}

// 播放合成之後的歌曲
- (void)playSong
{
    // 輸出檔案路徑
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *recordFile = [[tmpDirURL URLByAppendingPathComponent:@"output"] URLByAppendingPathExtension:@"m4a"];
    NSLog(@"playSong recordFile=> %@", [recordFile path] );

    if( !m_pLongMusicPlayer ) {

        m_pLongMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:recordFile error:nil];
    }

    m_pLongMusicPlayer = [m_pLongMusicPlayer initWithContentsOfURL:recordFile error:nil];
    [m_pLongMusicPlayer prepareToPlay];
    [m_pLongMusicPlayer play];

    startTime = CFAbsoluteTimeGetCurrent();

    // 音樂時間長度
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:recordFile options:nil];
    duration = (float)songAsset.duration.value / (float)songAsset.duration.timescale;
    NSLog(@"duration(%f)", duration);
}

// 停止播放合成之後的歌曲
- (void)stopSong
{
    NSLog(@"stopSong");

    [m_pLongMusicPlayer stop];
}

// 取得目前播放時間
- (void)getCurrentTime:(double*)currentTime getEndTime:(double*)cEndTime
{
    *currentTime = [m_pLongMusicPlayer currentTime];
    *cEndTime = self.duration;
}

- (void)pause
{
    if( [m_pLongMusicPlayer isPlaying] ) {
        
        [m_pLongMusicPlayer pause];
    } else {
        
        [m_pLongMusicPlayer play];
    }
}

@end