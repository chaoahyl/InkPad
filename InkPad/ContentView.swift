import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GalleryPage()
                .tabItem { Label("作品", systemImage: "square.grid.2x2") }
            SignaturePage()
                .tabItem { Label("签名", systemImage: "signature") }
        }
    }
}
