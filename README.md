# SwiftLinuxGATTServerExample

This is a bare bones example of how to create a Bluetooth 4.0 (BLE) peripheral (aka GATT server) on Linux (e.g. on a Raspberry Pi) using Swift and the [PureSwift BluetoothLinux library](https://github.com/PureSwift/BluetoothLinux).

This example sets up a simple BLE peripheral with 2 services, each with a single characteristic. 

* **Device Information**: an example of using a built-in GATT "Device Information" service (0x180A) with the built-in GATT "Manufacturer Name String" characteristic (0x2A29). Normally you'd have more characteristics for this service.

* **Example Service**: a custom service with a single read/write characteristic. This shows how to handle write requests and how to update a characteristics value.

*Note: I have no affiliation with the PureSwift project and this code may not be the recommended or canonical usage.*

# Installation for Raspberry Pi

1. Install Raspbian or Ubuntu on Raspberry Pi
2. [Install Swift 5 on Raspberry Pi](https://github.com/uraimo/buildSwiftOnARM) using the prebuilt binary
3. Checkout the SwiftLinuxGATTServerExample project
4. Navigate to project directory and run: `sudo /home/pi/usr/bin/swift run`

# Testing

I'm using [BlueSee BLE Debugger](https://apps.apple.com/us/app/bluesee-ble-debugger/id1336679524?mt=12) to test the BLE connection and verify that read/write works on the example customer characteristic.



# Dependencies

* [PureSwift/BluetoothLinux](https://github.com/PureSwift/BluetoothLinux) - Pure Swift Linux Bluetooth Stack
* [PureSwift/GATT](https://github.com/PureSwift/GATT) - Bluetooth Generic Attribute Profile (GATT) for Swift
