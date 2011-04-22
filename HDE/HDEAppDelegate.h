//
//  HDEAppDelegate.h
//  HDE
//
//  Created by Athiwat Chunlakhan on 4/23/11.
//  Copyright 2011 Kasetsart University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HDEAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
