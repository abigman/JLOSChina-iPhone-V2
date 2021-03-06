//
//  RCReplyModel.h
//  JLOSChina
//
//  Created by Lee jimney on 12/11/13.
//  Copyright (c) 2013 jimneylee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSCBaseModel.h"
#import "OSCCommentEntity.h"

typedef void (^SuccessBlock)(OSCCommentEntity* entity);
typedef void (^FailureBlock)(OSCErrorEntity* errorEntity);

@interface OSCReplyModel : OSCBaseModel

@property (nonatomic, strong) SuccessBlock successBlock;
@property (nonatomic, strong) FailureBlock failureBlock;
@property (nonatomic, strong) OSCCommentEntity* replyEntity;
@property (nonatomic, assign) BOOL isReplyComment;

// reply alse for other's comment, just add @someone
- (void)replyContentId:(NSString *)topicId
         catalogType:(OSCCatalogType)catalogType
                body:(NSString*)body
             success:(void(^)(OSCCommentEntity* replyEntity))success
             failure:(void(^)(OSCErrorEntity* error))failure;
// this is useless
- (void)replyCommentId:(NSString *)commentId
             contentId:(NSString *)topicId
           catalogType:(OSCCatalogType)catalogType
                  body:(NSString*)body
               success:(void(^)(OSCCommentEntity* replyEntity))success
               failure:(void(^)(OSCErrorEntity* error))failure;
@end
