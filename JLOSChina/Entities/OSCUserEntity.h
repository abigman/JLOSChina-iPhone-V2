//
//  RCUserEntity.h
//  JLOSChina
//
//  Created by ccjoy-jimneylee on 13-12-10.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "JLNimbusEntity.h"

@interface OSCUserEntity : JLNimbusEntity

@property (nonatomic, assign) long long authorId;
@property (nonatomic, copy)   NSString* authorName;
@property (nonatomic, copy)   NSString* avatarUrl;

@end
