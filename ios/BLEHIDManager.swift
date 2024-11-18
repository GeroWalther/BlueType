//
//  BLEHIDManager.swift
//  keyboard
//
//
import UIKit
import Foundation
import CoreBluetooth

@objc(BLEHIDManager)
class BLEHIDManager: NSObject, CBPeripheralManagerDelegate, ObservableObject {
  private var peripheralManager: CBPeripheralManager?
  
  private var reportMapCharacteristic: CBMutableCharacteristic?
  
  private var BReport: CBMutableCharacteristic?
  private var AReport: CBMutableCharacteristic?
  private var CReport: CBMutableCharacteristic?
  
  private var protocolModeCharacteristic: CBMutableCharacteristic?
  private var controlPointCharacteristic: CBMutableCharacteristic?
  private var bootKeyboardInputReportCharacteristic: CBMutableCharacteristic?
  private var bootKeyboardOutputReportCharacteristic: CBMutableCharacteristic?
  
  private var batteryLevelCharacteristic: CBMutableCharacteristic?
  
  @Published var isBluetoothReady = false
  private var canSendData = false
  private var shouldReconnect = true
  
  private var currentProtocolMode: UInt8 = 0x01
  private let gattServiceUUID = CBUUID(string: "00001801-0000-1000-8000-00805F9B34FB")
  private let serviceChangedCharacteristicUUID = CBUUID(string: "00002A05-0000-1000-8000-00805F9B34FB")
  private let gapServiceUUID = CBUUID(string: "00001800-0000-1000-8000-00805F9B34FB")
  private let deviceNameCharacteristicUUID = CBUUID(string: "00002A00-0000-1000-8000-00805F9B34FB")
  private let appearanceCharacteristicUUID = CBUUID(string: "00002A01-0000-1000-8000-00805F9B34FB")
  private let deviceInfoServiceUUID: CBUUID = CBUUID(string: "0000180A-0000-1000-8000-00805F9B34FB")
  private let pnpIDCharacteristicUUID = CBUUID(string: "00002A50-0000-1000-8000-00805F9B34FB")
  private let manufacturerNameCharacteristicUUID: CBUUID = CBUUID(string: "00002A29-0000-1000-8000-00805F9B34FB")
  private let batteryServiceUUID: CBUUID = CBUUID(string: "0000180F-0000-1000-8000-00805F9B34FB")
  private let batteryLevelCharacteristicUUID = CBUUID(string: "00002A19-0000-1000-8000-00805F9B34FB")
  private let hidServiceUUID: CBUUID = CBUUID(string: "00001812-0000-1000-8000-00805F9B34FB")
  private let hidInformationCharacteristicUUID: CBUUID = CBUUID(string: "00002A4A-0000-1000-8000-00805F9B34FB")
  private let reportMapCharacteristicUUID: CBUUID = CBUUID(string: "00002A4B-0000-1000-8000-00805F9B34FB")
  private let reportReferenceDiscriptorUUID: CBUUID = CBUUID(string: "00002908-0000-1000-8000-00805F9B34FB")
  private let reportCharacteristicUUID: CBUUID = CBUUID(string: "00002A4D-0000-1000-8000-00805F9B34FB")
  private let protocolModeCharacteristicUUID: CBUUID = CBUUID(string: "00002A4E-0000-1000-8000-00805F9B34FB")
  private let controlPointCharacteristicUUID: CBUUID = CBUUID(string: "00002A4C-0000-1000-8000-00805F9B34FB")
  private let bootKeyboardInputReportCharacteristicUUID: CBUUID = CBUUID(string: "00002A22-0000-1000-8000-00805F9B34FB")
  private let bootKeyboardOutputReportCharacteristicUUID: CBUUID = CBUUID(string: "00002A32-0000-1000-8000-00805F9B34FB")
  
  private let advertiseLocalName: String = "BLE Keyboard"
  
  private var connectedCentral: CBCentral?
  
