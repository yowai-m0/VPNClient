import Foundation

import NetworkExtension

@available(iOS 15.0, *)
public class VPNManager {
    public static let shared = VPNManager()

    private var vpnManager: NEVPNManager {
        return NEVPNManager.shared()
    }

    private init() {}

    public func configureVPN(serverAddress: String, username: String, password: String) {
        vpnManager.loadFromPreferences { error in
            if let error = error {
                print("Error loading config: \(error.localizedDescription)")
                return
            }

            let protocolConfig = NEVPNProtocolIKEv2()
            protocolConfig.serverAddress = serverAddress
            protocolConfig.username = username
            protocolConfig.passwordReference = self.savePasswordToKeychain(password)
            protocolConfig.authenticationMethod = .none
            protocolConfig.useExtendedAuthentication = true
            protocolConfig.disconnectOnSleep = false

            self.vpnManager.protocolConfiguration = protocolConfig
            self.vpnManager.localizedDescription = "VPN Client"
            self.vpnManager.isEnabled = true

            self.vpnManager.saveToPreferences { error in
                if let error = error {
                    print("Error saving: \(error.localizedDescription)")
                } else {
                    print("VPN configured successfully!")
                }
            }
        }
    }

    public func startVPN() {
        vpnManager.loadFromPreferences { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            do {
                try self.vpnManager.connection.startVPNTunnel()
                print("VPN starting...")
            } catch {
                print("Failed to start VPN: \(error.localizedDescription)")
            }
        }
    }

    public func stopVPN() {
        vpnManager.connection.stopVPNTunnel()
        print("VPN stopped")
    }

    public func getStatus() -> String {
        switch vpnManager.connection.status {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .disconnecting:
            return "Disconnecting..."
        case .invalid:
            return "Invalid"
        case .reasserting:
            return "Reasserting"
        @unknown default:
            return "Unknown"
        }
    }

    private func savePasswordToKeychain(_ password: String) -> Data? {
        let passwordData = password.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "vpn_password",
            kSecValueData as String: passwordData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            print("Password saved to Keychain")
            return passwordData
        } else {
            print("Error saving password: \(status)")
            return nil
        }
    }
}
