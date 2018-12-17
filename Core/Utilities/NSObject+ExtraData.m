//
//  NSObject+ExtraData.m
//  AK
//
//  Created by Akries.NY on 2017/9/14.
//  Copyright © 2017年 Akries.Ni. All rights reserved.
//

#import "NSObject+ExtraData.h"
#import "NSObject+Runtime.h"
#import <MJExtension/MJExtension.h>

@implementation NSObject (ExtraData)

- (void)setExtraData:(NSDictionary*)extraData {
    
    if ([extraData isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *classProps = [self classProps];
        
        [extraData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *keyDescription = [key description];
            NSString *setterKey = keyDescription;
            if (keyDescription.length >= 1) {
                NSString *firstLetter = [keyDescription substringToIndex:1];
                setterKey = [keyDescription stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[firstLetter uppercaseString]];
            }
            SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@:", setterKey]);
            if ([self respondsToSelector:setter]) {
                
                NSString *aClass = classProps[keyDescription];
                
                BOOL isClass = [[aClass lowercaseString] hasPrefix:@"ny"];
                
                if (isClass) {
                    NSDictionary *dic;
                    if([obj isKindOfClass:[NSDictionary class]]){
                        dic = obj;
                    } else if ([obj isKindOfClass:[NSString class]]) {
                        
                        dic = [NSJSONSerialization JSONObjectWithData:[obj dataUsingEncoding:NSUTF8StringEncoding]
                                                              options:NSJSONReadingAllowFragments
                                                                error:nil];
                    }
                    
                    if (dic) {
                        Class cls = NSClassFromString(aClass);
                        [self setValue:[cls mj_objectWithKeyValues:obj] forKey:keyDescription];
                    } else {
                        [self setValue:obj forKey:keyDescription];
                    }
                    
                } else {
                    [self setValue:obj forKey:keyDescription];
                    
                }
            }
        }];
        
        if (extraData.count) {
            [self objc_setAssociatedObject:@"NY_extraData" value:extraData policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
        }
    }
}

- (NSDictionary*)extraData {
    return [self objc_getAssociatedObject:@"NY_extraData"];
}

//获取属性类型
- (NSDictionary *)classProps
{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            if (propType == NULL)continue;
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            [results setObject:propertyType forKey:propertyName];//key 属性名称  value 属性类型
        }
    }
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:results];
}

//获取属性类型的方法
static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

@end
