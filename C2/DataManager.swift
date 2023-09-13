//
//  DataManager.swift
//  C2
//
//  Created by chengxin on 2023/9/8.
//

import SwiftOTP
import Foundation

class DataManager {
    static let shared = DataManager()

    private init() { }

    func saveItems(_ items: [G2FAItem]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            let url = getDocumentsDirectory().appendingPathComponent("g2faItems.json")
            try data.write(to: url)
        } catch {
            print("Failed to save items: \(error.localizedDescription)")
        }
    }

    func loadItems() -> [G2FAItem]? {
        do {
            let url = getDocumentsDirectory().appendingPathComponent("g2faItems.json")
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let items = try decoder.decode([G2FAItem].self, from: data)
            return items
        } catch {
            print("Failed to load items: \(error.localizedDescription)")
            return nil
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func getCode(secret: String) -> String {
           let time = Int(Date().timeIntervalSince1970)
           let code = generateTOTP(secret: secret, time: time)
           return String(format: "%06d", code)
    }
       
    func generateTOTP(secret: String, time: Int) -> Int {
        guard let data = base32DecodeToData(secret) else { return 0 }
        let totp = TOTP(secret: data, digits: 6, timeInterval: 30, algorithm: .sha1)!
        guard let code = totp.generate(time: Date(timeIntervalSince1970: TimeInterval(time))) else { return 0 }
        return Int(code)!
    }
}
