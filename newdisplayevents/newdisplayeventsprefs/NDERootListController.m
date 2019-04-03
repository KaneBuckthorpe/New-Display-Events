#include "NDERootListController.h"
#include <KBAppList/KBAppList.h>
#import <Preferences/PSSpecifier.h>
#include <libactivator/LASettingsViewController.h>

@implementation NDERootListController

- (NSArray *)specifiers {
    if (!_specifiers) {

        NSMutableArray *tempSpec = [NSMutableArray new];

        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];

        NSArray *appList = KBAppList.allApps;

        int groupAppsIndex = [self indexOfSpecifierID:@"Apps"] + 1;
        NSIndexSet *appsSet = [[NSIndexSet alloc]
            initWithIndexesInRange:NSMakeRange(groupAppsIndex, appList.count)];

        for (NSDictionary *appDict in appList) {
            NSString *appName = [appDict valueForKey:@"name"];
            NSString *bundleID = [appDict valueForKey:@"bundleID"];

            PSSpecifier *specifier = [PSSpecifier
                preferenceSpecifierNamed:appName
                                  target:self
                                     set:@selector(setPreferenceValue:
                                                            specifier:)
                                     get:@selector(readPreferenceValue:)
                                  detail:nil
                                    cell:1
                                    edit:Nil];
            [specifier setProperty:bundleID forKey:@"activatorEvent"];
            [specifier setProperty:@"LibActivator" forKey:@"bundle"];
            [specifier setProperty:@"1" forKey:@"isController"];
            [specifier setProperty:appName forKey:@"id"];
            [specifier setProperty:@"PSLnkCell" forKey:@"cell"];
            specifier.controllerLoadAction =
                @selector(pushViewControllerForEvent:);
            [tempSpec addObject:specifier];
        }
        NSLog(@"Apps index:%d", groupAppsIndex);
        NSSortDescriptor *sortDescriptor =
            [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [_specifiers
            insertObjects:[tempSpec
                              sortedArrayUsingDescriptors:@[ sortDescriptor ]]
                atIndexes:appsSet];
    }

    return _specifiers;
}
- (void)pushViewControllerForEvent:(PSSpecifier *)specifier {
    NSArray *modes = [NSArray
        arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
    NSString *eventName = [specifier propertyForKey:@"activatorEvent"];

    LAEventSettingsController *showVC =
        [[LAEventSettingsController alloc] initWithModes:modes
                                               eventName:eventName];

    [self.navigationController pushViewController:showVC animated:YES];
}
- (CGSize)cellCornerRadii {

    return CGSizeMake(10, 10);
}
@end