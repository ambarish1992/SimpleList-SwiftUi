//
//  HomeView.swift
//  Simpless
//
//  Created by Ambarish Shivakumar on 30/01/25.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = ProductViewModel()
    @State private var items = ["Apple", "Banana", "Orange", "Grapes", "Mango"]
    @State private var selectedIds: Set<Int> = []
    @State private var isEditMode = false
    @State private var showDeleteSelectedAlert = false
    @State private var showDeleteAllAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                if viewModel.products.isEmpty {
                    Text("No products available.")
                        .font(.headline)
                        .foregroundColor(.gray)
                }else {
                    
                    if isEditMode {
                        // Multi-selection List
                        List(viewModel.products, id: \.id, selection: $selectedIds) { item in
                            HStack {
                                if let url = URL(string: item.image) {
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
                                    Text(item.title)
                                        .font(.headline)
                                    Text(item.description)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .environment(\.editMode, .constant(.active))
                    } else {
                        // Swipe-to-delete List
                        List {
                            ForEach(viewModel.products, id: \.id) { item in
                                HStack {
                                    if let url = URL(string: item.image) {
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
                                        Text(item.title)
                                            .font(.headline)
                                        Text(item.description)
                                            .font(.subheadline)
                                            .lineLimit(2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .onDelete(perform: deleteRow)
                        }
                    }
                    
                    HStack {
                        Button(action: {
                            self.selectedIds.removeAll()
                            isEditMode.toggle()
                        }) {
                            Text(isEditMode ? "Done" : "Select Multiple")
                                .padding()
                                .foregroundColor(.white)
                                .background(isEditMode ? Color.blue : Color.green)
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Button("Delete Selected") {
                            
                            showDeleteSelectedAlert = true
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(selectedIds.isEmpty ? Color.gray : Color.red)
                        .cornerRadius(8)
                        .disabled(selectedIds.isEmpty)
                        
                        Spacer()
                        
                        Button("Delete All") {
                            showDeleteAllAlert = true
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(items.isEmpty ? Color.gray : Color.red)
                        .cornerRadius(8)
                        .disabled(items.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("Fruits List")
            .alert("Confirm Deletion", isPresented: $showDeleteSelectedAlert) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteSelectedProducts(self.selectedIds)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete the selected items?")
            }
            .alert("Confirm Delete All", isPresented: $showDeleteAllAlert) {
                Button("Delete All", role: .destructive) {
                    viewModel.deleteAllProducts()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete all items?")
            }
            .toolbar {
                EditButton() // Swipe delete toggle
            }
        }
    }
    
    // Swipe to delete handler
    private func deleteRow(at offsets: IndexSet) {
        offsets.forEach { index in
            let product = viewModel.products[index]
            viewModel.deleteProduct(product)
        }
    }
}


#Preview {
    HomeView()
}
