//
//  HDEAppDelegate.h
//  HDE
//
//  Created by Athiwat Chunlakhan on 4/23/11.
//  Copyright 2011 Kasetsart University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import<WebKit/WebKit.h>

@interface HDEAppDelegate : NSObject <NSApplicationDelegate, NSXMLParserDelegate> {
@private
    NSWindow *window;
    NSTextField *matchID;

    WebView *allWebView;
    WebView *infoWebView;
    WebView *playerWebView;
    WebView *chatWebView;
    WebView *abilityWebView;
    WebView *damageWebView;
    WebView *purchaseWebView;
    WebView *unknownWebView;
    WebView *killWebView;
    WebView *heroKillWebView;

    NSString *scratchFolder;
    NSMutableString *urlToServerLog;
    NSString *currentKey;
    NSMutableString *currentValue;
    NSString *currentPlayerName;
    NSMutableDictionary *realPlayerPosition;
    NSMutableDictionary *slotToPostion;
}

@property(assign) IBOutlet NSWindow *window;
@property(assign) IBOutlet NSTextField *matchID;

@property(assign) IBOutlet WebView *allWebView;
@property(assign) IBOutlet WebView *infoWebView;
@property(assign) IBOutlet WebView *playerWebView;
@property(assign) IBOutlet WebView *chatWebView;
@property(assign) IBOutlet WebView *abilityWebView;
@property(assign) IBOutlet WebView *damageWebView;
@property(assign) IBOutlet WebView *purchaseWebView;
@property(assign) IBOutlet WebView *unknownWebView;
@property(assign) IBOutlet WebView *killWebView;
@property(assign) IBOutlet WebView *heroKillWebView;

@property(nonatomic, retain) NSString *scratchFolder;
@property(nonatomic, retain) NSMutableString *urlToServerLog;
@property(nonatomic, retain) NSString *currentKey;
@property(nonatomic, retain) NSMutableString *currentValue;
@property(nonatomic, retain) NSString *currentPlayerName;
@property(nonatomic, retain) NSMutableDictionary *realPlayerPosition;
@property(nonatomic, retain) NSMutableDictionary *slotToPostion;


- (IBAction)ParserButton:(id)sender;

- (NSFileWrapper *)unzip:(NSData *)zipData;

- (NSDictionary *)parseLog:(NSString *)log;

- (NSString *)stringToDateString:(NSString *)time;

- (NSString *)removeClanTag:(NSString *)playerName;

- (void)addAndSetPlayerColorFrom:(NSDictionary *)keyValue toPlayers:(NSMutableDictionary *)playerNames f:(NSNumberFormatter *)f;

@end
