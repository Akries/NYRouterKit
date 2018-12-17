//
//  NYHandler.m
//  AK
//
//  Created by Akries.NY on 2018/9/14.
//  Copyright © 2018年 Akries.Ni. All rights reserved.
//

#import "NYHandler.h"

NSString const *NYHandlerCallBackKey = @"handlerCallBackKey";

@interface NYHandler ()

@property (nonatomic, strong) NSString *handlerKey;

@end

@implementation NYHandler

+ (id)realizeWithHandlerInstanceKey:(NSString *)handlerInstanceKey {
    id instance = [[NYIntentContext defaultContext] handlerInstanceForKey:handlerInstanceKey];
    if (!instance) {
        Class aClass = NSClassFromString(handlerInstanceKey);
        instance = [[aClass alloc] init];
        [[NYIntentContext defaultContext] registerHandlerInstance:instance forKey:handlerInstanceKey];
    }
    return instance;
}

- (instancetype)initWithHandlerKey:(NSString*)handlerKey {
    return [self initWithHandlerKey:handlerKey context:nil];
}

- (instancetype)initWithHandlerKey:(NSString*)handlerKey
                           context:(nullable NYIntentContext*)context {
    if (self = [super init]) {
        _context = context ?: [NYIntentContext defaultContext];
        self.handlerKey = handlerKey;
    }
    return self;
}

+ (void)realizeWithHandlerArray:(NSArray *)handlerKeys releaseHandler:(BOOL)isReleaseHandler  {
    
    for (id param in handlerKeys) {
        
        NSString *key;
        NSDictionary *dict;
        NYIntentCompletionBlock block;
        
        if ([param isKindOfClass:[NSString class]]) {
            key = param;
        }
        
        if ([param isKindOfClass:[NSArray class]]) {
            NSArray *arys = param;
            
            for (id ary in arys) {
                if ([ary isKindOfClass:[NSString class]]) {
                    key = ary;
                } else if ([ary isKindOfClass:[NSDictionary class]]) {
                    dict = ary;
                }  else {
                    block = ary;
                }
            }
        }
        
        NYHandler *handler = [[NYHandler alloc] initWithHandlerKey:key];
        [handler setExtraDataWithDictionary:dict];
        [handler submitWithCompletion:^(id  _Nullable data) {
            if (isReleaseHandler) {
                [[NYIntentContext defaultContext] unRegisterHandlerForKey:key];
            }
            if (block) {
                block(data);
            }
        }];
    }
}


- (id)submitWithCompletion:(NYIntentCompletionBlock)completionBlock {
    
    NYIntentContextHandler block = (NYIntentContextHandler)self.destination;
    if (block) {
        block(self.extraData, completionBlock);
    }
    return nil;
}


#pragma mark - get / set
- (NYIntentContextHandler)destination {
    if (!_destination) {
        _destination = [self.context handlerForKey:self.handlerKey];
    }
    return _destination;
}

@end



