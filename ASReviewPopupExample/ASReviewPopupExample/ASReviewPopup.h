//
//  ASReviewPopup.h
//


#define kASReviewPopupAlertTag              1000

#import <Foundation/Foundation.h>

typedef enum {
    ASReviewPopupFrequencyNever,				// Never show the alert - if you're using this option, then why the heck are you implementing this?
    ASReviewPopupFrequencyOnce,					// Alert appears only once during the app's install lifespan
    ASReviewPopupFrequencyMajorVersion,			// 1.0 to 2.0
	ASReviewPopupFrequencyMinorVersion,			// e.g. 0.1 to 0.2
	ASReviewPopupFrequencyMinorMinorVersion,	// e.g. 0.0.1 to 0.0.2
	ASReviewPopupFrequencyAlways
} ASReviewPopupFrequency;


@interface ASReviewPopup : NSObject <UIAlertViewDelegate>

@property (nonatomic, copy) NSString *appName;
@property (nonatomic, assign) int numberOfDaysBeforeShowingPopup;
@property (nonatomic, assign) ASReviewPopupFrequency popupFrequency;
@property (nonatomic, retain) NSURL *appStoreURL;
@property (nonatomic, copy) NSString *alertTitle;
@property (nonatomic, copy) NSString *alertMessage;
@property (nonatomic, copy) NSString *alertReviewButton;
@property (nonatomic, copy) NSString *alertCancelButton;


+(ASReviewPopup *)sharedPopup;

-(void)showAlertReminderAfterDaysHaveElapsed;
-(void)showAlert;

-(BOOL)hasExceededNumberOfDaysForDate:(NSDate *)date;

@end
