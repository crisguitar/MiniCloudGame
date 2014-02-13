//
//  MyScene.m
//  SKTextures
//
//  Created by Cris Pinto on 10/21/13.
//  Copyright (c) 2013 Cris Pinto. All rights reserved.
//

#import "GameScene.h"
#import "MenuScene.h"

static const uint32_t cloudCategory    =  0x1 << 0;
static const uint32_t obstacleCategory =  0x1 << 1;

@interface GameScene() {
    
    BOOL _isCloudDeformed;
    int _obstaclesCount;
    BOOL _gameOver;
    
}
@property SKSpriteNode *background;
@property SKSpriteNode *cloud;

@end

@implementation GameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0.0f, -2.0f);
    }
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    _obstaclesCount = 0;
    _isCloudDeformed = NO;
    _gameOver = NO;
    
    [self setupScene];
}

-(void)setupScene
{
    [self generateBackground];
    [self generateTop];
    [self generateCharacter];
    [self generateObstacle];
}

-(SKSpriteNode *)spriteWithColor:(UIColor *)bgColor size:(CGSize)size
{
    SKSpriteNode *skNode = [SKSpriteNode spriteNodeWithColor:bgColor size:size];
    SKSpriteNode *noise = [SKSpriteNode spriteNodeWithImageNamed:@"Noise"];
    [noise setBlendMode:SKBlendModeScreen];
    [skNode addChild:noise];
    return skNode;
    
}

-(UIColor *)randomColorWithValue:(int)value
{
    return [UIColor colorWithRed:[self randomNumberBetween:value and:255]/255.0 green:[self randomNumberBetween:value and:255]/255.0 blue:[self randomNumberBetween:value and:255]/255.0 alpha:1.0];
}

-(void)generateBackground
{
    [_background removeFromParent];
    // _background = [self spriteWithColor:[self randomBrightColor] size:self.frame.size];
    _background = [self spriteWithColor:[self randomColorWithValue:200] size:self.frame.size];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _background.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, self.frame.size.height) toPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    _background.physicsBody.dynamic = YES;
    _background.physicsBody.affectedByGravity = NO;
    _background.zPosition = -1;
    [self addChild:_background];
}

-(void)generateTop
{
    SKSpriteNode *top = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:0 alpha:0] size:CGSizeMake(self.frame.size.width, 10)];
    top.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height);
    top.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, 10)];
    top.physicsBody.dynamic = NO;
    top.physicsBody.affectedByGravity = NO;
    
    [self addChild:top];
    
    // temporary bottom
    SKSpriteNode *bottom = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:0 alpha:0] size:CGSizeMake(self.frame.size.width, 10)];
    bottom.position = CGPointMake(CGRectGetMidX(self.frame), 10);
    bottom.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bottom.size];
    bottom.physicsBody.dynamic = NO;
    bottom.physicsBody.affectedByGravity = NO;
    
    [self addChild:bottom];
    
}

-(void)generateCharacter
{
    [_cloud removeFromParent];
    _cloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
    _cloud.name = @"cloud";
    _cloud.position = CGPointMake(100, self.frame.size.height - 125);
    _cloud.zPosition = 100;
    _cloud.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_cloud.size.height/2];
    _cloud.physicsBody.categoryBitMask = cloudCategory;
    _cloud.physicsBody.collisionBitMask = obstacleCategory;
    _cloud.physicsBody.contactTestBitMask = obstacleCategory;
    _cloud.physicsBody.usesPreciseCollisionDetection = YES;
    _cloud.physicsBody.dynamic = YES;
    _cloud.physicsBody.affectedByGravity = YES;
    [self addChild:_cloud];
}

