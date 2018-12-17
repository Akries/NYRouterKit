//
//  NSObject+Runtime.h
//  AK
//
//  Created by Akries.NY on 2017/9/14.
//  Copyright © 2017年 Akries.Ni. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h>

FOUNDATION_EXTERN NSString *const NYObjectTypeNotHandled;
FOUNDATION_EXTERN NSString *const NYObjectTypeClass;

FOUNDATION_EXTERN NSString *const NYObjectTypeRawInt;
FOUNDATION_EXTERN NSString *const NYObjectTypeRawFloat;
FOUNDATION_EXTERN NSString *const NYObjectTypeRawPointer;

@interface NSObject (Runtime)

@property (nonatomic, strong, readonly) NSMutableArray *associatedObjectNames;
@property (nonatomic, strong, readonly) NSArray<NSString*> *properties;
@property (nonatomic, strong, readonly) NSArray<NSDictionary<NSString*, NSString*>*> *propertyInfos;//KEY:propertyName, Value:propertyType

/**
 *  为当前object动态增加分类
 *
 *  @param propertyName   分类名称
 *  @param value  分类值
 *  @param policy 分类内存管理类型
 */
- (void)objc_setAssociatedObject:(NSString *)propertyName value:(id)value policy:(objc_AssociationPolicy)policy;

/**
 *  获取当前object某个动态增加的分类
 *
 *  @param propertyName 分类名称
 *
 *  @return 值
 */
- (id)objc_getAssociatedObject:(NSString *)propertyName;

- (void)objc_removeAssociatedObjectForPropertyName: (NSString*)propertyName;

/**
 *  删除动态增加的所有分类
 */
- (void)objc_removeAssociatedObjects;

+ (BOOL)overrideMethod:(SEL)origSel withMethod:(SEL)altSel;

+ (BOOL)overrideClassMethod:(SEL)origSel withClassMethod:(SEL)altSel;

+ (BOOL)exchangeMethod:(SEL)origSel withMethod:(SEL)altSel;

+ (BOOL)exchangeClassMethod:(SEL)origSel withClassMethod:(SEL)altSel;

@end

