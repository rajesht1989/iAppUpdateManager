//
//
//  Created by Rajesh on 3/31/16.
//  Copyright © 2016 Rajesh. All rights reserved.
//

#import "AppModel.h"
#import "MTLValueTransformer.h"
#import "MTLJSONAdapter.h"
#import "NSString+Additions.h"
#import "NSDictionary+MTLManipulationAdditions.h"

@implementation AppModel

+ (NSUserDefaults *)preferences {
    return [NSUserDefaults standardUserDefaults];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [self propertyMapping];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    return dateFormatter;
}

+ (NSDateFormatter *)timeFormatter {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm:ss";
    return timeFormatter;
}

+ (MTLValueTransformer *)dateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError **error) {
        return [self.dateFormatter dateFromString:dateString];
    }                                           reverseBlock:^id(NSDate *date, BOOL *success, NSError **error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (MTLValueTransformer *)timeTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError **error) {
        return [self.timeFormatter dateFromString:dateString];
    }                                           reverseBlock:^id(NSDate *date, BOOL *success, NSError **error) {
        return [self.timeFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"createdAt"] || [key isEqualToString:@"updateAt"] || [key isEqualToString:@"lastActivityAt"]) {
        return [self dateTransformer];
    }
    else if ([key isEqualToString:@"from"] || [key isEqualToString:@"to"]) {
        return [self timeTransformer];
    }
    return nil;
}

+ (instancetype)fromJSON:(NSDictionary *)json {
    NSError *error;
    AppModel *model = [MTLJSONAdapter modelOfClass:self fromJSONDictionary:json error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    return model;
}

+ (NSArray *)fromJSONArray:(NSArray *)json {
    NSError *error;
    NSArray *array = [MTLJSONAdapter modelsOfClass:self fromJSONArray:json error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    return array;
}

- (void)save {
    [self.class.preferences setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:[NSString stringWithFormat:@"%@.%@", NSStringFromClass([self class]), @"cached"]];
    [self.class.preferences synchronize];
}

+ (instancetype)cached {
    id data = [self.preferences objectForKey:[NSString stringWithFormat:@"%@.%@", NSStringFromClass(self), @"cached"]];
    if(data){
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return data;
}

+ (void)clear {
    [self.preferences removeObjectForKey:[NSString stringWithFormat:@"%@.%@", NSStringFromClass([self class]), @"cached"]];
    [self.preferences synchronize];
    [self flush];
}

+ (void)flush {
    
}

+ (NSMutableDictionary *)propertyMapping {
    NSSet *properties = [self propertyKeys];
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] init];
    for (NSString *prop in properties) {
        mapping[prop] = self.shouldUseCamelCase ? [prop camelCaseToUnderscores] : prop;
    }
    return mapping;
}

+ (BOOL)shouldUseCamelCase {
    return NO;
}

/*
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super propertyMapping] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"identifier" : @"id"
              }];
}
*/

@end

@implementation DOUser

static DOUser *user = nil;

+ (DOUser *)currentUser {
    if (!user) {
        user = [DOUser cached];
    }
    return user;
}

- (void)save {
    [self setAuthToken:[AppAPIClient authToken]];
    [super save];
}

+ (void)flush {
    user = nil;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super propertyMapping] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"identifier" : @"id"
              }];
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"identifier"]) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
            return [NSString stringWithFormat:@"%@",value];
        } reverseBlock:^id(NSString *string, BOOL *success, NSError **error) {
            return string;
        }];
    }
    return [super JSONTransformerForKey:key];
}

@end

@implementation DOCountry

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super propertyMapping] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"identifier" : @"id"
              }];
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"identifier"]) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
            return [NSString stringWithFormat:@"%@",value];
        } reverseBlock:^id(NSString *string, BOOL *success, NSError **error) {
            return string;
        }];
    }
    return [super JSONTransformerForKey:key];
}

@end

@implementation DODependent

@end

@implementation DOMessage

@synthesize reuseIdentifier = _reuseIdentifier;

- (NSString *)reuseIdentifier {
    if (_reuseIdentifier.length == 0) {
        NSString *identifier;
        switch (_type) {
            case kImage :
                identifier = @"Image";
                break;
            default:
                identifier = @"Text";
                break;
        }
        _reuseIdentifier = [NSString stringWithFormat:@"%@%@",_isReceived ? @"received": @"sent",identifier];
    }
    return _reuseIdentifier;
}

@end

@implementation DOConsultation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super propertyMapping] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"identifier" : @"id"
              }];
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"identifier"]) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
            return [NSString stringWithFormat:@"%@",value];
        } reverseBlock:^id(NSString *string, BOOL *success, NSError **error) {
            return string;
        }];
    }
    return [super JSONTransformerForKey:key];
}

+ (BOOL)shouldUseCamelCase {
    return YES;
}

@end
