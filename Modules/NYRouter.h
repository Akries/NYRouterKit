//
//  NYRouter.h
//  AK
//
//  Created by Akries.NY on 2018/9/14.
//  Copyright © 2018年 Akries.Ni. All rights reserved.
//

#import "NYIntent.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kBackRouterKey = @"router_key";

//NYIntentOptions 枚举 来决定用什么方式来打开控制器
typedef NS_OPTIONS(NSUInteger, NYIntentOptions) {
    NYIntentActionPresent          = 1 << 0,   //调用 presentViewController:animated:completion:
    NYIntentActionPush             = 1 << 1,   //调用 pushViewController:animated:
    NYIntentActionPop              = 1 << 2,   //调用 popToViewController:animated: 可以返回到任何指定的控制器。
    NYIntentActionSideslipPop      = 1 << 10, //if options & NYIntentOptionsPush or  if option & NYIntentActionPresent | NYIntentPresentWrapNC, 侧滑时指定页面 需传kBackRouterKey ，不传默认首页。
    
    NYIntentPushClearTop           = 1 << 3,   //if options & NYIntentOptionsPush, push前移除掉前面所有的控制器
    NYIntentPushSingleTop          = 1 << 4,   //if options & NYIntentOptionsPush, push前移除掉同样类型的控制器
    NYIntentPushSingleSelfStopTop  = 1 << 5,   //if options & NYIntentOptionsPush, push前判断是否有同类型控制器，如果有阻止push
    
    NYIntentPresentWrapNC          = 1 << 6,   //if option & NYIntentActionPresent, add UINavigationController
    NYIntentPresentTransitionStyleFlipHorizontal = 1 << 7,//if option & NYIntentActionPresent | NYIntentPresentWrapNC, use UIModalTransitionStyleFlipHorizontal
    NYIntentPresentTransitionStyleCrossDissolve  = 1 << 8, //if option & NYIntentActionPresent |NYIntentPresentWrapNC, use UIModalTransitionStyleCrossDissolve
    NYIntentPresentTransitionStylePartialCurl    = 1 << 9, //if option & NYIntentActionPresent |NYIntentPresentWrapNC, use UIModalTransitionStylePartialCurl
};

@interface UIViewController (Dismiss)

- (void)_dismissViewController;

@end

@interface NYRouter : NYIntent

//被自动跳转到控制器
@property (nonatomic, strong, readonly) UIViewController *destination;

//跳转动画 default is true
@property (nonatomic, assign) BOOL animation;

/**
 *  Init NYRouter
 *
 *  @param source        如果没有设置，将自动获取一个UIViewController来执行路由器
 *  @param routerKey     通过routerKey找到需要跳转的控制器
 *
 */
- (instancetype)initWithSource:(nullable UIViewController*)source routerKey:(NSString*)routerKey;

- (instancetype)initWithSource:(nullable UIViewController*)source routerProtocolKey:(Protocol *)protocolKey;

/**
 *  Init NYRouter
 *
 *  @param source        如果没有设置，将自动获取一个UIViewController来执行路由器
 *  @param routerKey     通过routerKey找到需要跳转的控制器
 *  @param context       获取数据字典
 */
- (instancetype)initWithSource:(nullable UIViewController*)source routerKey:(NSString*)routerKey context:(nullable NYIntentContext*)context;

- (instancetype)initWithSource:(nullable UIViewController*)source routerProtocolKey:(Protocol *)protocolKey context:(nullable NYIntentContext*)context;

@end

NS_ASSUME_NONNULL_END
