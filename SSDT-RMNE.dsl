/* Modified by stevezhengshiqi: Added _STA method to disable RMNE device when NOT in macOS.
 *
 */

/* ssdt.dsl -- SSDT injector for NullEthernet
 *
 * Copyright (c) 2014 RehabMan <racerrehabman@gmail.com>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 */

// Use this SSDT as an alternative to patching your DSDT...

DefinitionBlock("", "SSDT", 2, "hack", "_RMNE", 0x00000000)
{
    Device (RMNE)
    {
        // The NullEthernet kext matches on this HID
        Name (_HID, "NULE0000")
        // This is the MAC address returned by the kext. Modify if necessary.
        // A good practice is to follow Organizationally Unique Identifier (OUI) to spoof real Apple, Inc. interface.
        // Reference: https://dortania.github.io/OpenCore-Post-Install/universal/iservices.html#choose-a-mac-address
        Name (MAC, Buffer() { 0x00, 0x16, 0xCB, 0x00, 0x11, 0x22 })
        Method (_STA, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                Return (0x0F)
            }
            Else
            {
                Return (Zero)
            }
        }
        Method (_DSM, 4, NotSerialized)
        {
            If (LEqual (Arg2, Zero)) { Return (Buffer(One) { 0x03 } ) }
            Return (Package()
            {
                "built-in", Buffer(One) { 0x00 },
                "IOName", "ethernet",
                "name", Buffer() { "ethernet" },
                "model", Buffer() { "RM-NullEthernet-1001" },
                "device_type", Buffer() { "ethernet" },
            })
        }
    }
}

