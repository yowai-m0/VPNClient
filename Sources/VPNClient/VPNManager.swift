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
                print("Ошибка загрузки конфигурации: \(error.localizedDescription)")
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
                    print("Ошибка сохранения: \(error.localizedDescription)")
                } else {
                    print("VPN настроен успешно!")
                }
            }
        }
    }

    public func startVPN() {
        vpnManager.loadFromPreferences { error in
            if let error = error {
                print("Ошибка: \(error.localizedDescription)")
                return
            }
            do {
                try self.vpnManager.connection.startVPNTunnel()
                print("VPN запускается...")
            } catch {
                print("Не удалось запустить VPN: \(error.localizedDescription)")
            }
        }
    }

    public func stopVPN() {
        vpnManager.connection.stopVPNTunnel()
        print("VPN остановлен")
    }

    public func getStatus() -> String {
        switch vpnManager.connection.status {
        case .disconnected:
            return "Отключен"
        case .connecting:
            return "Подключение..."
        case .connected:
            return "Подключен"
        case .disconnecting:
            return "Отключение..."
        @unknown default:
            return "Неизвестно"
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
            print("Пароль сохранен в Keychain")
            return passwordData
        } else {
            print("Ошибка сохранения пароля: \(status)")
            return nil
        }
    }
}
