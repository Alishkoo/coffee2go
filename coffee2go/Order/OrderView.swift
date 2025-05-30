//
//  OrderView.swift
//  coffee2go
//
//  Created by Камила Багдат on 12.05.2025.
//

import Foundation
import SwiftUI

struct OrderView: View {
    @StateObject private var viewModel = OrderViewModel()

    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Order")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    ForEach(viewModel.orders) { order in
                        HStack {
                            Image(systemName: order.imageName)
                                .foregroundColor(.white)
                                .padding(.trailing, 8)

                            VStack(alignment: .leading) {
                                Text("\(order.name) (\(order.size.rawValue))")
                                    .foregroundColor(.white)
                                Text("\(order.price * order.quantity) ₸")
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            HStack(spacing: 10) {
                                Button(action: {
                                    viewModel.decreaseQuantity(of: order)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.gray)
                                }

                                Text("\(order.quantity)")
                                    .foregroundColor(.white)

                                Button(action: {
                                    viewModel.increaseQuantity(of: order)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }

                            Button(action: {
                                viewModel.deleteOrder(order)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color(hex: "#1E140F"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    Text("Recommended for you")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.recommendations) { rec in
                                Button(action: {
                                    viewModel.addToOrder(rec)
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: rec.imageName)
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.white)
                                        Text(rec.name)
                                            .foregroundColor(.white)
                                        Text("\(rec.price) ₸")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(hex: "#3C2F26"))
                                    .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            VStack(spacing: 12) {
                HStack {
                    Text("Total:")
                        .foregroundColor(.white)
                        .font(.title3.bold())
                    Spacer()
                    Text("\(viewModel.total) ₸")
                        .foregroundColor(.white)
                        .font(.title3.bold())
                }
                .padding(.horizontal)

                Button(action: {
                    // Payment logic
                }) {
                    Text("Pay with Kaspi")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(24)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .background(Color(hex: "#0E0704").ignoresSafeArea())
    }
}

#Preview {
    OrderView()
}
