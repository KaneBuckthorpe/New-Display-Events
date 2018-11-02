#include <dispatch/dispatch.h>
#import <libactivator/libactivator.h>

int iOSVersion = 11;
BOOL hasBeenHomescreen = NO;

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

% hook SBCoverSheetPresentationManager - (void)_notifyDelegateDidDismiss {
    % orig;
    if ([[objc_getClass("SpringBoard") sharedApplication]
         isShowingHomescreen]) {
        
        LAEvent *homeScreenEvent =
        [LAEvent eventWithName:@"com.kaneb.homescreenopen"
                          mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:homeScreenEvent];
        
    } else {
        
        LAEvent *appEvent =
        [LAEvent eventWithName:@"com.kaneb.appopen"
                          mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:appEvent];
    }
}
% end

% hook SpringBoard -
(void)frontDisplayDidChange : (id)newDisplay {
    % orig(newDisplay);
    
    if ([newDisplay isKindOfClass: % c(SBRemoteAlertAdapter)]) {
        LAEvent *incomingCallEvent =
        [LAEvent eventWithName:@"com.kaneb.incomingcall"
                          mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:incomingCallEvent];
    } else if ([[objc_getClass("SBLockScreenManager") sharedInstance]
                isLockScreenVisible]) {
        
        LAEvent *lockScreenEvent =
        [LAEvent eventWithName:@"com.kaneb.lockscreenopen"
                          mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:lockScreenEvent];
        
    } else if ([[% c(SBUIController) sharedInstance] isAppSwitcherShowing]) {
        
        LAEvent *appSwitcherEvent =
        [LAEvent eventWithName:@"com.kaneb.appswitcheropen"
                          mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:appSwitcherEvent];
        
    } else if ([newDisplay isKindOfClass: % c(SBApplication)]) {
        
        LAEvent *appEvent =
        [LAEvent eventWithName:@"com.kaneb.appopen"
                          mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:appEvent];
        
    } else if ([newDisplay isKindOfClass: % c(SBLockScreenViewController)]) {
        
        LAEvent *lockScreenEvent =
        [LAEvent eventWithName:@"com.kaneb.lockscreenopen"
                          mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:lockScreenEvent];
        
    } else if ([newDisplay isKindOfClass: % c(SBDashBoardViewController)]) {
        
        LAEvent *lockScreenEvent =
        [LAEvent eventWithName:@"com.kaneb.lockscreenopen"
                          mode:[LASharedActivator currentEventMode]];
        [LASharedActivator sendEventToListener:lockScreenEvent];
        
    } else if (newDisplay == nil) {
        if (hasBeenHomescreen) {
            LAEvent *homeScreenEvent =
            [LAEvent eventWithName:@"com.kaneb.homescreenopen"
                              mode:[LASharedActivator currentEventMode]];
            [LASharedActivator sendEventToListener:homeScreenEvent];
            
        } else {
            hasBeenHomescreen = YES;
        }
    }
}
% end

@interface NewDisplayDS : NSObject<LAEventDataSource>
@end

@implementation NewDisplayDS
static NSString *appGeneric = @"com.kaneb.appopen";

static NSString *homescreen = @"com.kaneb.homescreenopen";

static NSString *appSwitcher = @"com.kaneb.appswitcheropen";

static NSString *lockscreen = @"com.kaneb.lockscreenopen";

static NSString *incomingCall = @"com.kaneb.incomingcall";

static NewDisplayDS *newDisplayDS;

+ (void)load {
    @autoreleasepool {
        newDisplayDS = [[NewDisplayDS alloc] init];
    }
}

- (id)init {
    if ((self = [super init])) {
        /// registering events
        /// app
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

- (void)dealloc {
    /// unregistered events
    // app
    [LASharedActivator unregisterEventDataSourceWithEventName:appGeneric];
    
    /// homescreen
    [LASharedActivator unregisterEventDataSourceWithEventName:homescreen];
    
    /// appSwitcher
    [LASharedActivator unregisterEventDataSourceWithEventName:appSwitcher];
    
    /// lockscreen
    [LASharedActivator unregisterEventDataSourceWithEventName:lockscreen];
    
    /// incoming call
    [LASharedActivator unregisterEventDataSourceWithEventName:incomingCall];
    [super dealloc];
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
    
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
    }
    return @" ";
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
    return @"New Display Events";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
    
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
    }
    return @" ";
}

@end
