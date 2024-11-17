//
//  ContentView.swift
//  AsynAwaitSwiftUI
//
//  Created by Ateeq Ahmed on 17/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: GitUser?
    
    var body: some View {
        VStack {
            
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundStyle(.gray)
                    .padding()
            }
            .frame(width: 150, height: 150)
            
            Text(user?.login ?? "Unkown user")
                .font(.title3)
                .fontWeight(.semibold)
                .padding()
            
            Text(user?.bio ?? "provide bio")
                .font(.body)
                .fontWeight(.regular)
            
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("Invalid URL")
            } catch GHError.invalidResponse {
                print("Invalid Response")
            } catch GHError.invalidData {
                print("Invalid Data")
            } catch {
                print("Unexpected Error")
            }
        }
    }
    
    func getUser() async throws -> GitUser {
        guard let url = URL(string: "https://api.github.com/users/atheeqahammed") else {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
    
    
    
    
}

#Preview {
    ContentView()
}


struct GitUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}


enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
