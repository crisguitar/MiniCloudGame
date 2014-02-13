//
//  MenuScene.m
//  SKTextures
//
//  Created by Cris Pinto on 2/9/14.
//  Copyright (c) 2014 Cris Pinto. All rights reserved.
//

#import "MenuScene.h"
#import "GameScene.h"


@interface MenuScene() {
    
}

@property SKSpriteNode *background;
@property SKSpriteNode *gameButton;


@end

@implementation MenuScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        
    }
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    [self setupScene];
    
}

-(void)setupScene
{
    [self generateBackground];
    [self generateButtons];
}

-(void)generateBackground
{
    _background = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:1.0 green:1.0 blue:243.0/255.0 alpha:1.0] size:CGSizeMake(self.frame.size.width, self.frame.size.height)];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    [self addChild:_background];
}

-(void)generateButtons
{
    _gameButton = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:40.0/255.0 green:87.0/255.0 blue:97.0/255.0 alpha:1] size:CGSizeMake(100, 30)];
    _gameButton.position = CGPointMake(CGRectGetMidX(self.frame), 300);
    _gameButton.name = @"gameButton";
    
    [self addChild:_gameButton];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"gameButton"]) {
        [self presentNewGameScene];
    }
}

-(void)presentNewGameScene
{
    SKTransition *transition = [SKTransition doorsCloseVerticalWithDuration:1];
    transition.pausesIncomingScene = YES;
    GameScene *gameScene = [[GameScene alloc] initWithSize:self.size];
    [self.scene.view presentScene:gameScene transition:transition];
}

@end
