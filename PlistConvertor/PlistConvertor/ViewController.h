//
//  ViewController.h
//  PlistConvertor
//
//  Created by SoSo on 5/29/15.
//  Copyright (c) 2015 SAP. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController <NSURLConnectionDelegate>

//@property IBOutlet NSButton* browse;
//@property (weak) IBOutlet NSButton *checkFile;

@property IBOutlet NSTextField* openField;
@property (weak) IBOutlet NSTextField *saveField;

@property (weak) IBOutlet NSTextField *companyDBField;
@property (weak) IBOutlet NSTextField *usernameField;


@property (weak) IBOutlet NSTextField *passwordField;
@property (weak) IBOutlet NSTextField *urlField;
@property (weak) IBOutlet NSTextField *modelField;
@property (weak) IBOutlet NSTextField *keyField;
@property (weak) IBOutlet NSTextField *checkField;

@property (weak) IBOutlet NSButton *loginButton;
@property (weak) IBOutlet NSButton *resetButton;
@property (weak) IBOutlet NSButton *checkButton;
@property (weak) IBOutlet NSButton *clearButton;
@property (weak) IBOutlet NSButton *logButton;

@property (unsafe_unretained) IBOutlet NSTextView *errorsTextView;
@property (unsafe_unretained) IBOutlet NSTextView *keysTextView;

- (IBAction)openFile:(id)sender;
- (IBAction)convert:(id)sender;

@end

