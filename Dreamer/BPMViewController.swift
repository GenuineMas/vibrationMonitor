
import Charts
import CoreBluetooth
import RealmSwift
import UIKit


class BPMViewController: UIViewController, ChartViewDelegate, UIScrollViewDelegate {
    
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!
    var bpmCharacteristic: CBCharacteristic?
    var conectedPeriferals = [String: CBPeripheral]()
    var beatsPerMin = [Int]()
    var currentTime = [Int]()
    let localRealm = try! Realm()

    @IBAction func getBPMData(_ sender: Any) {
        getBMP()
        print("Get Data")
    }

    @IBOutlet var lineChartView: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // charts
        lineChartView.delegate = self
        let set_a: LineChartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: Double(0), y: Double(0))], label: "sensor")
        set_a.drawCirclesEnabled = false
        set_a.setColor(UIColor.blue)

        lineChartView.data = LineChartData(dataSets: [set_a])
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in self.updateCounter() }
        lineChartView.dragEnabled = true

        centralManager = CBCentralManager(delegate: self, queue: nil) // initialization of the centralManager
        // Make the digits monospaces to avoid shifting when the numbers change
    }

    // add point
    var i = 1
    func updateCounter() {
        if beatsPerMin.count > 10 && i <= beatsPerMin.count - 1 {
            lineChartView.data?.addEntry(ChartDataEntry(x: Double(currentTime[i]), y: Double(beatsPerMin[i])), dataSetIndex: 0)
            lineChartView.setVisibleXRange(minXRange: Double(1), maxXRange: Double(150))
            lineChartView.notifyDataSetChanged()
            lineChartView.moveViewToX(Double(i))
            i = i + 1

            print()
        }
    }
}

extension BPMViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil) // Scaning( can only accept this command while in the powered on state)
        @unknown default:
            print("central.state is .poweredOFF")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        conectedPeriferals.updateValue(peripheral, forKey: peripheral.name ?? "Nothing")

        print(peripheral.name ?? "NO peripheral was found")

        if peripheral.name == "Mi Smart Band 4" {
            centralManager.stopScan()
            for conectPeriferal in conectedPeriferals.values {
                centralManager.connect(conectPeriferal)
                conectPeriferal.delegate = self
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        for conectPeriferal in conectedPeriferals.values {
            print(conectPeriferal.discoverServices(nil))
        }
    }
}

extension BPMViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)

            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            // print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                // print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.uuid == heartRateMeasurementCharacteristicCBUUID {
                bpmCharacteristic = characteristic
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        switch characteristic.uuid {
        case heartRateMeasurementCharacteristicCBUUID:
            print("characteristic VALUE", heartRate(from: characteristic))
   
                let number = heartRate(from: characteristic)
                print(number)
                beatsPerMin.append(number)
                currentTime.append(beatsPerMin.count)
                
//MARK:Persist BMP data
                
                let bpm = PersistBPM(bpm: heartRate(from: bpmCharacteristic!))
                try! localRealm.write {
                    localRealm.add(bpm)
                    print("Realm", localRealm.objects(PersistBPM.self))
                }
            

        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }

    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)

        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }

    func getBMP() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [self] _ in
            self.conectedPeriferals["Mi Smart Band 4"]?.readValue(for: self.bpmCharacteristic!)
            print("BPM:", self.heartRate(from: self.bpmCharacteristic!))
        }
    }
}
