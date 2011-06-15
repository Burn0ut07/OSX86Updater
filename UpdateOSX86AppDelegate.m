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

#import "UpdateOSX86AppDelegate.h"
#import "ShellTask.h"

@interface UpdateOSX86AppDelegate ()
@property (nonatomic, assign) int asyncWorkers;
@property (nonatomic, assign) NSString *disk;
@end

@implementation UpdateOSX86AppDelegate

@synthesize window, asyncWorkers, disk;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.asyncWorkers = 0;
	mounted = NO;
	self.disk = nil;
	disks = nil;
	lastSender = 1337;
}

#pragma mark Dynamic properties

- (NSArray *)disks
{
	NSString *ret = 
		[ShellTask executeShellCommandSynchronously:
			@"diskutil list | egrep '/dev/disk.'"];
	NSArray *temp = [ret componentsSeparatedByString:@"\n"];
		
	NSRange range = NSMakeRange(0, [temp count] - 1);
	disks = [temp subarrayWithRange:range];
	
	return disks;
}

#pragma mark Interface Builder Actions

- (IBAction)didClickButton:(NSButton *)sender
{	//Need a clean way to do this instead of if..else if
	if(asyncWorkers > 0) {
#ifdef DEBUG
		NSLog(@"Already working!");
#endif
		sender.state = !sender.state;
		[self makeAlertWithMessage:@"AsyncWorker Running"
						   andText:@"Work is being done on mounted disk!"];
		return;
	} else if(disk && (!mounted || lastSender == sender.tag)) {
		asyncWorkers++;
		lastSender = sender.tag;
		if (sender.tag % 2 == 0) {
			NSString *ret =
			[ShellTask executeShellCommandSynchronously:
			 [NSString stringWithFormat:@"diskutil list | egrep '%@s1' | grep EFI", [disk substringFromIndex:5]]];
			if ([ret length] <= 0) {
				[self makeAlertWithMessage:@"No EFI"
								   andText:@"No EFI partition on disk!"];
				sender.state = !sender.state;
				asyncWorkers--;
				return;
			}
		}
		[NSThread detachNewThreadSelector:@selector(buttonClickedWorker:)   
								 toTarget:self withObject:sender];
	} else if(mounted) {
		sender.state = !sender.state;
		[self makeAlertWithMessage:@"Disk mounted" 
						   andText:@"A disk is already mounted!"];
	} else if (!disk) {
		sender.state = !sender.state;
		[self makeAlertWithMessage:@"Choose disk"
						   andText:@"Must choose disk before operations!\n(Menu->Disk)."];
	}

}

- (IBAction)didClickButtonExtra:(NSButton *)sender 
{
	if(asyncWorkers > 0) {
#ifdef DEBUG
		NSLog(@"Already working!");
#endif
		sender.state = !sender.state;
		[self makeAlertWithMessage:@"AsyncWorker Running"
						   andText:@"Work is being done on mounted disk!"];
		return;
	} else if(!mounted || lastSender == sender.tag) {
		asyncWorkers++;
		lastSender = sender.tag;
		[NSThread detachNewThreadSelector:@selector(buttonClickedWorker:)   
								 toTarget:self withObject:sender];
	} else if(mounted) {
		sender.state = !sender.state;
		[self makeAlertWithMessage:@"Disk mounted" 
						   andText:@"A disk is already mounted!"];
	}
}

- (void)swapDisk:(NSMenuItem *)sender
{
	if(asyncWorkers > 0 && disk != sender.title) {
#ifdef DEBUG
		NSLog(@"Already working!");
#endif
		[self makeAlertWithMessage:@"AsyncWorker Running"
						   andText:@"Work is being done on mounted disk!"];
		return;
	}
	else if (disk && disk != sender.title) {
		if(mounted) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"Cancel"];
			[alert addButtonWithTitle:@"Ok"];
			[alert setMessageText:@"Dismount disk?"];
			[alert setInformativeText:@"Dismount current disk?"];
			[alert setAlertStyle:NSInformationalAlertStyle];
		
			if ([alert runModal] == NSAlertSecondButtonReturn) {
				[NSThread detachNewThreadSelector:@selector(menuItemClickedWorker:) 
										 toTarget:self withObject:sender];
                [alert release];
			} else {
                [alert release];
				return;
            }
		}
		
		NSMenuItem *curr = [menu itemWithTitle:disk];
		curr.state = NSOffState;
		disk = sender.title;
		sender.state = NSOnState;
        NSString *labelText = [NSString stringWithFormat:@"Selected disk : %@", disk];
        [selectedDiskLabel setTitleWithMnemonic:labelText];
        NSColor *rgb = [NSColor colorWithCalibratedRed:0.0f green:0.3f blue:0.0f alpha:1.0f];
        [selectedDiskLabel setTextColor:rgb];
	} else {
		disk = sender.title;
		sender.state = NSOnState;
        NSString *labelText = [NSString stringWithFormat:@"Selected disk : %@", disk];
        [selectedDiskLabel setTitleWithMnemonic:labelText];
        NSColor *rgb = [NSColor colorWithCalibratedRed:0.0f green:0.3f blue:0.0f alpha:1.0f];
        [selectedDiskLabel setTextColor:rgb];
	}
	
}

