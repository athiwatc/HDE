//
//  HDEAppDelegate.m
//  HDE
//
//  Created by Athiwat Chunlakhan on 4/23/11.
//  Copyright 2011 Kasetsart University. All rights reserved.
//

#import "HDEAppDelegate.h"

@implementation HDEAppDelegate

@synthesize window, scratchFolder, output, matchID, urlToServerLog, currentValue, currentKey;

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString * tempDir = NSTemporaryDirectory();
    if (tempDir == nil)
        tempDir = @"/tmp";
    
    NSString * template = [tempDir stringByAppendingPathComponent: @"HDEtemp"];
    const char * fsTemplate = [template fileSystemRepresentation];
    NSMutableData * bufferData = [NSMutableData dataWithBytes: fsTemplate
                                                       length: strlen(fsTemplate)+1];
    char * buffer = [bufferData mutableBytes];
    mkdtemp(buffer);
    NSString * temporaryDirectory = [[NSFileManager defaultManager]
                                     stringWithFileSystemRepresentation: buffer
                                     length: strlen(buffer)];
	self.scratchFolder = temporaryDirectory;
}

-(void)ParserButton:(id)sender{
    [sender setEnabled:NO];
    NSURL *urlXML = [NSURL URLWithString:[@"http://xml.heroesofnewerth.com/xml_requester.php?f=match_stats&opt=mid&mid[]=" stringByAppendingString:[matchID stringValue]]];
    NSXMLParser *parser = [[[NSXMLParser alloc] initWithContentsOfURL:urlXML] autorelease];
    
    [parser setDelegate:self];
    [parser parse];
    
    [self.urlToServerLog replaceOccurrencesOfString:@"honreplay" withString:@"zip" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [urlToServerLog length])];
    
    NSURL *urlServerLog = [NSURL URLWithString:self.urlToServerLog];
    NSData *downloadData = [NSData dataWithContentsOfURL:urlServerLog];
    
    //NSData *downloadData = [NSData dataWithContentsOfFile:@"/Users/Athiwat/Desktop/M37139782.zip"];
    
    NSFileWrapper* wrapper = [self unzip:downloadData];
	
	if( [wrapper isRegularFile] )
	{
		NSData *data = [wrapper regularFileContents];
        NSString *serverLog = [[[NSString alloc] initWithData:data encoding:NSUTF16StringEncoding] autorelease];
        NSArray *lines = [serverLog componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSMutableString *textOutput = [NSMutableString string];
        NSMutableDictionary *playerNames = [NSMutableDictionary dictionary];
        NSMutableDictionary *playerHeroes = [NSMutableDictionary dictionary];
        for (NSString *line in lines) {
            NSDictionary *keyValue = [self parseLog:[line stringByAppendingString:@" "]];
            if ([[keyValue objectForKey:@"title"] isEqualToString:@"INFO_DATE"]) {
                [textOutput appendFormat:@"Game started on %@ at %@\n", [keyValue objectForKey:@"date"], [keyValue objectForKey:@"time"]];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"INFO_SERVER"]) {
                [textOutput appendFormat:@"Hosted on %@\n", [keyValue objectForKey:@"name"]];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"INFO_GAME"]) {
                [textOutput appendFormat:@"Version %@\n", [keyValue objectForKey:@"version"]];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"INFO_MATCH"]) {
                [textOutput appendFormat:@"Game name %@ ID %@\n", [keyValue objectForKey:@"name"], [keyValue objectForKey:@"id"]];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"INFO_MAP"]) {
                [textOutput appendFormat:@"Map name %@ version %@\n", [keyValue objectForKey:@"name"], [keyValue objectForKey:@"version"]];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"INFO_SETTINGS"]) {
                [textOutput appendFormat:@"On mode %@ with options %@\n", [keyValue objectForKey:@"mode"], [keyValue objectForKey:@"options"]];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_CONNECT"] && ([keyValue objectForKey:@"time"] == nil)) {
                [playerNames setValue:[keyValue objectForKey:@"name"] forKey:[keyValue objectForKey:@"player"]];
                [textOutput appendFormat:@"Player %@ connected on slot %@\n", [keyValue objectForKey:@"name"], [keyValue objectForKey:@"player"]];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_SELECT"]) {
                [playerHeroes setValue:[keyValue objectForKey:@"hero"] forKey:[keyValue objectForKey:@"player"]];
                [textOutput appendFormat:@"%@ selected %@\n",
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 [keyValue objectForKey:@"hero"]];
            } else if ([[keyValue objectForKey:@"title"] isEqualToString:@"PLAYER_CHAT"]) {
                NSString *heroname = [playerHeroes objectForKey:[keyValue objectForKey:@"player"]];
                if (heroname == nil) heroname = [NSString stringWithString:@"No Hero"];
                [textOutput appendFormat:@"[%@]%@(%@): %@\n",
                 [keyValue objectForKey:@"target"],
                 [playerNames objectForKey:[keyValue objectForKey:@"player"]],
                 heroname,
                 [keyValue objectForKey:@"msg"]];
            } 
        }
        
        [output setString:textOutput];
    }
    else
    {
        NSLog(@"NOT HON");
    }
    
    urlToServerLog = nil;
    [sender setEnabled:YES];
}

