import Foundation
import Security

// Arguments for the keychain queries
let kSecClassValue = String(kSecClass)
let kSecAttrAccountValue = String(kSecAttrAccount)
let kSecValueDataValue = String(kSecValueData)
let kSecClassGenericPasswordValue = String(kSecClassGenericPassword)
let kSecAttrServiceValue = String(kSecAttrService)
let kSecMatchLimitValue = String(kSecMatchLimit)
let kSecReturnDataValue = String(kSecReturnData)
let kSecMatchLimitOneValue = String(kSecMatchLimitOne)

internal class KeychainService {

    internal class func save(session: Session?) {
        guard let session = session else {
            return
        }

        do {
            let encodedSession = try PropertyListEncoder().encode(session)
            let keychainQuery: [String: Any] = [kSecClassValue: kSecClassGenericPasswordValue,
                                                kSecAttrServiceValue: Constants.KeychainServiceValue,
                                                kSecAttrAccountValue: session.userName,
                                                kSecValueDataValue: encodedSession]
            UserDefaults.standard.set(session.userName, forKey: Constants.KeychainUsernameKey)
            SecItemDelete(keychainQuery as CFDictionary)
            SecItemAdd(keychainQuery as CFDictionary, nil)
        } catch {}
    }

    internal class func loadSession() -> Session? {
        guard let userName = UserDefaults.standard.value(forKey: Constants.KeychainUsernameKey) else {
            return nil
        }

        let keychainQuery: [String: Any] = [kSecClassValue: kSecClassGenericPasswordValue,
                                            kSecAttrServiceValue: Constants.KeychainServiceValue,
                                            kSecAttrAccountValue: userName,
                                            kSecReturnDataValue: kCFBooleanTrue,
                                            kSecMatchLimitValue: kSecMatchLimitOneValue]

        var dataBuffer: AnyObject?

        let status: OSStatus = SecItemCopyMatching(keychainQuery as CFDictionary, &dataBuffer)

        if status == errSecSuccess {
            if let contentsOfKeychain = dataBuffer as? Data {
                let decodedSession = try? PropertyListDecoder().decode(Session.self, from: contentsOfKeychain)
                return decodedSession
            }
        }

        return nil
    }
}