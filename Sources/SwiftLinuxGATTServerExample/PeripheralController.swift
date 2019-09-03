import Foundation
import Bluetooth
import GATT
import BluetoothLinux

public struct ExampleCharacteristic: GATTCharacteristic {
    public static var uuid = BluetoothUUID(rawValue: "35FD373F-241C-4725-A8A6-C644AADB9A1A")!
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public init?(data: Data) {
        guard let rawValue = String(data: data, encoding: .utf8)
            else { return nil }
        
        self.init(rawValue: rawValue)
    }
    public var data: Data {
        return Data(rawValue.utf8)
    }
}


public final class PeripheralController {
    
    enum Error : Swift.Error {
        case bluetoothUnavailible
    }
    
    // MARK: - Properties
    let peripheral: GATTPeripheral<HostController, L2CAPSocket>
    let peripheralName: GAPCompleteLocalName = "Example"
    let beaconUUID = UUID(rawValue: "1DC24957-9DDA-46C4-88D4-3D3640CB3FDA")!
    let exampleServiceUUID = BluetoothUUID(rawValue: "E47D83A9-1366-432A-A5C6-734BA62FAF7E")!
    var exampleCharacteristicHandle: UInt16?
    
    public init() throws {
        guard let hostController = HostController.default else {
            throw Error.bluetoothUnavailible
        }
        
        // Setup peripheral
        let address = try hostController.readDeviceAddress()
        let serverSocket = try L2CAPSocket.lowEnergyServer(controllerAddress: address, isRandom: false, securityLevel: .low)
        
        peripheral = GATTPeripheral<HostController, L2CAPSocket>(controller: hostController)
        peripheral.newConnection = {
           let socket = try serverSocket.waitForConnection()
           let central = Central(identifier: socket.address)
           print("BLE Peripheral: new connection")
           return (socket, central)
        }

        _ = try peripheral.add(service: deviceInformationService())
        _ = try peripheral.add(service: exampleService())
                
        exampleCharacteristicHandle = peripheral.characteristics(for: ExampleCharacteristic.uuid)[0]
        
        // Start peripheral
        try peripheral.start()
        print("BLE Peripheral started")
        
        
        // Setup advertising
        let rssi: Int8 = 30
        let beacon = AppleBeacon(uuid: beaconUUID, rssi: rssi)
        let flags: GAPFlags = [.lowEnergyGeneralDiscoverableMode, .notSupportedBREDR]
        try hostController.iBeacon(beacon, flags: flags, interval: .min, timeout: .default)
    
        let serviceUUIDs: GAPIncompleteListOf128BitServiceClassUUIDs = [UUID(bluetooth: exampleServiceUUID)]
        let encoder = GAPDataEncoder()
        let data = try encoder.encodeAdvertisingData(peripheralName, serviceUUIDs)
        try hostController.setLowEnergyScanResponse(data, timeout: .default)
        print("BLE Advertising started")
 
        // Setup callbacks
        peripheral.willRead = willRead
        peripheral.willWrite = willWrite
        peripheral.didWrite = didWrite
    }
    
    func deviceInformationService() -> GATT.Service {
        let manufacturerName: GATTManufacturerNameString = "Example Company"
        
        let characteristics = [
            GATT.Characteristic(uuid: type(of: manufacturerName).uuid, value: manufacturerName.data, permissions: [.read], properties: [.read], descriptors: []),
        ]
        return GATT.Service(uuid: .deviceInformation, primary: true, characteristics: characteristics)
    }
    func exampleService() -> GATT.Service {
        let characteristics = [
            GATT.Characteristic(uuid: ExampleCharacteristic.uuid, value: Data(), permissions: [.read, .write], properties: [.read, .write], descriptors: []),
        ]
        return GATT.Service(uuid: exampleServiceUUID, primary: true, characteristics: characteristics)
    }
    
    
    // MARK: - Peripheral Callbacks
    private func willRead(_ request: GATTReadRequest<Central>) -> ATT.Error? {
        print("BLE Peripheral willRead \(request.uuid)")
        return nil
    }
    private func willWrite(_ request: GATTWriteRequest<Central>) -> ATT.Error? {
        print("BLE Peripheral willWrite \(request.uuid)")
        return nil
    }
    private func didWrite(_ confirmation: GATTWriteConfirmation<Central>) {
        print("BLE Peripheral didWrite to \(confirmation.uuid): \(confirmation.value)")
        
        if let characteristic = ExampleCharacteristic(data: confirmation.value) {
            print("Updating characteristic data for handler \(exampleCharacteristicHandle!) to \(characteristic.data)")
            peripheral[characteristic: exampleCharacteristicHandle!] = characteristic.data
        } else {
            print("Invalid data")
        }
    }
}
