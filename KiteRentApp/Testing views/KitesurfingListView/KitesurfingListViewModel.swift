//
//  KitesurfingListViewModel.swift
//  KiteRentApp
//
//  Created by Filip on 15/11/2025.
//

import Foundation
import Combine

@MainActor
final class KitesurfingListViewModel: ObservableObject {
    @Published var kites: [DBKite] = []
    @Published var rentalsByKite: [String: DBRental] = [:]
    @Published var instructors: [String: DBInstructor] = [:]     // 🔥 nowość
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var timer: Timer?
    private let refreshInterval: TimeInterval = 10

    // MARK: - Computed

    var filteredKites: [DBKite] {
        guard !searchText.isEmpty else { return kites }
        return kites.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Listening

    func startListening() {
        Task {
            await loadKites()
            await loadActiveRentals()
            await loadInstructors()       // 🔥 wczytywanie instruktorów
        }

        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.checkFinishedRentals()
                await self?.loadActiveRentals()
                await self?.loadInstructors()   // 🔥 aktualizacja instruktorów
            }
        }
    }

    func stopListening() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Load functions

    func loadKites() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            let fetched = try await KiteManager.shared.getAllKites()
            self.kites = fetched
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadActiveRentals() async {
        do {
            let now = Date()
            let all = try await RentalManager.shared.getAllRentals()

            let active = all.filter { $0.startTime <= now && $0.endTime >= now }

            self.rentalsByKite = Dictionary(
                uniqueKeysWithValues: active.map { ($0.kiteId, $0) }
            )
        } catch {
            print("Error loading rentals: \(error)")
        }
    }

    func loadInstructors() async {      // 🔥 nowa funkcja
        do {
            let list = try await InstructorManager.shared.getAllInstructors()
            self.instructors = Dictionary(
                uniqueKeysWithValues: list.map { ($0.instructorId, $0) }
            )
        } catch {
            print("Error loading instructors: \(error)")
        }
    }

    // MARK: - Timer logic

    private func checkFinishedRentals() async {
        do {
            let now = Date()
            let ended = try await RentalManager.shared.getRentalsEndingBefore(now)

            for rental in ended {
                if let index = kites.firstIndex(where: { $0.id == rental.kiteId }) {
                    var kite = kites[index]

                    if kite.state == .used {
                        try await KiteManager.shared.updateKiteState(kiteId: kite.id, state: .free)
                        kite.state = .free
                        kites[index] = kite
                    }
                }
            }
        } catch {
            print("Timer rental check error: \(error)")
        }
    }

    // MARK: - Instructor binding

    func getInstructorForKite(kiteId: String) -> String? {
        guard let rental = rentalsByKite[kiteId],
              let instructor = instructors[rental.instructorId]
        else { return nil }

        return instructor.shortName      // 🔥 pełne short name
    }
}
