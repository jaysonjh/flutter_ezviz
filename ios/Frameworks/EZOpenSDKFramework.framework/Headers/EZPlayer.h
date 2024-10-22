//
//  EZPlayer.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/9/16.
//  Copyright (c) 2015年 Hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZDeviceRecordFile;
@class EZCloudRecordFile;
@class EZPlayer;
/**
 *  预览清晰度
 */
typedef NS_ENUM(NSInteger, EZVideoQuality) {
    EZVideoQualityLow    = 0,  //流畅
    EZVideoQualityMiddle = 1,  //均衡
    EZVideoQualityHigh   = 2   //高清
};

/* 播放器EZPlayer的状态消息定义 */
typedef NS_ENUM(NSInteger, EZMessageCode) {
    PLAYER_REALPLAY_START = 1,        //直播开始
    PLAYER_VIDEOLEVEL_CHANGE = 2,     //直播流清晰度切换中
    PLAYER_STREAM_RECONNECT = 3,      //直播流取流正在重连
    PLAYER_VOICE_TALK_START = 4,      //对讲开始
    PLAYER_VOICE_TALK_END = 5,        //对讲结束
    PLAYER_STREAM_START = 10,         //录像取流开始
    PLAYER_PLAYBACK_START = 11,       //录像回放开始播放
    PLAYER_PLAYBACK_STOP = 12,        //录像回放结束播放
    PLAYER_PLAYBACK_FINISHED = 13,    //录像回放被用户强制中断
    PLAYER_PLAYBACK_PAUSE = 14,       //录像回放暂停
    PLAYER_NET_CHANGED = 21,          //播放器检测到wifi变换过
    PLAYER_NO_NETWORK = 22,           //播放器检测到无网络
};


/**
 *  回放速率
 */
typedef NS_ENUM(NSInteger, EZPlaybackRate) {
    EZOPENSDK_PLAY_RATE_1_16 = 9,  //以1/16倍速度播放
    EZOPENSDK_PLAY_RATE_1_8 = 7,   //以1/8倍速度播放
    EZOPENSDK_PLAY_RATE_1_4 = 5,   //以1/4倍速度播放
    EZOPENSDK_PLAY_RATE_1_2 = 3,   //以1/2倍速播放
    EZOPENSDK_PLAY_RATE_1 = 1,     //以正常速度播放
    EZOPENSDK_PLAY_RATE_2 = 2,     //以2倍速播放
    EZOPENSDK_PLAY_RATE_4 = 4,     //以4倍速度播放
    EZOPENSDK_PLAY_RATE_8 = 6,     //以8倍速度播放
    EZOPENSDK_PLAY_RATE_16 = 8,    //以16倍速度播放
    EZOPENSDK_PLAY_RATE_32 = 10,   //以32倍速度播放
};

/// 萤石播放器delegate方法
@protocol EZPlayerDelegate <NSObject>

@optional
/**
 *  播放器播放失败错误回调
 *
 *  @param player 播放器对象
 *  @param error  播放器错误
 */
- (void)player:(EZPlayer *)player didPlayFailed:(NSError *)error;

/**
 *  播放器消息回调
 *
 *  @param player      播放器对象
 *  @param messageCode 播放器消息码，请对照EZOpenSDK头文件中的EZMessageCode使用
 */
- (void)player:(EZPlayer *)player didReceivedMessage:(NSInteger)messageCode;

/**
 *  该方法废弃于v4.8.8版本，底层库不再支持。请使用getStreamFlow方法
 *  收到的数据长度（每秒调用一次）
 *
 *  @param player     播放器对象
 *  @param dataLength 播放器流媒体数据的长度（每秒字节数）
 */
- (void)player:(EZPlayer *)player didReceivedDataLength:(NSInteger)dataLength DEPRECATED_MSG_ATTRIBUTE("use getStreamFlow instead");

/**
 *  收到的画面长宽值
 *
 *  @param player 播放器对象
 *  @param height 高度
 *  @param width  宽度
 */
- (void)player:(EZPlayer *)player didReceivedDisplayHeight:(NSInteger)height displayWidth:(NSInteger)width;

@end

/// 此类为萤石播放器类
@interface EZPlayer : NSObject

/// EZPlayer关联的delegate
@property (nonatomic, weak) id<EZPlayerDelegate> delegate;

/// 是否让播放器处理进入后台,YES:自动处理;NO:不处理,默认为YES
@property (nonatomic) BOOL backgroundModeByPlayer;

/**
 *  根据设备序列号和通道号创建EZPlayer对象
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *
 *  @return EZPlayer对象
 */
+ (instancetype)createPlayerWithDeviceSerial:(NSString *)deviceSerial cameraNo:(NSInteger)cameraNo;

/**
 *  根据url构造EZPlayer对象 （主要用来处理视频广场的播放）
 *
 *  @param url 播放url
 *
 *  @return EZPlayer对象
 */
+ (instancetype)createPlayerWithUrl:(NSString *)url;


/**
 局域网设备创建播放器接口

 @param userId 用户id，登录局域网设备后获取
 @param cameraNo 通道号
 @param streamType 码流类型 1:主码流 2:子码流
 @return EZPlayer对象
 */
+ (instancetype)createPlayerWithUserId:(NSInteger) userId cameraNo:(NSInteger) cameraNo streamType:(NSInteger) streamType;

/**
 *  销毁EZPlayer
 *
 *  @return YES/NO;
 */