-(void)generateObstacle
{
    SKSpriteNode *obstacle = [[SKSpriteNode alloc] initWithImageNamed:@"rainbow"];
    obstacle.name = @"obstacle";
    obstacle.position = CGPointMake((arc4random() % 400) + self.frame.size.width, [self randomNumberBetween:20 and:self.size.height - 20]);
    obstacle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(obstacle.size.width/2)];
    obstacle.physicsBody.categoryBitMask = obstacleCategory;
    obstacle.physicsBody.collisionBitMask = cloudCategory;
    obstacle.physicsBody.contactTestBitMask = cloudCategory;
    obstacle.physicsBody.dynamic = YES;
    obstacle.physicsBody.affectedByGravity = NO;
    
    float scale = [self randomNumberBetween:1 and:4] / 2.0;
    obstacle.size = CGSizeMake(obstacle.size.width * scale, obstacle.size.height * scale);
    
    SKAction *changeColor = [SKAction  colorizeWithColor:[self randomColorWithValue:60] colorBlendFactor:1 duration:0.1];
    SKAction *moveLeft = [SKAction moveByX: -[self randomNumberBetween:30 and:50] y:0 duration:0.2];
    
    [self addChild:obstacle];
    _obstaclesCount++;
    
    [obstacle runAction:changeColor];
    [obstacle runAction:[SKAction repeatActionForever:moveLeft]];
    
}

-(int)randomNumberBetween:(int)lowest and:(int)highest {
    return lowest + arc4random() % (highest - lowest);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // check for game over
    _cloud.physicsBody.affectedByGravity = NO;
    [_cloud.physicsBody setVelocity:CGVectorMake(0, 0)];
    SKAction *stretch = [SKAction scaleYTo:1.1 duration:0.3];
    SKAction *stretchBack = [SKAction scaleYTo:1 duration:0.5];
    [_cloud runAction:[SKAction sequence:@[stretch, stretchBack]]];
//    [_cloud.physicsBody applyImpulse:CGVectorMake(0, 30)];
    [_cloud.physicsBody applyForce:CGVectorMake(0, 300)];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _cloud.physicsBody.affectedByGravity = YES;
}


// contact detection will not be used, so yeah...
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    // check contact
    if ((firstBody.categoryBitMask & cloudCategory) != 0 && (secondBody.collisionBitMask & cloudCategory) != 0)
    {
        
        // NSLog(@"CONTACT!!!");
    }
}

- (void)deformCloudDueToVelocity {
    if (!_isCloudDeformed && abs(_cloud.physicsBody.velocity.dy) > 200) {
        SKAction *stretch = [SKAction scaleYTo:1.1 duration:0.3];
        [_cloud runAction:stretch];
        _isCloudDeformed = YES;
    } else if (_isCloudDeformed && abs(_cloud.physicsBody.velocity.dy) < 100) {
        SKAction *stretch = [SKAction scaleYTo:1 duration:0.3];
        [_cloud runAction:stretch];
        _isCloudDeformed = NO;
    }
}

- (void)spawnObstacles {
    
    if (_obstaclesCount < 15) {
        [self generateObstacle];
    }
}

- (void)removeObstacleWhenNotVisible {
    [self enumerateChildNodesWithName:@"obstacle" usingBlock:^(SKNode *node, BOOL *stop) {
        
        SKSpriteNode *theNode = (SKSpriteNode *)node;
        
        if (theNode.position.x + theNode.size.width < 0) {
            [node removeFromParent];
            _obstaclesCount--;
        }
    }];
}

-(void)checkGameOver
{
    if (!_gameOver && _cloud.position.x < 0) {
        NSLog(@"Game Over!!");
        _gameOver = YES;
        [self showGameOver];
    }
    
}

-(void)showGameOver
{
    SKTransition *transition = [SKTransition doorsCloseHorizontalWithDuration:1];
    transition.pausesIncomingScene = YES;
    MenuScene *menuScene = [[MenuScene alloc] initWithSize:self.size];
    [self.scene.view presentScene:menuScene transition:transition];
}

-(void)update:(CFTimeInterval)currentTime {
    
    /* Called before each frame is rendered */
    [self spawnObstacles];
    [self removeObstacleWhenNotVisible];
    [self deformCloudDueToVelocity];
    [self checkGameOver];
    
}

@end
