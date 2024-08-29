//
//  File.swift
//
//
//  Created by Victor Ramirez on 8/28/24.
//

import Foundation
import Fluent
import Vapor

final class JournalEntry: Model, Content, Sendable {
    static let schema = "journal_entries"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "content")
    var content: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, content: String) {
        self.id = id
        self.content = content
    }
}

