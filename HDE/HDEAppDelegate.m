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
//  HDEAppDelegate.m
//  HDE
//
//  Created by Athiwat Chunlakhan on 4/23/11.
//  Copyright 2011 Kasetsart University. All rights reserved.
//

#import "HDEAppDelegate.h"

@implementation HDEAppDelegate

@synthesize window, matchID;
@synthesize allWebView, infoWebView, chatWebView, abilityWebView, damageWebView, purchaseWebView, unknownWebView, killWebView, heroWebView, awardWebView, heroKillWebView, goldWebView, expWebView, apmWebView;
@synthesize scratchFolder, urlToServerLog, currentValue, currentKey, currentPlayerName, realPlayerPosition, slotToPostion, stringTable;

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *tempDir = NSTemporaryDirectory();
    if (tempDir == nil)
        tempDir = @"/tmp";
    
    NSString *template = [tempDir stringByAppendingPathComponent:@"HDEtemp"];
    const char *fsTemplate = [template fileSystemRepresentation];
    NSMutableData *bufferData = [NSMutableData dataWithBytes:fsTemplate
                                                      length:strlen(fsTemplate) + 1];
    char *buffer = [bufferData mutableBytes];
    mkdtemp(buffer);
    NSString *temporaryDirectory = [[NSFileManager defaultManager]
                                    stringWithFileSystemRepresentation:buffer
                                    length:strlen(buffer)];
    
    self.scratchFolder = temporaryDirectory;
    
    self.realPlayerPosition = [NSMutableDictionary dictionary];
    self.slotToPostion = [NSMutableDictionary dictionary];
    
    NSString *pathToStringTable = [[NSBundle mainBundle] pathForResource:@"stringTable" ofType:@"strings" inDirectory:@""];  
    if (pathToStringTable == nil) exit(1);
    self.stringTable = [self processStringTableFromString:[NSString stringWithContentsOfFile:pathToStringTable encoding:NSUTF16StringEncoding error:nil]];
}

-(NSString*)getStringFromTable: (NSString*)string {
    NSString *name = [self.stringTable objectForKey:[string stringByAppendingString:@"_name"]];
    if (name == nil) return string;
    return name;
}

-(NSDictionary*)processStringTableFromString: (NSString*)string {
    NSMutableDictionary *table = [NSMutableDictionary dictionary];
    NSMutableString *buffer;
    NSString *key;
    NSArray *lines = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines)
    {
        if ([line isEqualToString:@""]) continue;
        if ([line hasPrefix:@"//"]) continue;
        bool isKey = YES;
        bool isValue = NO;
        bool isSpace = NO;
        key = nil;
        buffer = [NSMutableString string];
        for (NSUInteger i = 0; i < [line length]; i++) {
            if (isValue)
            {
                [buffer appendFormat:@"%C",[line characterAtIndex:i]];
            }
            else if (isSpace && [line characterAtIndex:i] != '\t')
            {
                isValue = YES;
                [buffer appendFormat:@"%C",[line characterAtIndex:i]];
            }
            else if (isSpace && [line characterAtIndex:i] == '\t')
            {
            }
            else if ([line characterAtIndex:i] == '\t'){
                isKey = NO;
                isValue = NO;
                isSpace = YES;
                key = buffer;
                buffer = [NSMutableString string];
            }
            else if (isKey) {
                [buffer appendFormat:@"%C",[line characterAtIndex:i]];
            }
        }
        if (key != nil) [table setValue:buffer forKey:key];  
    }
    return table;
}

