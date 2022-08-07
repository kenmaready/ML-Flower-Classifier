//
//  WikiRequest.swift
//  ML-Flower-Classifier
//
//  Created by Ken Maready on 8/3/22.
//

import Foundation

protocol WikiRequestDelegate {
    func didUpdateInfo(_: WikiInfo)
    func didFailWithError(_: Error)
}

class WikiRequest {
    var delegate: WikiRequestDelegate?
    let baseUrl: String = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&indexpageids&redirects=1&titles="
    
    
    func fetchInfo(_ name: String) {
        if let urlCodifiedName = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            let url = baseUrl + urlCodifiedName
            performRequest(url)
        }
        
    }
    
    func performRequest(_ urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if let safeData = data {
                    if let info = self.parseJSON(data: safeData) {
                        self.delegate?.didUpdateInfo(info)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(data: Data) -> WikiInfo? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WikiData.self, from: data)
            let page = decodedData.query.pages[decodedData.query.pageids[0]]!
            return WikiInfo(title: page.title, desc: page.extract)
        } catch {
            print("Error decoding data: \(error)")
            self.delegate?.didFailWithError(error)
            return nil
        }
    }
}
