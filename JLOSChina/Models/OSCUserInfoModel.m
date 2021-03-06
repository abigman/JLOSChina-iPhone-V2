//
//  OSCUserInfoModel.m
//  RubyChina
//
//  Created by jimneylee on 13-7-25.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "OSCUserInfoModel.h"
#import "OSCAPIClient.h"

@interface OSCUserInfoModel()

@property (nonatomic, copy) NSString* detailItemElementName;
@property (nonatomic, strong) NSMutableDictionary* detailDictionary;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation OSCUserInfoModel

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LifeCycle

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init
{
    self = [super init];
    if (self) {
        self.itemElementNamesArray = @[XML_USER];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadUserInfoWithUserId:(NSString *)uid
                    orUsername:(NSString*)username
                         block:(void(^)(OSCUserFullEntity* entity, OSCErrorEntity* errorEntity))block
{
    self.userId = uid;
    self.username = username;
    self.returnBlock = block;
    
    [self getParams:nil errorBlock:^(OSCErrorEntity *errorEntity) {
        if (!errorEntity || ERROR_CODE_SUCCESS_200 == errorEntity.errorCode) {
            block(self.userEntity, errorEntity);
        }
        else {
            block(nil, errorEntity);
        }
    }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Override

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)relativePath
{
    NSString* path =
    [OSCAPIClient relativePathForUserInfoWithUserId:self.userId
                                         orUsername:self.username];
    return path;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseDataDictionary
{
    NSMutableDictionary* dic = self.dataDictionary[XML_USER];
    // TODO: dirty code: set uid -> authorid, name -> author
    if (dic[@"uid"]) {
        [dic setObject:dic[@"uid"] forKey:@"authorid"];
    }
    if (dic[@"name"]) {
        [dic setObject:dic[@"name"] forKey:@"author"];
    }
    self.userEntity = [OSCUserFullEntity entityWithDictionary:dic];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didFinishLoad
{
    if (!self.errorEntity || ERROR_CODE_SUCCESS_200 == self.errorEntity.errorCode) {
        self.returnBlock(self.userEntity, self.errorEntity);
    }
    else {
        self.returnBlock(nil, self.errorEntity);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didFailLoad
{
    self.returnBlock(nil, self.errorEntity);
}

@end
