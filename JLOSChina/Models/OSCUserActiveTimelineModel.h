//
//  RCForumTopicsModel.h
//  JLOSChina
//
//  Created by jimneylee on 13-12-10.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "OSCBaseTableModel.h"
#import "OSCUserFullEntity.h"

@interface OSCUserActiveTimelineModel : OSCBaseTableModel

@property (nonatomic, assign) long long userId;
@property (nonatomic, copy) NSString* username;
@property (nonatomic, strong) OSCUserFullEntity* userEntity;

@end
