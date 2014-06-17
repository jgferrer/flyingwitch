//
//  JGFStar.m
//  Flying witch
//
//  Created by José Gabriel Ferrer on 17/06/14.
//  Copyright (c) 2014 José Gabriel Ferrer. All rights reserved.
//

#import "Common.h"
#import <SpriteKit/SpriteKit.h>
#import "JGFStar.h"

@implementation JGFStar

-(instancetype)init{
    
    SKSpriteNode *star;
    NSMutableArray *animatedFrames = [NSMutableArray array];
    SKTextureAtlas *starAnimatedAtlas = [SKTextureAtlas atlasNamed:@"star"];
    NSUInteger numImages = starAnimatedAtlas.textureNames.count;
    for (int i=0; i < numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        SKTexture *temp = [starAnimatedAtlas textureNamed:textureName];
        [animatedFrames addObject:temp];
    }
    
    _starAnimatedFrames = animatedFrames;
    
    SKTexture *temp = _starAnimatedFrames[0];
    star = [SKSpriteNode spriteNodeWithTexture:temp];
    
    CGFloat screenWidth = DEVICE_SIZE.width;
    CGFloat screenHeight = DEVICE_SIZE.height;
    
    int x = [self getRandomNumberBetween:screenWidth+50 to:screenWidth+150];
    int y = [self getRandomNumberBetween:screenHeight-225 to:screenHeight-20];
    
    star.position = CGPointMake(x, y);
    
    star.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:star.size.width/2 - 3];
    star.physicsBody.dynamic = YES;
    star.physicsBody.categoryBitMask = starCategory;
    star.physicsBody.collisionBitMask = playerCategory;
    star.physicsBody.contactTestBitMask = playerCategory;
    star.physicsBody.affectedByGravity = NO;
    star.name = @"star";
    
    self.star = star;
    [self animatedStar];
    
    return self;
}

-(void)animatedStar{
    //This is our general runAction method to make our bear walk.
    [_star runAction:[SKAction repeatActionForever:
                     [SKAction animateWithTextures:_starAnimatedFrames
                                      timePerFrame:0.07f
                                            resize:NO
                                           restore:YES]] withKey:@"AnimatedStar"];
    return;
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

@end