#pragma mark asyncWorkers

- (void)turnOffLastSender
{
	id button = [efiTab viewWithTag:lastSender];
	[button setState:NSOffState];
	button = [extraTab viewWithTag:lastSender];
	[button setState:NSOffState];
}

- (void)menuItemClickedWorker:(NSMenuItem *)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *path = nil, *scriptText = nil, *params = nil;
	//NSDictionary *errorDict;
	path = [[NSBundle mainBundle] pathForResource:UNMOUNT 
										   ofType:@"sh"];
	
	switch (lastSender) {
		case EFI_BC:
			params = [@"EFI " stringByAppendingString:disk];
			break;
		case MBR_BC:
			params = @"Extra";
			break;
		default:
			break;
	}
	
	scriptText = [NSString stringWithFormat:AS_ADMIN, 
				  [path stringByAppendingFormat:@" %@", params]];
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptText];
	
	[script executeAndReturnError:nil];
    [script release];
	
	[self performSelectorOnMainThread:@selector(setAsyncWorkers:) 
						   withObject:0 waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(setMounted:) 
						   withObject:[NSNumber numberWithBool:NO] 
						waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(turnOffLastSender) 
						   withObject:nil waitUntilDone:YES];
    
    [pool release];
}

- (void)buttonClickedWorker:(NSButton *)sender
{	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSAppleScript *scriptMount = nil;
    NSAppleScript *scriptDownload = nil;
    NSAppleScript *scriptCompile = nil;
    NSAppleScript *scriptInstallCham = nil;
    NSAppleScript *scriptRun = nil;
	NSString *path = nil, *toRun = nil, *params = nil;
	//NSDictionary *errorDict = nil;
	if ([sender state] == NSOnState && sender.tag < 2) {
        if (sender.tag < -1) {  // Download, Compile and Install Chameleon.
            switch (sender.tag) {
                case EFI_INSTALL_BRANCHES:
                    params = @"branches";
                    break;
                case EFI_INSTALL_CHAMELEON:
                    params = @"trunk";
                    break;
                default:
                    break;
            }
            // Download Chameleon source code
            path = [[NSBundle mainBundle] pathForResource:DL_CHAMELEON 
                                                   ofType:@"sh"];
            NSString *scriptText2 = [NSString stringWithFormat:RUN_NO_ADMIN, 
                                     [path stringByAppendingFormat:@" %@", params]];
            scriptDownload = [[NSAppleScript alloc] initWithSource:scriptText2];
            [circularProgress startAnimation:self];
            [progressLabel setTitleWithMnemonic:
                                    @"Downloading Chameleon source code ..."];
            [scriptDownload executeAndReturnError:nil];
            [scriptDownload release];
            NSString *ret =
                [ShellTask executeShellCommandSynchronously:
                    @"egrep 'revision' ~/DL_Chameleon/DL_Log.txt"];
            NSString *tempLabeltext = [NSString stringWithFormat:
                                       @"Compiling... Chameleon Source: %@", ret];
            [progressLabel setTitleWithMnemonic:tempLabeltext];
            
            // Compile Chameleon source code
            path = [[NSBundle mainBundle] pathForResource:COMPILE_CHAMELEON 
                                                   ofType:@"sh"];
            NSString *scriptText3 = [NSString stringWithFormat:RUN_NO_ADMIN, 
                                     [path stringByAppendingFormat:@" %@", params]];
            scriptCompile = [[NSAppleScript alloc] initWithSource:scriptText3];
            [scriptCompile executeAndReturnError:nil];
            [scriptCompile release];
            
            // Install Chameleon
            switch (sender.tag) {
                case EFI_INSTALL_BRANCHES:
                    params = [@"branches " stringByAppendingString:disk];
                    break;
                case EFI_INSTALL_CHAMELEON:
                    params = [@"trunk " stringByAppendingString:disk];
                    break;
                default:
                    break;
            }
            path = [[NSBundle mainBundle] pathForResource:INSTALL_CHAMELEON 
                                                   ofType:@"sh"];
            NSString *scriptText4 = [NSString stringWithFormat:AS_ADMIN, 
                                     [path stringByAppendingFormat:@" %@", params]];
            scriptInstallCham = [[NSAppleScript alloc] initWithSource:scriptText4];
            [progressLabel setTitleWithMnemonic:@"Install Chameleon ..."];
            [scriptInstallCham executeAndReturnError:nil];
            [scriptInstallCham release];
            
        }
        
        
        switch (sender.tag) {
			case EFI_BC:
				params = [@"EFI " stringByAppendingString:disk];
				break;
			case MBR_BC:
				params = @"Extra";
				break;
			default:
				break;
		}
        
        if (sender.tag > -1) {
            path = [[NSBundle mainBundle] pathForResource:MOUNT 
                                                   ofType:@"sh"];
            NSString *scriptText = [NSString stringWithFormat:AS_ADMIN, 
                                    [path stringByAppendingFormat:@" %@", params]];
            scriptMount = [[NSAppleScript alloc] initWithSource:scriptText];
            
            [circularProgress startAnimation:self];
            switch (sender.tag) {
                case EFI_BC:
                    [progressLabel setTitleWithMnemonic:@"Mounting the EFI Partition ..."];
                    break;
                case MBR_BC:
                    [progressLabel setTitleWithMnemonic:@"Open the Extra Folder ..."];
                    break;
                default:
                    break;
            }
            
            [scriptMount executeAndReturnError:nil];
            [scriptMount release];
        }
        [circularProgress stopAnimation:self];
        [progressLabel setTitleWithMnemonic:@""];
        
		[self performSelectorOnMainThread:@selector(setAsyncWorkers:) 
							   withObject:0 waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(setMounted:) 
							   withObject:[NSNumber numberWithBool:YES] 
							waitUntilDone:YES];
		
		// set attachedWindow,
        // and button title change.
        float tempY = 0;
        int side = 2;
		switch (sender.tag) {
            case EFI_INSTALL_CHAMELEON:
            case EFI_INSTALL_BRANCHES:
                sender.title = @"Finish";
                tempY = 42.0;
                break;
            case EFI_BC:
				sender.title = @"Finish";
                tempY = 232.0;
				break;
			case MBR_BC:
				sender.title = @"Finish";
                tempY = 292.0;
				break;
			default:
				break;
		}
        
        if (!attachedWindow) {
            NSPoint buttonPoint = NSMakePoint(NSMidX([sender frame]),
                                              NSMidY([sender frame])+tempY);
            attachedWindow = [[MAAttachedWindow alloc] initWithView:view 
                                                    attachedToPoint:buttonPoint 
                                                           inWindow:[sender window]
                                                             onSide:side 
                                                         atDistance:95.0f];
            // set border color
            NSColor *rgbColor = [NSColor colorWithCalibratedRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
            [attachedWindow setBorderColor:rgbColor];
            //set text Field color
            rgbColor = [NSColor colorWithCalibratedRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
            [textField setTextColor:rgbColor];
            
            // set background color
            rgbColor = [NSColor colorWithCalibratedRed:0.95f green:0.95f blue:0.95f alpha:0.9f];
            [attachedWindow setBackgroundColor:rgbColor];
            
            //[attachedWindow setViewMargin:2.0f];
            [attachedWindow setBorderWidth:0.2f];
            //[attachedWindow setCornerRadius:8.0f];
            //[attachedWindow setHasArrow:1];
            //[attachedWindow setDrawsRoundCornerBesideArrow:1];
            //[attachedWindow setArrowBaseWidth:20.0f];
            //[attachedWindow setArrowHeight:18.0f];
            
            [[sender window] addChildWindow:attachedWindow ordered:NSWindowAbove];
        } else {
            [[sender window] removeChildWindow:attachedWindow];
            [attachedWindow orderOut:self];
            [attachedWindow release];
            attachedWindow = nil;
        } 
        // ...
        
		
	} else if([sender state] == NSOffState || sender.tag > 1) {
        // close attachedWindow
        if (attachedWindow) {
            [[sender window] removeChildWindow:attachedWindow];
            [attachedWindow orderOut:self];
            [attachedWindow release];
            attachedWindow = nil;
        }
        // ...
		switch (sender.tag) {
			case EFI_BC:
            case EFI_INSTALL_CHAMELEON:
            case EFI_INSTALL_BRANCHES:
				toRun = REBUILD_CACHE;
				params = [@"EFI " stringByAppendingString:disk];
				break;
			case MBR_BC:
				toRun = REBUILD_CACHE;
				params = @"Extra";
				break;
            case SLE_MKEXT:
                toRun = REBUILD_CACHE;
				params = @"SLE";
                break;
			case EFI_RESTORE:
				toRun = RESTORE;
				params = [@"EFI " stringByAppendingString:disk];
				break;
			case MBR_RESTORE:
				toRun = RESTORE;
				params = @"Extra";
				break;
            case EFI_FORMAT:
                toRun = FORMAT_HFS;
                params = disk;
                break;
			default:
				break;
		}
#ifdef DEBUG
		NSLog(@"%@", toRun);
#endif
		path = [[NSBundle mainBundle] pathForResource:toRun 
											   ofType:@"sh"];
		NSString *scriptText = [NSString stringWithFormat:AS_ADMIN, 
								[path stringByAppendingFormat:@" %@", params]];
		scriptRun = [[NSAppleScript alloc] initWithSource:scriptText];
		
		switch (sender.tag) {
            case EFI_BC:
            case MBR_BC:
            case SLE_MKEXT:
            case EFI_INSTALL_CHAMELEON:
            case EFI_INSTALL_BRANCHES:
                [progressLabel setTitleWithMnemonic:@"Rebuilding cache ..."];
                break;
            case EFI_RESTORE:
            case MBR_RESTORE:
                [progressLabel setTitleWithMnemonic:@"Restore and rebuilding cache ..."];
                break;
            case EFI_FORMAT:
                [progressLabel setTitleWithMnemonic:@"Formatting the EFI Partition ..."];
                break;
            default:
                break;
        }
        
        [circularProgress startAnimation:self];
        
		[scriptRun executeAndReturnError:nil];
        [scriptRun release];
        
        [circularProgress stopAnimation:self];
        [progressLabel setTitleWithMnemonic:@"Done!"];
        
		[self performSelectorOnMainThread:@selector(setAsyncWorkers:) 
							   withObject:0 waitUntilDone:NO];
        
        if (sender.tag < 10) {
            [self performSelectorOnMainThread:@selector(askReboot)
							       withObject:nil waitUntilDone:YES];
        }
        
		[self performSelectorOnMainThread:@selector(setMounted:) 
							   withObject:[NSNumber numberWithBool:NO]
							waitUntilDone:YES];
		
		// Button title change
		switch (sender.tag) {
            case EFI_INSTALL_CHAMELEON:
                sender.title = @"Install";
                break;
            case EFI_INSTALL_BRANCHES:
                sender.title = @"Install";
                break;
			case EFI_BC:
				sender.title = @"Change";
				break;
			case MBR_BC:
				sender.title = @"Change";
				break;
			case EFI_RESTORE:
				break;
			case MBR_RESTORE:
				break;
			default:
				break;
		}
	}
    
    [pool release];
}

- (void)setMounted:(NSNumber *)b
{
	mounted = [b boolValue];
}

#pragma mark NSAlerts

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode
		contextInfo:(void *)contextInfo
{
	//NSDictionary *errorDict = nil;
	if(returnCode == NSAlertSecondButtonReturn) {
#ifdef DEBUG
		NSLog(@"Rebooting!");
#endif
		NSAppleScript *script = [[NSAppleScript alloc] initWithSource:RESTART];
		[script executeAndReturnError:nil];
        [script release];
	} 
}

- (void)askReboot
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Later"];
	[alert addButtonWithTitle:@"Reboot Now"];
	[alert setMessageText:@"Reboot?"];
	[alert setInformativeText:@"Please reboot for changes to take effect."];
	[alert setAlertStyle:NSInformationalAlertStyle];
	
	[alert beginSheetModalForWindow:window
					  modalDelegate:self 
					 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
						contextInfo:nil];
    [alert release];
}

- (void)makeAlertWithMessage:(NSString *)message andText:(NSString *)text
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Ok"];
	[alert setMessageText:message];
	[alert setInformativeText:text];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	[alert beginSheetModalForWindow:window
					  modalDelegate:self 
					 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
						contextInfo:nil];
    [alert release];
}

#pragma mark NSMenu Delegate

- (NSInteger)numberOfItemsInMenu:(NSMenu *)nsmenu
{
	return [self.disks count];
}

- (BOOL)menu:(NSMenu *)nsmenu 
  updateItem:(NSMenuItem *)item 
	 atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel
{
	item.title = [self.disks objectAtIndex:index];
	item.target = self;
	item.action = @selector(swapDisk:);
	return YES;
}

#pragma mark NSApplication Delegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

@end
