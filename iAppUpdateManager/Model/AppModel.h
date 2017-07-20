//
//
//  Created by Rajesh on 3/31/16.
//  Copyright © 2016 Rajesh. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface AppModel : MTLModel <MTLJSONSerializing>

+ (NSMutableDictionary *)propertyMapping;

+ (instancetype)fromJSON:(NSDictionary *)json;

+ (NSArray *)fromJSONArray:(NSArray *)json;

- (void)save;

+ (void)clear;

+ (void)flush; // To flush live memory

+ (instancetype)cached;

@end

@interface DOUser : AppModel

+ (DOUser *)currentUser;

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, strong) NSString *country;
@property(nonatomic, strong) NSString *countryId;
@property(nonatomic, strong) NSString *promocode;
@property(nonatomic, strong) NSString *authToken;
@property(nonatomic, assign) BOOL isTermsAccepted;

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *expiryYear;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *address1;
@property (nonatomic, strong) NSString *cardName;
@property (nonatomic, strong) NSString *expiryMonth;
@property (nonatomic, strong) NSString *dob;
@property (nonatomic, strong) NSString *address2;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *alternateEmail;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *pincode;
@property (nonatomic, strong) NSString *preferredLanguages;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *cardNumber;

@end

@interface DOCountry  : AppModel

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *sortname;

@end


@interface DODependent  : AppModel

@property(nonatomic, strong) NSString *dependentId;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *dob;
@property(nonatomic, strong) NSString *user;
@property(nonatomic, strong) NSString *socialSecurityNumber;

@end

typedef enum {
    kText = 0,
    kImage,
    kVideo,
    kDoc
} DOMessageType;

@interface DOMessage  : AppModel

@property(nonatomic, assign) DOMessageType type;
@property(nonatomic, assign) BOOL isReceived;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSDate *date;
@property(nonatomic, readonly) NSString *reuseIdentifier;
@property(nonatomic, strong) UIImage *image;

@end

@interface DOConsultation  : AppModel

@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *imageUrl;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *type;

@end
