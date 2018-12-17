//
//  NYHandler.h
//  AK
//
//  Created by Akries.NY on 2018/9/14.
//  Copyright © 2018年 Akries.Ni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NYIntent.h"
#import "NYIntentContext.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString const *NYHandlerCallBackKey;

@class NYIntentContext;
@interface NYHandler : NYIntent

@property (nonatomic, copy, readonly) NYIntentContextHandler destination;//回调

/**
 *   NYHandler 对应的对象实例
 *
 *  @param handlerInstanceKey     HandlerInstanceKey
 *  @return 返回NYHandler 对应的对象实例
 */
+ (id)realizeWithHandlerInstanceKey:(NSString *)handlerInstanceKey;

/**
 *  Init NYHandler.
 *
 *  @param handlerKey     用于创建全局方法key
 *
 */
- (instancetype)initWithHandlerKey:(NSString *)handlerKey;

/**
 *  Init NYHandler.
 *
 *  @param handlerKey     用于创建全局方法
 *  @param context        if not nil,将成为context的方法
 *
 */
- (instancetype)initWithHandlerKey:(NSString *)handlerKey
                           context:(nullable NYIntentContext *)context;

/**
 *  批量执行handler
 *
 *  @param handlerKeys     用于创建全局方法key数组
 *  @param isReleaseHandler  是否自动释放key对象 默认NO
 */
+ (void)realizeWithHandlerArray:(NSArray *)handlerKeys releaseHandler:(BOOL)isReleaseHandler;

@end

NS_ASSUME_NONNULL_END
