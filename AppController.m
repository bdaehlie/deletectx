/*
 This file is part of DeleteCTX.

 DeleteCTX is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 DeleteCTX is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with DeleteCTX; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

 Copyright (c) 2002 Josh Aas.
 */

#import "AppController.h"

#define FileManager [NSFileManager defaultManager]
#define Workspace [NSWorkspace sharedWorkspace]

@implementation AppController

- (id)init {
    if ((self = [super init])) {
        appIsLaunching = YES;
        wasLaunchedWithDocument = NO;
        filesToProcess = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

- (void)dealloc {
    [filesToProcess release];
    [super dealloc];
}

/*
 ACTIONS
 */

// Convert document via open panel
- (IBAction)convertViaOpenPanel:(id)sender {
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setCanChooseDirectories:YES];
    [oPanel setAllowsMultipleSelection:YES];
    [oPanel setResolvesAliases:YES];
    if ([oPanel runModalForDirectory:NSHomeDirectory() file:nil types:nil] == NSOKButton) {
        [filesToProcess addObjectsFromArray:[oPanel filenames]];
        [self handleCTRemoval:@"ignored"];
    }
}

/*
 METHODS
 */

- (void)handleCTRemoval:(id)ignored {
    int i;
    BOOL isDir = NO;
    BOOL processAllDirs = NO;
    for (i = 0; i < [filesToProcess count]; i++) {
        if (![Workspace isFilePackageAtPath:[filesToProcess objectAtIndex:i]]) {
            if ([FileManager fileExistsAtPath:[filesToProcess objectAtIndex:i] isDirectory:&isDir] && isDir) {
                if (!processAllDirs) {
                    NSString *alertMessage;
                    int result;
                    alertMessage = [@"Are you sure you want to process everything in the folder: \""
                                    stringByAppendingString:[[[filesToProcess objectAtIndex:i] lastPathComponent] stringByAppendingString:@"\"?"]];
                    result = NSRunCriticalAlertPanel(nil, alertMessage, @"Do It", @"Cancel", @"Process All Folders");
                    if (result == NSAlertDefaultReturn) {
                        [self processDirRecursively:[filesToProcess objectAtIndex:i]];
                    }
                    else if (result == NSAlertOtherReturn) {
                        processAllDirs = YES;
                        [self processDirRecursively:[filesToProcess objectAtIndex:i]];
                    }
                }
                else {
                    [self processDirRecursively:[filesToProcess objectAtIndex:i]];
                }
            }
            else {
                [self removeForFile:[filesToProcess objectAtIndex:i]];
            }
        }
    }
    if (wasLaunchedWithDocument) {
        [NSApp terminate:self];
    }
    else {
        [filesToProcess removeAllObjects];
    }
}

- (NSArray*)getDirPaths:(NSString*)directory {
    int i;
    NSMutableArray *dirContents = [[[NSMutableArray alloc] init] autorelease];
    [dirContents addObjectsFromArray:[FileManager directoryContentsAtPath:directory]];
    for (i = 0; i < [dirContents count]; i++) {
        [dirContents replaceObjectAtIndex:i withObject:[NSString pathWithComponents:
            [NSArray arrayWithObjects:directory, [dirContents objectAtIndex:i], nil]]];
    }
    return dirContents;
}

- (void)processDirRecursively:(NSString*)directory {
    int i;
    BOOL isDir = NO;
    NSArray *dirFiles = [self getDirPaths:directory];
    for (i = 0; i < [dirFiles count]; i++) {
        if (![Workspace isFilePackageAtPath:[dirFiles objectAtIndex:i]]) {
            if ([FileManager fileExistsAtPath:[dirFiles objectAtIndex:i] isDirectory:&isDir] && isDir) {
                [self processDirRecursively:[dirFiles objectAtIndex:i]];
            }
            else {
                [self removeForFile:[dirFiles objectAtIndex:i]];
            }
        }
    }
}

- (void)removeForFile:(NSString*)file {
    NSMutableDictionary *attributesToChange = [[NSMutableDictionary alloc] init];
    [attributesToChange setObject:[NSNumber numberWithUnsignedLong:NSHFSTypeCodeFromFileType(nil)] forKey:NSFileHFSCreatorCode];
    [attributesToChange setObject:[NSNumber numberWithUnsignedLong:NSHFSTypeCodeFromFileType(nil)] forKey:NSFileHFSTypeCode];
    [FileManager changeFileAttributes:attributesToChange atPath:file];
    [Workspace noteFileSystemChanged:file];
    [attributesToChange release];
}

/*
 DELEGATES
 */

- (void)applicationWillFinishLaunching:(NSNotification*)aNotification {
    appIsLaunching = YES;
}

- (BOOL)application:(NSApplication*)anApplication openFile:(NSString*)aFileName {
    wasLaunchedWithDocument = appIsLaunching;
    [filesToProcess addObject:aFileName];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleCTRemoval:) object:nil];
    [self performSelector:@selector(handleCTRemoval:) withObject:nil afterDelay:0.2];
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
    appIsLaunching = NO;
}

@end