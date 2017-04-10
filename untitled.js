
struct {
	var products: [Product]
	var tagName: String
	var tagId: Int
}

struct Product{
	var deleted: Bool
	var type: Int
	var translateKeywords: Bool
	var updateDate: Date
	var icon: URL
	var creationDate: Date
	var typeId: Int
	var banner: URL
	var name: String
	var isFree: Bool
	var id: Int
	var isDraft: Bool
	var artist: Artist
}