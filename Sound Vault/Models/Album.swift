import Foundation

struct Album: Identifiable, Codable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: URL?
    let releaseDate: Date
    let genre: String
    var rating: Double?
    var review: String?
    var listenDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, title, artist, artworkURL, releaseDate, genre, rating, review, listenDate
    }
    
    init(id: String, title: String, artist: String, artworkURL: URL?, releaseDate: Date, genre: String,
         rating: Double? = nil, review: String? = nil, listenDate: Date? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.releaseDate = releaseDate
        self.genre = genre
        self.rating = rating
        self.review = review
        self.listenDate = listenDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decode(String.self, forKey: .artist)
        let urlString = try container.decode(String?.self, forKey: .artworkURL)
        artworkURL = urlString.flatMap { URL(string: $0) }
        releaseDate = try container.decode(Date.self, forKey: .releaseDate)
        genre = try container.decode(String.self, forKey: .genre)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        review = try container.decodeIfPresent(String.self, forKey: .review)
        listenDate = try container.decodeIfPresent(Date.self, forKey: .listenDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(artist, forKey: .artist)
        try container.encode(artworkURL?.absoluteString, forKey: .artworkURL)
        try container.encode(releaseDate, forKey: .releaseDate)
        try container.encode(genre, forKey: .genre)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(review, forKey: .review)
        try container.encodeIfPresent(listenDate, forKey: .listenDate)
    }
}
