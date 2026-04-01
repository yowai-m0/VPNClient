import Foundation

import NetworkExtension

print("========================================")
print("VPN Client for iOS")
print("========================================")
print()
if #available(iOS 15.0, *) {
    print("[OK] iOS 15.0+ available")
} else {
    print("[ERROR] iOS 15.0+ required")
}
let manager = VPNManager.shared
print("[OK] VPN Manager initialized")
print()
print("Current VPN status: \(manager.getStatus())")
print()
print("Usage:")
print(
    "  manager.configureVPN(serverAddress: \"vpn.example.com\", username: \"user\", password: \"pass\")"
)
print("  manager.startVPN()")
print("  manager.stopVPN()")
print()
print("========================================")
print("Ready")
RunLoop.main.run()
