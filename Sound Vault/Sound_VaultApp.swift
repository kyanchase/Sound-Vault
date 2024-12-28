//
//  Sound_VaultApp.swift
//  Sound Vault
//
//  Created by Kyan Chase on 12/20/24.
//

import SwiftUI

@main
struct Sound_VaultApp: App {
    @StateObject private var vaultViewModel = VaultViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vaultViewModel)
        }
    }
}
