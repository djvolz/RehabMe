//
//  UIColor+HexString.h
//
//  Created by Micah Hainline
//  http://stackoverflow.com/users/590840/micah-hainline
//

#import <UIKit/UIKit.h>

//#define REHABME_GREEN @"44DB5E"
#define REHABME_GREEN @"3BB35E"

@interface UIColor (HexString)

+ (UIColor *) colorWithHexString: (NSString *) hexString;

@end
