//
//  NYRouter.h
//  AK
//
//  Created by Akries.NY on 2018/9/14.
//  Copyright © 2018年 Akries.Ni. All rights reserved.
//

#import "NYRouter.h"
#import "NYIntentContext.h"
#import <objc/runtime.h>

#import "NSObject+ExtraData.h"
#import "UIViewController+Router.h"
#import <KVOController/KVOController.h>
#import "REFrostedViewController.h"//抽屉
#import <RTRootNavigationController/RTRootNavigationController.h>

@implementation UIViewController (Dismiss)

- (void)_dismissViewController {
    [self.KVOController unobserveAll];
    [self dismissViewControllerAnimated:true completion:nil];
}

@end

@interface NYRouter()
@property (nonatomic, strong) UIViewController *routerSource;//当前的控制器 ps：视图层级最高的控制器
@property (nonatomic, strong) Class destinationClass;//获取destination的Class
@property (nonatomic, copy) NSString *routerKey;
@end

@implementation NYRouter

- (instancetype)initWithSource:(UIViewController*)source
                     routerKey:(NSString*)routerKey {
    return [self initWithSource:source routerKey:routerKey context:nil];
}

- (instancetype)initWithSource:(nullable UIViewController*)source routerProtocolKey:(Protocol *)protocolKey {
    NSString *key = NSStringFromProtocol(protocolKey);
    return [self initWithSource:source routerKey:key];
}

- (instancetype)initWithSource:(UIViewController *)source
                     routerKey:(NSString *)routerKey
                       context:(NYIntentContext *)context {
    if (self = [super init]) {
        _context = context ?: [NYIntentContext defaultContext];
        self.routerKey = routerKey;
        self.routerSource = source;
        self.animation = true;
        self.destinationClass = [self.context routerClassForKey:routerKey];
        NSAssert([self.destinationClass isSubclassOfClass:[UIViewController class]], @"%@ is not kind of UIViewController.class for key %@", self.destinationClass, routerKey);
    }
    return self;
    
}

- (instancetype)initWithSource:(nullable UIViewController*)source routerProtocolKey:(Protocol *)protocolKey context:(nullable NYIntentContext*)context {
    NSString *key = NSStringFromProtocol(protocolKey);
    return [self initWithSource:source routerKey:key context:context];
}


- (id)submitWithCompletion:(NYIntentCompletionBlock)completionBlock {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow endEditing:true];
        [super submitWithCompletion:completionBlock];
        
        if (!self.routerSource) {
            self.routerSource = AutoGetRoSourceViewController();
        }
        [self _submitRouterWithCompletion:completionBlock];
    });
    return nil;
}

#pragma mark - Private

