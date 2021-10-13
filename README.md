# heartRateMonitor
App wich can indicate Beats per minutes from the MiBand 4 device ,monitor charts in the real time 
Also this app can persist Results of heart rate and store it by using Realm DB

If you want to use different type of heart rate device ,try to change name of conectedPeriferals in  

    
    ![alt text](  func getBMP() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [self] _ in
            self.conectedPeriferals["Mi Smart Band 4"]?.readValue(for: self.bpmCharacteristic!)
            print("BPM:", self.heartRate(from: self.bpmCharacteristic!))
        }
    })
    
   ![screenShot](https://user-images.githubusercontent.com/29837060/137176418-35c725c7-feb6-40df-a275-478a17d3d744.PNG)
