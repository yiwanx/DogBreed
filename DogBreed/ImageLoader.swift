//
// Created by Ivan Petukhov on 31.07.2022.
//

import UIKit

enum ImageLoadingError: Error {
    case UIImageCantBeDecoded
    case responseUnsuccessful
}

@globalActor actor ImageLoader {

    private var images: [URLRequest: Status] = [:]

    private init() {}

    public static let shared = ImageLoader()

    /// Same as fetch but without return. Used to initiate downloading process in advance.
    public func preFetch(_ url: URL) async throws {
        let request = URLRequest(url: url)
        try await fetch(request)
    }

    public func fetch(_ url: URL) async throws -> UIImage {
        let request = URLRequest(url: url)
        return try await fetch(request)
    }

    public func fetch(_ urlRequest: URLRequest) async throws -> UIImage {
        print("getting \(urlRequest.url?.relativeString)")
        if let status = images[urlRequest] {
            switch status {
            case .fetched(let image):
                return image
            case .downloading(let task):
                return try await task.value
            }
        }

        if let image = imageFromFileSystem(for: urlRequest) {
            images[urlRequest] = .fetched(image)
            return image
        }

        let task: Task<UIImage, Error> = Task {
            let (imageData, response) = try await URLSession.shared.data(for: urlRequest)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw ImageLoadingError.responseUnsuccessful
            }
            guard let image = UIImage(data: imageData) else {
                throw ImageLoadingError.UIImageCantBeDecoded
            }
            try self.persistImage(image, for: urlRequest)
            return image
        }

        images[urlRequest] = .downloading(task)
        print("downloading \(urlRequest.url?.relativeString)")
        let image = try await task.value

        images[urlRequest] = .fetched(image)
        print("fetched \(urlRequest.url?.relativeString)")
        return image
    }

    private enum Status {
        case downloading(Task<UIImage, Error>)
        case fetched(UIImage)
    }

    private func imageFromFileSystem(for urlRequest: URLRequest) -> UIImage? {
        guard let url = fileName(for: urlRequest) else {
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            return nil
        }

        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        } else {
            return nil
        }
    }

    private func fileName(for urlRequest: URLRequest) -> URL? {
        guard let fileName = urlRequest.url?.lastPathComponent,
              let documentDirectoryPath = documentDirectoryPath else {
            return nil
        }
        return documentDirectoryPath.appendingPathComponent(fileName)
    }

    private func persistImage(_ image: UIImage, for urlRequest: URLRequest) throws {
        guard let url = fileName(for: urlRequest),
              let data = image.jpegData(compressionQuality: 0.8) else {
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            return
        }

        try data.write(to: url)

    }

    private var documentDirectoryPath: URL? {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path.first
    }
}