
#import "WMFBaseExploreSectionController.h"
@import CoreLocation;
@class WMFLocationManager, MWKSite, MWKDataStore;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const WMFNearbySectionIdentifier;

@interface WMFNearbySectionController : WMFBaseExploreSectionController
    <WMFExploreSectionController, WMFTitleProviding, WMFMoreFooterProviding, WMFAnalyticsContentTypeProviding>

- (instancetype)initWithLocation:(CLLocation*)location
                       placemark:(nullable CLPlacemark*)placemark
                            site:(MWKSite*)site
                       dataStore:(MWKDataStore*)dataStore NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) MWKSite* searchSite;
@property (nonatomic, strong, readonly) CLLocation* location;
@property (nonatomic, strong, readonly) CLPlacemark* placemark;

@end

NS_ASSUME_NONNULL_END