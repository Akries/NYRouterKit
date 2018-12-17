//
//  NYWeakObjDeathNoti.h
//  AK
//
//  Created by Akries.NY on 2018/9/14.
//  Copyright © 2018年 Akries.Ni. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//当owner释放的时候通知block
@class NYWeakObjDeathNoti;

typedef void(^NYWeakObjDeathNotiBlock)(NYWeakObjDeathNoti *sender);

@interface NYWeakObjDeathNoti : NSObject

@property (nonatomic, weak) id owner;//持有对象

//回调
- (void)setBlock:(NYWeakObjDeathNotiBlock)block;

@end

NS_ASSUME_NONNULL_END
