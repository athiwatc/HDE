//
//  HDEAppDelegate.h
//  HDE
//
//  Created by Athiwat Chunlakhan on 4/23/11.
//  Copyright 2011 Kasetsart University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HDEAppDelegate : NSObject <NSApplicationDelegate, NSXMLParserDelegate> {
@private
    NSWindow *window;
    NSTextView *output;
    NSTextField *matchID;
    NSString* scratchFolder;
    NSMutableString *urlToServerLog;
    NSString *currentKey;
    NSMutableString *currentValue;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *output;
@property (assign) IBOutlet NSTextField *matchID;
@property (retain) NSString *scratchFolder;
@property (retain) NSMutableString *urlToServerLog;
@property (retain) NSString *currentKey;
@property (retain) NSMutableString *currentValue;

-(IBAction) ParserButton:(id)sender;
-(NSFileWrapper*)unzip:(NSData*)zipData;
-(NSString*)getValueFrom:(NSArray*)array at:(int)position;
-(NSDictionary*)parseLog: (NSString*)log;

@end
