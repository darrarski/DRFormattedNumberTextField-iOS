//
//  DRFormattedNumberTextField.h
//  DRFormattedNumberTextField
//
//  Created by Dariusz Rybicki on 12/08/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRFormattedNumberTextField;

@protocol DRFormattedNumberTextFieldDelegate <NSObject>

- (BOOL)formattedNumberTextField:(DRFormattedNumberTextField *)textField shouldChangeNumberTo:(NSNumber *)number;

@end

@interface DRFormattedNumberTextField : UITextField

@property (nonatomic, weak) id<DRFormattedNumberTextFieldDelegate> formattedNumberTextFieldDelegate;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) NSNumber *number;

@end
