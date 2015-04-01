//
//  Generator.m
//  Model Generator
//
//  Created by A656440 on 3/29/15.
//  Copyright (c) 2015 Justin Houck. All rights reserved.
//

#import "ModelGenerator.h"

@implementation NSString (StringTransformations)

- (NSString *)camelUpperCase {
    return [self camelCaseFromUnderscoreCapitalizeFirstCharacter:YES];
}

- (NSString *)camelCase {
    return [self camelCaseFromUnderscoreCapitalizeFirstCharacter:NO];
}

- (NSString *)camelCaseFromUnderscoreCapitalizeFirstCharacter:(BOOL)capitalizeFirstCharacter {
    NSString *underScore = self;
    if ([underScore isEqualToString:@"id"]) {
        underScore = @"objectID";
    }
    if ([underScore isEqualToString:@"description"]) {
        underScore = @"objectDescription";
    }
    if (capitalizeFirstCharacter) {
        underScore = [[underScore substringToIndex:1].capitalizedString
                      stringByAppendingString:[underScore substringFromIndex:1]];
    }
    NSMutableString *output = [NSMutableString string];
    BOOL makeNextCharacterUpperCase = NO;
    for (NSInteger idx = 0; idx < [underScore length]; idx += 1) {
        unichar c = [underScore characterAtIndex:idx];
        if (c == '_') {
            makeNextCharacterUpperCase = YES;
        } else if (makeNextCharacterUpperCase) {
            [output appendString:[[NSString stringWithCharacters:&c
                                                          length:1] uppercaseString]];
            makeNextCharacterUpperCase = NO;
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}

@end

@interface ModelGenerator ()

@property (nonatomic) NSMutableString *model;
@property (nonatomic) NSDictionary *json;
@property (nonatomic) NSString *prefix;
@property (nonatomic) NSString *subClass;
@property (assign) ITModelGeneratorLanguage language;

@end

@implementation ModelGenerator

- (instancetype)initWithLanguage:(ITModelGeneratorLanguage)language prefix:(NSString *)prefix subClass:(NSString *)subClass {
    self = [super init];
    if (self) {
        self.model = [NSMutableString string];
        self.language = language;
        self.prefix = prefix ?: @"";
        self.subClass = subClass ?: @"NSObject";
    }
    return self;
}

- (void)headerBeginclassName:(NSString *)className {
    if (self.language == ITModelGeneratorLanguageObjC) {
        [self.model appendFormat:@"\n\n"
         @"@interface %@%@ : %@\n"
         , self.prefix, [className camelUpperCase], self.subClass];
    }
    else if (self.language == ITModelGeneratorLanguageSwift) {
        [self.model appendFormat:@"\n\n"
         @"@objc (%@%@) class %@%@ : %@ {\n",
         self.prefix, [className camelUpperCase], self.prefix, [className camelUpperCase], self.subClass];
    }
}

- (void)createPropertiesWithJSON:(NSDictionary *)json {
    [json.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSString *type;
        if ([json[key] isKindOfClass:[NSDictionary class]]) {
            type = [NSString stringWithFormat:@"%@%@", self.prefix, [key camelUpperCase]];
        } else if ([json[key] isKindOfClass:[NSArray class]]) {
            type = NSStringFromClass([NSArray class]);
        } else if ([json[key] isKindOfClass:[NSNumber class]]) {
            type = NSStringFromClass([NSNumber class]);
        } else if ([json[key] isKindOfClass:[NSString class]]) {
            type = NSStringFromClass([NSString class]);
        }
        if (self.language == ITModelGeneratorLanguageObjC) {
            if (idx == 0) {
                [self.model appendFormat:@"\n"
                 @"#pragma mark - Properties\n"
                 ];
            }
            if (type) {
                [self.model appendFormat:@"\n"
                 @"@property (nonatomic) %@ *%@;"
                 , type, [key camelCase]];
            } else {
                [self.model appendFormat:@"\n"
                 @"@property (nonatomic, assign) id %@;",
                 [key camelCase]];
            }
        }
        else if (self.language == ITModelGeneratorLanguageSwift) {
            if (idx == 0) {
                [self.model appendFormat:@"\n\n"
                 @"// MARK: - Properties\n"
                 ];
            }
            if (type) {
                [self.model appendFormat:@"\n"
                 @"    var %@: %@?"
                 , [key camelCase], type];
            } else {
                [self.model appendFormat:@"\n"
                 @"@property (nonatomic, assign) id %@;",
                 [key camelCase]];
            }
        }
    }];
    if (self.language == ITModelGeneratorLanguageObjC) {
        [self.model appendFormat:@"\n\n"
         @"+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;\n"
         @"- (instancetype)initWithDictionary:(NSDictionary *)dict;\n"
         ];
    }
}

- (void)headerEnd {
    if (self.language == ITModelGeneratorLanguageObjC) {
        [self.model appendString:@"\n\n"
         @"@end"
         ];
    }
    else if (self.language == ITModelGeneratorLanguageSwift) {
        [self.model appendString:@"\n\n"
         @"}"
         ];
    }
}

- (void)createConstantsWithJSON:(NSDictionary *)json {
    [json.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if (self.language == ITModelGeneratorLanguageObjC) {
            if (idx == 0) {
                [self.model appendFormat:@"\n"
                 @"#import \"%@%@.h\n"
                 , self.prefix, [key camelUpperCase]];
                [self.model appendFormat:@"\n"
                 @"#pragma mark - Constants\n"
                 ];
                
            }
            [self.model appendFormat:@"\n"
             @"NSString *const k%@%@ = @\"%@\";"
             ,self.prefix, [key camelUpperCase], key];
        } else if (self.language == ITModelGeneratorLanguageSwift) {
            if (idx == 0) {
                [self.model appendFormat:@"\n"
                 @"// MARK: - Constants\n"
                 ];
            }
            [self.model appendFormat:@"\n"
             @"    let %@ = \"%@\""
             , [key camelCase], key];
        }
    }];
}
- (NSString *)classNameFromKey:(NSString *)key {
    return [NSString stringWithFormat:@"%@%@", self.prefix, [key camelUpperCase]];
}

