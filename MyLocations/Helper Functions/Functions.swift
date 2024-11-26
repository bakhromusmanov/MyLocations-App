//
//  Functions.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 22/11/24.
//
import Foundation

//MARK: Showing HUD with delay
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
   DispatchQueue.main.asyncAfter(
      deadline: .now() + seconds,
      execute: run)
}

//MARK: Core Data File Directory
let applicationDocumentsDirectory: URL = {
   let paths = FileManager.default.urls(
      for: .documentDirectory,
      in: .userDomainMask)
   return paths[0]
}()

//MARK: Core Data Error Notification
let dataSaveFailedNotification = Notification.Name("DataSaveFailedNotification")

func fatalCoreDataError(_ error: Error) {
   print("Fatal Error \(error.localizedDescription)")
   NotificationCenter.default.post(name: dataSaveFailedNotification, object: nil)
}
