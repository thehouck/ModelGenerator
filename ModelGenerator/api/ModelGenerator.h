//
//  Generator.h
//  Model Generator
//
//  Created by A656440 on 3/29/15.
//  Copyright (c) 2015 Justin Houck. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ITModelGeneratorLanguage) {
    ITModelGeneratorLanguageObjC,
    ITModelGeneratorLanguageSwift,
    ITModelGeneratorLanguageJava,
};
@interface ModelGenerator : NSObject

- (instancetype)initWithLanguage:(ITModelGeneratorLanguage)language prefix:(NSString *)prefix subClass:(NSString *)subClass;
- (void)generateWithJSON:(NSDictionary *)json;

@end