  private let HID_REPORT_DESCRIPTOR: [UInt8] = [
    0x05, 0x01, 0x09, 0x02, 0xA1, 0x01, 0x85, 0x01, 0x09, 0x01, 0xA1, 0x00, 0x05, 0x09, 0x19, 0x01,
    0x29, 0x03, 0x75, 0x01, 0x95, 0x03, 0x15, 0x00, 0x25, 0x01, 0x81, 0x02, 0x95, 0x05, 0x81, 0x03,
    0x05, 0x01, 0x09, 0x30, 0x09, 0x31, 0x09, 0x38, 0x75, 0x08, 0x95, 0x03, 0x15, 0x81, 0x25, 0x7F,
    0x81, 0x06, 0xC0, 0xC0, 0x05, 0x01, 0x09, 0x06, 0xA1, 0x01, 0x85, 0x02, 0x05, 0x07, 0x19, 0xE0,
    0x29, 0xE7, 0x75, 0x01, 0x95, 0x08, 0x15, 0x00, 0x25, 0x01, 0x81, 0x02, 0x95, 0x01, 0x75, 0x08,
    0x81, 0x01, 0x19, 0x00, 0x29, 0xDD, 0x95, 0x06, 0x25, 0xDD, 0x81, 0x00, 0x85, 0x03, 0x05, 0x08,
    0x19, 0x01, 0x29, 0x05, 0x95, 0x05, 0x75, 0x01, 0x25, 0x01, 0x91, 0x02, 0x95, 0x03, 0x91, 0x03,
    0xC0
  ]
  
  override init() {
    super.init()
    self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
  }
  
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    if peripheral.state == .poweredOn {
      print("BLE HID Manager is powered on")
      isBluetoothReady = true
      setupServices()
      updateBatteryLevel()
      startAdvertising()
      
    }
    else {
      print("BLE HID Manager is powered on")
      isBluetoothReady = false
    }
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
    if request.characteristic.uuid == protocolModeCharacteristicUUID {
      protocolModeCharacteristic!.value = Data([currentProtocolMode])
      request.value = Data([currentProtocolMode]) // Respond with the current mode
      peripheralManager?.respond(to: request, withResult: .success)
    }
    else if request.characteristic.uuid == reportMapCharacteristicUUID {
      request.value = reportMapCharacteristic!.value
      peripheralManager?.respond(to: request, withResult: .success)
      
    }
    else if request.characteristic.uuid == batteryLevelCharacteristicUUID {
      let batteryLevel = getSystemBatteryLevel()
      request.value = Data([batteryLevel])
      peripheralManager?.respond(to: request, withResult: .success)
    }
    
    else if request.characteristic == BReport {
      request.value = BReport!.value
      peripheralManager?.respond(to: request, withResult: .success)
      
    }
    else if request.characteristic == AReport {
      request.value = AReport!.value
      peripheralManager?.respond(to: request, withResult: .success)
      
    }
    else if request.characteristic == CReport {
      request.value = CReport!.value
      peripheralManager?.respond(to: request, withResult: .success)
      
    }
    
