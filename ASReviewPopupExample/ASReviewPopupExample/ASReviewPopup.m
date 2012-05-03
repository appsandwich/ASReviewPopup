//
//  ASReviewPopup.m
//


#import "ASReviewPopup.h"

static ASReviewPopup *sharedPopup = nil;


@implementation ASReviewPopup

@synthesize appName;
@synthesize numberOfDaysBeforeShowingPopup;
@synthesize popupFrequency;
@synthesize appStoreURL;
@synthesize alertTitle;
@synthesize alertMessage;
@synthesize alertReviewButton;
@synthesize alertCancelButton;

-(id)init {
    
	if (self = [super init]) {
        
		self.popupFrequency = ASReviewPopupFrequencyMinorVersion;
		self.appStoreURL = nil;
		self.alertTitle = nil;
		self.alertMessage = nil;
		self.alertReviewButton = nil;
		self.alertCancelButton = nil;
		self.numberOfDaysBeforeShowingPopup = 14;
	}
	
	return self;
}


-(void)dealloc {
    
	[appStoreURL release];
	[alertTitle release];
	[alertMessage release];
	[alertReviewButton release];
	[alertCancelButton release];
	[appName release];

	[super dealloc];
}


+(ASReviewPopup *)sharedPopup {
    
    @synchronized (self) {
        
        if (sharedPopup == nil)
			sharedPopup = [[ASReviewPopup alloc] init];
    }
	
    return sharedPopup;
}


+(id)allocWithZone:(NSZone *)zone {
    
    @synchronized (self) {
        
        if (sharedPopup == nil) {
            
            sharedPopup = [super allocWithZone:zone];
			
            return sharedPopup;  // assignment and return on first allocation
        }
    }
	
    return nil; // on subsequent allocation attempts return nil
}

-(id)copyWithZone:(NSZone *)zone {
    return self;
}

-(id)retain {
    return self;
}