- (void)classBeginclassName:(NSString *)className {
    if (self.language == ITModelGeneratorLanguageObjC) {
        [self.model appendFormat:@"\n\n"
         @"@implementation %@\n"
         , [self classNameFromKey:className]];
    }
}

- (void)classImplementation:(NSDictionary *)json className:(NSString *)className {
    if (self.language == ITModelGeneratorLanguageObjC) {
        [self.model appendFormat:@"\n"
         @"+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {\n"
         @"     return [[self alloc] initWithDictionary:dict] {\n"
         @"}\n"
         ];
    }
    if (self.language == ITModelGeneratorLanguageSwift) {
        [self.model appendFormat:@"\n"
         @"class func modelObject(dict dictionary: Dictionary<String, AnyObject>) -> %@{\n"
         @"     return %@(dictionary: dict)\n"
         @"}\n"
         , className, className];
    }
    if (self.language == ITModelGeneratorLanguageObjC) {
        [self.model appendFormat:@"\n"
         @"- (instancetype)initWithDictionary:(NSDictionary *)dict {\n"
         @"     self = [super init];\n"
         @"     if (self && [dict isKindOfClass:[NSDictionary class]]) {\n"
         ];
    }
    else if (self.language == ITModelGeneratorLanguageSwift) {
//        init(dictionary: Dictionary<String, AnyObject>) {
//            self.myDict = dictionary
//        }
        [self.model appendFormat:@"\n"
         @"init(dictionary: Dictionary<String, AnyObject>) {\n"
         @"     self.myDict = dictionary\n"
         @"     if (self && [dict isKindOfClass:[NSDictionary class]]) {\n"
         ];
    }
    if ([json isKindOfClass:[NSDictionary class]]) {
        [json.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            if ([json[key] isKindOfClass:[NSDictionary class]]) {
                [self.model appendFormat:@""
                 @"self.%@ = [%@ modelObjectWithDictionary:dict[%@]];\n"
                 , [key camelCase], [self classNameFromKey:key], [NSString stringWithFormat:@"k%@%@", self.prefix, [key camelUpperCase]]];
            }
            else if ([json[key] isKindOfClass:[NSArray class]]) {
                [self.model appendFormat:@""
                 @"        NSMutableArray *%@Array = [NSMutableArray array];\n"
                 @"        for (id item in json[key]) {\n"
                 @"            if ([item isKindOfClass:[NSDictionary class]]) {\n"
                 @"                 self.%@ = [%@ modelObjectWithDictionary:dict[%@]];\n"
                 @"                 [tempArray addObject:[%@ modelObjectWithDictionary:item]];\n"
                 @"            }\n"
                 @"        }\n"
                 ,[key camelCase], [key camelCase], [self classNameFromKey:key], [NSString stringWithFormat:@"k%@%@", self.prefix, [key camelUpperCase]], [self classNameFromKey:key]];
            }
            else {
                [self.model appendFormat:@""
                 @"        self.%@ = dict[%@];\n", [key camelCase], [NSString stringWithFormat:@"k%@%@", self.prefix, [key camelUpperCase]]];
            }
        }];
    }
    [self.model appendFormat:@""
     @"    }\n"
     @"    return self;\n"
     @"}\n"
     ];
}

