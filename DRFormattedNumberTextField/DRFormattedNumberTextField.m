//
//  DRFormattedNumberTextField.m
//  DRFormattedNumberTextField
//
//  Created by Dariusz Rybicki on 12/08/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#import "DRFormattedNumberTextField.h"

@interface DRFormattedNumberTextFieldDelegate : NSObject <UITextFieldDelegate>

@property (nonatomic, weak) id<UITextFieldDelegate> delegate;

@end

@interface DRFormattedNumberTextField ()

@property (nonatomic, strong) NSCharacterSet *invalidInputCharacterSet;
@property (nonatomic, strong) DRFormattedNumberTextFieldDelegate *formattedTextFieldDelegate;

@end

#pragma mark - DRFromattedNumberTextField

@implementation DRFormattedNumberTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        super.delegate = self.formattedTextFieldDelegate;
        self.keyboardType = UIKeyboardTypeNumberPad;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        super.delegate = self.formattedTextFieldDelegate;
        self.keyboardType = UIKeyboardTypeNumberPad;
    }
    return self;
}

- (id<UITextFieldDelegate>)delegate
{
    return self.formattedTextFieldDelegate.delegate;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    self.formattedTextFieldDelegate.delegate = delegate;
}

- (DRFormattedNumberTextFieldDelegate *)formattedTextFieldDelegate
{
    if (!_formattedTextFieldDelegate) {
        _formattedTextFieldDelegate = [[DRFormattedNumberTextFieldDelegate alloc] init];
    }
    return _formattedTextFieldDelegate;
}

- (NSCharacterSet *)invalidInputCharacterSet
{
    if (!_invalidInputCharacterSet) {
        _invalidInputCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    }
    return _invalidInputCharacterSet;
}

- (NSNumberFormatter *)numberFormatter
{
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
    }
    return _numberFormatter;
}

- (NSNumber *)number
{
    return [self numberFromString:self.text];
}

- (void)setNumber:(NSNumber *)number
{
    NSString *string = [NSString stringWithFormat:@"%.*lf",
                        self.numberFormatter.maximumFractionDigits,
                        number.doubleValue];
    [self setText:string];
}

- (void)setText:(NSString *)text
{
    NSNumber *number = [self numberFromString:text];
    if ([number compare:@0] == NSOrderedSame) {
        [super setText:nil];
    }
    else {
        NSString *formattedText = [self.numberFormatter stringFromNumber:number];
        [super setText:formattedText];
    }
}

#pragma mark Helpers

- (NSNumber *)numberFromString:(NSString*)string
{
    NSString* digitString = [[string componentsSeparatedByCharactersInSet:self.invalidInputCharacterSet] componentsJoinedByString:@""];
    NSParameterAssert(self.numberFormatter.maximumFractionDigits == self.numberFormatter.minimumFractionDigits);
    NSUInteger fractionDigitsCount = self.numberFormatter.maximumFractionDigits;
    NSNumber *number = [NSNumber numberWithDouble:[digitString doubleValue] / pow(10.0, fractionDigitsCount)];
    return number;
}

- (void)setCaretPosition:(NSInteger)position
{
    [self setSelectionRange:NSMakeRange(position, 0)];
}

- (void)setSelectionRange:(NSRange)range
{
    UITextPosition *start = [self positionFromPosition:[self beginningOfDocument]
                                                offset:range.location];
    UITextPosition *end = [self positionFromPosition:start
                                              offset:range.length];
    [self setSelectedTextRange:[self textRangeFromPosition:start toPosition:end]];
}

@end

#pragma mark - DRFormattedNumberTextFieldDelegate

@implementation DRFormattedNumberTextFieldDelegate

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return ([super respondsToSelector:aSelector] || [self.delegate respondsToSelector:aSelector]);
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.delegate respondsToSelector:aSelector]) {
        return self.delegate;
    }
    
    return nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![textField isKindOfClass:[DRFormattedNumberTextField class]]) {
        return NO;
    }
    
    DRFormattedNumberTextField *formattedNumberTextField = (DRFormattedNumberTextField *)textField;
    
    if (string.length == 0
        && range.length == 1
        && [[formattedNumberTextField invalidInputCharacterSet] characterIsMember:[formattedNumberTextField.text characterAtIndex:range.location]])
    {
        [formattedNumberTextField setCaretPosition:range.location];
        return NO;
    }
    
    NSInteger distanceFromEnd = formattedNumberTextField.text.length - (range.location + range.length);
    NSString *change = [formattedNumberTextField.text stringByReplacingCharactersInRange:range withString:string];
    NSNumber *newNumericValue = [formattedNumberTextField numberFromString:change];
    
    BOOL delegateResponseForShouldChange = YES;
    if ([formattedNumberTextField.formattedNumberTextFieldDelegate respondsToSelector:@selector(formattedNumberTextField:shouldChangeNumberTo:)]) {
        delegateResponseForShouldChange = [formattedNumberTextField.formattedNumberTextFieldDelegate formattedNumberTextField:formattedNumberTextField
                                                                                                         shouldChangeNumberTo:newNumericValue];
    }
    
    if (delegateResponseForShouldChange) {
        [formattedNumberTextField setText:change];
        
        NSInteger position = formattedNumberTextField.text.length - distanceFromEnd;
        if ( position >= 0 && position <= formattedNumberTextField.text.length )
        {
            [formattedNumberTextField setCaretPosition:position];
        }
        
        [formattedNumberTextField sendActionsForControlEvents:UIControlEventEditingChanged];
    }
    
    return NO;
}

@end
