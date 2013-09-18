//
//  NSString+URLEncoding.m
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 9/9/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import "NSString+URLEncoding.h"
@implementation NSString (URLEncoding)
-(NSString *)urlEncode {
        NSMutableString * output = [NSMutableString string];
        const unsigned char * source = (const unsigned char *)[self UTF8String];
        int sourceLen = strlen((const char *)source);
        for (int i = 0; i < sourceLen; ++i) {
            const unsigned char thisChar = source[i];
            if (thisChar == ' '){
                [output appendString:@"%20"];
            } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                       (thisChar >= 'a' && thisChar <= 'z') ||
                       (thisChar >= 'A' && thisChar <= 'Z') ||
                       (thisChar >= '0' && thisChar <= '9')) {
                [output appendFormat:@"%c", thisChar];
            } else {
                [output appendFormat:@"%%%02X", thisChar];
            }
        }
        return output;

}
@end
