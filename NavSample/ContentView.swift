import Combine
import SwiftUI
import RealmSwift

struct ContentView: View {

    @ObservedObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.details) { detail in
                NavigationLink(destination: DetailView(viewModel: detail)) {
                    Text(detail.text)
                }
            }
        }.onAppear {
            viewModel.load()
        }
    }
}

class ContentViewModel: ObservableObject {

    static let dataStore = DataStore()

    @Published var details = [DetailViewModel]()
    private var disposables = Set<AnyCancellable>()

    func load() {
        Self.dataStore.getData()
            .replaceError(with: [])
            .sink { entities in
                self.details = entities.map({ entity in
                    DetailViewModel(text: entity.text)
                })
            }.store(in: &disposables)
    }
}

struct DetailView: View {

    @ObservedObject var viewModel: DetailViewModel

    var body: some View {
        ZStack {
            Text(viewModel.text)
        }.onAppear {
            viewModel.onAppear()
        }
    }
}

class DetailViewModel: ObservableObject, Identifiable {

    @Published var text: String = ""
    private let dataStore = ContentViewModel.dataStore

    init(text: String) {
        self.text = text
    }
    
    func onAppear() {
        self.dataStore.storeData(entity: Entity(text: text, created: Date()))
    }
}

class DataStore {
    private let realm: Realm
    init() {
        self.realm = try! Realm()
        try! realm.write {
            realm.add(Entity(text: "Entity 1", created: Date()), update: .modified)
            realm.add(Entity(text: "Entity 2", created: Date()), update: .modified)
            realm.add(Entity(text: "Entity 3", created: Date()), update: .modified)
            realm.add(Entity(text: "Entity 4", created: Date()), update: .modified)
        }
    }
    
    func getData() -> AnyPublisher<[Entity], Error> {
        realm.objects(Entity.self).sorted(byKeyPath: "created", ascending: false).collectionPublisher
            .map({ results -> [Entity] in
                results.map { entity -> Entity in
                    entity
                }
            }).eraseToAnyPublisher()
    }
    
    func storeData(entity: Entity) {
        try! realm.write {
            realm.add(entity, update: .modified)
        }
    }
}

class Entity: Object {
    @objc dynamic var text: String!
    @objc dynamic var created: Date!

    override required init() {
        super.init()
    }

    init(text: String, created: Date) {
        super.init()
        self.text = text
        self.created = created
    }

    override static func primaryKey() -> String? {
        return "text"
    }
}
