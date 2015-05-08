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

@interface _UIDefinitionValue : NSObject
- (NSString *)localizedDictionaryName;
@end

%hook UIReferenceLibraryViewController

- (NSString *)tableView:(id)arg1 titleForHeaderInSection:(int)arg2
{
	return [(_UIDefinitionValue *)MSHookIvar<NSArray *>(self, "_definitionValues")[arg2] localizedDictionaryName];
}

%end

%end

%group Mail

%hook MailboxPickerController

- (NSString *)tableView:(id)arg1 titleForHeaderInSection:(int)arg2
{
	noUpperCaseHook = YES;
	NSString *ret = %orig;
	noUpperCaseHook = NO;
	return ret;
}

- (id)tableView:(id)arg1 viewForHeaderInSection:(int)arg2
{
	noUpperCaseHook = YES;
	id ret = %orig;
	noUpperCaseHook = NO;
	return ret;
}

%end

%hook PreviousDraftPickerHeaderView

- (void)updateUI
{
	noUpperCaseHook = YES;
	%orig;
	noUpperCaseHook = NO;
}

%end

%end

MSHook(void, CFStringUppercase, CFMutableStringRef string, CFLocaleRef locale)
{
	if (noUpperCaseHook)
		return;
	_CFStringUppercase(string, locale);
}

%ctor
{
	NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
	NSUInteger count = args.count;
	if (count != 0) {
		NSString *executablePath = args[0];
		if (executablePath) {
			NSString *name = [executablePath lastPathComponent];
			BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
			BOOL isSpringBoard = [name isEqualToString:@"SpringBoard"];
			if (isApplication || isSpringBoard) {
				MSHookFunction(CFStringUppercase, MSHake(CFStringUppercase));
				%init();
				if ([name isEqualToString:@"MobileMail"]) {
					%init(Mail);
				}
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
