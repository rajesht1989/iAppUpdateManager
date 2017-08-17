//
//  AppUpdateManager.m
//  iAppUpdateManager
//
//  Created by Rajesh Thangaraj on 20/07/17.
//  Copyright © 2017 Yaash. All rights reserved.
//

#import "iAppUpdateManager.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface AppModel : NSObject

- (void)save;

+ (void)clear;

+ (void)flush; // To flush live memory

+ (instancetype)saved;

@property (nonatomic, strong) NSDate *lastShownDate;
@property (nonatomic, assign) NSInteger appLaunchCount;
@property (nonatomic, strong) NSString *skippedVersion;
@property (nonatomic, assign) BOOL showLater;
@property (nonatomic, assign) BOOL neverShow;

@end

@implementation AppModel

+ (NSUserDefaults *)preferences {
    return [NSUserDefaults standardUserDefaults];
}

- (void)save {
    [self.class.preferences setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:[NSString stringWithFormat:@"%@.%@", NSStringFromClass([self class]), @"saved"]];
    [self.class.preferences synchronize];
}

+ (instancetype)saved {
    id data = [self.preferences objectForKey:[NSString stringWithFormat:@"%@.%@", NSStringFromClass(self), @"saved"]];
    if(data){
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return data;
}

+ (void)clear {
    [self.preferences removeObjectForKey:[NSString stringWithFormat:@"%@.%@", NSStringFromClass([self class]), @"saved"]];
    [self.preferences synchronize];
    [self flush];
}

+ (void)flush {
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString *key in [self propertyKeys]) {
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [self init])) {
        for (NSString *key in [self propertyKeys]) {
            id value = [aDecoder decodeObjectForKey:key];
            if (value != nil) {
                [self setValue:value forKey:key];
            }
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

- (NSArray *)propertyKeys
{
    NSMutableArray *array = [NSMutableArray array];
    Class class = [self class];
    while (class != [NSObject class])
    {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        for (int i = 0; i < propertyCount; i++)
        {
            //get property
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
            
            //check if read-only
            BOOL readonly = NO;
            const char *attributes = property_getAttributes(property);
            NSString *encoding = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
            if ([[encoding componentsSeparatedByString:@","] containsObject:@"R"])
            {
                readonly = YES;
                
                //see if there is a backing ivar with a KVC-compliant name
                NSRange iVarRange = [encoding rangeOfString:@",V"];
                if (iVarRange.location != NSNotFound)
                {
                    NSString *iVarName = [encoding substringFromIndex:iVarRange.location + 2];
                    if ([iVarName isEqualToString:key] ||
                        [iVarName isEqualToString:[@"_" stringByAppendingString:key]])
                    {
                        //setValue:forKey: will still work
                        readonly = NO;
                    }
                }
            }
            
            if (!readonly)
            {
                //exclude read-only properties
                [array addObject:key];
            }
        }
        free(properties);
        class = [class superclass];
    }
    return array;
}


@end

@interface iAppUpdateManager ()

@property (nonatomic, strong) AppModel *model;

@end

@implementation iAppUpdateManager

+ (iAppUpdateManager *)manager {
    static iAppUpdateManager *manager;
    if (manager == nil) {
        manager = [[iAppUpdateManager alloc] init];
    }
    return manager;
}

- (AppModel *)model {
    if (_model == nil) {
        _model = [AppModel saved];
        if (_model == nil) {
            _model = [[AppModel alloc] init];
        }
    }
    return _model;
}

- (void)evaluateAndShow {
    if ([[self model] neverShow]) return;
    NSURL* url;
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    if (_appId.length == 0) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@",infoDictionary[@"CFBundleIdentifier"]]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",_appId]];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:url];
        if (data == nil) return;
        NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([lookup[@"resultCount"] integerValue] == 1) {
            NSString* appStoreVersion = [lookup[@"results"] firstObject][@"version"];
            NSString* trackViewUrl = [lookup[@"results"] firstObject][@"trackViewUrl"];
            NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
            [_model setAppLaunchCount:_model.appLaunchCount + 1];
            if ([self canShowAlert:currentVersion version:appStoreVersion]) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    UIViewController *topViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                    
                    while (topViewController.presentedViewController != nil) topViewController = topViewController.presentedViewController;
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", nil) message:NSLocalizedString(@"An update is available in appstore. Would you like to download?", nil) preferredStyle:UIAlertControllerStyleAlert];
                    [topViewController presentViewController:alertController animated:YES completion:nil];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Update", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        if (@available(iOS 10.0, *)) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackViewUrl] options:@{} completionHandler:nil];
                        } else {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackViewUrl]];
                        }
                    }]];
                    if (_shouldShowLater) {
                        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Later", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [_model setAppLaunchCount:0];
                            [_model setShowLater:YES];
                            [_model save];
                        }]];
                    }
                    if (_shouldShowSkipThisUpdate) {
                        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Skip this version", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [_model setSkippedVersion:appStoreVersion];
                            [_model save];
                        }]];
                    }
                    if (_shouldShowNever) {
                        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Do not show this again", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [_model setNeverShow:YES];
                            [_model save];
                        }]];
                    }
                });
                [_model setShowLater:NO];
                [_model setAppLaunchCount:0];
                [_model setLastShownDate:[NSDate date]];
            }
            [_model save];
        }
    });
}

- (BOOL)canShowAlert:(NSString*)currentVersion version:(NSString*)appStoreVersion {
    BOOL isAppUpdated = NO;
    NSArray *currentVersionCompnts = [currentVersion componentsSeparatedByString:@"."];
    NSArray *appStoreVersionCompnts = [appStoreVersion componentsSeparatedByString:@"."];
    
    NSInteger index = 0;
    for (NSString *aComponent in appStoreVersionCompnts) {
        if ([currentVersionCompnts count] > index) {
            if ([aComponent integerValue] > [currentVersionCompnts[index] integerValue]) {
                isAppUpdated = YES;
                break;
            } else if ([aComponent integerValue] < [currentVersionCompnts[index] integerValue]) break;
        } else {
            isAppUpdated = YES;
        }
        index++;
    }
    if (isAppUpdated == NO) return isAppUpdated;
    BOOL canShowAlert = NO;
    if (_showFromLaunch <= _model.appLaunchCount && [appStoreVersion isEqualToString:_model.skippedVersion] == NO && ((_model.showLater && _model.appLaunchCount > 10) || _model.showLater == NO))
    {
        if (_model.lastShownDate == nil) {
            canShowAlert = YES;
        } else {
            NSInteger hoursBetween = abs((int)_model.lastShownDate.timeIntervalSinceNow / 3600);
            switch (_showType) {
                case kOnFirstLaunchOfADay :
                    canShowAlert = hoursBetween >= 24;
                    break;
                case kOnFirstLaunchOfAWeek :
                    canShowAlert = hoursBetween >= 7*24;
                    break;
                case kOnFirstLaunchOfADayAfterOther :
                    canShowAlert = hoursBetween >= 2*24;
                    break;
                default:
                    break;
            }
        }
        
    }
    return canShowAlert;
}



@end

