# heartRateMonitor
App wich can indicate Beats per minutes from the MiBand 4 device ,monitor charts in the real time 
Also this app can persist Results of heart rate and store it by using Realm DB

If you want to use different type of heart rate decvice ,try to change name of conectedPeriferals in  

  func getBMP() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [self] _ in
            self.conectedPeriferals["Mi Smart Band 4"]?.readValue(for: self.bpmCharacteristic!)
            print("BPM:", self.heartRate(from: self.bpmCharacteristic!))
        }
    }
    
    ![alt text](https://github.com/GenuineMas/vibrationMonitor/blob/master/Dreamer/Assets.xcassets/screenShot.imageset/screenShot.PNG)
