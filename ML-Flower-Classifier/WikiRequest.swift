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
    let baseUrl: String = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts|pageimages&exintro&explaintext&indexpageids&redirects=1&pithumbsize=500&titles="
    
    
    func fetchInfo(_ name: String) {
        if let urlCodifiedName = (baseUrl + name).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            performRequest(urlCodifiedName)
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
                if let safeError = error {
                    print("Error from urlrequest: \(safeError.localizedDescription)")
                }
            }
            task.resume()
        }
        else {
            print("Error occured converting url into URL object.")
        }
    }
    
    func parseJSON(data: Data) -> WikiInfo? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WikiData.self, from: data)
            print("decodedData: \(decodedData)")
            let page = decodedData.query.pages[decodedData.query.pageids[0]]!
            return WikiInfo(title: page.title, desc: page.extract, image: page.thumbnail.source)
        } catch {
            print("Error decoding data: \(error)")
            self.delegate?.didFailWithError(error)
            return nil
        }
    }
}
