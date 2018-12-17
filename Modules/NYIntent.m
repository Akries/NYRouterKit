//
//  NYInternet.h
//  AK
//
//  Created by Akries.NY on 2017/9/14.
//  Copyright © 2017年 Akries.Ni. All rights reserved.
//

#import "NYIntent.h"
#import "NYRouter.h"
#import "NYHandler.h"
#import "NYProtocol.h"
#import "NYIntentContext.h"

#import <UIKit/UIKit.h>
#import "NSObject+ExtraData.h"
#import <REFrostedViewController/REFrostedViewController.h>

//当前控制器
UIViewController *AutoGetRoSourceViewController() {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *topVC = keyWindow.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    if ([topVC isKindOfClass:[UINavigationController class]]) {
        topVC = ((UINavigationController*)topVC).topViewController;
    }
    
    if ([topVC isKindOfClass:[REFrostedViewController class]]) {
        REFrostedViewController *frostedVC = (REFrostedViewController *)topVC;
        UINavigationController *nc = (UINavigationController *)frostedVC.contentViewController;
        topVC = nc.topViewController;
    }
    
    if ([topVC isKindOfClass:[UITabBarController class]]) {
        topVC = ((UITabBarController*)topVC).selectedViewController;
    }
    
    return topVC;
}

UINavigationController* AutoGetNavigationViewController(UIViewController *sourceVC) {
    
    UINavigationController *navigationController = nil;
    if ([sourceVC isKindOfClass:[UINavigationController class]]) {
        navigationController = (id)sourceVC;
    } else {
        UIViewController *superViewController = sourceVC.parentViewController;
        while (superViewController) {
            if ([superViewController isKindOfClass:[UINavigationController class]]) {
                navigationController = (id)superViewController;
                break;
            } else {
                superViewController = superViewController.parentViewController;
            }
        }
    }
    if (!navigationController) {
        REFrostedViewController *frostedVc = (REFrostedViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        
        if ([frostedVc isKindOfClass:[REFrostedViewController class]]) {
            navigationController = (UINavigationController *)frostedVc.contentViewController;
            [frostedVc hideMenuViewController];
        }
    }
    return navigationController;
}


@implementation NYIntent

@dynamic extraData;//使用NSObject+ExtraData中的setter和getter，所以此处不需要自己合成setter和getter

+ (nullable instancetype)intentWithURLString:(NSString *)destinationURLString
                                     context:(nullable NYIntentContext*)context {
    NSURL *link = [NSURL URLWithString:[destinationURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    return [self intentWithURL:link context:context];
}

+ (nullable instancetype)intentWithURL:(NSURL *)destinationURL
                               context:(nullable NYIntentContext*)context {
    
    if (!context) {
        context = [NYIntentContext defaultContext];
    }
    if (![destinationURL.scheme isEqualToString:context.scheme])return nil;
    
    NSString *host = destinationURL.host;
    NSString *path = destinationURL.path;
    NSString *query = destinationURL.query;
    
    
    if ([path hasPrefix:@"/"]) {
        path = [path substringWithRange:NSMakeRange(1,path.length - 1)];
    }
    
    query = [query stringByRemovingPercentEncoding];
    
    NYIntent *aIntent = nil;//默认handler
    if ([host isEqualToString:context.router]) {
        aIntent = [[NYRouter alloc] initWithSource:nil routerKey:path context:context];
    } else if ([host isEqualToString:context.handler]){
        aIntent = [[NYHandler alloc] initWithHandlerKey:path context:context];
    } else if ([host isEqualToString:context.protocol]){
        aIntent = [NYProtocol createInstanceWithProtocolKey:NSProtocolFromString(path)];
    }
    
    if (aIntent) {
        [aIntent _setExtraDataByQueryString:query];
    }
    aIntent.key = path;
    return aIntent;
}

- (void)setExtraDataWithValue:(nullable id)value forKey:(NSString *)key {
    if (value == nil)return;
    NSMutableDictionary *dict = self.extraData.mutableCopy;
    if (!dict) dict = [NSMutableDictionary dictionary];
    [dict setObject:value forKey:key];
    self.extraData = dict.copy;
}

- (void)setExtraDataWithDictionary:(nullable NSDictionary *)dictionary {
    if (dictionary == nil)return;
    NSMutableDictionary *dict = self.extraData.mutableCopy;
    if (!dict) dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:dictionary];
    self.extraData = dict.copy;
}

- (id)submit {
    return [self submitWithCompletion:nil];
}

- (id)submitWithCompletion:(NYIntentCompletionBlock)completionBlock {
    return nil;
}


#pragma mark - Private
- (void)_setExtraDataByQueryString:(NSString*)queryString {
    if (!queryString.length) {
        return;
    }
    
    NSString *jsonString = [queryString stringByRemovingPercentEncoding];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSArray *subStrings = [jsonString componentsSeparatedByString:@"="];
    NSString *body = [NYIntentContext defaultContext].parameterKey;
    if ([body isEqualToString:subStrings[0]]) {
        if (subStrings[1]) {
            NSRange endCharRange = [jsonString rangeOfString:@"}" options:NSBackwardsSearch];
            if (endCharRange.location != NSNotFound) {
                jsonString = [jsonString substringToIndex:endCharRange.location + 1];
            }
            NSRange range = [jsonString rangeOfString:@"="];
            //除去body＝剩下纯json格式string
            NSString *jsonStr = [jsonString substringFromIndex:range.location + 1];
            
            if ([[jsonStr substringFromIndex:(jsonStr.length - 1)] isEqualToString:@"\""]) { // 去掉末尾"号
                jsonStr = [jsonStr substringToIndex:(jsonStr.length-1)];
            }
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingAllowFragments
                                                                  error:nil];
            dict[body] = dic;
        }
    }
    [dict.copy enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            dict[key] = [obj stringValue];
        }
    }];
    
    NSDictionary *data = dict[body];
    if ([data isKindOfClass:[NSDictionary class]]) {
        self.extraData = data;
    }
}


@end

