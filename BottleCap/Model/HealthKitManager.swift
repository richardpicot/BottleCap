//
//  HealthKitManager.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 06/10/2023.
//

import HealthKit

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()

    @Published var isHealthDataAvailable: Bool = false

    enum HealthKitAuthorizationStatus {
        case authorized
        case notDetermined
        case denied
    }

    // Checks the authorization status of HealthKit
    func checkHealthKitAuthorization(completion: @escaping (HealthKitAuthorizationStatus) -> Void) {
        let drinkType = HKObjectType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!

        // Check the current authorization status
        let status = healthStore.authorizationStatus(for: drinkType)

        DispatchQueue.main.async {
            switch status {
            case .notDetermined:
                // User has not yet made a choice regarding whether this app can access HealthKit data
                completion(.notDetermined)
            case .sharingDenied:
                // User has explicitly denied this app access to HealthKit data
                completion(.denied)
            case .sharingAuthorized:
                // User has authorized this app to access HealthKit data
                completion(.authorized)
            @unknown default:
                // Handle any future cases
                completion(.denied)
            }
        }
    }

    // Requests permissions for HealthKit
    func requestHealthKitPermission(completion: @escaping (Bool, Error?) -> Void) {
        let readTypes: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!]
        let writeTypes: Set<HKSampleType> = [HKObjectType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!]

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            DispatchQueue.main.async { // Ensure UI updates are on main thread
                if success {
                    self.isHealthDataAvailable = true
                    print("Permission granted")
                } else {
                    self.isHealthDataAvailable = false
                    print("Permission denied \(String(describing: error?.localizedDescription))")
                }
                completion(success, error)
            }
        }
    }

    func readAlcoholData(startWeekDay: Weekday, completion: @escaping (Double) -> Void) {
        let calendar = Calendar.current
        let now = Date()

        guard let closestPastWeekday = calendar.date(toNearestOrLastWeekday: startWeekDay, matching: now) else {
            completion(0)
            return
        }

        // Ensure the start of the week is at the beginning of the day
        let startOfWeek = calendar.startOfDay(for: closestPastWeekday)

        print("Updated startOfWeek: \(startOfWeek), closestPastWeekday: \(closestPastWeekday)")

        // Create a predicate based on the adjusted start of the week
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: now, options: .strictStartDate)

        // Specify the sample type
        let sampleType = HKObjectType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!

        // Create the query with predicate
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, _ in
            var totalDrinks = 0.0
            if let results = results as? [HKQuantitySample] {
                for sample in results {
                    totalDrinks += sample.quantity.doubleValue(for: HKUnit.count())
                }
            }
            completion(totalDrinks)
        }

        print("Calculated startOfWeek: \(startOfWeek), closestPastWeekday: \(closestPastWeekday)")

        // Execute the query
        healthStore.execute(query)
    }

    func addAlcoholData(numberOfDrinks: Double, date: Date, completion: (() -> Void)? = nil) {
        // Create the quantity and the sample
        let quantity = HKQuantity(unit: HKUnit.count(), doubleValue: numberOfDrinks)
        let sampleType = HKQuantityType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!
        let sample = HKQuantitySample(type: sampleType, quantity: quantity, start: date, end: date)

        // Save the sample to the health store
        healthStore.save(sample) { success, error in
            if success {
                print("Successfully saved data")
                DispatchQueue.main.async {
                    completion?()
                }
            } else {
                if let error = error {
                    print("Error Saving Data: \(error)")
                }
            }
        }
    }

    func readAllAlcoholEntries(completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.numberOfAlcoholicBeverages) else {
            print("The numberOfAlcoholicBeverages type is not available")
            return
        }

        let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, results, _ in
            if let results = results as? [HKQuantitySample] {
                completion(results)
            }
        }

        HKHealthStore().execute(query)
    }

    func deleteAlcoholData(sample: HKQuantitySample, completion: @escaping (Bool, Error?) -> Void) {
        healthStore.delete(sample) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Successfully deleted alcohol data")
                } else {
                    print("Error deleting data: \(String(describing: error?.localizedDescription))")
                }
                completion(success, error)
            }
        }
    }

    func deleteAlcoholDataForDate(_ date: Date, completion: @escaping (Bool, Error?) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let sampleType = HKObjectType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!

        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            if let results = results as? [HKQuantitySample], !results.isEmpty {
                // Delete all samples for this date
                self.healthStore.delete(results) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            print("Successfully deleted alcohol data for date: \(date)")
                        } else {
                            print("Error deleting data for date: \(String(describing: error?.localizedDescription))")
                        }
                        completion(success, error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }

        healthStore.execute(query)
    }
}
