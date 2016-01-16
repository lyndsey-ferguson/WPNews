//
//  NSAttributedString+HTML.h
//  WPNews
//
//  Created by Lyndsey on 1/16/16.
//  Copyright © 2016 Lyndsey Ferguson Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSAttributedString (HTML)
+ (instancetype)attributedStringFromHTMLString:(NSString*)htmlString;
@end
