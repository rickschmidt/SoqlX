// Copyright (c) 2008,2012 Simon Fell
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
// THE SOFTWARE.
//

#import "QueryListController.h"

static NSString *RECENT_QUERIES = @"recentQueries";
static NSString *RECENT_SHOWN = @"recentQueriesVisible";

@implementation QueryListController

@synthesize tableViewItems;
-(void)awakeFromNib {
    [super awakeFromNib];
	[panelWindow setContentBorderThickness:28.0 forEdge:NSMinYEdge];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [self loadSavedItems];
    tableViewItems = [[NSMutableArray alloc]initWithCapacity:10];
    [tableView reloadData];
}

-(NSString *)windowVisiblePrefName {
    return RECENT_SHOWN;
}


//incoming soql strings
- (void)addQuery:(NSString *)soql {
	soql = [soql stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"adding query %@",soql);
    [tableViewItems addObject:soql];

    NSLog(@"tableview %@", tableViewItems);
    [tableView reloadData];
	if ([view upsertHead:soql]) {
        // save the current list of recent queries
//		NSMutableArray *q = [NSMutableArray arrayWithCapacity:[[view items] count]];
        NSMutableDictionary *dq = [NSMutableDictionary dictionaryWithCapacity:[[view items]count]];
		for (QueryTextListViewItem *i in [view items]) 
//			[q addObject:[i text]];
            [dq setValue:@" test" forKey:[i text]]; 
			
		[[NSUserDefaults standardUserDefaults] setObject:dq forKey:[self prefName:RECENT_QUERIES]];
	}
}

-(void)setDelegate:(id<QueryTextListViewDelegate>)delegate {
    [view setDelegate:delegate];
}

-(id<QueryTextListViewDelegate>)delegate {
    return [view delegate];
}

-(void)loadSavedItems {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *saved = [def arrayForKey:[self prefName:RECENT_QUERIES]];

    if (saved == nil) {
        // see if we need to migrate the existing items from the previous versions pref scheme.
        saved = [def arrayForKey:RECENT_QUERIES];
      //  [tableViewItems initWithArray:[def arrayForKey:RECENT_QUERIES]];
        if (saved != nil) {
            [def setObject:saved forKey:[self prefName:RECENT_QUERIES]];
            [def removeObjectForKey:RECENT_QUERIES];
            
        }
    }
    NSLog(@"saved %@",saved);
	if (saved != nil)
        [view setInitialItems:saved];
      //  [tableViewItems initWithArray:saved];
}
    
-(void)onPrefsPrefixSet:(NSString *)pp {
    [self loadSavedItems];
    [super onPrefsPrefixSet:pp];
}
/////Table view code
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSLog(@"tv count %lu",[tableViewItems count]);
    return [tableViewItems count];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSTableCellView *text = [[NSTableCellView alloc]init];
    text.textField = [tableViewItems objectAtIndex:row];
    return text;
}
@end
