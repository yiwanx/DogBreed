//
// Created by Ivan Petukhov on 30.07.2022.
//

import Foundation
import UIKit

class Service {
    private init() { }

    static let shared = Service()

    public func fetchData<T: Decodable>(from url: URL, type: T.Type) async throws -> T {
        do {
            let (data, URLResponse) = await try URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw error
        }
    }

}
