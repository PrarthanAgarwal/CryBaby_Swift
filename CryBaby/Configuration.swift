import Foundation
import SwiftUI
import CoreText

extension Bundle {
    func registerFonts() {
        let fontNames = ["Poppins-Regular", "Poppins-Medium", "Poppins-SemiBold", "Poppins-Bold"]
        fontNames.forEach { fontName in
            guard let fontURL = self.url(forResource: "Fonts/\(fontName)", withExtension: "ttf") else {
                print("Could not find font file: \(fontName)")
                return
            }
            
            var error: Unmanaged<CFError>?
            guard CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) else {
                print("Error registering font: \(fontName)")
                if let error = error?.takeUnretainedValue() {
                    print("Error description: \(error)")
                }
                return
            }
            
            print("Successfully registered font: \(fontName)")
        }
    }
} 