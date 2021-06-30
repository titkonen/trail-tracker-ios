import UIKit

import Foundation

// Create Date
let date = Date()

// Create Date Formatter
let dateFormatter = DateFormatter()

// Set Date Format
dateFormatter.dateFormat = "YY/MM/dd"

// Convert Date to String
dateFormatter.string(from: date)

print(date)
