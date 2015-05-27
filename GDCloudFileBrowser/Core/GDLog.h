//
//  GDLog.h
//  GDCloudFileBrowser
//
//  Created by Linto Mathew on 5/26/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import <Foundation/Foundation.h>

static BOOL const ENABLE_LOG = NO; ///< Set this to YES, if you'd like to see debug logs

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static const void GDLog(NSString *format, ...) {
#ifdef DEBUG
    if (ENABLE_LOG) {
        va_list varArgsList;
        va_start(varArgsList, format);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
        NSString *formatString = [[NSString alloc] initWithFormat:format arguments:varArgsList];
#pragma clang diagnostic pop
        va_end(varArgsList);
        NSLog(@"%@", formatString);
    }
#endif
}
#pragma clang diagnostic pop