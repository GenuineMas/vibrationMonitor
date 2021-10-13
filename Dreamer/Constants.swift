//
//  Variables.swift
//  Dreamer
//
//  Created by Genuine on 13.10.2021.
//  Copyright © 2021 Genuine. All rights reserved.
//


import CoreBluetooth

import UIKit

let frame = CGRect(x: 0, y: 61, width: 320, height: 241) // graph
let heartRateServiceCBUUID = CBUUID(string: "180D") // the UUID for the Heart Rate service(probabile in hexodecimal phorme)
let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37") // the UUID for the Heart Rate service Characteristic
let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A39")
let heartRateMiBand2 = CBUUID(string: "2A06")
let bluetoothChar = CBUUID(string: "FFE1")
