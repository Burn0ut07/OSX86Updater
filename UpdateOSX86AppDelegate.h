//
// This file is part of OSX86Updater.
//
// OSX86Updater is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// OSX86Updater is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with OSX86Updater.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright © 2010 Joel Jauregui
//
//
// P.S. MAAttachedWindow Source Code by Matt Gemmell <http://mattgemmell.com/>.
//

#import <Cocoa/Cocoa.h>
#import "MAAttachedWindow.h"

@interface UpdateOSX86AppDelegate : NSObject 
	<NSApplicationDelegate, NSMenuDelegate> 
{
    NSWindow *window;
    MAAttachedWindow *attachedWindow;
	IBOutlet NSMenu *menu;
	IBOutlet NSView *efiTab;
	IBOutlet NSView *extraTab;
    IBOutlet NSTextField *progressLabel;
    IBOutlet NSTextField *selectedDiskLabel;
    IBOutlet NSProgressIndicator *circularProgress;
    IBOutlet NSView *view;
    IBOutlet NSTextField *textField;
    
	int asyncWorkers, lastSender;
	BOOL mounted;
	NSArray *disks;
	NSString *disk;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)didClickButton:(NSButton *)sender;
- (IBAction)didClickButtonExtra:(NSButton *)sender;
- (void)buttonClickedWorker:(NSButton *)sender;
- (void)menuItemClickedWorker:(NSMenuItem *)sender;
- (void)askReboot;
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode
		contextInfo:(void *)contextInfo;
- (void)makeAlertWithMessage:(NSString *)message andText:(NSString *)text;
- (NSInteger)numberOfItemsInMenu:(NSMenu *)nsmenu;
- (BOOL)menu:(NSMenu *)nsmenu 
  updateItem:(NSMenuItem *)item 
	 atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel;
- (void)swapDisk:(NSMenuItem *)sender;
- (void)turnOffLastSender;

@end
#define EFI_INSTALL_BRANCHES -4
#define EFI_INSTALL_CHAMELEON -2
#define EFI_BC 0
#define MBR_BC 1
#define EFI_RESTORE 4
#define MBR_RESTORE 5
#define SLE_MKEXT 7
#define EFI_FORMAT 10
#define RESTART @"do shell script \"shutdown -r now\" with administrator privileges\nquit"
#define AS_ADMIN @"do shell script \"%@\" with administrator privileges"
#define RUN_NO_ADMIN @"do shell script \"%@\""
#define REBUILD_CACHE @"rebuild_cache"
#define MOUNT @"mount"
#define UNMOUNT @"clean_unmount"
#define RESTORE @"restore"
#define FORMAT_HFS @"format_hfs"
#define DL_CHAMELEON @"dl_chameleon"
#define COMPILE_CHAMELEON @"compile_chameleon"
#define INSTALL_CHAMELEON @"install_chameleon"
