//
//  EventTap.c
//  EventTapBug
//
//  Created by Rick Mann on 2023-10-23.
//

#include <CoreGraphics/CoreGraphics.h>



/**
	Wrapper around ``CGEventCreateCopy`` because it’s the only way I
	could figure out how to call this from Swift.
*/

CGEventRef
copyEvent(CGEventRef inEvent)
{
	return CGEventCreateCopy(inEvent);
}
