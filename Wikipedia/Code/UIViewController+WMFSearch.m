
#import "UIViewController+WMFSearch.h"
#import "WMFSearchViewController.h"
#import <BlocksKit/UIBarButtonItem+BlocksKit.h>
#import "SessionSingleton.h"
#import "MWKSite.h"


NS_ASSUME_NONNULL_BEGIN

@implementation UIViewController (WMFSearchButton)

static MWKDataStore * _dataStore = nil;
static WMFSearchViewController* _sharedSearchViewController = nil;

+ (void)wmf_setSearchButtonDataStore:(MWKDataStore*)dataStore {
    NSParameterAssert(dataStore);
    _dataStore = dataStore;
    [self wmf_clearSearchViewController];
}

+ (void)wmf_clearSearchViewController {
    _sharedSearchViewController = nil;
}

+ (WMFSearchViewController*)sharedSearchViewController {
    return _sharedSearchViewController;
}

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(wmfSearchButton_applicationDidEnterBackgroundWithNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(wmfSearchButton_applicationDidReceiveMemoryWarningWithNotification:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

+ (void)wmfSearchButton_applicationDidEnterBackgroundWithNotification:(NSNotification*)note {
    [self wmf_clearSearchViewController];
}

+ (void)wmfSearchButton_applicationDidReceiveMemoryWarningWithNotification:(NSNotification*)note {
    [self wmf_clearSearchViewController];
}

- (UIBarButtonItem*)wmf_searchBarButtonItem {
    @weakify(self);
    return [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"search"]
                                               style:UIBarButtonItemStylePlain
                                             handler:^(id sender) {
        @strongify(self);
        if (!self) {
            return;
        }

        [self wmf_showSearchAnimated:YES];
    }];
}

- (void)wmf_showSearchAnimated:(BOOL)animated {
    NSParameterAssert(_dataStore);
    MWKSite* searchSite = [[SessionSingleton sharedInstance] searchSite];

    if (![searchSite isEqual:_sharedSearchViewController.searchSite]) {
        WMFSearchViewController* searchVC =
            [WMFSearchViewController searchViewControllerWithSite:searchSite
                                                        dataStore:_dataStore];
        _sharedSearchViewController = searchVC;
    }
    [self presentViewController:_sharedSearchViewController animated:animated completion:nil];
}

@end

NS_ASSUME_NONNULL_END
