import Combine
import SwiftUI
import Introspect

struct ContentView: View {
    
    var body: some View {
        TabView {
            NavigationView {
                TabItemView(num: 1)
            }.tabItem {
                Text("One")
            }
            NavigationView {
                TabItemView(num: 2)
            }.tabItem {
                Text("Two")
            }
        }
    }
}

struct TabItemView: View {
    
    private let num: Int
    
    init(num: Int) {
        self.num = num
    }
    
    var body: some View {
        NavigationLink(destination: DetailView(text: "Detail View \(num)").introspectViewController { viewController in
            if viewController is UITabBarController {
                print("booyah UITabBarController")
            }
            if viewController is UINavigationController {
                print("booyah UINavigationController")
            }
            viewController.hidesBottomBarWhenPushed = true
        }) {
            Text("Go to Detail View")
        }
    }
}

struct DetailView: View {
    
    @State private var showingSheet = false
    
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        Button("Open Sheet") {
            showingSheet.toggle()
        }.sheet(isPresented: $showingSheet) {
            Text("Sheet Text")
        }
    }
}
