//
//  ULUIDefs.m
//  United Libraries
//
//  Created by Mikhail Larionov on 1/01/14.
//

#import "ULInApp.h"

@implementation SKProduct (priceAsString)

- (NSString *) priceAsString
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[self priceLocale]];
    if ( formatter.currencySymbol.length > 1 )
        [formatter setCurrencySymbol:[NSString stringWithFormat:@"%@ ", formatter.currencySymbol]];
    NSString *str = [formatter stringFromNumber:[self price]];
    return str;
}

@end