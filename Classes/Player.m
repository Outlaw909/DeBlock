//
//  Player.m
//  Deblock
//
//  Created by Maarten Billemont on 06/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "Player.h"

#define lNotSet 2<<0
#define lSet    2<<1


@interface UIAlertView (TextField)

- (void)addTextFieldWithValue:(NSString *)value label:(NSString *)label;
- (UITextField *)textFieldAtIndex:(NSUInteger)index;

@end

@interface Player ()

- (void)registerObservers;

- (void)showNameDialog;
- (void)showPassDialog;


@property (readwrite, retain) NSConditionLock                     *nameLock;
@property (readwrite, retain) UIAlertView                         *nameAlert;
@property (readwrite, retain) UITextField                         *nameField;

@property (readwrite, retain) NSConditionLock                     *passLock;
@property (readwrite, retain) UIAlertView                         *passAlert;
@property (readwrite, retain) UITextField                         *passField;

@end

@implementation Player

@synthesize name = _name;
@synthesize pass = _pass;
@synthesize score = _score;
@synthesize level = _level;
@synthesize onlineOk = _onlineOk;
@synthesize nameLock = _nameLock;
@synthesize nameAlert = _nameAlert;
@synthesize nameField = _nameField;
@synthesize passLock = _passLock;
@synthesize passAlert = _passAlert;
@synthesize passField = _passField;


- (id)init {
    
    [self = [super init] registerObservers];

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if(!(self = [super init]))
        return self;
    
    _name                   = [[decoder decodeObjectForKey: @"Player_Name"] retain];
    _pass                   = [[decoder decodeObjectForKey: @"Player_Password"] retain];
    _score                  = [decoder decodeIntegerForKey: @"Player_Score"];
    _level                  = [decoder decodeIntegerForKey: @"Player_Level"];
    _onlineOk               = [decoder decodeBoolForKey:    @"Player_OnlineOK"];
    
    [self registerObservers];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:_name                     forKey: @"Player_Name"];
    [encoder encodeObject:_pass                     forKey: @"Player_Password"];
    [encoder encodeInteger:_score                   forKey: @"Player_Score"];
    [encoder encodeInteger:_level                   forKey: @"Player_Level"];
    [encoder encodeBool:_onlineOk                   forKey: @"Player_OnlineOK"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (object == self)
        [[DeblockConfig get] updatePlayer:self];
}

- (void)registerObservers {

    [self addObserver:self forKeyPath:@"name"       options:0 context:NULL];
    [self addObserver:self forKeyPath:@"pass"       options:0 context:NULL];
    [self addObserver:self forKeyPath:@"score"      options:0 context:NULL];
    [self addObserver:self forKeyPath:@"level"      options:0 context:NULL];
    [self addObserver:self forKeyPath:@"onlineOk"   options:0 context:NULL];
}

- (void)unregisterObservers {

    [self removeObserver:self forKeyPath:@"name"];
    [self removeObserver:self forKeyPath:@"pass"];
    [self removeObserver:self forKeyPath:@"score"];
    [self removeObserver:self forKeyPath:@"level"];
    [self removeObserver:self forKeyPath:@"onlineOk"];
}

- (void)setName:(NSString *)aName {

    [[DeblockConfig get] removePlayer:self];
    
    [_name release];
    _name = [aName copy];
    
    [[DeblockConfig get] updatePlayer:self];
}

- (NSString *)onlineName {

    if ([[NSThread currentThread] isMainThread])
        [[Logger get] err:@"This method should NOT be called from the MAIN thread!"];

    else if (!_name) {

        self.nameLock = [[[NSConditionLock alloc] initWithCondition:lNotSet] autorelease];
        [self performSelectorOnMainThread:@selector(showNameDialog) withObject:nil waitUntilDone:NO];

        [self.nameLock lockWhenCondition:lSet];
        [self.nameLock unlockWithCondition:_name? lSet: lNotSet];
    }

    return _name;
}

- (NSString *)pass {

    if ([[NSThread currentThread] isMainThread])
        [[Logger get] err:@"This method should NOT be called from the MAIN thread!"];

    else if (!_pass) {

        self.passLock = [[[NSConditionLock alloc] initWithCondition:lNotSet] autorelease];
        [self performSelectorOnMainThread:@selector(showPassDialog) withObject:nil waitUntilDone:NO];

        [self.passLock lockWhenCondition:lSet];
        [self.passLock unlockWithCondition:_pass? lSet: lNotSet];
    }

    return _pass;
}

- (void)showNameDialog {

    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    self.nameAlert = [[[UIAlertView alloc] initWithTitle:l(@"dialog.title.name") message:
                       [NSString stringWithFormat:l(@"dialog.text.name.ask"), self.name]
                                                delegate:self cancelButtonTitle:l(@"button.save") otherButtonTitles:nil] autorelease];
    [self.nameAlert addTextFieldWithValue:@"" label:@""];

    self.nameField                       = [self.nameAlert textFieldAtIndex:0];
    self.nameField.keyboardType          = UIKeyboardTypeNamePhonePad;
    self.nameField.keyboardAppearance    = UIKeyboardAppearanceAlert;
    self.nameField.autocorrectionType    = UITextAutocorrectionTypeNo;
    [self.nameAlert show];

    [pool drain];
}

- (void)showPassDialog {

    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    self.passAlert = [[[UIAlertView alloc] initWithTitle:l(@"dialog.title.compete.code") message:
                       [NSString stringWithFormat:l(@"dialog.text.compete.code.ask"), self.name]
                                                delegate:self cancelButtonTitle:l(@"button.save") otherButtonTitles:nil] autorelease];
    [self.passAlert addTextFieldWithValue:@"" label:@""];

    self.passField                       = [self.passAlert textFieldAtIndex:0];
    self.passField.keyboardType          = UIKeyboardTypeNumberPad;
    self.passField.keyboardAppearance    = UIKeyboardAppearanceAlert;
    self.passField.autocorrectionType    = UITextAutocorrectionTypeNo;
    [self.passAlert show];

    [pool drain];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView == self.nameAlert) {

        [self.nameLock lockWhenCondition:lNotSet];
        self.name = self.nameField.text;
        [self.nameLock unlockWithCondition:_name? lSet: lNotSet];

        self.nameAlert = nil;
        self.nameField = nil;
    }

    if (alertView == self.passAlert) {

        [self.passLock lockWhenCondition:lNotSet];
        self.pass = self.passField.text;
        [self.passLock unlockWithCondition:_pass? lSet: lNotSet];

        self.passAlert = nil;
        self.passField = nil;
    }
}


- (void)dealloc {

    [self unregisterObservers];

    self.name = nil;
    self.pass = nil;

    self.nameLock = nil;
    self.nameAlert = nil;
    self.nameField = nil;
    self.passLock = nil;
    self.passAlert = nil;
    self.passField = nil;

    [super dealloc];
}

@end
