/**
 * Permissions
 *
 * Created by Ben Bahrenburg
 * Copyright (c) 2014 bencoding.com. All rights reserved.
 */

#import "BencodingPermissionsModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <EventKit/EventKit.h>

@implementation BencodingPermissionsModule

int const kBCXPermission_Unknown = 1;
int const kBCXPermission_Authorized = 2;
int const kBCXPermission_Denied = 3;
int const kBCXPermission_NotSupported = 4;

MAKE_SYSTEM_UINT(PERMISSION_UNKNOWN, kBCXPermission_Unknown);
MAKE_SYSTEM_UINT(PERMISSION_AUTHORIZED, kBCXPermission_Authorized);
MAKE_SYSTEM_UINT(PERMISSION_DENIED, kBCXPermission_Denied);
MAKE_SYSTEM_UINT(PERMISSION_NOT_SUPPORTED, kBCXPermission_NotSupported);

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"01c854d7-8fc7-4f33-8aed-b0c9404d52ee";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"bencoding.permissions";
}

#pragma mark Lifecycle

-(void)startup
{
	[super startup];
}

-(void)shutdown:(id)sender
{
	[super shutdown:sender];
}

#pragma mark Cleanup


#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	[super didReceiveMemoryWarning:notification];
}


#pragma Public APIs

-(NSNumber*)checkCalendar:(id)unused
{
    EKAuthorizationStatus authorizationStatus =
    [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (authorizationStatus) {
        case EKAuthorizationStatusAuthorized:
            return NUMINT(kBCXPermission_Authorized);
            
        case EKAuthorizationStatusNotDetermined:
            return NUMINT(kBCXPermission_Unknown);

        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied:
            return NUMINT(kBCXPermission_Denied);
    }
}

-(NSNumber*)checkReminders:(id)unused
{
    EKAuthorizationStatus authorizationStatus =
    [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (authorizationStatus) {
        case EKAuthorizationStatusAuthorized:
            return NUMINT(kBCXPermission_Authorized);
            
        case EKAuthorizationStatusNotDetermined:
            return NUMINT(kBCXPermission_Unknown);
            
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied:
            return NUMINT(kBCXPermission_Denied);
    }
}

-(NSNumber*)checkContacts:(id)unused
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status) {
        case kABAuthorizationStatusAuthorized:
            return NUMINT(kBCXPermission_Authorized);
            
        case kABAuthorizationStatusRestricted:
        case kABAuthorizationStatusDenied:
            return NUMINT(kBCXPermission_Denied);
            
        case kABAuthorizationStatusNotDetermined:
            return NUMINT(kBCXPermission_Unknown);
    }
}

-(NSNumber*)checkLocation:(id)unused
{
    CLAuthorizationStatus systemState = [CLLocationManager authorizationStatus];
    
    switch (systemState) {
#ifndef __IPHONE_8_0
        case kCLAuthorizationStatusAuthorized:
            return NUMINT(kBCXPermission_Authorized);
#else
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return NUMINT(kBCXPermission_Authorized);
#endif
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            return NUMINT(kBCXPermission_Denied);
            
        default:
            return NUMINT(kBCXPermission_Unknown);
    }
    
}

-(NSNumber*)checkMicrophone:(id)unused
{
    if ([TiUtils isIOS8OrGreater]) {
        AVAudioSession * audioSession = [AVAudioSession sharedInstance];
        AVAudioSessionRecordPermission systemState = [audioSession recordPermission];
        switch (systemState) {
            case AVAudioSessionRecordPermissionDenied:
                return NUMINT(kBCXPermission_Denied);
            case AVAudioSessionRecordPermissionGranted:
                return NUMINT(kBCXPermission_Authorized);
            case AVAudioSessionRecordPermissionUndetermined:
                return NUMINT(kBCXPermission_Unknown);
        }
    }else{
        return NUMINT(kBCXPermission_Authorized);
    }
    
}

-(NSNumber*)checkNotifications:(NSNumber*)permission
{
    //If not iOS 8
    if ([TiUtils isIOS8OrGreater]) {
        return NUMINT(kBCXPermission_Authorized);
    }
    
    UIUserNotificationSettings *noticationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    if (!noticationSettings || (noticationSettings.types == UIUserNotificationTypeNone)) {
        return NUMINT(kBCXPermission_Unknown);
    }
    
    if(noticationSettings.types == UIUserNotificationTypeBadge ||
       noticationSettings.types == UIUserNotificationTypeSound ||
       noticationSettings.types == UIUserNotificationTypeAlert){
        return NUMINT(kBCXPermission_Authorized);
    }
    
    return NUMINT(kBCXPermission_Unknown);
    
}

-(NSNumber*)checkPhotoLibrary:(id)unused
{
    ALAuthorizationStatus systemState = [ALAssetsLibrary authorizationStatus];
    switch (systemState) {
        case ALAuthorizationStatusAuthorized:
            return NUMINT(kBCXPermission_Authorized);
        case ALAuthorizationStatusDenied:
        case ALAuthorizationStatusRestricted:
            return NUMINT(kBCXPermission_Denied);
        default:
            return NUMINT(kBCXPermission_Unknown);
    }
}

-(NSNumber*)checkCamera:(id)unused
{
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
    if (!captureInput) {
        return NUMINT(kBCXPermission_NotSupported);
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            return NUMINT(kBCXPermission_Authorized);
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            return NUMINT(kBCXPermission_Denied);
        case AVAuthorizationStatusNotDetermined:
            return NUMINT(kBCXPermission_Unknown);
        default:
            return NUMINT(kBCXPermission_Unknown);
    }
}

@end
