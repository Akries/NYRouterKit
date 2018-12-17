//
//  NYIntentContext.m
//  AK
//
//  Created by Akries.NY on 2018/9/14.
//  Copyright © 2018年 Akries.Ni. All rights reserved.
//

#import "NYIntentContext.h"
#import "NYWeakObjDeathNoti.h"
#import <malloc/malloc.h>
#import <objc/runtime.h>

#pragma mark -- Context
@implementation NYIntentContext {
    NSMutableDictionary *_handlerDict;
    NSMutableDictionary *_handlerInstanceDict;
    NSMutableDictionary *_routerDict;
    NSMutableDictionary *_protocolDict;
    NSMutableDictionary *_protocolInstanceDict;
    dispatch_queue_t _innerQueue;
}


+ (instancetype) defaultContext {
    static dispatch_once_t once;
    static NYIntentContext * _singleton;
    dispatch_once(&once, ^{
        _singleton = [[self alloc] init];
    });
    return _singleton;
}


- (instancetype)init {
    if (self = [super init]) {
        _innerQueue = dispatch_queue_create("com.saic.router", DISPATCH_QUEUE_SERIAL);
        _scheme = @"saic";
        _router = @"saicmobility.com";
        _handler = @"handler";
        _protocol = @"protocol";
        _parameterKey = @"body";
        
        _handlerDict = [NSMutableDictionary dictionary];
        _handlerInstanceDict = [NSMutableDictionary dictionary];
        _routerDict = [NSMutableDictionary dictionary];
        _protocolDict = [NSMutableDictionary dictionary];
        _protocolInstanceDict = [NSMutableDictionary dictionary];
    }
    return self;
}

@end


#pragma mark -- router
@implementation NYIntentContext (Router)

- (void)registerRouterClass:(Class)aClass forKey:(NSString*)key {
    
    if (!aClass || !key.length) {
        return;
    }
    
    dispatch_async(_innerQueue, ^{
        [self->_routerDict setObject:aClass forKey:key];
    });
    
}

- (void)registerRouterClass:(Class)aClass
             forProtocolKey:(Protocol *)protocolKey {
    NSString *key = NSStringFromProtocol(protocolKey);
    [self registerRouterClass:aClass forKey:key];
}


- (void)unRegisterRouterClassForKey:(NSString*)key {
    
    if (key.length) {
        dispatch_async(_innerQueue, ^{
            [self->_routerDict removeObjectForKey:key];
        });
    }
    
}

- (_Nullable Class)routerClassForKey:(NSString*)key {
    
    __block Class aClass;
    dispatch_sync(_innerQueue, ^{
        aClass = [self->_routerDict objectForKey:key];
    });
    return aClass;
}

- (_Nullable Class)routerClassForProtocolKey:(Protocol *)protocolKey {
    
    NSString *key = NSStringFromProtocol(protocolKey);
    __block Class aClass;
    dispatch_sync(_innerQueue, ^{
        aClass = [self->_routerDict objectForKey:key];
    });
    return aClass;
}
@end


#pragma mark -- handler
@implementation NYIntentContext (Handler)

- (void)registerHandler:(NYIntentContextHandler)handler forKey:(NSString*)key {
    [self registerHandler:handler forKey:key holder:nil];
}

- (void)registerHandler:(NYIntentContextHandler)handler forKey:(NSString*)key holder:(nullable NSObject*)holder {
    if (!handler || !key.length) {
        return;
    }
    
    dispatch_async(_innerQueue, ^{
        [self->_handlerDict setObject:handler forKey:key];
        if (holder) {
            NYWeakObjDeathNoti *deadNotifier = [[NYWeakObjDeathNoti alloc] init];
            deadNotifier.owner = holder;
            
            //weak strong self for retain cycle
            __weak typeof(self)weakSelf = self;
            //目的在于，持有者在完成销毁时，自动把注册在字典里的Handler方法从内存中剔除。
            [deadNotifier setBlock:^(NYWeakObjDeathNoti *sender) {
                __strong typeof(weakSelf)self = weakSelf;
                [self unRegisterHandlerForKey:key];
            }];
        }
    });
}

- (void)unRegisterHandlerForKey:(NSString*)key {
    if (key.length) {
        dispatch_async(_innerQueue, ^{
            [self->_handlerDict removeObjectForKey:key];
        });
    }
}

- (_Nullable NYIntentContextHandler)handlerForKey:(NSString*)key {
    __block NYIntentContextHandler aHandler;
    dispatch_sync(_innerQueue, ^{
        aHandler = [self->_handlerDict objectForKey:key];
    });
    return aHandler;
}

- (void)registerHandlerInstance:(id)aInstance
                         forKey:(NSString *)key {
    
    if (!aInstance || !key.length) {
        return;
    }
    
    dispatch_async(_innerQueue, ^{
        [self->_handlerInstanceDict setObject:aInstance forKey:key];
    });
}

- (void)unRegisterHandlerInstanceForKey:(NSString *)key {
    if (key.length) {
        dispatch_async(_innerQueue, ^{
            [self->_handlerInstanceDict removeObjectForKey:key];
        });
    }
}

- (_Nullable id)handlerInstanceForKey:(NSString *)key {
    __block id aHandlerInstance;
    dispatch_sync(_innerQueue, ^{
        aHandlerInstance = [self->_handlerInstanceDict objectForKey:key];
    });
    return aHandlerInstance;
}

@end



#pragma mark -- protocol
@implementation NYIntentContext(Protocol)


- (void)registerProtocolClass:(Class)aClass
                       forKey:(Protocol *)key {
    
    NSString *protocolKey = NSStringFromProtocol(key);
    if (!aClass || !protocolKey.length) {
        return;
    }
    dispatch_async(_innerQueue, ^{
        [self->_protocolDict setObject:aClass forKey:protocolKey];
    });
}


- (void)unRegisterProtocolClassForKey:(Protocol *)key {
    
    NSString *protocolKey = NSStringFromProtocol(key);
    if (protocolKey.length) {
        dispatch_async(_innerQueue, ^{
            [self->_protocolDict removeObjectForKey:protocolKey];
        });
    }
}


- (void)unRegisterProtocolInstanceClassForKey:(Protocol *)key {
    NSString *protocolKey = NSStringFromProtocol(key);
    if (protocolKey.length) {
        dispatch_async(_innerQueue, ^{
            [self->_protocolInstanceDict removeObjectForKey:protocolKey];
        });
    }
}

- (_Nullable Class)protocolClassForKey:(Protocol *)key {
    __block Class aClass;
    
    NSString *protocolKey = NSStringFromProtocol(key);
    dispatch_sync(_innerQueue, ^{
        aClass = [self->_protocolDict objectForKey:protocolKey];
    });
    return aClass;
}


- (void)registerProtocolInstance:(id)aInstance
                          forKey:(Protocol *)key {
    
    NSString *protocolKey = NSStringFromProtocol(key);
    
    if (!aInstance || !protocolKey.length) {
        return;
    }
    dispatch_async(_innerQueue, ^{
        [self->_protocolInstanceDict setObject:aInstance forKey:protocolKey];
    });
}


- (_Nullable id)protocolInstanceClassForKey:(Protocol *)key {
    __block id aInstance;
    NSString *protocolKey = NSStringFromProtocol(key);
    dispatch_sync(_innerQueue, ^{
        aInstance = [self->_protocolInstanceDict objectForKey:protocolKey];
    });
    return aInstance;
}

@end
