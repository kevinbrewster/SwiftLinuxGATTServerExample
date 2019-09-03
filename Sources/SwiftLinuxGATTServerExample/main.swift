do {
    _ = try PeripheralController()
} catch let error {
    print("Error initializing peripheral: \(error)")
}
while true { }


