#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SwiftOTP.h"

FOUNDATION_EXPORT double SwiftOTPVersionNumber;
FOUNDATION_EXPORT const unsigned char SwiftOTPVersionString[];

