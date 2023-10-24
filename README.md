If you write a CGEventTap handler in C, you can call CGEventCreateCopy() and return that copy from the handler, and all is well. If you write it in Swift and call CGEvent.copy() and return that copy, the system logs "Invalid event returned by callback" and ignores the event returned.

To reproduce:

1. Run the attached project in Xcode. It will prompt to give access. Grant it, then run it again.
2. With the Xcode log window visible, press a key on the keyboard.
3. You should see "Got key down" logged.
4. If the selected method in the app’s window is "Swift Copy", you will also see "Invalid event returned by callback."

Upon further investigation, the "invalid event" message can be avoided by returning the event with `Unmanaged.passRetained()`, but this feels like it would leak. I added logging for the retain count of the event to be returned. It is different for each of the three methods. A copy created with CGEvent.copy() has a retain count of 2. A copy created with CGEventCreateCopy() has a retain count of 3. And the event passed into the handler has a retain count of 4.

It’s not clear to me what the right approach is here. But something feels wrong about this, as I would have to return events differently depending on whether or not I copy them (in my application, I often return the event unmodified, but the return statement doesn’t know how the event was created).