- (BOOL)destoryPlayer;

/**
 *  设置使用硬件解码器优先，需在startRealPlay之前调用
 *
 *  @param HDPriority 是否硬解优先
 */
-(void)setHDPriority:(BOOL)HDPriority;

/**
 获取当前的软硬解情况，在码流正常播放后调用
 
 @return 1：软解 2：硬解 0：出错
 */
- (int) getHDPriorityStatus;

/**
 *  设置播放器的view
 *
 *  @param playerView 播放器view
 */
- (void)setPlayerView:(UIView *)playerView;

/**
 *  开始播放，异步接口，返回值只是表示操作成功，不代表播放成功
 *
 *  @return YES/NO
 */
- (BOOL)startRealPlay;

/**
 *  停止播放，异步接口，返回值只是表示操作成功
 *
 *  @return YES/NO
 */
- (BOOL)stopRealPlay;

/**
 *  设置播放器解码密码
 *
 *  @param verifyCode 设备验证码
 */
- (void)setPlayVerifyCode:(NSString *)verifyCode;

/**
 *  开启声音
 *
 *  @return YES/NO
 */
- (BOOL)openSound;

/**
 *  关闭声音
 *
 *  @return YES/NO
 */
- (BOOL)closeSound;

/**
 获取播放组件内部的播放库的port
 
 @return 播放库的port,可能为-1（无效值）
 */
- (int) getInnerPlayerPort;

/**
 获取当前已播放的总流量，单位字节
 eg.计算每秒的流量：
 NSInteger a = [self getStreamFlow];
 //1s后调用
 NSInteger b = [self getStreamFlow];
 NSInteger perSecondFlow = b - a;
 
 @return 流量值
 */
- (NSInteger) getStreamFlow;

/**
 *  开始对讲，异步接口，返回值只是表示操作成功，不代表播放成功
 *
 *  @return YES/NO
 */
- (BOOL)startVoiceTalk;

/**
 *  停止对讲，异步接口，返回值只是表示操作成功
 *
 *  @return YES/NO
 */
- (BOOL)stopVoiceTalk;

/**
 预览时开始本地录像预录制功能，异步方法
 
 @param path 文件存储路径
 @return YES/NO
 */
- (BOOL)startLocalRecordWithPathExt:(NSString *)path;


/**
 结束本地录像预录制，并生成mp4录制文件，异步方法
 
 @param complete 操作是否成功 YES/NO
 */
- (void)stopLocalRecordExt:(void (^)(BOOL ret))complete;


/**
 *  半双工对讲专用接口，是否切换到听说状态
 *
 *  @param isPressed 是否只说状态
 *
 *  @return YES/NO
 */
- (BOOL)audioTalkPressed:(BOOL)isPressed;

/**
 *  开始云存储远程回放，异步接口，返回值只是表示操作成功，不代表播放成功
 *  @param cloudFile 云存储文件信息
 *
 *  @return YES/NO
 */
- (BOOL)startPlaybackFromCloud:(EZCloudRecordFile *)cloudFile;

/**
 *  开始远程SD卡回放，异步接口，返回值只是表示操作成功，不代表播放成功
 *
 *  @param deviceFile SD卡文件信息
 *
 *  @return YES/NO
 */
- (BOOL)startPlaybackFromDevice:(EZDeviceRecordFile *)deviceFile;

/**
 *  暂停远程回放播放
 */
- (BOOL)pausePlayback;

/**
 *  继续远程回放播放
 */
- (BOOL)resumePlayback;

/**
 *  根据偏移时间播放
 *
 *  @param offsetTime 录像偏移时间
 */
- (void)seekPlayback:(NSDate *)offsetTime;

/**
 *  获取当前播放时间进度
 *
 *  @return 播放进度的NSDate数据
 */
- (NSDate *)getOSDTime;

/**
 *  停止远程回放
 */
- (BOOL)stopPlayback;

/**
 *  直播画面抓图
 *
 *  @param quality 抓图质量（0～100）,数值越大图片质量越好，图片大小越大
 *
 *  @return image
 */
- (UIImage *)capturePicture:(NSInteger)quality;

/**
 获取内部播放器句柄。建议每次使用播放器句柄时均调用此方法获取，并进行有效性判断。

 @return 小于0为无效值，大于等于0为有效值
 */
- (int) getPlayPort;

/**
 获取当前取流方式：

 @return 
 */
- (int) getStreamFetchType;

/**
 SD卡回放专用接口，倍数回放，支持的倍速需要设备支持
 1.支持抽帧快放的设备最高支持16倍速快放（所有取流方式，包括P2P）
 2.不支持抽帧快放的设备，仅支持内外网直连快放，最高支持8倍
 3.HCNetSDK取流没有快放概念，全速推流，只改变播放库速率
 
 @param rate 回放倍率，见EZPlaybackRate
 @return YES/NO
 */
- (BOOL) setPlaybackRate:(EZPlaybackRate) rate;

/**
 云存储回放专用接口，倍数回放
 
 @param rate 回放倍率，见EZCloudPlaybackRate,目前云存储支持1、4、8、16、32倍数
 @return YES/NO
 */
- (BOOL) setCloudPlaybackRate:(EZPlaybackRate) rate;

/**
 设置全双工对讲时的模式,对讲成功后调用
 
 @param routeToSpeaker YES:使用扬声器 NO:使用听筒
 */
- (void) changeTalkingRouteMode:(BOOL) routeToSpeaker;

@end

