#import "../PS.h"

static BOOL noCapitalHook = NO;

%hook NSString

- (NSString *)uppercaseStringWithLocale:(NSLocale *)locale
{
	return noCapitalHook ? self : %orig;
}

%end

%hook UITableView

%group preiOS8

- (id)_sectionHeaderView:(BOOL)arg1 withFrame:(CGRect)arg2 forSection:(int)arg3 floating:(BOOL)arg4 reuseViewIfPossible:(BOOL)arg5
{
	noCapitalHook = YES;
	id ret = %orig;
	noCapitalHook = NO;
	return ret;
}

%end

%group iOS8

- (id)_sectionHeaderView:(BOOL)arg1 withFrame:(CGRect)arg2 forSection:(int)arg3 floating:(BOOL)arg4 reuseViewIfPossible:(BOOL)arg5 willDisplay:(BOOL)arg6
{
	noCapitalHook = YES;
	id ret = %orig;
	noCapitalHook = NO;
	return ret;
}

%end

%end

%ctor
{
	%init();
	if (isiOS8) {
		%init(iOS8);
	} else {
		%init(preiOS8);
	}
}
