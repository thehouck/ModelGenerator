//
//  ViewController.m
//  Model Generator
//
//  Created by A656440 on 3/27/15.
//  Copyright (c) 2015 Justin Houck. All rights reserved.
//

#import "ViewController.h"
#import "ModelGenerator.h"
@interface ViewController ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *language;
@property (nonatomic) IBOutlet NSTextView *json;
@property (nonatomic) IBOutlet NSTextField *prefix;
@property (nonatomic) IBOutlet NSTextField *subClass;
@property (nonatomic) IBOutlet NSButton *generate;
@property (weak) IBOutlet NSTextField *url;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.generate.title = @"Submit";
    self.json.string = @"";
    self.url.stringValue = @"";
    //	NSString *data = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:@"https://staging-02.itriagehealth.com/api/v1/clinical/conditions/65.json?content=full"] encoding:NSUTF8StringEncoding error:nil];
    //	self.json.string = data;
    //	[self didTouchGenerate:self.generate];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

- (IBAction)didTouchGenerate:(id)sender {
    NSString *jsonString = self.json.string;
    if (!jsonString.length) {
        jsonString = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:self.url.stringValue] encoding:NSUTF8StringEncoding error:nil];
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (!error) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        if (!error) {
            self.json.string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [self.json scrollRangeToVisible:NSMakeRange(0, 0)];
            self.generate.title = @"Submit";
            ModelGenerator *generator = [[ModelGenerator alloc]
                                         initWithLanguage:self.language.indexOfSelectedItem
                                         prefix:self.prefix.stringValue subClass:self.subClass.stringValue];
            [generator generateWithJSON:json];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [paths.firstObject stringByAppendingString:@"/models/"];
            [[NSWorkspace sharedWorkspace] openFile:path];
        }
        else {
        }
    }
    self.json.layer.borderWidth = 2.0;
    self.json.layer.borderColor = error ? [NSColor redColor].CGColor : [NSColor greenColor].CGColor;
}

@end
