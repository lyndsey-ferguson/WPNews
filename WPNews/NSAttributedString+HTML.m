//
//  NSAttributedString+HTML.m
//  WPNews
//
//  Created by Lyndsey on 1/16/16.
//  Copyright © 2016 Lyndsey Ferguson Software. All rights reserved.
//

#import "NSAttributedString+HTML.h"

@implementation NSAttributedString (HTML)
+ (instancetype)attributedStringFromHTMLString:(NSString*)htmlString {
    NSData* htmlStringData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithData:htmlStringData
                                            options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                      NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                 documentAttributes:nil
                                              error:&error];
    if (!attributedString) {
        NSLog(@"Unable to convert string to attributed string: %@", error);
    }
    return attributedString;
}
@end
