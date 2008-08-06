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

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject {
@private
    BOOL appIsLaunching;
    BOOL wasLaunchedWithDocument;
    NSMutableArray *filesToProcess;
}

- (IBAction)convertViaOpenPanel:(id)sender; // responds to the "Open" menu item
- (void)handleCTRemoval:(id)ignored;
- (void)processDirRecursively:(NSString*)directory;
- (void)removeForFile:(NSString*)file;
- (NSArray*)getDirPaths:(NSString*)directory;

@end
