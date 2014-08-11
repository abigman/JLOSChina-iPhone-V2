//
//  RCLoginModel.m
//  RubyChina
//
//  Created by jimneylee on 13-7-25.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "OSCRelationshipActionModel.h"
#import "OSCAPIClient.h"

@interface OSCRelationshipActionModel()

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation OSCRelationshipActionModel

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (OSCRelationshipActionModel *)sharedModel
{
    static OSCRelationshipActionModel* _sharedModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[OSCRelationshipActionModel alloc] init];
    });
    
    return _sharedModel;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LifeCycle

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)followUserId:(long long)userId block:(void(^)(OSCErrorEntity* errorEntity))block
{
    self.returnBlock = block;
    
    NSString *userIdStr = [NSString stringWithFormat:@"%lld", userId];
    NSDictionary *parameters = @{@"friend" : userIdStr,
                                 @"relation" : @"1"};
    
    [self getParams:parameters errorBlock:^(OSCErrorEntity *errorEntity) {
        if (ERROR_CODE_SUCCESS == errorEntity.errorCode) {
            block(nil);
        }
        else {
            block(errorEntity);
        }
    }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unfollowUserId:(long long)userId block:(void(^)(OSCErrorEntity* errorEntity))block
{
    self.returnBlock = block;
    
    NSString *userIdStr = [NSString stringWithFormat:@"%lld", userId];
    NSDictionary *parameters = @{@"friend" : userIdStr,
                                 @"relation" : @"0"};
    
    [self getParams:parameters errorBlock:^(OSCErrorEntity *errorEntity) {
        if (ERROR_CODE_SUCCESS == errorEntity.errorCode) {
            block(nil);
        }
        else {
            block(errorEntity);
        }
    }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Override

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)relativePath
{
    return [OSCAPIClient relativePathForUpdateUserRelationship];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didFinishLoad
{
    if (!self.errorEntity || ERROR_CODE_SUCCESS == self.errorEntity.errorCode) {
        self.returnBlock(self.errorEntity);
    }
    else {
        self.returnBlock(self.errorEntity);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didFailLoad
{
    self.returnBlock(self.errorEntity);
}

@end