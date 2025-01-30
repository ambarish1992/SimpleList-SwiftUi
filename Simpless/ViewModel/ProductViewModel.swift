//
//  ProductViewModel.swift
//  Simpless
//
//  Created by Ambarish Shivakumar on 04/12/24.
//

import Combine
import CoreData
import Foundation
import Network

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isOffline = false
    
    private let context = PersistenceController.shared.container.viewContext
    private var cancellables = Set<AnyCancellable>()
    private let monitor = NWPathMonitor()
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isOffline = path.status != .satisfied
                if self.isOffline {
                    self.loadProductsFromCoreData()
                } else {
                    self.fetchProductsFromAPI()
                }
            }
        }
        monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
    }
    
    func fetchProductsFromAPI() {
        guard let url = URL(string: "https://fakestoreapi.com/products") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Product].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching products: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] products in
                guard let self = self else { return }
                self.products = self.removeDuplicates(from: products)
                self.saveProductsToCoreData(products)
            })
            .store(in: &cancellables)
    }
    
    func saveProductsToCoreData(_ products: [Product]) {
        do {
            // Fetch existing Core Data entries
            let request: NSFetchRequest<CachedProduct> = CachedProduct.fetchRequest()
            let existingProducts = try context.fetch(request)
            let existingIDs = Set(existingProducts.map { Int($0.id) })
            
            // Save only new products
            products.forEach { product in
                if !existingIDs.contains(product.id) {
                    let cachedProduct = CachedProduct(context: context)
                    cachedProduct.id = Int64(product.id)
                    cachedProduct.title = product.title
                    cachedProduct.productDescription = product.description
                    cachedProduct.imageURL = product.image
                }
            }
            
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error.localizedDescription)")
        }
    }
    
    func loadProductsFromCoreData() {
        let request: NSFetchRequest<CachedProduct> = CachedProduct.fetchRequest()
        
        do {
            let cachedProducts = try context.fetch(request)
            self.products = removeDuplicates(from: cachedProducts.map {
                Product(
                    id: Int($0.id),
                    title: $0.title ?? "",
                    description: $0.productDescription ?? "",
                    image: $0.imageURL ?? ""
                )
            })
        } catch {
            print("Error loading from Core Data: \(error.localizedDescription)")
        }
    }
    
    func removeDuplicates(from products: [Product]) -> [Product] {
        var seenIDs = Set<Int>()
        return products.filter { product in
            guard !seenIDs.contains(product.id) else { return false }
            seenIDs.insert(product.id)
            return true
        }
    }
    
    func deleteProduct(_ product: Product) {
        let fetchRequest: NSFetchRequest<CachedProduct> = CachedProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", product.id)
        
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                context.delete(object)
            }
            try context.save()
            // Update the UI after deletion
            self.products.removeAll { $0.id == product.id }
        } catch {
            print("Error deleting product: \(error.localizedDescription)")
        }
    }
    
    func deleteSelectedProducts(_ SelectedProducts: Set<Int>) {
        
        let selectedIDs = SelectedProducts.map { $0 }
        
        let fetchRequest: NSFetchRequest<CachedProduct> = CachedProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", selectedIDs)
        
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                context.delete(object)
            }
            try context.save()
            
            // Update the UI by removing deleted products
            self.products.removeAll { selectedIDs.contains($0.id) }
        } catch {
            print("Error deleting selected products: \(error.localizedDescription)")
        }
    }
    
    func deleteAllProducts() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CachedProduct.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            // Clear the products array to update the UI
            self.products.removeAll()
        } catch {
            print("Error deleting all products: \(error.localizedDescription)")
        }
    }
}


