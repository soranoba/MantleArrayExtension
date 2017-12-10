//
//  MAEFragmentTests.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEFragment.h"

QuickSpecBegin(MAEFragmentTests)
{
    it(@"Quoted means double-quoted", ^{
        MAEFragment* fragment = MAEQuoted(@"a");
        expect(fragment.propertyName).to(equal(@"a"));
        expect(@(fragment.type)).to(equal(MAEFragmentDoubleQuotedString));
        expect(fragment.isOptional).to(equal(NO));
        expect(fragment.isVariadic).to(equal(NO));
    });

    it(@"SingleQuoted means single-quoted", ^{
        MAEFragment* fragment = MAESingleQuoted(@"a");
        expect(fragment.propertyName).to(equal(@"a"));
        expect(@(fragment.type)).to(equal(MAEFragmentSingleQuotedString));
        expect(fragment.isOptional).to(equal(NO));
        expect(fragment.isVariadic).to(equal(NO));
    });

    it(@"Enum means enumerate-string", ^{
        MAEFragment* fragment = MAEEnum(@"a");
        expect(fragment.propertyName).to(equal(@"a"));
        expect(@(fragment.type)).to(equal(MAEFragmentEnumerateString));
        expect(fragment.isOptional).to(equal(NO));
        expect(fragment.isVariadic).to(equal(NO));
    });

    it(@"Optional means optional value", ^{
        MAEFragment* fragment = MAEOptional(@"a");
        expect(fragment.propertyName).to(equal(@"a"));
        expect(@(fragment.type)).to(equal(MAEFragmentMaybeQuotedString));
        expect(fragment.isOptional).to(equal(YES));
        expect(fragment.isVariadic).to(equal(NO));

        fragment = MAEOptional(MAEQuoted(@"a"));
        expect(fragment.propertyName).to(equal(@"a"));
        expect(@(fragment.type)).to(equal(MAEFragmentDoubleQuotedString));
        expect(fragment.isOptional).to(equal(YES));
        expect(fragment.isVariadic).to(equal(NO));
    });

    it(@"Variadic means variable length", ^{
        MAEFragment* fragment = MAEVariadic(MAEOptional(@"a"));
        expect(fragment.propertyName).to(equal(@"a"));
        expect(@(fragment.type)).to(equal(MAEFragmentMaybeQuotedString));
        expect(fragment.isOptional).to(equal(YES));
        expect(fragment.isVariadic).to(equal(YES));

        fragment = MAEVariadic(@"a");
        expect(fragment.propertyName).to(equal(@"a"));
        expect(@(fragment.type)).to(equal(MAEFragmentMaybeQuotedString));
        expect(fragment.isOptional).to(equal(NO));
        expect(fragment.isVariadic).to(equal(YES));
    });

    it(@"description", ^{
        expect([MAEVariadic(@"a") description]).to(equal(@"<MAEFragment: a :--V>"));
        expect([MAEOptional(@"a") description]).to(equal(@"<MAEFragment: a :-O->"));
        expect([MAEQuoted(@"b") description]).to(equal(@"<MAEFragment: b :D-->"));
        expect([MAESingleQuoted(@"c") description]).to(equal(@"<MAEFragment: c :S-->"));
        expect([MAEVariadic([[MAEFragment alloc] initWithPropertyName:@"d"]) description])
            .to(equal(@"<MAEFragment: d :--V>"));
        expect([MAEVariadic(MAEOptional(MAESingleQuoted(@"e"))) description])
            .to(equal(@"<MAEFragment: e :SOV>"));
    });
}
QuickSpecEnd