- (void)ParserButton:(id)sender {
    
    [(NSButton *)sender setEnabled:NO];
    
    NSURL *urlXML = [NSURL URLWithString:[@"http://xml.heroesofnewerth.com/xml_requester.php?f=match_stats&opt=mid&mid[]=" stringByAppendingString:[matchID stringValue]]];
    
    NSXMLParser *parser = [[[NSXMLParser alloc] initWithContentsOfURL:urlXML] autorelease];
    
    [parser setDelegate:self];
    [parser parse];
    
    [self.urlToServerLog replaceOccurrencesOfString:@"honreplay" withString:@"zip" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [urlToServerLog length])];
    
    if (self.urlToServerLog == nil) {
        NSRunAlertPanel(@"MatchID doesn't exists", @"The MatchID that you provide doesn't exists", @"return", nil, nil);
        [(NSButton *)sender setEnabled:YES];
        return;
    }
    NSURL *urlServerLog = [NSURL URLWithString:self.urlToServerLog];
    NSData *downloadData = [NSData dataWithContentsOfURL:urlServerLog];
    
    //NSData *downloadData = [NSData dataWithContentsOfFile:@"/Users/Athiwat/Desktop/M37139782.zip"];
    
    NSFileWrapper *wrapper = [self unzip:downloadData];
    
    if ([wrapper isRegularFile]) {
        NSData *data = [wrapper regularFileContents];
        NSString *serverLog = [[[NSString alloc] initWithData:data encoding:NSUTF16StringEncoding] autorelease];
        NSArray *lines = [serverLog componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        NSMutableString *allText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *infoText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *playerText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *chatText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *abilityText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *damageText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *purchaseText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *unknownText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *killText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *heroText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *heroKillText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *awardText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *goldText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *expText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">"];
        NSMutableString *apmText = [NSMutableString stringWithString:@"<body bgcolor=\"black\" text=\"white\">This is not shown in the All Tab</br>"];
        
        
        //Formatter
        NSNumberFormatter *f = [[[NSNumberFormatter alloc] init] autorelease];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        
        NSMutableDictionary *playerNames = [NSMutableDictionary dictionary];
        NSMutableDictionary *playerHeroes = [NSMutableDictionary dictionary];
        
        for (NSString *line in lines) {
            if ([line isEqualToString:@""]) continue;
            NSDictionary *keyValue = [self parseLog:[line stringByAppendingString:@" "]];
            NSMutableString *temp = [NSMutableString string];
            //INFO Section
            if ([[keyValue objectForKey:@"title"] isEqualToString:@"INFO_DATE"]) {
                [temp appendFormat:@"Game started on %@ at %@</br>", [keyValue objectForKey:@"date"], [keyValue objectForKey:@"time"]];
                
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"INFO_SERVER"]) {
                [temp appendFormat:@"Hosted on %@</br>", [keyValue objectForKey:@"name"]];
                
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"INFO_GAME"]) {
                [temp appendFormat:@"Version %@</br>", [keyValue objectForKey:@"version"]];
                
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"INFO_MATCH"]) {
                [temp appendFormat:@"Game name %@ ID %@</br>", [keyValue objectForKey:@"name"], [keyValue objectForKey:@"id"]];
                
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"INFO_MAP"]) {
                [temp appendFormat:@"Map name %@ version %@</br>", [keyValue objectForKey:@"name"], [keyValue objectForKey:@"version"]];
                
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"INFO_SETTINGS"]) {
                [temp appendFormat:@"On mode %@ with options %@</br>", [keyValue objectForKey:@"mode"], [keyValue objectForKey:@"options"]];
                
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"GAME_CONCEDE"]) {
                NSString *winner;
                if ([[keyValue objectForKey:@"team"] isEqualToString:@"1"]) winner = [NSString stringWithString:@"<span style=\"color: green;\">Legion</span>]</br>"];
                else winner = [NSString stringWithString:@"[<span style=\"color: rgb(255,0,0);\">Hellbourne</span></br>"];
                [temp appendFormat:@"[%@]%@ Wins</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 winner];
                
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"GAME_START"]) {
                [temp appendString:@"Game started</br>"];
                
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_TEAM_CHANGE"]) {
                [temp appendFormat:@"Change player %@ to team %@</br>",
                 [keyValue objectForKey:@"player"],
                 [keyValue objectForKey:@"team"]];
                
                [allText appendString:temp];
                [infoText appendString:temp];
            } 
            //INFO PLAYER Section
            else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_CONNECT"] && ([keyValue objectForKey:@"time"] == nil)) {
                [self addAndSetPlayerColorFrom:keyValue toPlayers:playerNames f:f];
                
                [temp appendFormat:@"Player %@ connected on slot %@</br>", [playerNames objectForKey:[keyValue objectForKey:@"player"]], [keyValue objectForKey:@"player"]];
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_CONNECT"] && ([keyValue objectForKey:@"time"] != nil)) {
                
                [temp appendFormat:@"[%@]Player %@ reconnected</br>", [self stringToDateString:[keyValue objectForKey:@"time"]], [playerNames objectForKey:[keyValue objectForKey:@"player"]]];
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_SELECT"]) {
                [playerHeroes setValue:[self getStringFromTable:[keyValue objectForKey:@"hero"]] forKey:[keyValue objectForKey:@"player"]];
                
                [temp appendFormat:@"%@ selected %@</br>",
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [self getStringFromTable:[keyValue objectForKey:@"hero"]]];
                [allText appendString:temp];
                [infoText appendString:temp];
            }  else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_BAN"]) {
                [temp appendFormat:@"%@ banned %@</br>",
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [self getStringFromTable:[keyValue objectForKey:@"hero"]]];
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_RANDOM"]) {
                [playerHeroes setValue:[self getStringFromTable:[keyValue objectForKey:@"hero"]] forKey:[keyValue objectForKey:@"player"]];
                
                [temp appendFormat:@"%@ randomed %@</br>",
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [self getStringFromTable:[keyValue objectForKey:@"hero"]]];
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_SWAP"]) {
                [playerHeroes setValue:[self getStringFromTable:[keyValue objectForKey:@"newhero"]] forKey:[keyValue objectForKey:@"player"]];
                
                [temp appendFormat:@"%@ swapped %@ for %@</br>",
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [self getStringFromTable:[keyValue objectForKey:@"oldhero"]],
                 [self getStringFromTable:[keyValue objectForKey:@"newhero"]]];
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_REPICK"]) {
                [playerHeroes setValue:[keyValue objectForKey:@"newhero"] forKey:[keyValue objectForKey:@"player"]];
                
                [temp appendFormat:@"%@ is now repicking %@ is now avaliable</br>",
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [self getStringFromTable:[keyValue objectForKey:@"hero"]]];
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_CALL_VOTE"]) {
                [temp appendFormat:@"[%@]%@(%@) called the %@ vote</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [keyValue objectForKey:@"type"]];
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_VOTE"]) {
                [temp appendFormat:@"[%@]%@(%@) voted %@ for %@</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [keyValue objectForKey:@"vote"],
                 [keyValue objectForKey:@"type"]];
                [allText appendString:temp];
                [infoText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_BUYBACK"]) {
                [temp appendFormat:@"[%@]%@(%@) buyback for %@</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [keyValue objectForKey:@"cost"]];
                
                [allText appendString:temp];
                [infoText appendString:temp];
                [goldText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_TIMEDOUT"]) {
                [temp appendFormat:@"[%@]%@(%@) timedout</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]]];
                
                [allText appendString:temp];
                [infoText appendString:temp];
                [goldText appendString:temp];
            }
            //CHAT Section
            else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_CHAT"]) {
                NSString *heroName = [playerHeroes objectForKey:[keyValue objectForKey:@"player"]];
                if (heroName == nil) heroName = [NSString stringWithString:@"No Hero"];
                NSString *time = [self stringToDateString:[keyValue objectForKey:@"time"]];
                if ([time isEqualToString:@"00:00:00:f00"]) time = [NSString stringWithString:@"Lobby"];
                
                if ([[keyValue objectForKey:@"target"] isEqualToString:@"team"]) {
                    if ([[f numberFromString:[self.slotToPostion objectForKey:[keyValue objectForKey:@"player"]]] longValue]< 5) {
                        [temp appendFormat:@"[%@][<span style=\"color: green;\">Legion</span>]%@(%@): %@</br>",
                         time,
                         [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                         heroName,
                         [keyValue objectForKey:@"msg"]];
                    } else {
                        [temp appendFormat:@"[%@][<span style=\"color: rgb(255,0,0);\">Hellbourne</span>]%@(%@): %@</br>",
                         time,
                         [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                         heroName,
                         [keyValue objectForKey:@"msg"]];
                    }
                } else {
                    [temp appendFormat:@"[%@][ALL]%@(%@): %@</br>",
                     time,
                     [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                     heroName,
                     [keyValue objectForKey:@"msg"]];
                }
                
                [allText appendString:temp];
                [chatText appendString:temp];
            }
            //ABILITY Section
            else if ([[keyValue objectForKey:@"title"] isEqualToString:@"ABILITY_UPGRADE"]) {
                [temp appendFormat:@"[%@]%@ learned %@ to level %@</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]], [self getStringFromTable:[keyValue objectForKey:@"name"]], [keyValue objectForKey:@"level"]];
                [allText appendString:temp];
                [abilityText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"ABILITY_ACTIVATE"]) {
                [temp appendFormat:@"[%@]%@ used %@(%@)</br>", [self stringToDateString:[keyValue objectForKey:@"time"]], [playerNames objectForKey:[keyValue objectForKey:@"player"]], [self getStringFromTable:[keyValue objectForKey:@"name"]], [keyValue objectForKey:@"level"]];
                [allText appendString:temp];
                [abilityText appendString:temp];
            }
            //DAMAGE Section
            else if ([[keyValue objectForKey:@"title"] isEqualToString:@"DAMAGE"]) {
                [temp appendFormat:@"%@(%@) damaged %@ for %@</br>", [playerNames objectForKey:[keyValue objectForKey:@"player"]], [playerHeroes objectForKey:[keyValue objectForKey:@"player"]], [self getStringFromTable:[keyValue objectForKey:@"target"]], [keyValue objectForKey:@"damage"]];
                [allText appendString:temp];
                [damageText appendString:temp];
            }
            //KILL Section
            else if ([[keyValue objectForKey:@"title"] isEqualToString:@"KILL"]) {
                NSString *killer = [playerNames objectForKey:[keyValue objectForKey:@"player"]];
                NSString *owner = [playerNames objectForKey:[keyValue objectForKey:@"owner"]];
                if (killer == nil && owner == nil) {
                    [temp appendFormat:@"[%@]%@ killed %@</br>",
                     [self stringToDateString:[keyValue objectForKey:@"time"]],
                     [self getStringFromTable:[keyValue objectForKey:@"attacker"]],
                     [self getStringFromTable:[keyValue objectForKey:@"target"]]];  
                } else if (killer != nil && owner == nil) {
                    [temp appendFormat:@"[%@]%@(%@) killed %@</br>",
                     [self stringToDateString:[keyValue objectForKey:@"time"]],
                     killer,
                     [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                     [self getStringFromTable:[keyValue objectForKey:@"target"]]];
                } else if (killer != nil && owner != nil) {
                    [temp appendFormat:@"[%@]%@(%@) killed %@(%@)</br>",
                     [self stringToDateString:[keyValue objectForKey:@"time"]],
                     killer,
                     [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                     owner,
                     [playerHeroes objectForKey:[keyValue objectForKey:@"owner"]]];
                } else if (killer == nil && owner != nil) {
                    [temp appendFormat:@"[%@]%@ killed %@(%@)</br>",
                     [self stringToDateString:[keyValue objectForKey:@"time"]],
                     [self getStringFromTable:[keyValue objectForKey:@"attacker"]],
                     owner,
                     [playerHeroes objectForKey:[keyValue objectForKey:@"owner"]]];
                }
                [allText appendString:temp];
                if (([keyValue objectForKey:@"player"] != nil) && ([[keyValue objectForKey:@"target"] hasPrefix:@"Hero"])){ [heroKillText appendString:temp];
                    [heroText appendString:temp];
                }
                [killText appendString:temp];
            }
            //HERO Section
            else if ([[keyValue objectForKey:@"title"] isEqualToString:@"HERO_RESPAWN"]) {
                [temp appendFormat:@"[%@]%@(%@) respawned after %@</br>", [self stringToDateString:[keyValue objectForKey:@"time"]], [playerNames objectForKey:[keyValue objectForKey:@"player"]], [playerHeroes objectForKey:[keyValue objectForKey:@"player"]], [self stringToDateString:[keyValue objectForKey:@"duration"]]];
                
                [allText appendString:temp];
                [heroText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"HERO_DEATH"]) {
                [temp appendFormat:@"[%@]%@(%@) died from %@</br>", [self stringToDateString:[keyValue objectForKey:@"time"]], [playerNames objectForKey:[keyValue objectForKey:@"player"]], [playerHeroes objectForKey:[keyValue objectForKey:@"player"]], [self getStringFromTable:[keyValue objectForKey:@"attacker"]]];
                
                [allText appendString:temp];
                [heroText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"HERO_LEVEL"]) {
                [temp appendFormat:@"[%@]%@(%@) level up to %@</br>", [self stringToDateString:[keyValue objectForKey:@"time"]], [playerNames objectForKey:[keyValue objectForKey:@"player"]], [playerHeroes objectForKey:[keyValue objectForKey:@"player"]], [keyValue objectForKey:@"level"]];
                
                [allText appendString:temp];
                [heroText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"HERO_POWERUP"]) {
                [temp appendFormat:@"[%@]%@(%@) used the rune %@</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [self getStringFromTable:[keyValue objectForKey:@"type"]]];
                
                [allText appendString:temp];
                [heroText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"HERO_ASSIST"]) {
                [temp appendFormat:@"[%@]%@(%@) got an assist from killing %@(%@)</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"owner"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"owner"]]];
                
                [allText appendString:temp];
                [heroText appendString:temp];
            }
            //PURCHASE Section
            else if ([[keyValue objectForKey:@"title"] isEqualToString:@"ITEM_PURCHASE"]) {
                [temp appendFormat:@"[%@]%@(%@) bought %@ for %@</br>", [self stringToDateString:[keyValue objectForKey:@"time"]], [playerNames objectForKey:[keyValue objectForKey:@"player"]], [playerHeroes objectForKey:[keyValue objectForKey:@"player"]], [self getStringFromTable:[keyValue objectForKey:@"item"]], [keyValue objectForKey:@"cost"]];
                [allText appendString:temp];
                [purchaseText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"ITEM_SELL"]) {
                [temp appendFormat:@"[%@]%@(%@) sold %@ for %@</br>", [self stringToDateString:[keyValue objectForKey:@"time"]], [playerNames objectForKey:[keyValue objectForKey:@"player"]], [playerHeroes objectForKey:[keyValue objectForKey:@"player"]], [self getStringFromTable:[keyValue objectForKey:@"item"]], [keyValue objectForKey:@"value"]];
                [allText appendString:temp];
                [purchaseText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"ITEM_ACTIVATE"]) {
                [temp appendFormat:@"[%@]%@(%@) used %@ on %@</br>", [self stringToDateString:[keyValue objectForKey:@"time"]], [playerNames objectForKey:[keyValue objectForKey:@"player"]], [playerHeroes objectForKey:[keyValue objectForKey:@"player"]], [self getStringFromTable:[keyValue objectForKey:@"item"]], [keyValue objectForKey:@"target"]];
                [allText appendString:temp];
                //Add to ABILITY
                [abilityText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"ITEM_TRANSFER"]) {
                [temp appendFormat:@"[%@]%@(%@) recieved %@ from %@</br>", [self stringToDateString:[keyValue objectForKey:@"time"]], [playerNames objectForKey:[keyValue objectForKey:@"player"]], [playerHeroes objectForKey:[keyValue objectForKey:@"player"]], [self getStringFromTable:[keyValue objectForKey:@"item"]], [self getStringFromTable:[keyValue objectForKey:@"source"]]];
                [allText appendString:temp];
                [purchaseText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"ITEM_ASSEMBLE"]) {
                [temp appendFormat:@"[%@]%@(%@) assembled %@</br>", [self stringToDateString:[keyValue objectForKey:@"time"]], [playerNames objectForKey:[keyValue objectForKey:@"player"]], [playerHeroes objectForKey:[keyValue objectForKey:@"player"]], [self getStringFromTable:[keyValue objectForKey:@"item"]]];
                [allText appendString:temp];
                [purchaseText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"ITEM_DROP"]) {
                [temp appendFormat:@"[%@]%@(%@) dropped %@</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [self getStringFromTable:[keyValue objectForKey:@"item"]]];
                [allText appendString:temp];
                [purchaseText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"ITEM_PICKUP"]) {
                [temp appendFormat:@"[%@]%@(%@) picked %@ up</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [self getStringFromTable:[keyValue objectForKey:@"item"]]];
                [allText appendString:temp];
                [purchaseText appendString:temp];
            }
            //AWARD Section
            else if ([[keyValue objectForKey:@"title"] isEqualToString:@"AWARD_MULTI_KILL"]) {
                [temp appendFormat:@"[%@]%@(%@) is on a %@ multikill</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [keyValue objectForKey:@"count"]];
                [allText appendString:temp];
                [awardText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"AWARD_KILL_STREAK"]) {
                [temp appendFormat:@"[%@]%@(%@) is on a %@ killstreak</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [keyValue objectForKey:@"count"]];
                [allText appendString:temp];
                [awardText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"AWARD_RIVAL"]) {
                [temp appendFormat:@"[%@]%@(%@) is completely owning %@</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [self getStringFromTable:[keyValue objectForKey:@"name"]]];
                [allText appendString:temp];
                [awardText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"AWARD_FIRST_BLOOD"]) {
                [temp appendFormat:@"[%@]%@(%@) just got first blood on %@(%@) for %@ gold</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"owner"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"owner"]],
                 [keyValue objectForKey:@"gold"]];
                [allText appendString:temp];
                [awardText appendString:temp];
                [goldText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"AWARD_KILL_STREAK_BREAK"]) {
                [temp appendFormat:@"[%@]%@(%@) broke %@(%@) steak which last %@ steak</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"owner"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"owner"]],
                 [keyValue objectForKey:@"count"]];
                [allText appendString:temp];
                [awardText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"AWARD_SMACKDOWN"]) {
                [temp appendFormat:@"[%@]%@(%@) got a smackdown %@(%@)</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"owner"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"owner"]]];
                [allText appendString:temp];
                [awardText appendString:temp];
                [goldText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"AWARD_PAYBACK"]) {
                [temp appendFormat:@"[%@]%@(%@) just got a payback from %@(%@)</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"owner"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"owner"]]];
                [allText appendString:temp];
                [awardText appendString:temp];
                [goldText appendString:temp];
            }
            //GOLD Section
            else if ([[keyValue objectForKey:@"title"] isEqualToString:@"GOLD_EARNED"]) {
                NSString *owner = [keyValue objectForKey:@"owner"];
                if ([keyValue objectForKey:@"source"] != nil) {
                    if (owner == nil){
                        [temp appendFormat:@"[%@]%@(%@) earned %@ gold from %@</br>",
                         [self stringToDateString:[keyValue objectForKey:@"time"]],
                         [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                         [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                         [keyValue objectForKey:@"gold"],
                         [self getStringFromTable:[keyValue objectForKey:@"source"]]];
                    } else {
                        [temp appendFormat:@"[%@]%@(%@) earned %@ gold from %@(%@)</br>",
                         [self stringToDateString:[keyValue objectForKey:@"time"]],
                         [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                         [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                         [keyValue objectForKey:@"gold"],
                         [playerNames objectForKey:[keyValue objectForKey:@"owner"]],
                         [playerHeroes objectForKey:[keyValue objectForKey:@"owner"]]]; 
                    }
                }
                
                [allText appendString:temp];
                [goldText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"GOLD_LOST"]) {
                NSString *owner = [keyValue objectForKey:@"owner"];
                if ([keyValue objectForKey:@"source"] != nil) {
                    if (owner == nil){
                        [temp appendFormat:@"[%@]%@(%@) lost %@ gold because %@</br>",
                         [self stringToDateString:[keyValue objectForKey:@"time"]],
                         [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                         [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                         [keyValue objectForKey:@"gold"],
                         [self getStringFromTable:[keyValue objectForKey:@"source"]]];
                    } else {
                        [temp appendFormat:@"[%@]%@(%@) lost %@ gold because %@(%@)</br>",
                         [self stringToDateString:[keyValue objectForKey:@"time"]],
                         [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                         [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                         [keyValue objectForKey:@"gold"],
                         [playerNames objectForKey:[keyValue objectForKey:@"owner"]],
                         [playerHeroes objectForKey:[keyValue objectForKey:@"owner"]]]; 
                    }
                }
                
                [allText appendString:temp];
                [goldText appendString:temp];
            }
            //EXP Section
            else if ([[keyValue objectForKey:@"title"] isEqualToString:@"EXP_EARNED"]) {
                NSString *owner = [keyValue objectForKey:@"owner"];
                if ([keyValue objectForKey:@"source"] != nil) {
                    if (owner == nil){
                        [temp appendFormat:@"[%@]%@(%@) gained %@ experience from %@</br>",
                         [self stringToDateString:[keyValue objectForKey:@"time"]],
                         [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                         [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                         [keyValue objectForKey:@"experience"],
                         [self getStringFromTable:[keyValue objectForKey:@"source"]]];
                    } else {
                        [temp appendFormat:@"[%@]%@(%@) gained %@ experience from %@(%@)</br>",
                         [self stringToDateString:[keyValue objectForKey:@"time"]],
                         [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                         [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                         [keyValue objectForKey:@"experience"],
                         [playerNames objectForKey:[keyValue objectForKey:@"owner"]],
                         [playerHeroes objectForKey:[keyValue objectForKey:@"owner"]]]; 
                    }
                }
                
                [allText appendString:temp];
                [expText appendString:temp];
            }
            else if ([[keyValue objectForKey:@"title"] isEqualToString:@"EXP_DENIED"]) {
                [temp appendFormat:@"[%@]%@(%@) denied %@ experience from %@(%@)</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"owner"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"owner"]],
                 [keyValue objectForKey:@"experience"],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]]]; 
                
                [allText appendString:temp];
                [expText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"CREEP_DENY"]) {
                [temp appendFormat:@"[%@]%@(%@) denied %@ experience and %@ gold from %@(total lost)</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [keyValue objectForKey:@"experience"],
                 [keyValue objectForKey:@"gold"],
                 [self getStringFromTable:[keyValue objectForKey:@"name"]]]; 
                
                [allText appendString:temp];
                [expText appendString:temp];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"BUILDING_DENY"]) {
                [temp appendFormat:@"[%@]%@(%@) denied %@ gold from %@(total lost)</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [keyValue objectForKey:@"gold"],
                 [self getStringFromTable:[keyValue objectForKey:@"name"]]]; 
                
                [allText appendString:temp];
                [expText appendString:temp];
            }
            //APM Section
            else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_ACTIONS"]) {
                [temp appendFormat:@"[%@]%@(%@) got %@ apm counted for a period of %@ millisecond(s)</br>",
                 [self stringToDateString:[keyValue objectForKey:@"time"]],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [playerHeroes objectForKey:[keyValue objectForKey:@"player"]],
                 [keyValue objectForKey:@"count"],
                 [keyValue objectForKey:@"period"]]; 
                
                [apmText appendString:temp];
            }
            //UNKNOWN
            else {
                [unknownText appendString:line];
                [unknownText appendString:@"</br>"];
            }
        }
        
        NSURL *baseURL = [NSURL URLWithString:@"//"];
        
        [[self.allWebView mainFrame] loadHTMLString:allText baseURL:baseURL];
        [[self.infoWebView mainFrame] loadHTMLString:infoText baseURL:baseURL];
        [[self.chatWebView mainFrame] loadHTMLString:chatText baseURL:baseURL];
        [[self.abilityWebView mainFrame] loadHTMLString:abilityText baseURL:baseURL];
        [[self.damageWebView mainFrame] loadHTMLString:damageText baseURL:baseURL];
        [[self.purchaseWebView mainFrame] loadHTMLString:purchaseText baseURL:baseURL];
        [[self.unknownWebView mainFrame] loadHTMLString:unknownText baseURL:baseURL];
        [[self.killWebView mainFrame] loadHTMLString:killText baseURL:baseURL];
        [[self.heroWebView mainFrame] loadHTMLString:heroText baseURL:baseURL];
        [[self.heroKillWebView mainFrame] loadHTMLString:heroKillText baseURL:baseURL];
        [[self.awardWebView mainFrame] loadHTMLString:awardText baseURL:baseURL];
        [[self.goldWebView mainFrame] loadHTMLString:goldText baseURL:baseURL];
        [[self.expWebView mainFrame] loadHTMLString:expText baseURL:baseURL];
        [[self.apmWebView mainFrame] loadHTMLString:apmText baseURL:baseURL];
    }
    else {
        NSLog(@"NOT HON");
    }
    
    urlToServerLog = nil;
    
    [(NSButton *)sender setEnabled:YES];
    
}

- (NSString *)stringToDateString:(NSString *)time {
    //Formatter
    NSNumberFormatter *f = [[[NSNumberFormatter alloc] init] autorelease];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber *num = [f numberFromString:time];
    
    long long milliSec = [num longLongValue];
    long long sec = milliSec / 1000;
    long long min = sec / 60;
    long long hour = min / 60;
    
    return [NSString stringWithFormat:@"%.2qi:%.2qi:%.2qi:f%.2qi", hour, min % 60, sec % 60, (milliSec % 1000) / 50];
}

- (NSDictionary *)parseLog:(NSString *)log {
    bool isTitle = YES;
    bool isQuote = NO;
    NSMutableString *buffer = [NSMutableString string];
    NSString *key = nil;
    NSString *value;
    NSMutableDictionary *keyValue = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < [log length]; i++) {
        if ((!isQuote) && (' ' == [log characterAtIndex:i])) {
            if (isTitle) {
                [keyValue setValue:buffer forKey:@"title"];
                buffer = [NSMutableString string];
                isTitle = NO;
            } else {
                value = [[buffer copy] autorelease];
                buffer = [NSMutableString string];
                [keyValue setValue:value forKey:key];
            }
            continue;
        }
        if ((isQuote) && ([log characterAtIndex:i] == '"')) {
            isQuote = NO;
            continue;
        }
        else if ((!isQuote) && ([log characterAtIndex:i] == '"')) {
            isQuote = YES;
            continue;
        }
        
        if ((!isQuote) && ([log characterAtIndex:i] == ':')) {
            key = [[buffer copy] autorelease];
            buffer = [NSMutableString string];
            continue;
        }
        
        [buffer appendFormat:@"%C", [log characterAtIndex:i]];
    }
    
    return keyValue;
}

- (NSString *)removeClanTag:(NSString *)playerName {
    bool isClanTagOver = NO;
    for (NSUInteger i = 0; i < [playerName length]; i++) {
        if (isClanTagOver) {
            return [playerName substringFromIndex:i];
        } else if ([playerName characterAtIndex:i] == ']') {
            isClanTagOver = YES;
        }
    }
    
    return playerName;
}

- (NSString *) getPositionByName: (NSDictionary *) keyValue  {
    NSString* playerPosition = [self.realPlayerPosition objectForKey:[self removeClanTag:[keyValue objectForKey:@"name"]]];
    return playerPosition;
}
- (void)addAndSetPlayerColorFrom:(NSDictionary *)keyValue toPlayers:(NSMutableDictionary *)playerNames f:(NSNumberFormatter *)f {
    NSString *playerPosition;
    playerPosition = [self getPositionByName: keyValue];
    [slotToPostion setValue:playerPosition forKey:[keyValue objectForKey:@"player"]];
    switch ([[f numberFromString:playerPosition] intValue]) {
        case 0:
            [playerNames setValue:[NSString stringWithFormat:@"<span style=\"color: rgb(0, 60, 233);\">%@</span>", [keyValue objectForKey:@"name"]] forKey:[keyValue objectForKey:@"player"]];
            break;
        case 1:
            [playerNames setValue:[NSString stringWithFormat:@"<span style=\"color: rgb(124, 255, 241);\">%@</span>", [keyValue objectForKey:@"name"]] forKey:[keyValue objectForKey:@"player"]];
            break;
        case 2:
            [playerNames setValue:[NSString stringWithFormat:@"<span style=\"color: rgb(97, 50, 148);\">%@</span>", [keyValue objectForKey:@"name"]] forKey:[keyValue objectForKey:@"player"]];
            break;
        case 3:
            [playerNames setValue:[NSString stringWithFormat:@"<span style=\"color: rgb(255, 252, 1);\">%@</span>", [keyValue objectForKey:@"name"]] forKey:[keyValue objectForKey:@"player"]];
            break;
        case 4:
            [playerNames setValue:[NSString stringWithFormat:@"<span style=\"color: rgb(254, 138, 14);\">%@</span>", [keyValue objectForKey:@"name"]] forKey:[keyValue objectForKey:@"player"]];
            break;
        case 5:
            [playerNames setValue:[NSString stringWithFormat:@"<span style=\"color: rgb(229, 91, 176);\">%@</span>", [keyValue objectForKey:@"name"]] forKey:[keyValue objectForKey:@"player"]];
            break;
        case 6:
            [playerNames setValue:[NSString stringWithFormat:@"<span style=\"color: rgb(149, 150, 151);\">%@</span>", [keyValue objectForKey:@"name"]] forKey:[keyValue objectForKey:@"player"]];
            break;
        case 7:
            [playerNames setValue:[NSString stringWithFormat:@"<span style=\"color: rgb(106, 171, 255);\">%@</span>", [keyValue objectForKey:@"name"]] forKey:[keyValue objectForKey:@"player"]];
            break;
        case 8:
            [playerNames setValue:[NSString stringWithFormat:@"<span style=\"color: rgb(16, 98, 70);\">%@</span>", [keyValue objectForKey:@"name"]] forKey:[keyValue objectForKey:@"player"]];
            break;
        case 9:
            [playerNames setValue:[NSString stringWithFormat:@"<span style=\"color: rgb(173, 92, 51);\">%@</span>", [keyValue objectForKey:@"name"]] forKey:[keyValue objectForKey:@"player"]];
            break;
        default:
            [playerNames setValue:[NSString stringWithFormat:@"<span style=\"color: rgb(173, 92, 51);\">%@</span>", [keyValue objectForKey:@"name"]] forKey:[keyValue objectForKey:@"player"]];
    }
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"stat"]) {
        self.currentKey = [attributeDict objectForKey:@"name"];
        self.currentValue = [[[NSMutableString alloc] init] autorelease];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentValue appendFormat:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([self.currentKey isEqualToString:@"url"])
        self.urlToServerLog = [[self.currentValue mutableCopy] autorelease];
    else if ([self.currentKey isEqualToString:@"nickname"])
        self.currentPlayerName = [[self.currentValue copy] autorelease];
    else if ([self.currentKey isEqualToString:@"position"])
        [self.realPlayerPosition setValue:[[self.currentValue copy] autorelease] forKey:self.currentPlayerName];
}

- (NSFileWrapper *)unzip:(NSData *)zipData {
    NSString *sourceFilename = @"zipped data";
    NSString *targetFilename = @"unzipped folder";
    
    NSString *sourcePath = [self.scratchFolder stringByAppendingPathComponent:sourceFilename];
    NSString *targetPath = [self.scratchFolder stringByAppendingPathComponent:targetFilename];
    
    
    BOOL flag = [zipData writeToFile:sourcePath atomically:YES];
    
    if (flag == NO) {
        NSLog(@"error");
        return NULL;
    }
    
    
    //Unzip
    
    //-------------------
    NSTask *cmd = [[NSTask alloc] init];
    [cmd setLaunchPath:@"/usr/bin/ditto"];
    [cmd setArguments:[NSArray arrayWithObjects:
                       @"-v", @"-x", @"-k", @"--rsrc", sourcePath, targetPath, nil]];
    [cmd launch];
    [cmd waitUntilExit];
    
    if ([cmd terminationStatus] != 0) {
        NSLog(@"Sorry, didn't work.");
        [cmd release];
        return NULL;
    }
    [cmd release];
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetPath error:nil];
    
    NSFileWrapper *wrapper = nil;
    
    if ([contents count] == 1) {
        NSString *onePath;
        onePath = [targetPath stringByAppendingPathComponent:[contents lastObject]];
        
        NSData *data = [NSData dataWithContentsOfFile:onePath];
        
        wrapper = [[[NSFileWrapper alloc] initRegularFileWithContents:data] autorelease];
        
        
    }
    else if ([contents count] > 1) {
        
        wrapper = [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:NULL] autorelease];
        
        unsigned hoge;
        for (hoge = 0; hoge < [contents count]; hoge++) {
            NSString *onePath;
            NSString *oneFilename;
            
            oneFilename = [contents objectAtIndex:hoge];
            onePath = [targetPath stringByAppendingPathComponent:oneFilename];
            
            NSData *data = [NSData dataWithContentsOfFile:onePath];
            
            [wrapper addRegularFileWithContents:data preferredFilename:oneFilename];
        }
    }
    
    
    
    //delete scratch
    
    [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceDestroyOperation
                                                 source:self.scratchFolder
                                            destination:@""
                                                  files:[NSArray arrayWithObjects:sourceFilename, targetFilename, NULL]
                                                    tag:NULL];
    
    
    return wrapper;
}
@end
