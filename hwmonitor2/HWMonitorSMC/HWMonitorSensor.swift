//
//  HWMonitorSensor.swift
//  HWMS2
//
//  Created by Vector Sigma on 18/10/2018.
//  Copyright © 2018 Vector Sigma. All rights reserved.
//

import Cocoa

enum LogType : Int {
  case noLog      = 0
  case systemLog  = 1
  case cpuLog     = 2
  case gpuLog     = 3
  case memoryLog  = 4
  case mediaLog   = 5
  case batteryLog = 6
  case usbLog     = 7
}

enum HWUnit : String {
  case auto     = " "
  case GHz      = "GHz"
  case MHz      = "MHz"
  case MB       = "MB"
  case GB       = "GB"
  case C        = "°C"
  case Watt     = "W"
  case mWh      = "mWh"
  case Joule    = "J"
  case Volt     = "V"
  case mV       = "mV"
  case mA       = "mA"
  case RPM      = "rpm"
  case Percent  = "%"
}

enum HWSensorType : Int {
  // generic percentage
  case percent              =  0
  
  // Intel Power Gadget specific
  case intelCPUFrequency    =  1
  case intelGPUFrequency    =  2
  case intelmWh             =  3
  case intelJoule           =  4
  case intelWatt            =  5
  case intelTemp            =  6

  // SMC
  case cpuPowerWatt         =  7
  case temperature          =  8
  case voltage              =  9
  case tachometer           = 10
  case frequencyCPU         = 11
  case frequencyGPU         = 12
  case frequencyOther       = 13
  case multiplier           = 14
  
  // S.M.A.R.T.
  case hdSmartTemp          = 15
  case hdSmartLife          = 16
  case mediaSMARTContenitor = 17 // identify just the sub groups that aren't sensors
  
  // Battery (actually taken from the driver only)
  case battery              = 18
  case genericBattery       = 19

  case gpuIO_coreClock      = 20
  case gpuIO_temp           = 21
  case gpuIO_FanRPM         = 22
  case gpuIO_percent        = 23
  case gpuIO_RamBytes       = 24
  
  
  // RAM. Taken from the System
  case memory               = 25
  // usb, taken from the driver. used only in logs
  case usb                  = 26
}


class HWMonitorSensor: NSObject {
  var prefix : String = ""
  var key : String
  var type : String
  var title : String
  var sensorType : HWSensorType
  var outLine: HWOulineView?
  var favorite: Bool = false
  var logType : LogType = .noLog
  var unit : HWUnit
  var doubleValue : Double = 0
  var str : String = ""
  
  var isInformativeOnly: Bool = false
  
  let canPlot: Bool
  var hasPlot: Bool = false
  var plot : PlotView? = nil
  
  var stringValue: String {
    get {
      return self.str
    }
    set {
      if self.canPlot && self.hasPlot { // update the plot
        if (self.plot == nil) {
          self.addPlot()
        }
        self.plot?.newData(value: self.doubleValue)
      } else {
        if (self.plot != nil) {
          self.plot = nil
        }
      }
      self.str = newValue
    }
  }
  
  func removePlot() {
    self.plot = nil
    self.hasPlot = false
    UDs.set(false, forKey: "coreplot_" + self.key)
    UDs.synchronize()
  }
  func addPlot() {
    self.plot = PlotView(frame: NSRect(x: 0, y: 0, width: 111, height: 17), sensor: self)
    self.hasPlot = true
    UDs.set(true, forKey: "coreplot_" + self.key)
    UDs.synchronize()
  }

  var format : String = ""
  var characteristics : String = ""
  var vendor : String = ""
  
  init(key: String, unit: HWUnit, type: String, sensorType: HWSensorType, title: String, canPlot: Bool) {
    self.type = type
    self.key = key;
    self.sensorType = sensorType;
    self.title = title
    self.unit = unit
    
    self.canPlot = canPlot
    if self.canPlot {
      self.hasPlot = UDs.bool(forKey: "coreplot_" + self.key)
    }
  }
}

