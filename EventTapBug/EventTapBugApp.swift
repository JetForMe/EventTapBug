//
//  EventTapBugApp.swift
//  EventTapBug
//
//  Created by Rick Mann on 2023-10-23.
//

import SwiftUI
import CoreGraphics




@main
struct
EventTapBugApp: App
{
	var
	body: some Scene
	{
		WindowGroup
		{
			Picker("", selection: self.$method)
			{
				Text("Swift Copy").tag(TapMethod.swiftCopy)
				Text("C Copy").tag(TapMethod.cCopy)
				Text("Passthrough").tag(TapMethod.passthrough)
			}
			.pickerStyle(SegmentedPickerStyle())
			.frame(maxWidth: 300.0)
		}
		.onChange(of: self.scenePhase)
		{ inNewValue in
			print("Phase: \(inNewValue)")
			if inNewValue == .active
			{
				createTap()
			}
		}
		.onChange(of: self.method)
		{ inNewValue in
			gMethod = inNewValue
		}
	}
	
	func
	createTap()
	{
		let swiftCallback: CGEventTapCallBack =
		{ inProxy, inEventType, inEvent, inUserInfo -> Unmanaged<CGEvent>? in
										
			//	If the tap was disabled due to a timeout, re-enable it…
			
			if [.tapDisabledByTimeout, .tapDisabledByUserInput].contains(inEventType)
			{
				CGEvent.tapEnable(tap: gTap, enable: true)
				return Unmanaged.passUnretained(inEvent)
			}
			
			print("Got key down")
			
			//	Make a copy and return that, get "invalid event"…
			
			let newEvent: CGEvent
			switch (gMethod)
			{
				case .swiftCopy:
					newEvent = inEvent.copy()!
					let count = CFGetRetainCount(newEvent)
					print("swiftCopy retain count: \(count)")
				
				case .cCopy:
					newEvent = copyEvent(inEvent).takeUnretainedValue()
					let count = CFGetRetainCount(newEvent)
					print("cCopy retain count: \(count)")
				
				case .passthrough:
					newEvent = inEvent
					let count = CFGetRetainCount(newEvent)
					print("Passthrough retain count: \(count)")
			}

			return Unmanaged.passRetained(newEvent)
		}

		let port = CGEvent.tapCreate(tap: .cghidEventTap,
										place: .headInsertEventTap,
										options: .defaultTap,
										eventsOfInterest: 1 << CGEventMask(CGEventType.keyDown.rawValue),
										callback: swiftCallback,
										userInfo: nil)
		
		//	Remember the port…
		
		guard
			let port
		else
		{
			print("Couldn't create tap")
			return
		}
		
		gTap = port
		
		//	Add it to the run loop…
		
		let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, gTap, 0)
		CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
	}
	
	@State						private	var		method				=	TapMethod.swiftCopy
	@Environment(\.scenePhase)	private	var		scenePhase
}

enum
TapMethod
{
	case swiftCopy
	case cCopy
	case passthrough
}

private	var	gTap		:	CFMachPort!
private var	gMethod		:	TapMethod				=	.swiftCopy
