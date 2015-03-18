//
// AppDelegate.m
//
// Copyright (c) 2015 , Dan Volz @djvolz
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

// If you want to use any of the UI components, uncomment this line
#import <ParseUI/ParseUI.h>

// If you are using Facebook, uncomment this line
// #import <ParseFacebookUtils/PFFacebookUtils.h>

// If you want to use Crash Reporting - uncomment this line
#import <ParseCrashReporting/ParseCrashReporting.h>

#import "AppDelegate.h"
#import <Parse/Parse.h>

//#import "ChooseExerciseViewController.h"

#pragma mark -
#pragma mark UIApplicationDelegate

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
//
//    self.window.rootViewController = [ChooseExerciseViewController new];
    
    
    
//     [Optional] Power your app with Local Datastore. For more info, go to
//     https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"jix4a7ziO3LTyuL4PZ3IyyRUA7DmnwRO0zvka2z5"
                  clientKey:@"OTzCw43KgIQDE6LvPC3ffycj95V1EAunMTmEtHcI"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

//    [ParseCrashReporting enable];
    
    
    
    [PFUser enableAutomaticUser];
  
//
//    PFACL *defaultACL = [PFACL ACL];
//    
//    // If you would like all objects to be private by default, remove this line.
//    [defaultACL setPublicReadAccess:YES];
//    
//    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    

//    if (application.applicationState != UIApplicationStateBackground) {
//        // Track an app open here if we launch with a push, unless
//        // "content_available" was used to trigger a background push (introduced in iOS 7).
//        // In that case, we skip tracking here to avoid double counting the app-open.
//        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
//        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
//        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
//            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
//        }
//    }
//    
////#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
//    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
//                                                        UIUserNotificationTypeBadge |
//                                                        UIUserNotificationTypeSound);
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
//                                                                                 categories:nil];
//        [application registerUserNotificationSettings:settings];
//        [application registerForRemoteNotifications];
//    } //else
//#endif
//    {
//        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
//                                                         UIRemoteNotificationTypeAlert |
//                                                         UIRemoteNotificationTypeSound)];
//    }

    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//#pragma mark Push Notifications
//
//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    [currentInstallation setDeviceTokenFromData:deviceToken];
//    [currentInstallation saveInBackground];
//    
//    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
//        } else {
//            NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
//        }
//    }];
//}
//
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    if (error.code == 3010) {
//        NSLog(@"Push notifications are not supported in the iOS Simulator.");
//    } else {
//        // show some alert or otherwise handle the failure to register.
//        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
//    }
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    [PFPush handlePush:userInfo];
//    
//    if (application.applicationState == UIApplicationStateInactive) {
//        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
//    }
//}
//
/////////////////////////////////////////////////////////////
//// Push Notifications with Background App Refresh
/////////////////////////////////////////////////////////////
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    if (application.applicationState == UIApplicationStateInactive) {
//        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
//    }
//}


@end
