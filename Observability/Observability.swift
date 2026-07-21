//
//  Observability.swift
//  Observability
//
//  Created by Cezar Mauricio on 07/05/26.
//

import Foundation
import os.signpost

public enum LLMTracing {
    public static let subsystem = "io.czrml.visualizer.observability"
    public static let category = "Observation"
    
    public static let signposter = OSSignposter(subsystem: subsystem, category: category)
    
    public enum Role: String, Sendable {
        case system, user, assistant, tool
    }
    
    public struct Conversation: Sendable {
        fileprivate let id: OSSignpostID
        fileprivate let state: OSSignpostIntervalState
    }
    
    public struct Actor: Sendable {
        fileprivate let id: OSSignpostID
        fileprivate let state: OSSignpostIntervalState
        fileprivate let role: Role
        fileprivate let conversationID: UInt64
    }
    
    public static func beginConversation(
        function: String = #function,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line
    ) -> Conversation {
        let id = signposter.makeSignpostID()
        let state = signposter.beginInterval(
            "Conversation", id: id,
            "conversationID=\(id.rawValue, privacy: .public)"
        )
        
        return Conversation(id: id, state: state)
    }
    
    public static func endConversation(_ conversation: Conversation) {
        signposter.endInterval("Conversation", conversation.state)
    }
    
    public static func beginActor(
        _ role: Role,
        on conversation: Conversation,
        function: String = #function,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line
    ) -> Actor {
        let id = signposter.makeSignpostID()
        let stack = Thread.callStackReturnAddresses
        let address = stack.dropFirst().first.map { $0.uintValue &- 1 } ?? .zero
        
        let state = signposter.beginInterval(
            "Actor",
            id: id,
            """
            role=\(role.rawValue, privacy: .public) \
            conversationID=\(conversation.id.rawValue, privacy: .public) \
            actorID=\(id.rawValue, privacy: .public) \
            fileID=\(fileID, privacy: .public) \
            filePath=\(filePath, privacy: .public) \
            line=\(line) \
            function=\(function, privacy: .public) \
            address=\(address)
            """
        )
        
        return Actor(id: id, state: state, role: role, conversationID: conversation.id.rawValue)
    }
    
    public static func endActor(_ actor: Actor) {
        signposter.endInterval(
            "Actor", actor.state,
            """
            role=\(actor.role.rawValue, privacy: .public)
            """
        )
    }
    
    /// Reuses the actor's signpost id so Instruments can correlate the point
    /// event with the open Actor interval and the click jumps back to the turn.
    public static func emitToken(
        in actor: Actor,
        content: String
    ) {
        let stack = Thread.callStackReturnAddresses
        let address = stack.dropFirst().first.map { $0.uintValue &- 1 } ?? .zero

        signposter.emitEvent(
            "Token",
            id: actor.id,
            """
            role=\(actor.role.rawValue, privacy: .public) \
            conversationID=\(actor.conversationID, privacy: .public) \
            actorID=\(actor.id.rawValue, privacy: .public) \
            address=\(address) \
            content=\(content, privacy: .public)
            """
        )
    }

    public static func emitJSONNode(
        key0: String,
        key1: String,
        key2: String,
        value: String
    ) {
        signposter.emitEvent(
            "JSONNode",
            id: .exclusive,
            "key0=\(key0, privacy: .public) key1=\(key1, privacy: .public) key2=\(key2, privacy: .public) value=\(value, privacy: .public)"
        )
    }

    public static func emitJSONTreeNode(
        nodeId: String,
        parentId: String,
        key: String,
        value: String
    ) {
        signposter.emitEvent(
            "JSONTreeNode",
            id: .exclusive,
            "nodeId=\(nodeId, privacy: .public) parentId=\(parentId, privacy: .public) key=\(key, privacy: .public) value=\(value, privacy: .public)"
        )
    }

    /// One event per agent-call-graph node. nodeType is "tool" or "agent".
    /// name is last so it can contain spaces without breaking pattern capture.
    public static func emitAgentNode(
        nodeId: String,
        parentId: String,
        nodeType: String,
        model: String,
        cost: String,
        hasError: Bool,
        name: String
    ) {
        signposter.emitEvent(
            "AgentNode",
            id: .exclusive,
            "nodeId=\(nodeId, privacy: .public) parentId=\(parentId, privacy: .public) nodeType=\(nodeType, privacy: .public) model=\(model, privacy: .public) cost=\(cost, privacy: .public) hasError=\(hasError ? "1" : "0", privacy: .public) name=\(name, privacy: .public)"
        )
    }
}
