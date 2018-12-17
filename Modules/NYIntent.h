//
//  NYInternet.h
//  AK
//
//  Created by Akries.NY on 2017/9/14.
//  Copyright © 2017年 Akries.Ni. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN UIViewController *AutoGetRoSourceViewController(void);
FOUNDATION_EXTERN UINavigationController * _Nullable  AutoGetNavigationViewController(UIViewController *sourceVC);

typedef void(^NYIntentCompletionBlock)(__nullable id data);


@class NYIntentContext;
@interface NYIntent : NSObject {
    id _destination;
    NYIntentContext *_context;
}

//使用 [NYIntentContext defaultContext]
@property (nonatomic, strong, readonly) NYIntentContext *context;

//解析后的key
@property (nonatomic, copy ,nullable) NSString *key;

/**
 *  通过NYIntent传递的参数
 *  在viewController中，可以通过调用self.extraData来获得参数集合
 */
@property (nonatomic, strong,readonly,nullable) NSDictionary *extraData;

@property (nonatomic, assign) NSInteger options;

/**
 *  Init NYIntent.
 *  destinationURLString 传递url
 */
+ (nullable instancetype)intentWithURLString:(NSString *)destinationURLString
                                     context:(nullable NYIntentContext*)context;

+ (nullable instancetype)intentWithURL:(NSURL *)destinationURL
                               context:(nullable NYIntentContext*)context;

/**
 *  安全添加元素
 */
- (void)setExtraDataWithValue:(nullable id)value forKey:(NSString *)key;

/**
 *  安全添加字典
 */
- (void)setExtraDataWithDictionary:(nullable NSDictionary *)dictionary;

/**
 *  提交行动
 */
- (id)submit;

/**
 *  提交行动，完成回调
 */
- (id)submitWithCompletion:(nullable NYIntentCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END