- (void)classEnd {
    [self.model appendString:@"\n"
     @"@end"
     ];
}

- (void)fileName:(NSString *)fileName header:(BOOL)header {
    fileName = [NSString stringWithFormat:@"%@%@", self.prefix, fileName];
    if (self.language == ITModelGeneratorLanguageObjC) {
        fileName = [fileName stringByAppendingString:header ? @".h" : @".m"];
    }
    else if (self.language == ITModelGeneratorLanguageSwift) {
        fileName = [fileName stringByAppendingString:@".swift"];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths.firstObject stringByAppendingString:@"/models/"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    path = [path stringByAppendingString:fileName];
    [self.model writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self.model deleteCharactersInRange:NSMakeRange(0, (self.model).length)];
}

- (void)createFile:(NSString *)key json:(id)json {
    if (self.language == ITModelGeneratorLanguageObjC) {
        [self headerBeginclassName:key];
        [self createPropertiesWithJSON:[json isKindOfClass:[NSArray class]] ? [json firstObject]: json];
        [self headerEnd];
        [self fileName:[key camelUpperCase] header:YES];
        [self createConstantsWithJSON:[json isKindOfClass:[NSArray class]] ? [json firstObject]: json];
        [self classBeginclassName:[key camelUpperCase]];
        [self classImplementation:[json isKindOfClass:[NSArray class]] ? [json firstObject]: json className:[key camelUpperCase]];
        [self classEnd];
        [self fileName:[key camelUpperCase] header:NO];
    }
    else if (self.language == ITModelGeneratorLanguageSwift) {
        [self headerBeginclassName:key];
        [self createConstantsWithJSON:[json isKindOfClass:[NSArray class]] ? [json firstObject]: json];
        [self createPropertiesWithJSON:[json isKindOfClass:[NSArray class]] ? [json firstObject]: json];
        [self headerEnd];
        [self classImplementation:[json isKindOfClass:[NSArray class]] ? [json firstObject]: json className:[key camelUpperCase]];
        [self fileName:[key camelUpperCase] header:NO];
    }
}

- (void)generateWithJSON:(NSDictionary *)json {
    [json.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if ([json[key] isKindOfClass:[NSDictionary class]]) {
            [self createFile:key json:json[key]];
            [self generateWithJSON:json[key]];
        } else if ([json[key] isKindOfClass:[NSArray class]]) {
            [self createFile:key json:json[key]];
            [self generateWithJSON:[json[key] firstObject]];
        }
    }];
}


@end