    else if request.characteristic.uuid == bootKeyboardInputReportCharacteristicUUID {
      request.value = bootKeyboardInputReportCharacteristic!.value
      peripheralManager?.respond(to: request, withResult: .success)
    }
    else if request.characteristic.uuid == bootKeyboardOutputReportCharacteristicUUID {
      request.value = bootKeyboardOutputReportCharacteristic!.value
      peripheralManager?.respond(to: request, withResult: .success)
    }
    else if request.characteristic.uuid == controlPointCharacteristicUUID {
      controlPointCharacteristic!.value = Data([0x01])
      request.value = controlPointCharacteristic!.value
      peripheralManager?.respond(to: request, withResult: .success)
    }
    else {
      peripheralManager?.respond(to: request, withResult: .requestNotSupported)
    }
  }
  
  func getSystemBatteryLevel() -> UInt8 {
    UIDevice.current.isBatteryMonitoringEnabled = true
    let batteryLevel = UIDevice.current.batteryLevel
    let batteryPercentage = UInt8(batteryLevel * 100)
    return batteryPercentage
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
    for request in requests {
      if request.characteristic.uuid == protocolModeCharacteristicUUID {
        handleProtocolModeChange(request)
      } else if request.characteristic.uuid == reportCharacteristicUUID {
        handleReportWrite(request)
      }
      else if request.characteristic.uuid == batteryLevelCharacteristicUUID {
        request.value = batteryLevelCharacteristic!.value
        peripheralManager?.respond(to: request, withResult: .success)
      }
      else if request.characteristic.uuid == controlPointCharacteristicUUID {
        handleControlPointWrite(request)
      }
      else {
        print("didReceiveWrite Unknown characteristic: \(request.characteristic.uuid)")
        peripheralManager?.respond(to: request, withResult: .requestNotSupported)
      }
    }
  }
  
  private func handleProtocolModeChange(_ request: CBATTRequest) {
    guard let newValue = request.value?.first else {
      peripheralManager?.respond(to: request, withResult: .invalidAttributeValueLength)
      return
    }
    
    if newValue == 0x01 {
      currentProtocolMode = newValue
      peripheralManager?.respond(to: request, withResult: .success)
    }
    else if newValue == 0x00 {
      currentProtocolMode = newValue
      peripheralManager?.respond(to: request, withResult: .success)
    }
    else {
      print("Invalid protocol mode value")
      peripheralManager?.respond(to: request, withResult: .invalidPdu)
    }
  }
  
  private func handleReportWrite(_ request: CBATTRequest) {
    guard let data = request.value else {
      peripheralManager?.respond(to: request, withResult: .invalidAttributeValueLength)
      return
    }
    peripheralManager?.respond(to: request, withResult: .success)
  }
  
  private func handleControlPointWrite(_ request: CBATTRequest) {
    guard let value = request.value, let command = value.first else {
      peripheralManager?.respond(to: request, withResult: .invalidAttributeValueLength)
      return
    }
    
    peripheralManager?.respond(to: request, withResult: .success)
  }
  
  func startAdvertising() {
    let advertisementData: [String: Any] = [
      CBAdvertisementDataLocalNameKey: advertiseLocalName,
      CBAdvertisementDataServiceUUIDsKey: [hidServiceUUID],
    ]
    
    peripheralManager?.startAdvertising(advertisementData)
  }
  
  private func setupServices() {
    
    let deviceInfoService = CBMutableService(type: deviceInfoServiceUUID, primary: false)
    
    let pnpValue = Data(NSData(bytes: [0x0002, 0x10C4, 0x0001, 0x0001] as [UInt16], length: 8))
    let pnpIDCharacteristic = CBMutableCharacteristic(type: pnpIDCharacteristicUUID, properties: [.read], value: pnpValue, permissions: [.readable])
    
    let manufacturerNameCharacteristic = CBMutableCharacteristic(
      type: manufacturerNameCharacteristicUUID,
      properties: [.read],
      value: Data("HassanBleKeyboard".utf8),
      permissions: [.readable]
    )
    
    deviceInfoService.characteristics = [pnpIDCharacteristic, manufacturerNameCharacteristic]
    peripheralManager?.add(deviceInfoService)
    
    batteryLevelCharacteristic = CBMutableCharacteristic(
      type: batteryLevelCharacteristicUUID,
      properties: [.read, .notify],
      value: nil, // Battery level set to 100%
      permissions: [.readable]
    )
    
    let batteryService = CBMutableService(type: batteryServiceUUID, primary: true)
    batteryService.characteristics = [batteryLevelCharacteristic!]
    peripheralManager?.add(batteryService)
    
    let hidInformationCharacteristic = CBMutableCharacteristic(
      type: hidInformationCharacteristicUUID,
      properties: [.read],
      value: Data(NSData(bytes: [0x01, 0x11, 0x00, 0x02] as [UInt8], length: 4)),
      permissions: [.readable]
    )
    
    protocolModeCharacteristic = CBMutableCharacteristic(
      type: protocolModeCharacteristicUUID,
      properties: [.read, .notify, .writeWithoutResponse],
      value: nil,
      permissions: [.readable, .writeable]
    )
    
    reportMapCharacteristic = CBMutableCharacteristic(
      type: reportMapCharacteristicUUID,
      properties: [.read],
      value: Data(HID_REPORT_DESCRIPTOR),
      permissions: [.readable]
    )
    
    controlPointCharacteristic = CBMutableCharacteristic(
      type: controlPointCharacteristicUUID,
      properties: [.read, .writeWithoutResponse],
      value: nil,
      permissions: [.readable, .writeable]
    )
    
    bootKeyboardInputReportCharacteristic = CBMutableCharacteristic(
      type: bootKeyboardInputReportCharacteristicUUID,
      properties: [.read, .notify, .write],
      value: nil,
      permissions: [.readable, .writeable]
    )
    
    bootKeyboardOutputReportCharacteristic = CBMutableCharacteristic(
      type: bootKeyboardOutputReportCharacteristicUUID,
      properties: [.read, .write, .writeWithoutResponse],
      value: nil,
      permissions: [.readable, .writeable]
    )
    
    BReport = CBMutableCharacteristic(type: reportCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
    BReport!.descriptors = [CBMutableDescriptor(type: reportReferenceDiscriptorUUID, value: Data([0x01, 0x01]) )]
    
    AReport = CBMutableCharacteristic(type: reportCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
    AReport!.descriptors = [CBMutableDescriptor(type: reportReferenceDiscriptorUUID, value: Data([0x02, 0x01]) )]
    
    CReport = CBMutableCharacteristic(type: reportCharacteristicUUID, properties: [.read, .write], value: nil, permissions: [.readable, .writeable])
    CReport!.descriptors = [CBMutableDescriptor(type: reportReferenceDiscriptorUUID, value: Data([0x03, 0x02]) )]
    
    let hidService = CBMutableService(type: hidServiceUUID, primary: true)
    
    hidService.characteristics = [
      hidInformationCharacteristic,
      protocolModeCharacteristic!,
      reportMapCharacteristic!,
      BReport!,
      AReport!,
      CReport!,
      controlPointCharacteristic!
    ]
    peripheralManager?.add(hidService)
  }
  
  func updateBatteryLevel() {
    let AReportSampleData = Data( [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    let BReportSampleData = Data([0x00, 0x00, 0x00, 0x00])
    let CReportSampleData = Data([0x00])
    
    protocolModeCharacteristic!.value = Data(bytes: [currentProtocolMode] as [UInt8], count: 1)
    AReport!.value = AReportSampleData
    BReport!.value = BReportSampleData
    CReport!.value = CReportSampleData
    
    let batteryLevel = getSystemBatteryLevel()
    peripheralManager?.updateValue(Data([batteryLevel]), for: batteryLevelCharacteristic!, onSubscribedCentrals: nil)
  }
  
  func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
    print("BLE HID Keyboard advertising started")
  }
  
  @objc(sendKeys:)
  func sendKeys(_ key: String) -> Void {
    switch key {
      // Alphabet
    case "A":
        sendKeyPress(keyCode: 0x04, modifier: 0x02) // A
    case "a":
        sendKeyPress(keyCode: 0x04)  // a
    case "B":
        sendKeyPress(keyCode: 0x05, modifier: 0x02) // B
    case "b":
        sendKeyPress(keyCode: 0x05)  // b
    case "C":
        sendKeyPress(keyCode: 0x06, modifier: 0x02) // C
    case "c":
        sendKeyPress(keyCode: 0x06)  // c
    case "D":
        sendKeyPress(keyCode: 0x07, modifier: 0x02) // D
    case "d":
        sendKeyPress(keyCode: 0x07)  // d
    case "E":
        sendKeyPress(keyCode: 0x08, modifier: 0x02) // E
    case "e":
        sendKeyPress(keyCode: 0x08)  // e
    case "F":
        sendKeyPress(keyCode: 0x09, modifier: 0x02) // F
    case "f":
        sendKeyPress(keyCode: 0x09)  // f
    case "G":
        sendKeyPress(keyCode: 0x0A, modifier: 0x02) // G
    case "g":
        sendKeyPress(keyCode: 0x0A)  // g
    case "H":
        sendKeyPress(keyCode: 0x0B, modifier: 0x02) // H
    case "h":
        sendKeyPress(keyCode: 0x0B)  // h
    case "I":
        sendKeyPress(keyCode: 0x0C, modifier: 0x02) // I
    case "i":
        sendKeyPress(keyCode: 0x0C)  // i
    case "J":
        sendKeyPress(keyCode: 0x0D, modifier: 0x02) // J
    case "j":
        sendKeyPress(keyCode: 0x0D)  // j
    case "K":
        sendKeyPress(keyCode: 0x0E, modifier: 0x02) // K
    case "k":
        sendKeyPress(keyCode: 0x0E)  // k
    case "L":
        sendKeyPress(keyCode: 0x0F, modifier: 0x02) // L
    case "l":
        sendKeyPress(keyCode: 0x0F)  // l
    case "M":
        sendKeyPress(keyCode: 0x10, modifier: 0x02) // M
    case "m":
        sendKeyPress(keyCode: 0x10)  // m
    case "N":
        sendKeyPress(keyCode: 0x11, modifier: 0x02) // N
    case "n":
        sendKeyPress(keyCode: 0x11)  // n
    case "O":
        sendKeyPress(keyCode: 0x12, modifier: 0x02) // O
    case "o":
        sendKeyPress(keyCode: 0x12)  // o
    case "P":
        sendKeyPress(keyCode: 0x13, modifier: 0x02) // P
    case "p":
        sendKeyPress(keyCode: 0x13)  // p
    case "Q":
        sendKeyPress(keyCode: 0x14, modifier: 0x02) // Q
    case "q":
        sendKeyPress(keyCode: 0x14)  // q
    case "R":
        sendKeyPress(keyCode: 0x15, modifier: 0x02) // R
    case "r":
        sendKeyPress(keyCode: 0x15)  // r
    case "S":
        sendKeyPress(keyCode: 0x16, modifier: 0x02) // S
    case "s":
        sendKeyPress(keyCode: 0x16)  // s
    case "T":
        sendKeyPress(keyCode: 0x17, modifier: 0x02) // T
    case "t":
        sendKeyPress(keyCode: 0x17)  // t
    case "U":
        sendKeyPress(keyCode: 0x18, modifier: 0x02) // U
    case "u":
        sendKeyPress(keyCode: 0x18)  // u
    case "V":
        sendKeyPress(keyCode: 0x19, modifier: 0x02) // V
    case "v":
        sendKeyPress(keyCode: 0x19)  // v
    case "W":
        sendKeyPress(keyCode: 0x1A, modifier: 0x02) // W
    case "w":
        sendKeyPress(keyCode: 0x1A)  // w
    case "X":
        sendKeyPress(keyCode: 0x1B, modifier: 0x02) // X
    case "x":
        sendKeyPress(keyCode: 0x1B)  // x
    case "Y":
        sendKeyPress(keyCode: 0x1C, modifier: 0x02) // Y
    case "y":
        sendKeyPress(keyCode: 0x1C)  // y
    case "Z":
        sendKeyPress(keyCode: 0x1D, modifier: 0x02) // Z
    case "z":
        sendKeyPress(keyCode: 0x1D)  // z
      
    // Numbers
    case "1":
      sendKeyPress(keyCode: 0x1E)  // 1
    case "2":
      sendKeyPress(keyCode: 0x1F)  // 2
    case "3":
      sendKeyPress(keyCode: 0x20)  // 3
    case "4":
      sendKeyPress(keyCode: 0x21)  // 4
    case "5":
      sendKeyPress(keyCode: 0x22)  // 5
    case "6":
      sendKeyPress(keyCode: 0x23)  // 6
    case "7":
      sendKeyPress(keyCode: 0x24)  // 7
    case "8":
      sendKeyPress(keyCode: 0x25)  // 8
    case "9":
      sendKeyPress(keyCode: 0x26)  // 9
    case "0":
      sendKeyPress(keyCode: 0x27)  // 0
      
      // Other Keys
    case "ENTER":
      sendKeyPress(keyCode: 0x28)  // Enter
    case "ESC":
      sendKeyPress(keyCode: 0x29)  // Escape
    case "SPACE":
      sendKeyPress(keyCode: 0x2C)  // Spacebar
    case "DELETE":
      sendKeyPress(keyCode: 0x2A)  // Delete
    case "TAB":
      sendKeyPress(keyCode: 0x2B)  // Tab
    case "CAPSLOCK":
      sendKeyPress(keyCode: 0x39)  // Caps Lock - does not work!
    case "LEFT":
      sendKeyPress(keyCode: 0x50)  // Left Arrow
    case "RIGHT":
      sendKeyPress(keyCode: 0x4F)  // Right Arrow
    case "UP":
      sendKeyPress(keyCode: 0x52)  // Up Arrow
    case "DOWN":
      sendKeyPress(keyCode: 0x51)  // Down Arrow
      
      // Dot and Comma
    case ".":
      sendKeyPress(keyCode: 0x37)  // . key
    case ",":
      sendKeyPress(keyCode: 0x36)  // , key
      
      //Special Characters
    case "!":
        sendKeyPress(keyCode: 0x1E, modifier: 0x02) // ! (with Shift)
    case "@":
        sendKeyPress(keyCode: 0x1F, modifier: 0x02) // @ (with Shift)
    case "#":
        sendKeyPress(keyCode: 0x20, modifier: 0x02) // # (with Shift)
    case "$":
        sendKeyPress(keyCode: 0x21, modifier: 0x02) // $ (with Shift)
    case "%":
        sendKeyPress(keyCode: 0x22, modifier: 0x02) // % (with Shift)
    case "^":
        sendKeyPress(keyCode: 0x23, modifier: 0x02) // ^ (with Shift)
    case "&":
        sendKeyPress(keyCode: 0x24, modifier: 0x02) // & (with Shift)
    case "*":
        sendKeyPress(keyCode: 0x25, modifier: 0x02) // * (with Shift)
    case "(":
        sendKeyPress(keyCode: 0x26, modifier: 0x02) // ( (with Shift)
    case ")":
        sendKeyPress(keyCode: 0x27, modifier: 0x02) // ) (with Shift)
    case ";":
        sendKeyPress(keyCode: 0x33) // ; (no Shift)
    case ":":
        sendKeyPress(keyCode: 0x33, modifier: 0x02) // : (with Shift)
    case "/":
        sendKeyPress(keyCode: 0x38) // / (no Shift)
    case "?":
        sendKeyPress(keyCode: 0x38, modifier: 0x02) // ? (with Shift)
    case "<":
        sendKeyPress(keyCode: 0x36, modifier: 0x02) // < (with Shift)
    case ">":
        sendKeyPress(keyCode: 0x37, modifier: 0x02) // > (with Shift)
    case "_":
        sendKeyPress(keyCode: 0x2D, modifier: 0x02) // _ (with Shift)
    case "-":
        sendKeyPress(keyCode: 0x2D) // - (no Shift)
    case "+":
        sendKeyPress(keyCode: 0x2E, modifier: 0x02) // + (with Shift)
    case "=":
        sendKeyPress(keyCode: 0x2E) // = (no Shift)
    case "[":
        sendKeyPress(keyCode: 0x2F) // [ (no Shift)
    case "]":
        sendKeyPress(keyCode: 0x30) // ] (no Shift)
    case "{":
        sendKeyPress(keyCode: 0x2F, modifier: 0x02) // { (with Shift)
    case "}":
        sendKeyPress(keyCode: 0x30, modifier: 0x02) // } (with Shift)
    default:
      print("Key \(key) not mapped.")
    }
  }
  
  @objc(moveMouse:)
  func moveMouse(_ direction: String) -> Void {
    switch direction {
    case "right":
      peripheralManager?.updateValue(
        Data(
          [
            0x00,
            0x0A,
            0x00,
            0x00
          ]),
        for: BReport!,
        onSubscribedCentrals: nil)
    case "left":
      peripheralManager?.updateValue(
        Data(
          [
            0x00,
            0xF6,
            0x00,
            0x00
          ]),
        for: BReport!,
        onSubscribedCentrals: nil)
    case "up":
      peripheralManager?.updateValue(
        Data(
          [
            0x00, // 0x01 is left 0x02 right click
            0x00, // x
            0xF6, // y
            0x00  // related to something else
          ]),
        for: BReport!,
        onSubscribedCentrals: nil)
    case "down":
      peripheralManager?.updateValue(
        Data(
          [
            0x00,
            0x00,
            0x0A,
            0x00
          ]),
        for: BReport!,
        onSubscribedCentrals: nil)
    default:
      print("Invalid direction")
    }
  }
  
  @objc(mouseClick:)
  func mouseClick(_ button: String) -> Void {
    if(button == "left") {
      peripheralManager?.updateValue(
        Data(
          [
            0x01,
            0x00,
            0x00,
            0x00
          ]),
        for: BReport!,
        onSubscribedCentrals: nil)
      usleep(50000)
      peripheralManager?.updateValue(
        Data(
          [
            0x00,
            0x00,
            0x00,
            0x00]
        ),
        for: BReport!,
        onSubscribedCentrals: nil)
    }
    else if(button == "right") {
      peripheralManager?.updateValue(
        Data(
          [
            0x02,
            0x00,
            0x00,
            0x00
          ]),
        for: BReport!,
        onSubscribedCentrals: nil)
      usleep(50000)
      peripheralManager?.updateValue(
        Data(
          [
            0x00,
            0x00,
            0x00,
            0x00
          ]),
        for: BReport!,
        onSubscribedCentrals: nil)
    }
  }
  
  func sendKeyPress(keyCode: UInt8, modifier: UInt8 = 0x00) {
      // Construct the HID input report:
      // First byte: Modifier keys (e.g., SHIFT, CTRL, ALT)
      // Second byte: Reserved (always 0x00)
      // Next 6 bytes: Key codes (press up to 6 keys simultaneously)
      let report = Data([modifier, 0x00, keyCode, 0x00, 0x00, 0x00, 0x00, 0x00])

      // Update characteristic value and notify subscribed centrals
      guard let aReport = AReport, let peripheralManager = peripheralManager else {
          print("Failed to send key press: Peripheral manager or characteristic unavailable.")
          return
      }

      // Send key press report
      aReport.value = report
      peripheralManager.updateValue(report, for: aReport, onSubscribedCentrals: nil)

      // Simulate key release by sending an empty key press report after a delay
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          let releaseReport = Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
          aReport.value = releaseReport
          peripheralManager.updateValue(releaseReport, for: aReport, onSubscribedCentrals: nil)
      }
  }
  
  //below not in use old approach without shift key
//  func sendKeyPress(keyCode: UInt8) {
//    peripheralManager?.updateValue(
//      Data(
//        [
//          0x00,
//          0x00,
//          keyCode,
//          0x00,
//          0x00,
//          0x00,
//          0x00,
//          0x00
//        ]),
//      for: AReport!,
//      onSubscribedCentrals: nil)
//    usleep(50000)
//    peripheralManager?.updateValue(
//      Data(
//        [
//          0x00,
//          0x00,
//          0x00,
//          0x00,
//          0x00,
//          0x00,
//          0x00,
//          0x00
//        ]),
//      for: AReport!,
//      onSubscribedCentrals: nil)
//  }
  
  func sendKeyRelease() {
    peripheralManager?.updateValue(
      Data([
        0x00,
        0x00,
        0x00,
        0x00, 0x00, 0x00, 0x00, 0x00
      ]),
      for: AReport!,
      onSubscribedCentrals: nil)
  }
  
  func moveMouse() {
    peripheralManager?.updateValue(
      Data([
        0x00,
        0x0A,
        0x00,
        0x00
      ]),
      for: BReport!,
      onSubscribedCentrals: nil)
  }
}
