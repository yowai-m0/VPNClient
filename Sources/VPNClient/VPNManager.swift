import Foundation
import NetworkExtension

@available(iOS 15.0, *)
public class VPNManager: ObservableObject {
    public static let shared = VPNManager()
    
    @Published public var status: NEVPNStatus = .disconnected
    
    private var vpnManager: NEVPNManager {
        return NEVPNManager.shared()
    }
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(vpnStatusChanged),
            name: .NEVPNStatusDidChange,
            object: nil
        )
    }
    
    public func configureVPN(serverAddress: String, username: String, password: String) {
        vpnManager.loadFromPreferences { error in
            if let error = error {
                print("Ошибка загрузки: \(error)")
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
                    print("Ошибка сохранения: \(error)")
                } else {
                    print("VPN настроен успешно")
                }
            }
        }
    }
    
    public func startVPN() {
        vpnManager.loadFromPreferences { error in
            if let error = error {
                print("Ошибка: \(error)")
                return
            }
            do {
                try self.vpnManager.connection.startVPNTunnel()
                print("VPN запускается...")
            } catch {
                print("Не удалось запустить: \(error)")
            }
        }
    }
    
    public func stopVPN() {
        vpnManager.connection.stopVPNTunnel()
        print("VPN остановлен")
    }
    
    private func savePasswordToKeychain(_ password: String) -> Data? {
        let passwordData = password.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "vpn_password",
            kSecValueData as String: passwordData
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess ? passwordData : nil
    }
    
    @objc private func vpnStatusChanged() {
        DispatchQueue.main.async {
            self.status = self.vpnManager.connection.status
        }
    }
}