//自动判断打开方式
- (NYIntentOptions)_autoGetActionOptions {
    return NYIntentActionPush;
    //    if (self.source.navigationController || [self.source isKindOfClass:[UINavigationController class]]) {
    //        return NYIntentActionPush;
    //    } else {
    //        return NYIntentActionPresent;
    //    }
}
//跳转
- (void)_submitRouterWithCompletion:(NYIntentCompletionBlock)completionBlock {
    //当前控制器
    UIViewController *sourceViewController = self.routerSource;
    //需要跳转的控制器
    UIViewController *destinationViewController = self.destination;
    
    
    if (self.options & NYIntentActionPresent) {
        
        UIViewController *destinationVC = destinationViewController;
        
        if (self.options & NYIntentPresentWrapNC) {
            //            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:destinationVC];
            //            navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            RTRootNavigationController *navigationController = [[RTRootNavigationController alloc] initWithRootViewController:destinationVC];
            navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            if (self.options & NYIntentPresentTransitionStyleFlipHorizontal) {
                navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            } else if (self.options & NYIntentPresentTransitionStyleCrossDissolve) {
                navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            } else if (self.options & NYIntentPresentTransitionStylePartialCurl) {
                navigationController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
            }
            
            destinationVC = navigationController;
        }
        
        if (self.options & NYIntentActionSideslipPop) {
            if ([destinationVC isKindOfClass:[UINavigationController class]]) {
                destinationViewController.router_options = self.options;
            } else {
                destinationVC.router_options = self.options;
            }
        }
        
        [sourceViewController presentViewController:destinationVC
                                           animated:self.animation
                                         completion:^{
                                             if (completionBlock) {
                                                 completionBlock(nil);
                                             }
                                         }];
        
    } else if (self.options & NYIntentActionPush) {
        
        //导航头
        UINavigationController *navigationController = AutoGetNavigationViewController(sourceViewController);
        NSAssert(navigationController, @"导航控制器不存在");
        
        if (self.options & NYIntentActionSideslipPop) {
            destinationViewController.router_options = self.options;
        }
        
        if (self.options & NYIntentPushSingleSelfStopTop) {
            
            for (UIViewController *aViewController in navigationController.viewControllers) {
                if ([aViewController isKindOfClass:[destinationViewController class]]) {
                    if (completionBlock) {
                        completionBlock(nil);
                    }
                    return;
                }
            }
            
        }
        
        BOOL shouldResetHideBottomBarWhenPushed = !sourceViewController.hidesBottomBarWhenPushed;
        sourceViewController.hidesBottomBarWhenPushed = true;
        [navigationController pushViewController:destinationViewController animated:self.animation];
        
        if (shouldResetHideBottomBarWhenPushed) {
            self.routerSource.hidesBottomBarWhenPushed = false;
        }
        
        if (self.options & NYIntentPushClearTop) {
            
            if (navigationController.viewControllers.count > 2) {
                NSMutableArray *copiedArray = [NSMutableArray array];
                [copiedArray addObject:navigationController.viewControllers.firstObject];
                [copiedArray addObject:destinationViewController];
                navigationController.viewControllers = copiedArray;
            }
            
        } else if (self.options & NYIntentPushSingleTop) {
            
            NSMutableArray *copiedArray = [NSMutableArray array];
            for (UIViewController *aViewController in navigationController.viewControllers) {
                if (aViewController != destinationViewController &&
                    [aViewController isMemberOfClass:[destinationViewController class]]) {
                    continue;
                }
                [copiedArray addObject:aViewController];
            }
            navigationController.viewControllers = copiedArray;
            
        }
        
        
        
        if (completionBlock) {
            completionBlock(nil);
        }
        
    }else if (self.options & NYIntentActionPop) {
        
        UINavigationController *nc = sourceViewController.navigationController;
        
        if ([sourceViewController isKindOfClass:[REFrostedViewController class]]) {
            REFrostedViewController *rostedVc = (REFrostedViewController *)sourceViewController;
            nc = (UINavigationController *)rostedVc.contentViewController;
        }
        nc.viewControllers.lastObject.router_key = self.routerKey;
        nc.viewControllers.lastObject.router_options = NYIntentActionSideslipPop;
        [nc popViewControllerAnimated:YES];
        
    } else {
        self.options = self.options | [self _autoGetActionOptions];
        [self _submitRouterWithCompletion:completionBlock];
    }
}

#pragma mark  get / set

- (UIViewController*)destination {
    if (!_destination && self.destinationClass) {
        NSBundle *bundle = [NSBundle bundleForClass:self.destinationClass];
        
        NSString *className = NSStringFromClass(self.destinationClass);
        BOOL isNibExist = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.nib",[bundle resourcePath],className]];
        
        if (isNibExist) {
            _destination = [[self.destinationClass alloc] initWithNibName:NSStringFromClass(self.destinationClass) bundle:bundle];
        } else {
            _destination = [[self.destinationClass alloc] init];
        }
    }
    return _destination;
}

- (void)setExtraData:(NSDictionary *)extraData {
    [super setExtraData:extraData];
    if ([self.destination isKindOfClass:[NSObject class]]) {
        ((NSObject*)self.destination).extraData = extraData;
    }
}
@end
