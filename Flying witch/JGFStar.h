//
//  JGFStar.h
//  Flying witch
//
//  Created by José Gabriel Ferrer on 17/06/14.
//  Copyright (c) 2014 José Gabriel Ferrer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface JGFStar : NSObject


@property (nonatomic) SKSpriteNode *star;
@property (nonatomic) NSArray* starAnimatedFrames;

-(void)animatedStar;

@end
