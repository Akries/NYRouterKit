//
//  UIViewController+Router.h
//  AK
//
//  Created by Akries.NY on 2017/9/14.
//  Copyright © 2017年 Akries.Ni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYRouter.h"

@interface UIViewController (Router)
@property (nonatomic,copy) NSString *router_key;
@property (nonatomic,assign) NYIntentOptions router_options;
@end
