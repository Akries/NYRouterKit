//
//  NYProtocol.m
//  AK
//
//  Created by Akries.NY on 2018/9/14.
//  Copyright © 2018年 Akries.Ni. All rights reserved.
//

#import "NYProtocol.h"
#import "NYIntentContext.h"
#import "NSObject+ExtraData.h"


@interface NYProtocol()
@property (nonatomic, strong, readonly) id destination;
@property (nonatomic, strong) Class destinationClass;//获取destination的Class
@property (nonatomic, strong) id destinationInstance;//获取destination的实例对象
@end


@implementation NYProtocol

+ (id)createInstanceWithProtocolKey:(Protocol *)protocolKey {
    NYProtocol *protocol = [[NYProtocol alloc] initWithProtocolKey:protocolKey];
    return [protocol submit];
}

+ (id)sharedInstanceWithProtocolKey:(Protocol *)protocolKey {
    NYProtocol *protocol = [[NYProtocol alloc] initWithProtocolInstanceKey:protocolKey];
    return [protocol submit];
}

+ (id)replaceSharedInstance:(id)instance protocolKey:(Protocol *)protocolKey {
    NYProtocol *protocol = [[NYProtocol alloc] initWithProtocolInstanceKey:protocolKey aInstance:instance];
    return [protocol submit];
}

+ (Class)classFromProtocol:(Protocol *)protocolKey {
    NYProtocol *protocol = [[NYProtocol alloc] initWithProtocolKey:protocolKey];
    return protocol.destinationClass;
}

- (instancetype)initWithProtocolKey:(Protocol *)protocolKey {
    if (self = [super init]) {
        _context = [NYIntentContext defaultContext];
        self.destinationClass = [self.context protocolClassForKey:protocolKey];
    }
    return self;
}

- (instancetype)initWithProtocolInstanceKey:(Protocol *)protocolKey {
    if (self = [super init]) {
        _context = [NYIntentContext defaultContext];
        
        id instance = [self.context protocolInstanceClassForKey:protocolKey];
        if (instance) {
            self.destinationInstance = instance;
        } else {
            self.destinationClass = [self.context protocolClassForKey:protocolKey];
            [self.context registerProtocolInstance:self.destination forKey:protocolKey];
        }
    }
    return self;
}

- (instancetype)initWithProtocolInstanceKey:(Protocol *)protocolKey aInstance:(id)instance {
    if (self = [super init]) {
        _context = [NYIntentContext defaultContext];
        [self.context registerProtocolInstance:instance forKey:protocolKey];
        self.destinationInstance = instance;
    }
    return self;
}

/**
 *  提交行动
 */
- (id)submit {
    return [self destination];
}

#pragma mark  get / set

- (id)destination {
    if (self.destinationInstance) {
        return self.destinationInstance;
    }
    if (!_destination && self.destinationClass) {
        _destination = [[self.destinationClass alloc] init];
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
