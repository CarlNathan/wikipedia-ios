//
//  UIViewController+WMFSearchButtonTests.m
//  Wikipedia
//
//  Created by Brian Gerstle on 12/11/15.
//  Copyright © 2015 Wikimedia Foundation. All rights reserved.
//

@import Quick;
@import Nimble;

#import "UIViewController+WMFSearch.h"
#import "WMFSearchViewController.h"
#import "MWKDataStore+TempDataStoreForEach.h"
#import "SessionSingleton.h"

@interface UIViewController (WMFSharedTestAccess)

+ (WMFSearchViewController*)sharedSearchViewController;
+ (void)                    wmf_clearSearchViewController;

@end

QuickSpecBegin(UIViewController_WMFSearchButtonTests)

#pragma mark - Utils

/**
 *  Dismiss the shared search view controller and wait for its view to leave the window.
 *
 *  The added wait is necessary because the view doesn't disappear synchronously even though the dismissal is not animated.
 */
dispatch_block_t dismissSearchAndWait = ^{
    [[UIViewController sharedSearchViewController] dismissViewControllerAnimated:NO completion:nil];

    [self expectationForPredicate:
     [NSPredicate predicateWithBlock:
      ^BOOL (UIViewController* _Nonnull evaluatedObject, NSDictionary < NSString*, id > * _Nullable bindings) {
        return evaluatedObject.view.window == nil;
    }]        evaluatedWithObject:[UIViewController sharedSearchViewController] handler:nil];
    [self waitForExpectationsWithTimeout:10 handler:nil];
};

/**
 *  Present the shared search view controller from a given presenting view controller and wait for its view to enter the window.
 *
 *  The added wait is necessary because the view doesn't appear synchronously even though the presentation is not animated.
 */
void (^ presentSearchFromVCAndWait)(UIViewController* presentingVC) = ^(UIViewController* presentingVC) {
    [presentingVC wmf_showSearchAnimated:NO];

    [self expectationForPredicate:
     [NSPredicate predicateWithBlock:
      ^BOOL (UIViewController* _Nonnull evaluatedObject, NSDictionary < NSString*, id > * _Nullable bindings) {
        return evaluatedObject.view.window != nil;
    }]        evaluatedWithObject:[UIViewController sharedSearchViewController] handler:nil];
    [self waitForExpectationsWithTimeout:10 handler:nil];
};

#pragma mark - Setup

/**
 *  Dummy @c UIViewController which is used to present search.
 *
 *  Recycled between tests.
 *
 *  @warning Do not call @c wmf_showSearch: directly on this or other view controllers during tests. Use the utility
 *           functions provided above to ensure the search view is in the window before proceeding.
 */
__block UIViewController* testVC = nil;

configureTempDataStoreForEach(tempDataStore, ^{
    [UIViewController wmf_setSearchButtonDataStore:tempDataStore];
    testVC = [UIViewController new];
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:testVC];
});

afterEach(^{
    // tear down search
    if ([UIViewController sharedSearchViewController].view.window) {
        dismissSearchAndWait();
    }
    [UIViewController wmf_clearSearchViewController];
    testVC.view.window.rootViewController = nil;
});

#pragma mark - Tests

describe(@"search button", ^{
    it(@"should have the same (correct) site when presented consecutively", ^{
        presentSearchFromVCAndWait(testVC);

        WMFSearchViewController* oldSearchVC = [UIViewController sharedSearchViewController];
        dismissSearchAndWait();

        presentSearchFromVCAndWait(testVC);

        expect([UIViewController sharedSearchViewController]).to(equal(oldSearchVC));

        expect([UIViewController sharedSearchViewController].searchSite).to(equal(oldSearchVC.searchSite));
    });

    it(@"should have correct site when presented after changes to search site", ^{
        presentSearchFromVCAndWait(testVC);

        WMFSearchViewController* oldSearchVC = [UIViewController sharedSearchViewController];

        dismissSearchAndWait();

        [[SessionSingleton sharedInstance] setSearchLanguage:
         [[[SessionSingleton sharedInstance] searchLanguage] stringByAppendingString:@"a"]];

        presentSearchFromVCAndWait(testVC);

        expect([UIViewController sharedSearchViewController]).toNot(equal(oldSearchVC));
    });

    it(@"should be presentable from different view controllers", ^{
        presentSearchFromVCAndWait(testVC);

        WMFSearchViewController* oldSearchVC = [UIViewController sharedSearchViewController];

        dismissSearchAndWait();

        UIViewController* otherTestVC = [UIViewController new];

        testVC.view.window.rootViewController = otherTestVC;

        presentSearchFromVCAndWait(otherTestVC);

        expect([UIViewController sharedSearchViewController]).to(equal(oldSearchVC));
    });
});

describe(@"global searchVC", ^{
    void (^ verifyGlobalVCOutOfWindowResetAfterNotificationNamed)(NSString*) = ^(NSString* notificationName) {
        presentSearchFromVCAndWait(testVC);

        expect([UIViewController sharedSearchViewController]).toNot(beNil());

        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];

        expect([UIViewController sharedSearchViewController]).to(beNil());
    };

    it(@"should be reset on memory warnings when it is not in the window", ^{
        verifyGlobalVCOutOfWindowResetAfterNotificationNamed(UIApplicationDidReceiveMemoryWarningNotification);
    });

    it(@"should reset when the app enters the background if it's not in the window", ^{
        verifyGlobalVCOutOfWindowResetAfterNotificationNamed(UIApplicationDidEnterBackgroundNotification);
    });
});

QuickSpecEnd
