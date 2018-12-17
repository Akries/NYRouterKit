//
//  NYWeakObjDeathNoti.m
//  AK
//
//  Created by Akries.NY on 2018/9/14.
//  Copyright © 2018年 Akries.Ni. All rights reserved.
//

#import "NYWeakObjDeathNoti.h"
#import "NSObject+Runtime.h"

@interface NYWeakObjDeathNoti ()

@property (nonatomic, copy) NYWeakObjDeathNotiBlock aBlock;

@end

@implementation NYWeakObjDeathNoti

- (void)setBlock:(NYWeakObjDeathNotiBlock)block {
    self.aBlock = block;
}

- (void)setOwner:(id)owner {
    _owner = owner;
    
    [owner objc_setAssociatedObject:[NSString stringWithFormat:@"observerOwner_%p",self] value:self policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (void)dealloc {
    if (self.aBlock) {
        self.aBlock(self);
    }
    
    self.aBlock = nil;
}

@end
