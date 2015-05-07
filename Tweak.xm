#import "../PS.h"

BOOL noUpperCaseHook = NO;

%hook UITableView

%group preiOS8

- (id)_sectionHeaderView:(BOOL)arg1 withFrame:(CGRect)arg2 forSection:(NSInteger)arg3 floating:(BOOL)arg4 reuseViewIfPossible:(BOOL)arg5
{
	noUpperCaseHook = YES;
	id ret = %orig;
	noUpperCaseHook = NO;
	return ret;
}

%end

%group iOS8

- (id)_sectionHeaderView:(BOOL)arg1 withFrame:(CGRect)arg2 forSection:(NSInteger)arg3 floating:(BOOL)arg4 reuseViewIfPossible:(BOOL)arg5 willDisplay:(BOOL)arg6
{
	noUpperCaseHook = YES;
	id ret = %orig;
	noUpperCaseHook = NO;
	return ret;
}

%end

%end

%group iOS7Up

%hook UIReferenceLibraryViewController

- (NSString *)tableView:(id)arg1 titleForHeaderInSection:(int)arg2
{
	noUpperCaseHook = YES;
	NSString *ret = %orig;
	noUpperCaseHook = NO;
	return ret;
}

%end

%end

MSHook(void, CFStringUppercase, CFMutableStringRef string, CFLocaleRef locale)
{
	if (noUpperCaseHook)
		return;
}

%ctor
{
	NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
	NSUInteger count = args.count;
	if (count != 0) {
		NSString *executablePath = args[0];
		if (executablePath) {
			BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
			BOOL isSpringBoard = [[executablePath lastPathComponent] isEqualToString:@"SpringBoard"];
			if (isApplication || isSpringBoard) {
				MSHookFunction(CFStringUppercase, MSHake(CFStringUppercase));
				%init();
				if (isiOS8Up) {
					%init(iOS8);
				} else {
					%init(preiOS8);
				}
				if (isiOS7Up) {
					%init(iOS7Up);
				}
			}
		}
	}
}
