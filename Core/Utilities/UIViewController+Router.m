//
//  UIViewController+Router.m
//  AK
//
//  Created by Akries.NY on 2017/9/14.
//  Copyright © 2017年 Akries.Ni. All rights reserved.
//


#import "UIViewController+Router.h"
#import "NSObject+Runtime.h"
#import "NYIntentContext.h"
#import <REFrostedViewController/REFrostedViewController.h>//抽屉

@implementation UIViewController (Router)

+ (void)runtimeOriginMethod:(SEL)originSelector forSwizzledMethod:(SEL)swizzledSelector {
    Class class = [self class];
    Method originMethod = class_getInstanceMethod(class, originSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originMethod),
                            method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, swizzledMethod);
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originSelector = @selector(willMoveToParentViewController:);
        SEL swizzledSelector = @selector(router_willMoveToParentViewController:);
        [self runtimeOriginMethod:originSelector forSwizzledMethod:swizzledSelector];
        
        SEL originSelector2 = @selector(dismissViewControllerAnimated:completion:);
        SEL swizzledSelector2 = @selector(router_dismissViewControllerAnimated:completion:);
        [self runtimeOriginMethod:originSelector2 forSwizzledMethod:swizzledSelector2];
    });
}

#pragma mark - LifeCycle

- (void)router_dismissViewControllerAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion {
    
    if (self.router_options & NYIntentActionSideslipPop) {
        
        UIViewController *currentVc = [self router_findVc];
        if ([self router_homeWithVC:currentVc])return;
        if (!currentVc)return;
        
        NSArray *vcs = [self router_retrieveWithVC:currentVc];
        
        //判断是否需要dissmiss
        if (self.presentingViewController != currentVc.presentingViewController && self.presentingViewController) {
            [currentVc.navigationController setViewControllers:vcs animated:NO];
            [currentVc dismissViewControllerAnimated:YES completion:nil];
        } else {
            [currentVc.navigationController setViewControllers:vcs animated:YES];
        }
    }
    
    [self router_dismissViewControllerAnimated:flag completion:completion];
}

- (void)router_willMoveToParentViewController:(UIViewController*)parent {
    
    [self router_willMoveToParentViewController:parent];
    
    if (!(self.router_options & NYIntentActionSideslipPop) || parent || ![AutoGetRoSourceViewController() isEqual:self])return;
    
    self.router_options = 0;
    
    UIViewController *currentVc = [self router_findVc];
    
    if ([self router_homeWithVC:currentVc])return;
    if (!currentVc)return;
    
    NSArray *vcs = [self router_retrieveWithVC:currentVc];
    
    //判断是否需要dissmiss
    if (self.presentingViewController != currentVc.presentingViewController && self.presentingViewController) {
        [currentVc.navigationController setViewControllers:vcs animated:NO];
        [currentVc dismissViewControllerAnimated:YES completion:nil];
    } else {
        [currentVc.navigationController setViewControllers:vcs animated:YES];
    }
}

//找到需要返回的控制器
- (UIViewController *)router_findVc {
    
    Class cls = [[NYIntentContext defaultContext] routerClassForKey:self.router_key];
    
    UIViewController *presentingVc = self;
    UIViewController *homePageVc = self;
    
    for (UIViewController *subVc in presentingVc.navigationController.viewControllers) {
        if ([subVc isKindOfClass:[cls class]]) {
            return subVc;
        }
    }
    
    while(presentingVc.presentingViewController != nil){
        presentingVc = presentingVc.presentingViewController;
        
        UINavigationController *nc = [self acquireNavigationController:presentingVc];
        
        for (UIViewController *subVc in nc.viewControllers) {
            if ([subVc isKindOfClass:[cls class]]) {
                return subVc;
            }
            homePageVc = subVc;
        }
    }
    
    return homePageVc;
}

//清理掉不需要显示的控制器
- (NSArray *)router_retrieveWithVC:(UIViewController *)currentVc {
    
    Class routerClass = [[NYIntentContext defaultContext] routerClassForKey:self.router_key];
    
    UINavigationController *nc = [self acquireNavigationController:currentVc];
    
    NSMutableArray *removeArray =  [NSMutableArray array];
    
    NSInteger vcCount = nc.viewControllers.count;
    
    for (NSInteger i = vcCount - 1; i >= 0; i--) {
        UIViewController *vc = nc.viewControllers[i];
        if ([vc isKindOfClass:[routerClass class]] || vc == currentVc) {
            break;
        } else {
            [removeArray addObject:vc];
        }
    }
    
    NSArray *copiedArray = nil;
    if (removeArray.count) {
        copiedArray = [nc.viewControllers subarrayWithRange:NSMakeRange(0, vcCount - removeArray.count)];
    }
    
    for (UIViewController *vc in removeArray) {
        if ([vc isEqual:self]) {
            continue;
        }
        if ([vc isViewLoaded]) {
            [vc.view removeFromSuperview];
        }
        [vc removeFromParentViewController];
    }
    
    return nc.viewControllers;
}

//返回首页
- (BOOL)router_homeWithVC:(UIViewController *)currentVc {
    BOOL isBakeHome = !self.router_key.length || [currentVc isEqual:self];
    if (isBakeHome) {
        if (currentVc) {
            currentVc = currentVc.navigationController.viewControllers.firstObject;
            NSArray *vcs = [self router_retrieveWithVC:currentVc];
            [currentVc dismissViewControllerAnimated:YES completion:^{//dismiss 所有model出来的vc
                [currentVc.navigationController setViewControllers:vcs animated:YES];
            }];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
    return isBakeHome;
}

- (UINavigationController *)acquireNavigationController:(UIViewController *)vc {
    UINavigationController *nc = vc.navigationController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        nc = (UINavigationController *)vc;
    }
    
    if ([vc isKindOfClass:[REFrostedViewController class]]) {
        REFrostedViewController *rostedVc = (REFrostedViewController *)vc;
        nc = (UINavigationController *)rostedVc.contentViewController;
    }
    return nc;
}

#pragma mark - get / set
- (NYIntentOptions)router_options {
    NSString *options = [self objc_getAssociatedObject:@"ny_router_options"];
    if (!options) {
        options = @"0";
    }
    return [options integerValue];
}

- (void)setRouter_options:(NYIntentOptions)router_options {
    NSString *options = [NSString stringWithFormat:@"%lu",(unsigned long)router_options];
    [self objc_setAssociatedObject:@"ny_router_options" value:options policy:OBJC_ASSOCIATION_COPY_NONATOMIC];
}

- (NSString *)router_key {
    NSString *key = [self objc_getAssociatedObject:@"ny_router_key"];
    return key;
}

- (void)setRouter_key:(NSString *)router_key {
    [self objc_setAssociatedObject:@"ny_router_key" value:router_key policy:OBJC_ASSOCIATION_COPY_NONATOMIC];
}

@end
