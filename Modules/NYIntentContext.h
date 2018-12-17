//
//  NYIntentContext.h
//  AK
//
//  Created by Akries.NY on 2018/9/14.
//  Copyright © 2018年 Akries.Ni. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NYIntentContextHandler)(NSDictionary * _Nullable param,  void (^ _Nullable completion)(_Nullable id data));

/** 协议定义 */
@interface NYIntentContext : NSObject

/** 协议头 默认：kAppScheme */
@property (nonatomic, strong) NSString *scheme;

/** 跳转页面 默认：saicmobility.com */
@property (nonatomic, strong) NSString *router;

/** 全局方法 默认：handler */
@property (nonatomic, strong) NSString *handler;

/** 协议 默认：protocol */
@property (nonatomic, strong) NSString *protocol;

/** 参数key 默认：body */
@property (nonatomic, strong) NSString *parameterKey;

/**
 *  单例
 */
+ (instancetype) defaultContext;

@end


/** Router的处理 */
@interface NYIntentContext(Router)

/**
 *  注册视图控制器类（UIViewController or UIView）
 *
 *  @param aClass UIViewController or UIView 的子类
 *  @param key 键
 *
 */
- (void)registerRouterClass:(Class)aClass
                     forKey:(NSString *)key;

- (void)registerRouterClass:(Class)aClass
             forProtocolKey:(Protocol *)protocolKey;

/**
 *  卸载视图控制器类
 *
 *  @param key 键
 *
 */
- (void)unRegisterRouterClassForKey:(NSString *)key;


/**
 *  获取 视图控制器类
 *
 *  @param key 键
 *  @return Class
 */
- (_Nullable Class)routerClassForKey:(NSString *)key;

- (_Nullable Class)routerClassForProtocolKey:(Protocol *)protocolKey;

@end

/** Handler的处理 */
@interface NYIntentContext(Handler)


/**
 *  注册全局方法
 *  @param key 键
 */
- (void)registerHandler:(NYIntentContextHandler)handler
                 forKey:(NSString *)key;

/**
 *  注册全局方法
 *  @param key 键
 *  @param holder 持有者自动销毁全局方法
 */
- (void)registerHandler:(NYIntentContextHandler)handler
                 forKey:(NSString *)key
                 holder:(nullable NSObject *)holder;

/**
 *  卸载全局方法
 */
- (void)unRegisterHandlerForKey:(NSString *)key;

/**
 *  获取全局方法
 */
- (_Nullable NYIntentContextHandler)handlerForKey:(NSString *)key;


/**
 *  注册全局方法对应的对象实例
 *  @param key 键
 */
- (void)registerHandlerInstance:(id)aInstance
                         forKey:(NSString *)key;

/**
 *  卸载全局方法对应的对象实例
 */
- (void)unRegisterHandlerInstanceForKey:(NSString *)key;

/**
 *  获取全局方法对应的对象实例
 */
- (_Nullable id)handlerInstanceForKey:(NSString *)key;


@end


/** Protocol的处理 */
@interface NYIntentContext(Protocol)

/**
 *  注册 实现Protocol的类
 *
 *  @param aClass NSObject
 *  @param key 键
 *
 */
- (void)registerProtocolClass:(Class)aClass
                       forKey:(Protocol *)key;

/**
 *  卸载 实现Protocol的类
 *
 *  @param key 键
 *
 */
- (void)unRegisterProtocolClassForKey:(Protocol *)key;

/**
 *  卸载 实现Protocol的单例
 *
 *  @param key 键
 *
 */
- (void)unRegisterProtocolInstanceClassForKey:(Protocol *)key;


/**
 *  获取 实现Protocol的类
 *
 *  @param key 键
 *  @return Class
 */
- (_Nullable Class)protocolClassForKey:(Protocol *)key;


/**
 *  注册 实现Protocol的对象实例
 *
 *  @param aInstance 实例
 *  @param key 键
 *
 */
- (void)registerProtocolInstance:(id)aInstance
                          forKey:(Protocol *)key;

/**
 *  获取 实现Protocol类的对象实例
 *
 *  @param key 键
 *  @return Class
 */
- (_Nullable id)protocolInstanceClassForKey:(Protocol *)key;

@end


NS_ASSUME_NONNULL_END

