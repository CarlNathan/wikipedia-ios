
#import <Mantle/Mantle.h>

typedef NS_ENUM (NSUInteger, WMFSettingsMenuItemDisclosureType){
    WMFSettingsMenuItemDisclosureType_None,
    WMFSettingsMenuItemDisclosureType_ViewController,
    WMFSettingsMenuItemDisclosureType_ViewControllerWithDisclosureText,
    WMFSettingsMenuItemDisclosureType_ExternalLink,
    WMFSettingsMenuItemDisclosureType_Switch
};

typedef NS_ENUM (NSUInteger, WMFSettingsMenuItemType) {
    WMFSettingsMenuItemType_Login,
    WMFSettingsMenuItemType_Support,
    WMFSettingsMenuItemType_SearchLanguage,
    WMFSettingsMenuItemType_SearchLanguageBarVisibility,
    WMFSettingsMenuItemType_PrivacyPolicy,
    WMFSettingsMenuItemType_Terms,
    WMFSettingsMenuItemType_SendUsageReports,
    WMFSettingsMenuItemType_ZeroWarnWhenLeaving,
    WMFSettingsMenuItemType_ZeroFAQ,
    WMFSettingsMenuItemType_RateApp,
    WMFSettingsMenuItemType_SendFeedback,
    WMFSettingsMenuItemType_About,
    WMFSettingsMenuItemType_FAQ,
    WMFSettingsMenuItemType_DebugCrash,
    WMFSettingsMenuItemType_DevSettings
};

@interface WMFSettingsMenuItem : MTLModel

@property (nonatomic, assign, readonly) WMFSettingsMenuItemType type;

@property (nonatomic, copy, readonly) NSString* title;

@property (nonatomic, copy, readonly) NSString* iconName;

@property (nonatomic, copy, readonly) UIColor* iconColor;

@property (nonatomic, assign, readonly) WMFSettingsMenuItemDisclosureType disclosureType;

@property (nonatomic, copy, readonly) NSString* disclosureText;

@property (nonatomic, assign, readwrite) BOOL isSwitchOn;

+ (WMFSettingsMenuItem*)itemForType:(WMFSettingsMenuItemType)type;

- (instancetype)initWithType:(WMFSettingsMenuItemType)type
                       title:(NSString*)title
                    iconName:(NSString*)iconName
                   iconColor:(UIColor*)iconColor
              disclosureType:(WMFSettingsMenuItemDisclosureType)disclosureType
              disclosureText:(NSString*)disclosureText
                  isSwitchOn:(BOOL)isSwitchOn;
@end
