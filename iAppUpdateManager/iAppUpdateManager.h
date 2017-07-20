//
//  AppUpdateManager.h
//  iAppUpdateManager
//
//  Created by Rajesh Thangaraj on 20/07/17.
//  Copyright © 2017 Yaash. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kOnFirstLaunchOfADay,
    kOnFirstLaunchOfADayAfterOther,
    kOnFirstLaunchOfAWeek,
} iShowType ;


@interface iAppUpdateManager : NSObject

+ (iAppUpdateManager *)manager;

@property(nonatomic, strong) NSString *appId; // if app identifier is not given app of bundleId will be taken
@property(nonatomic, assign) NSInteger showFromLaunch; // default is 1 and shown form first launch
@property(nonatomic, assign) iShowType showType;
@property(nonatomic, assign) BOOL shouldShowSkipThisUpdate;
@property(nonatomic, assign) BOOL shouldShowLater;
@property(nonatomic, assign) BOOL shouldShowNever;

- (void)evaluateAndShow;

@end
