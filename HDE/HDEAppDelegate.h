/*
 This file is part of HDE.
 
 HDE is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Foobar is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */
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
    WebView *chatWebView;
    WebView *abilityWebView;
    WebView *damageWebView;
    WebView *purchaseWebView;
    WebView *unknownWebView;
    WebView *killWebView;
    WebView *heroWebView;
    WebView *heroKillWebView;
    WebView *awardWebView;
    WebView *expWebView;
    WebView *goldWebView;
    WebView *apmWebView;

    NSString *scratchFolder;
    NSMutableString *urlToServerLog;
    NSString *currentKey;
    NSMutableString *currentValue;
    NSString *currentPlayerName;
    NSMutableDictionary *realPlayerPosition;
    NSMutableDictionary *slotToPostion;
    NSMutableDictionary *stringTable;
}

@property(assign) IBOutlet NSWindow *window;
@property(assign) IBOutlet NSTextField *matchID;

@property(assign) IBOutlet WebView *allWebView;
@property(assign) IBOutlet WebView *infoWebView;
@property(assign) IBOutlet WebView *chatWebView;
@property(assign) IBOutlet WebView *abilityWebView;
@property(assign) IBOutlet WebView *damageWebView;
@property(assign) IBOutlet WebView *purchaseWebView;
@property(assign) IBOutlet WebView *unknownWebView;
@property(assign) IBOutlet WebView *killWebView;
@property(assign) IBOutlet WebView *heroWebView;
@property(assign) IBOutlet WebView *heroKillWebView;
@property(assign) IBOutlet WebView *awardWebView;
@property(assign) IBOutlet WebView *expWebView;
@property(assign) IBOutlet WebView *goldWebView;
@property(assign) IBOutlet WebView *apmWebView;

@property(nonatomic, retain) NSString *scratchFolder;
@property(nonatomic, retain) NSMutableString *urlToServerLog;
@property(nonatomic, retain) NSString *currentKey;
@property(nonatomic, retain) NSMutableString *currentValue;
@property(nonatomic, retain) NSString *currentPlayerName;
@property(nonatomic, retain) NSMutableDictionary *realPlayerPosition;
@property(nonatomic, retain) NSMutableDictionary *slotToPostion;
@property(nonatomic, retain) NSDictionary *stringTable;


- (IBAction)ParserButton:(id)sender;

- (NSFileWrapper *)unzip:(NSData *)zipData;

- (NSDictionary *)parseLog:(NSString *)log;

- (NSString *)stringToDateString:(NSString *)time;

- (NSString *)removeClanTag:(NSString *)playerName;

-(NSDictionary*)processStringTableFromString: (NSString*)string;

-(NSString*)getStringFromTable: (NSString*)string ;

- (void)addAndSetPlayerColorFrom:(NSDictionary *)keyValue toPlayers:(NSMutableDictionary *)playerNames f:(NSNumberFormatter *)f;

@end
