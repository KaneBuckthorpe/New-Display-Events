#include <KBAppList/KBAppList.h>
#include <dispatch/dispatch.h>
#import <libactivator/libactivator.h>

@interface SpringBoard : NSObject
+ (id)sharedApplication;
- (BOOL)isShowingHomescreen;
- (BOOL)_atHomescreen;
@end

@interface SBUIController : NSObject
+ (id)sharedInstance;
- (BOOL)isAppSwitcherShowing;
@end

@interface SBLockScreenManager : NSObject
- (id)sharedInstance;
- (BOOL)isLockScreenVisible;
@end

@interface SBApplication : NSObject {
    NSString *_bundleIdentifier;
}
@property(nonatomic, readonly) NSString *bundleIdentifier;
@end

@interface NewDisplayDS : NSObject <LAEventDataSource>
@end

int iOSVersion = 11;
BOOL hasBeenHomescreen = NO;

static NSString *appGeneric = @"com.kaneb.appopen";

static NSString *homescreen = @"com.kaneb.homescreenopen";

static NSString *appSwitcher = @"com.kaneb.appswitcheropen";

static NSString *lockscreen = @"com.kaneb.lockscreenopen";

static NSString *incomingCall = @"com.kaneb.incomingcall";

static NewDisplayDS *newDisplayDS;

static NSArray *appList;

%hook SBCoverSheetPresentationManager
 - (void)_notifyDelegateDidDismiss {
    %orig;
    if ([[objc_getClass("SpringBoard") sharedApplication]
            isShowingHomescreen]) {

        LAEvent *homeScreenEvent =
            [LAEvent eventWithName:homescreen
                              mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:homeScreenEvent];

    } else {

        LAEvent *appEvent =
            [LAEvent eventWithName:appGeneric
                              mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:appEvent];
    }
}
%end

        %hook SpringBoard
-(void)applicationDidFinishLaunching : (id)application {
    %orig;
    appList = KBAppList.allApps;
    newDisplayDS = [[NewDisplayDS alloc] init];
}
- (void)frontDisplayDidChange:(id)newDisplay {
    %orig(newDisplay);

    if ([newDisplay isKindOfClass: %c(SBRemoteAlertAdapter)]) {
        LAEvent *incomingCallEvent =
            [LAEvent eventWithName:incomingCall
                              mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:incomingCallEvent];
    } else if ([[objc_getClass("SBLockScreenManager") sharedInstance]
                   isLockScreenVisible]) {

        LAEvent *lockScreenEvent =
            [LAEvent eventWithName:lockscreen
                              mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:lockScreenEvent];

    } else if ([[%c(SBUIController) sharedInstance] isAppSwitcherShowing]) {

        LAEvent *appSwitcherEvent =
            [LAEvent eventWithName:appSwitcher
                              mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:appSwitcherEvent];

    } else if ([newDisplay isKindOfClass: %c(SBApplication)]) {

        LAEvent *appEvent = [LAEvent
            eventWithName:[(SBApplication *)newDisplay bundleIdentifier]
                     mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:appEvent];

        if (!appEvent.handled) {
            LAEvent *appGenericEvent =
                [LAEvent eventWithName:appGeneric
                                  mode:[LASharedActivator currentEventMode]];
            [LASharedActivator sendEventToListener:appGenericEvent];
        }

    } else if ([newDisplay isKindOfClass: %c(SBLockScreenViewController)]) {

        LAEvent *lockScreenEvent =
            [LAEvent eventWithName:lockscreen
                              mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:lockScreenEvent];

    } else if ([newDisplay isKindOfClass: %c(SBDashBoardViewController)]) {

        LAEvent *lockScreenEvent =
            [LAEvent eventWithName:lockscreen
                              mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:lockScreenEvent];

    } else if (newDisplay == nil) {
        if (hasBeenHomescreen) {
            LAEvent *homeScreenEvent =
                [LAEvent eventWithName:homescreen
                                  mode:[LASharedActivator currentEventMode]];
            [LASharedActivator sendEventToListener:homeScreenEvent];

        } else {
            hasBeenHomescreen = YES;
        }
    }
}
%end

 @implementation NewDisplayDS
+ (void)load {
    @autoreleasepool {
        //  newDisplayDS = [[NewDisplayDS alloc] init];
    }
}

- (id)init {
    if ((self = [super init])) {
        /// registering events

        /// All Apps
        for (NSDictionary *appDict in appList) {

            [LASharedActivator
                registerEventDataSource:self
                           forEventName:[appDict valueForKey:@"bundleID"]];
        }

        /// Generic app
        [LASharedActivator registerEventDataSource:self
                                      forEventName:appGeneric];

        /// homescreen
        [LASharedActivator registerEventDataSource:self
                                      forEventName:homescreen];

        // appSwitcher
        [LASharedActivator registerEventDataSource:self
                                      forEventName:appSwitcher];

        /// lockscreen
        [LASharedActivator registerEventDataSource:self
                                      forEventName:lockscreen];

        /// incoming call
        [LASharedActivator registerEventDataSource:self
                                      forEventName:incomingCall];
    }
    return self;
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {

    NSPredicate *predicate = [NSPredicate
        predicateWithFormat:@"%K CONTAINS[cd] %@", @"bundleID", eventName];

    NSArray *apps = [appList filteredArrayUsingPredicate:predicate];

    if ([eventName isEqualToString:appGeneric]) {
        return @"App Opened";

    } else if ([eventName isEqualToString:homescreen]) {
        return @"Homescreen Opened";

    } else if ([eventName isEqualToString:appSwitcher]) {
        return @"App Switcher Open";

    } else if ([eventName isEqualToString:lockscreen]) {
        return @"LockScreen Opened";

    } else if ([eventName isEqualToString:incomingCall]) {
        return @"Incoming Call";
    } else if (apps.count > 0) {
        return [apps[0] valueForKey:@"name"];
    }

    return @" ";
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
    NSPredicate *predicate = [NSPredicate
        predicateWithFormat:@"%K CONTAINS[cd] %@", @"bundleID", eventName];

    NSArray *apps = [appList filteredArrayUsingPredicate:predicate];
    if (apps.count > 0) {
        return @"New Display App Events";
    } else {
        return @"New Display Events";
    }
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {

    NSPredicate *predicate = [NSPredicate
        predicateWithFormat:@"%K CONTAINS[cd] %@", @"bundleID", eventName];

    NSArray *apps = [appList filteredArrayUsingPredicate:predicate];

    if ([eventName isEqualToString:appGeneric]) {
        return @"App Opened";

    } else if ([eventName isEqualToString:homescreen]) {
        return @"Homescreen Opened";

    } else if ([eventName isEqualToString:appSwitcher]) {
        return @"App Switcher Open";

    } else if ([eventName isEqualToString:lockscreen]) {
        return @"LockScreen Opened";

    } else if ([eventName isEqualToString:incomingCall]) {
        return @"Incoming Call";
    } else if (apps.count > 0) {

        return [NSString
            stringWithFormat:@"%@ opened", [apps[0] valueForKey:@"name"]];
    }

    return @" ";
}

@end