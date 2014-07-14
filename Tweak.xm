#import <Foundation/Foundation.h>

static BOOL noCapitalHook = NO;

%hook NSString

- (NSString *)uppercaseStringWithLocale:(NSLocale *)locale
{
	return noCapitalHook ? self : %orig;
}

%end

%hook UITableView

- (id)_sectionHeaderView:(BOOL)arg1 withFrame:(struct CGRect)arg2 forSection:(int)arg3 floating:(BOOL)arg4 reuseViewIfPossible:(BOOL)arg5
{
	noCapitalHook = YES;
	id ret = %orig;
	noCapitalHook = NO;
	return ret;
}

%end