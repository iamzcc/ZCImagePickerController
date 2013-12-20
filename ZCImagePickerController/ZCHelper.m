
#import "ZCHelper.h"

@implementation ZCHelper

+ (BOOL)isPad {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)isPhone {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)isiOS7orLater {
    float systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (systemVersion >= 7.0) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
