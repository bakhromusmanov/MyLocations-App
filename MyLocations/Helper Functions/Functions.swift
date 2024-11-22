//
//  Functions.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 22/11/24.
//
import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
   DispatchQueue.main.asyncAfter(
      deadline: .now() + seconds,
      execute: run)
}
