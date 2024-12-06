//
//  G2FAItem.swift
//  C2
//
//  Created by chengxin on 2023/9/7.
//

import Foundation

struct G2FAItem: Codable, Identifiable {
    var id: UUID = UUID()
    var label: String
    var secret: String
}

func saveItems(_ items: [G2FAItem]) {
    do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(items)
        let url = getDocumentsDirectory().appendingPathComponent(
            "g2faItems.json")
        try data.write(to: url)
    } catch {
        print("Failed to save items: \(error.localizedDescription)")
    }
}

func loadItems() -> [G2FAItem]? {
    do {
        let url = getDocumentsDirectory().appendingPathComponent(
            "g2faItems.json")
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
    let paths = FileManager.default.urls(
        for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
