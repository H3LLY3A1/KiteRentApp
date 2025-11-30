//
//  KiteManager.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import Foundation
import FirebaseFirestore

final class KiteManager {
    
    static let shared = KiteManager()
    private init() { }
    
    private let kiteCollection = Firestore.firestore().collection("kites")
    
    private func kiteDocument(kiteId: String) -> DocumentReference {
        kiteCollection.document(kiteId)
    }
    
    func createNewKite(kite: DBKite) async throws {
        try kiteDocument(kiteId: kite.id!).setData(from: kite, merge: false)
    }
    
//    func getAllKites() async throws -> [DBKite] {
//        let snapshot = try await kiteCollection.getDocuments()
//        
//        var kites: [DBKite] = []
//        
//        for document in snapshot.documents {
//            var data = document.data()
//            
//            if let timestamp = data["date_created"] as? Timestamp {
//                data["date_created"] = timestamp.dateValue().timeIntervalSince1970
//            }
//            
//            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
//            let kite = try JSONDecoder().decode(DBKite.self, from: jsonData)
//            kites.append(kite)
//        }
//        
//        return kites
//    }

    func getAllKites() async throws -> [DBKite] {
        let snapshot = try await kiteCollection.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: DBKite.self) }
    }

    

//    func getKite(kiteId: String) async throws -> DBKite {
//        let snapshot = try await kiteDocument(kiteId: kiteId).getDocument()
//        
//        guard var data = snapshot.data() else {
//            throw URLError(.badServerResponse)
//        }
//        
//        if let timestamp = data["date_created"] as? Timestamp {
//            data["date_created"] = timestamp.dateValue().timeIntervalSince1970
//        }
//        
//        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
//        return try JSONDecoder().decode(DBKite.self, from: jsonData)
//    }
    
    func updateKite(kite: DBKite) async throws {
        try kiteDocument(kiteId: kite.id!).setData(from: kite, merge: true)
    }
    
    func getKite(kiteId: String) async throws -> DBKite {
        try await kiteDocument(kiteId: kiteId).getDocument(as: DBKite.self)
    }
}


