//
//  CPRule.m
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPRule.h"
#import "CPRule+Internal.h"

#import "CPGrammarSymbol.h"

@implementation CPRule
{
    NSMutableArray *rightHandSide;
    BOOL _shouldCollapse;
    NSSet *_tagNames;
}

@synthesize name;
@synthesize tag;
@synthesize representitiveClass;

- (NSArray *)rightHandSideElements
{
    return rightHandSide;
}

- (void)setRightHandSideElements:(NSArray *)rightHandSideElements
{
    @synchronized(self)
    {
        if (rightHandSide != rightHandSideElements)
        {
            rightHandSide = [rightHandSideElements mutableCopy];
        }
    }
}

+ (id)ruleWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements representitiveClass:(Class)representitiveClass
{
    return [[self alloc] initWithName:name rightHandSideElements:rightHandSideElements representitiveClass:representitiveClass];
}

- (id)initWithName:(NSString *)initName rightHandSideElements:(NSArray *)rightHandSideElements representitiveClass:(Class)initRepresentitiveClass
{
    self = [super init];
    
    if (nil != self)
    {
        [self setName:initName];
        [self setRightHandSideElements:rightHandSideElements];
        [self setTag:0];
        [self setRepresentitiveClass:initRepresentitiveClass];
    }
    
    return self;
}

+ (id)ruleWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements tag:(NSUInteger)tag
{
    return [[self alloc] initWithName:name rightHandSideElements:rightHandSideElements tag:tag];
}

- (id)initWithName:(NSString *)initName rightHandSideElements:(NSArray *)rightHandSideElements tag:(NSUInteger)initTag
{
    self = [self initWithName:initName rightHandSideElements:rightHandSideElements representitiveClass:nil];
    
    if (nil != self)
    {
        [self setTag:initTag];
    }
    
    return self;
}

+ (id)ruleWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements
{
    return [[CPRule alloc] initWithName:name rightHandSideElements:rightHandSideElements];
}

- (id)initWithName:(NSString *)initName rightHandSideElements:(NSArray *)rightHandSideElements
{
    return [self initWithName:initName rightHandSideElements:rightHandSideElements tag:0];
}

- (id)init
{
    return [self initWithName:@"" rightHandSideElements:[NSArray array]];
}

#define CPRuleTagKey                 @"t"
#define CPRuleNameKey                @"n"
#define CPRuleRHSElementsKey         @"r"
#define CPRuleRepresentitiveClassKey @"c"
#define CPRuleShouldCollapseKey      @"s"
#define CPRuleTagNamesKey            @"tn"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (nil != self)
    {
        [self setTag:[aDecoder decodeIntegerForKey:CPRuleTagKey]];
        [self setName:[aDecoder decodeObjectForKey:CPRuleNameKey]];
        [self setRightHandSideElements:[aDecoder decodeObjectForKey:CPRuleRHSElementsKey]];
        [self setRepresentitiveClass:NSClassFromString([aDecoder decodeObjectForKey:CPRuleRepresentitiveClassKey])];
        [self setShouldCollapse:[[aDecoder decodeObjectForKey:CPRuleShouldCollapseKey] boolValue]];

        NSArray *tagNamesArray = [aDecoder decodeObjectForKey:CPRuleTagNamesKey];
        if(tagNamesArray.count)
            [self setTagNames:[NSSet setWithArray:tagNamesArray]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:[self tag] forKey:CPRuleTagKey];
    [aCoder encodeObject:[self name] forKey:CPRuleNameKey];
    [aCoder encodeObject:[self rightHandSideElements] forKey:CPRuleRHSElementsKey];
    [aCoder encodeObject:NSStringFromClass([self representitiveClass]) forKey:CPRuleRepresentitiveClassKey];
    [aCoder encodeObject:@([self shouldCollapse]) forKey:CPRuleShouldCollapseKey];

    NSSet *tagNames = [self tagNames];
    if([tagNames count]) {
        NSSortDescriptor *tagNamesSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description"
                                                                                 ascending:YES
                                                                                  selector:@selector(caseInsensitiveCompare:)];

        [aCoder encodeObject:[tagNames sortedArrayUsingDescriptors:@[tagNamesSortDescriptor]]
                      forKey:CPRuleTagNamesKey];

    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ ::= %@", [self name], [[rightHandSide valueForKey:@"description"] componentsJoinedByString:@" "]];
}

- (NSUInteger)hash
{
    return [name hash] ^ [self tag];
}

- (BOOL)isRule
{
    return YES;
}

- (BOOL)isEqual:(id)object
{
    return ([object isRule] &&
            ((CPRule *)object)->tag == tag &&
            [((CPRule *)object)->name isEqualToString:name] &&
            [((CPRule *)object)->rightHandSide isEqualToArray:rightHandSide] &&
            (_tagNames == nil || [((CPRule *)object)->_tagNames isEqualToSet:_tagNames]));
}

@end

@implementation CPRule (Internal)

- (BOOL)shouldCollapse
{
    return _shouldCollapse;
}

- (void)setShouldCollapse:(BOOL)shouldCollapse
{
    _shouldCollapse = shouldCollapse;
}

- (NSSet *)tagNames
{
    return _tagNames;
}

- (void)setTagNames:(NSSet *)tagNames
{
    if (_tagNames != tagNames)
    {
        _tagNames = [tagNames copy];
    }
}

@end

@implementation NSObject (CPIsRule)

- (BOOL)isRule
{
    return NO;
}

@end