-(unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

-(void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}


-(void)showAlertReminderAfterDaysHaveElapsed {
    
	if (self.appStoreURL) {
        
		BOOL shouldShowAlert = NO;
		
		BOOL firstRunAfterInstall = NO;
		
		
		// Break the version number down into separate components for comparison
		
		NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
		
		NSArray* versionComponents = [version componentsSeparatedByString:@"."];
		
		int minorMinorVersion = 0;
		int minorVersion = 0;
		int majorVersion = 0;
		
		if (3 == [versionComponents count])
			minorMinorVersion = [[versionComponents objectAtIndex:2] intValue];
		
		if (2 <= [versionComponents count])
			minorVersion = [[versionComponents objectAtIndex:1] intValue];
		
		if (1 <= [versionComponents count])
			majorVersion = [[versionComponents objectAtIndex:0] intValue];
		
		
		
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		
		NSString* previousInstallVersion = [defaults objectForKey:@"_VCReviewPopupInstallVersion"];
		
		NSDate* versionInstallDate = [defaults objectForKey:[NSString stringWithFormat:@"_VCReviewPopupInstallDate_%@", version]];
		
		// If no previous version was installed (i.e. no updates since the last clean install), then set now as the previous install date.
		if (!versionInstallDate) {
            
			firstRunAfterInstall = YES;
			versionInstallDate = [NSDate date];
			[defaults setObject:versionInstallDate forKey:[NSString stringWithFormat:@"_VCReviewPopupInstallDate_%@", version]];
		}
		
		// Was the alert shown for this version already?
		BOOL alertShownForThisVersion = [defaults boolForKey:[NSString stringWithFormat:@"_VCReviewPopupShown_%@", version]];
		
		// Has the alert ever been shown?
		BOOL alertShown = [defaults boolForKey:@"_VCReviewPopupShown"];
		
		
		int previousMinorMinorVersion = -1;
		int previousMinorVersion = -1;
		int previousMajorVersion = -1;
		
		// If there was a previous install, then break the version number down into components for comparison with the current version
		if ((previousInstallVersion) && ([previousInstallVersion length] > 0)) {
            
			NSArray* previousVersionComponents = [previousInstallVersion componentsSeparatedByString:@"."];
			
			if (3 == [previousVersionComponents count])
				previousMinorMinorVersion = [[previousVersionComponents objectAtIndex:2] intValue];
			
			if (2 <= [previousVersionComponents count])
				previousMinorVersion = [[previousVersionComponents objectAtIndex:1] intValue];
			
			if (1 <= [previousVersionComponents count])
				previousMajorVersion = [[previousVersionComponents objectAtIndex:0] intValue];
		}
		
		
		// Depending on the selected popup frequency, do some calculations...
		switch (self.popupFrequency)
		{
			case ASReviewPopupFrequencyNever:
				break;
				
			case ASReviewPopupFrequencyOnce:
				
				if (alertShown)		// If the alert has been shown at some stage, then we don't want to show it again.
					return;
				
				break;
				
			case ASReviewPopupFrequencyMajorVersion:
				
				// If the alert has not been shown for this version and the major version number has increased, 
				// then check how many days have passed since the install.
				if ((!alertShownForThisVersion) && (majorVersion > previousMajorVersion))
					shouldShowAlert = [self hasExceededNumberOfDaysForDate:versionInstallDate];
				
				break;
				
			case ASReviewPopupFrequencyMinorVersion:
				
				// If the alert has not been shown for this version and the minor version number has increased, 
				// then check how many days have passed since the install.
				if ((!alertShownForThisVersion) && (minorVersion > previousMinorVersion))
					shouldShowAlert = [self hasExceededNumberOfDaysForDate:versionInstallDate];
				
				break;
				
			case ASReviewPopupFrequencyMinorMinorVersion:
				
				// If the alert has not been shown for this version and the minor minor (e.g. 0.0.1 -> 0.0.2) version number has increased, 
				// then check how many days have passed since the install.
				if ((!alertShownForThisVersion) && (minorMinorVersion > previousMinorMinorVersion))
					shouldShowAlert = [self hasExceededNumberOfDaysForDate:versionInstallDate];
				
				break;
				
			case ASReviewPopupFrequencyAlways:
				shouldShowAlert = YES;			// Always show the alert.
				break;
		}
		
		
		if (shouldShowAlert) {		// We should show the alert 
            
			// Set some variables
			[defaults setBool:YES forKey:@"_VCReviewPopupShown"];
			[defaults setBool:YES forKey:[NSString stringWithFormat:@"_VCReviewPopupShown_%@", version]];
			[defaults setObject:version forKey:@"_VCReviewPopupInstallVersion"];
			
			if (!firstRunAfterInstall) {
                
				// Do some cleaning up - we don't want a huge amount of redundant entries in the user defaults
				[defaults setObject:nil forKey:[NSString stringWithFormat:@"_VCReviewPopupInstallDate_%@", previousInstallVersion]];
				[defaults setObject:nil forKey:[NSString stringWithFormat:@"_VCReviewPopupShown_%@", previousInstallVersion]];
			}
			
			// Makes this class thread-safe
			[self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:YES];
		}
		
		// Syncronise the defaults
		[defaults synchronize];
	}
}

-(void)showAlert {
    
	// Build & display the alert view
	
	if (!self.alertTitle)
		self.alertTitle = @"Like this App?";
	
	if (!self.alertMessage) {
        
		if (self.appName)
			self.alertMessage = [NSString stringWithFormat:@"Your feedback is essential to improving %@.\n\nPlease consider leaving a rating and/or review on the App Store.", self.appName];
		else
			self.alertMessage = [NSString stringWithFormat:@"Your feedback is essential to improving %@.\n\nPlease consider leaving a rating and/or review on the App Store.", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
	}
	
	if (!self.alertReviewButton)
		self.alertReviewButton = @"Rate App";
	
	if (!self.alertCancelButton)
		self.alertCancelButton = @"No, Thanks!";
	
	UIAlertView* reviewAlert = [[UIAlertView alloc] initWithTitle:self.alertTitle message:self.alertMessage delegate:self cancelButtonTitle:self.alertCancelButton otherButtonTitles:self.alertReviewButton, nil];
	reviewAlert.tag = kASReviewPopupAlertTag;
	[reviewAlert show];
	[reviewAlert release];
}


// Compare the input date to today and determine if the number of days passed is greater than the numberOfDaysBeforeShowingPopup variable
-(BOOL)hasExceededNumberOfDaysForDate:(NSDate *)date {
    
	if (date) {
        
		if ([[NSDate date] timeIntervalSinceDate:date] > (self.numberOfDaysBeforeShowingPopup * 86400.0))
			return YES;
	}
	
	return NO;
}


#pragma mark -
#pragma mark UIAlertViewDelegate method

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
	if (kASReviewPopupAlertTag == [alertView tag]) {
        
		if (buttonIndex == [alertView cancelButtonIndex]) {
            // Do nothing
		}
		else  {
            
			// Open the App Store URL
			if (self.appStoreURL) {
				[[UIApplication sharedApplication] openURL:self.appStoreURL];
			}
		}
	}
}

@end
