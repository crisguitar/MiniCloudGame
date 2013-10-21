//
//  MyScene.m
//  SKTextures
//
//  Created by Cris Pinto on 10/21/13.
//  Copyright (c) 2013 Cris Pinto. All rights reserved.
//

#import "MyScene.h"

@interface MyScene() {
}
@property SKSpriteNode *background;
@property SKSpriteNode *cloud;
@property SKAction *jumpAction;
@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
    }
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    [self setupScene];
}

-(void)setupScene
{
    self.physicsWorld.gravity = CGVectorMake(-0.0f, -0.3f);
    [self generateBackground];
    [self generateCloud];
}

-(SKSpriteNode *)spriteWithColor:(UIColor *)bgColor size:(CGSize)size
{
    SKSpriteNode *skNode = [SKSpriteNode spriteNodeWithColor:bgColor size:size];
    SKSpriteNode *noise = [SKSpriteNode spriteNodeWithImageNamed:@"Noise"];
    [noise setBlendMode:SKBlendModeScreen];
    [skNode addChild:noise];
    return skNode;
    
}

-(UIColor *)randomBrightColor
{
    while (true) {
        float requiredBrightness = 192.0/255.0;
        float red = (arc4random() % 255) / 255.0;
        float green = (arc4random() % 255) / 255.0;
        float blue = (arc4random() % 255) / 255.0;
        if (red > requiredBrightness || green > requiredBrightness || blue > requiredBrightness) {
            UIColor *randomColor = [SKColor colorWithRed:red green:green blue:blue alpha:1.0];
            return randomColor;
        }
    }
}

-(void)generateBackground
{
    [_background removeFromParent];
    _background = [self spriteWithColor:[self randomBrightColor] size:self.frame.size];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _background.zPosition = -1;
    [self addChild:_background];
}

-(void)generateCloud
{
    [_cloud removeFromParent];
    _cloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
    _cloud.position = CGPointMake(100, self.frame.size.height - 200);
    _cloud.zPosition = 2;
    _cloud.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_cloud.size.height/2];
    _cloud.physicsBody.dynamic = YES;
    _cloud.physicsBody.affectedByGravity = NO;
    [self addChild:_cloud];
    [self setupCloudActions];
}

-(void)setupCloudActions
{
    SKAction *up = [SKAction moveByX:0 y:5 duration:0.3];
    SKAction *down = [SKAction moveByX:0 y:-5 duration:0.3];
    
    SKAction *standAction = [SKAction sequence:@[up, down]];
    
    [_cloud runAction:[SKAction repeatActionForever:standAction]];
    
    SKAction *moveUp = [SKAction moveByX: 0 y: 50.0 duration: 0.4];
    SKAction *moveDown = [SKAction moveByX:0 y:-50 duration:0.3];
    
    _jumpAction = [SKAction sequence:@[moveUp, moveDown]];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    SKAction *stretch = [SKAction scaleYTo:1.1 duration:0.3];
    SKAction *stretchBack = [SKAction scaleYTo:1.0 duration:0.3];
    [_cloud runAction: [SKAction sequence:@[stretch, stretchBack]]];
    [_cloud runAction: _jumpAction];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