-(NSDictionary *)parseLog:(NSString *)log{
    bool isTitle = YES;
    bool isQuote = NO;
    NSMutableString *buffer = [NSMutableString string];
    NSString *key = nil;
    NSString *value = nil;
    NSMutableDictionary *keyValue = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < [log length]; i++) {
        if ((!isQuote) && ([log characterAtIndex:i] == ' ')) {
            if (isTitle) {
                [keyValue setValue:buffer forKey:@"title"];
                buffer = [NSMutableString string];
                isTitle = NO;
            } else {
                value = [buffer copy];
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
            key = [buffer copy];
            buffer = [NSMutableString string];
            continue;
        }
        
        [buffer appendFormat:@"%C", [log characterAtIndex:i]];
    }
    
    return keyValue;
}

-(NSString *)getValueFrom:(NSArray *)array at:(int)position{
    if ([[array objectAtIndex:position] rangeOfString:@":"].location != NSNotFound)
    {
        NSString *value = [[array objectAtIndex:position] substringFromIndex:[[array objectAtIndex:position] rangeOfString:@":"].location + 1];
        return [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
    }
    return nil;
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"stat"]) {
        self.currentKey = [attributeDict objectForKey:@"name"];
        self.currentValue = [[[NSMutableString alloc] init] autorelease];
    }  
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [self.currentValue appendFormat:string];
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([self.currentKey isEqualToString:@"url"])
        self.urlToServerLog = [self.currentValue mutableCopy];
}

-(NSFileWrapper*)unzip:(NSData*)zipData
{
    NSString* sourceFilename = @"zipped data";
    NSString* targetFilename = @"unzipped folder";
    
    NSString* sourcePath = [self.scratchFolder stringByAppendingPathComponent: sourceFilename];
    NSString* targetPath = [self.scratchFolder stringByAppendingPathComponent: targetFilename];
    
    
    
    BOOL flag = [zipData writeToFile:sourcePath atomically:YES];
    
    if( flag == NO )
    {
        NSLog(@"error");
        return NULL;
    }
    
    
    //Unzip
    
    //-------------------
    NSTask *cmnd=[[NSTask alloc] init];
    [cmnd setLaunchPath:@"/usr/bin/ditto"];
    [cmnd setArguments:[NSArray arrayWithObjects:
                        @"-v",@"-x",@"-k",@"--rsrc",sourcePath,targetPath,nil]];
    [cmnd launch];
    [cmnd waitUntilExit];
    
    // Handle the task's termination status
    if ([cmnd terminationStatus] != 0)
    {
        NSLog(@"Sorry, didn't work.");
        [cmnd release];
        return NULL;
    }
    
    // You *did* remember to wash behind your ears ...
    // ... right?
    [cmnd release];
    
    
    
    //unzip
    //
    
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetPath error:nil];
    
    
    NSFileWrapper* wrapper = nil;
    
    if( [contents count] == 1 )
    {
        NSString* onepath;
        onepath = [targetPath stringByAppendingPathComponent:[contents lastObject]];
        
        NSData* data = [NSData dataWithContentsOfFile:onepath];
        
        wrapper = [[[NSFileWrapper alloc] initRegularFileWithContents:data  ] autorelease];
        
        
    }
    else	if( [contents count] > 1 )
    {
        
        wrapper = [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:NULL ] autorelease];
        
        unsigned hoge;
        for( hoge = 0; hoge < [contents count]; hoge++ )
        {
            NSString* onepath;
            NSString* onefilename;
            
            onefilename = [contents objectAtIndex:hoge];
            onepath = [targetPath stringByAppendingPathComponent:onefilename];
            
            NSData* data = [NSData dataWithContentsOfFile:onepath];
            
            [wrapper addRegularFileWithContents:data   preferredFilename:onefilename ];
        }
    }
    
    
    
    //delete scratch
    
    [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceDestroyOperation
                                                 source:self.scratchFolder
                                            destination:@"" 
                                                  files:[NSArray arrayWithObjects:sourceFilename, targetFilename,NULL]
                                                    tag:NULL];
    
    
    return wrapper;
}
@end
