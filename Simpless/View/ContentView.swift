//
//  ContentView.swift
//  Simpless
//
//  Created by Ambarish Shivakumar on 03/12/24.
//

import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var isDeleteAll: Bool = false
    @State private var selectedItems = Set<String>()
    @State private var isEditing = false
    @State private var showDeleteSelectedAlert = false
    @State private var showDeleteAllAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                if viewModel.products.isEmpty {
                    Text("No products available.")
                        .font(.headline)
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(viewModel.products) { product in
                            HStack {
                                if let url = URL(string: product.image) {
                                    CachedImage(url: url)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(product.title)
                                        .font(.headline)
                                    Text(product.description)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: deleteRow) // Swipe-to-delete action
                    }
                }
                
                // Button to delete all products
                
                Button(action: {
                    
                    viewModel.deleteAllProducts()
                    
                }) {
                    Text("Delete All")
                        .foregroundColor(.red)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationTitle("Products")
            .alert(isPresented: .constant(viewModel.isOffline)) {
                Alert(
                    title: Text("Offline Mode"),
                    message: Text("You're viewing cached data."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // Method to handle swipe-to-delete
    private func deleteRow(at offsets: IndexSet) {
        offsets.forEach { index in
            let product = viewModel.products[index]
            viewModel.deleteProduct(product)
        }
    }
}

#Preview {
    ProductListView()
}
