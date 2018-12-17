//
//  NSObject+Runtime.m
//  AK
//
//  Created by Akries.NY on 2017/9/14.
//  Copyright © 2017年 Akries.Ni. All rights reserved.
//


#import "NSObject+Runtime.h"

NSString *const NYObjectTypeNotHandled = @"__NY_OBJECT_TYPE_NOT_HANDLED";
NSString *const NYObjectTypeClass = @"__NY_OBJECT_TYPE_CLASS";

NSString *const NYObjectTypeRawInt = @"__NY_OBJECT_TYPE_RAW_INT";
NSString *const NYObjectTypeRawFloat = @"__NY_OBJECT_TYPE_RAW_FLOAT";
NSString *const NYObjectTypeRawPointer = @"__NY_OBJECT_TYPE_RAW_POINTER";


@implementation NSObject (Runtime)

static char associatedObjectNamesKey;

- (void)setAssociatedObjectNames:(NSMutableArray *)associatedObjectNames {
    objc_setAssociatedObject(self, &associatedObjectNamesKey, associatedObjectNames,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)associatedObjectNames {
    NSMutableArray *array = objc_getAssociatedObject(self, &associatedObjectNamesKey);
    if (!array) {
        array = [NSMutableArray array];
        [self setAssociatedObjectNames:array];
    }
    return array;
}

- (void)objc_setAssociatedObject:(NSString *)propertyName value:(id)value policy:(objc_AssociationPolicy)policy {
    objc_setAssociatedObject(self, (__bridge objc_objectptr_t)propertyName, value, policy);
    [self.associatedObjectNames addObject:propertyName];
}

- (id)objc_getAssociatedObject:(NSString *)propertyName {
    for (NSString *key in self.associatedObjectNames) {
        if ([key isEqualToString:propertyName]) {
            return objc_getAssociatedObject(self, (__bridge objc_objectptr_t)key);
        }
    }
    return nil;
}

- (void)objc_removeAssociatedObjectForPropertyName: (NSString*)propertyName {
    [self objc_setAssociatedObject:propertyName value:nil policy:OBJC_ASSOCIATION_ASSIGN];
    [self.associatedObjectNames removeObject:propertyName];
}

- (void)objc_removeAssociatedObjects {
    [self.associatedObjectNames removeAllObjects];
    objc_removeAssociatedObjects(self);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

- (void)setNilValueForKey:(NSString *)key {
}

- (NSArray *)properties {
    NSArray *storedProperties = [self objc_getAssociatedObject:@"NY_properties"];
    if (storedProperties) {
        return storedProperties;
    }
    NSMutableArray *props = [NSMutableArray array];
    unsigned int outCount, i;
    Class targetClass = [self class];
    while (targetClass != [NSObject class]) {
        objc_property_t *properties = class_copyPropertyList(targetClass, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *char_f = property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:char_f];
            [props addObject:propertyName];
        }
        free(properties);
        targetClass = [targetClass superclass];
    }
    [self objc_setAssociatedObject:@"NY_properties" value:props.copy policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
    return props;
}

- (NSArray *)propertyInfos {
    NSMutableArray *props = [NSMutableArray array];
    unsigned int outCount, i;
    Class targetClass = [self class];
    while (targetClass != [NSObject class]) {
        objc_property_t *properties = class_copyPropertyList(targetClass, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            
            const char *char_f = property_getName(property);
            
            NSString *resultPropertyName = [NSString stringWithUTF8String:char_f];
            NSString *resultPropertyType = nil;
            
            
            const char *type = property_getAttributes(property);
            NSString * typeString = [NSString stringWithUTF8String:type];
            NSArray * attributes = [typeString componentsSeparatedByString:@","];
            NSString * typeAttribute = [attributes objectAtIndex:0];
            NSString * propertyType = [typeAttribute substringFromIndex:1];
            const char * rawPropertyType = [propertyType UTF8String];
            
            if (strcmp(rawPropertyType, @encode(float)) == 0) {
                resultPropertyType = NYObjectTypeRawFloat;
            } else if (strcmp(rawPropertyType, @encode(int)) == 0) {
                resultPropertyType = NYObjectTypeRawInt;
            } else if (strcmp(rawPropertyType, @encode(id)) == 0) {
                resultPropertyType = NYObjectTypeRawPointer;
            }
            if ([typeAttribute hasPrefix:@"T@"]) {
                resultPropertyType = NYObjectTypeClass;
            }
            [props addObject:@{resultPropertyName:(resultPropertyType?:NYObjectTypeNotHandled)}];
        }
        free(properties);
        targetClass = [targetClass superclass];
    }
    return props;
}

+ (BOOL)overrideMethod:(SEL)origSel withMethod:(SEL)altSel {
    Method origMethod =class_getInstanceMethod(self, origSel);
    if (!origMethod) {
        return NO;
    }
    
    Method altMethod =class_getInstanceMethod(self, altSel);
    if (!altMethod) {
        return NO;
    }
    
    method_setImplementation(origMethod, class_getMethodImplementation(self, altSel));
    return YES;
}

+ (BOOL)overrideClassMethod:(SEL)origSel withClassMethod:(SEL)altSel {
    Class c = object_getClass((id)self);
    return [c overrideMethod:origSel withMethod:altSel];
}

+ (BOOL)exchangeMethod:(SEL)origSel withMethod:(SEL)altSel {
    Method origMethod =class_getInstanceMethod(self, origSel);
    if (!origMethod) {
        return NO;
    }
    
    Method altMethod =class_getInstanceMethod(self, altSel);
    if (!altMethod) {
        return NO;
    }
    
    method_exchangeImplementations(class_getInstanceMethod(self, origSel),class_getInstanceMethod(self, altSel));
    
    return YES;
}

+ (BOOL)exchangeClassMethod:(SEL)origSel withClassMethod:(SEL)altSel {
    Class c = object_getClass((id)self);
    return [c exchangeMethod:origSel withMethod:altSel];
}
@end

