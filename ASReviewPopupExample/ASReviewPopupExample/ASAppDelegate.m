//
//  ASAppDelegate.m
//  ASReviewPopupExample
//

#import "ASAppDelegate.h"
#import "ASReviewPopup.h"

@implementation ASAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
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
    
    // Show the popup for every major update of the app
    [[ASReviewPopup sharedPopup] setPopupFrequency:ASReviewPopupFrequencyMajorVersion];     // You can set this to ASReviewPopupFrequencyAlways to force the alert to always show when testing
    
    // Set the number of days to wait before showing the alert
    [[ASReviewPopup sharedPopup] setNumberOfDaysBeforeShowingPopup:7];
    
    // Set the App Store URL - replace the "455519398" with your own app's ID (found in iTunes Connect)
    [[ASReviewPopup sharedPopup] setAppStoreURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=455519398"]];
    
    // Call to trigger
    [[ASReviewPopup sharedPopup] showAlertReminderAfterDaysHaveElapsed];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
