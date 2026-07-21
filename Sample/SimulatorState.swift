//
//  SimulatorState.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import Foundation
import Observability

@Observable
final class SimulatorState {
    
    // MARK: - Configuration
    
    var simulationMode: SimulationMode = .stream
    var speedPreset: SpeedPreset = .fast
    var customDelayMs: Double = 100
    var toolCallEnabled: Bool = true
    var defaultShowToolCalls: Bool = false
    var systemPrompt: String = "You are a helpful assistant that answers concisely."
    var configTurns: [ConversationTurn] = Scenario.simpleQA.turns
    
    // MARK: - Agent Graph

    func emitAgentCallGraph() {
        let json = """
        {
          "id": "orchestrate_resume_tuning",
          "type": "tool",
          "name": "orchestrate_resume_tuning",
          "children": [
            {
              "id": "orchestrator_agent",
              "type": "agent",
              "name": "Orchestrator Agent",
              "model": "gpt-5-mini 2025-08-07",
              "cost": "$0.02",
              "children": [
                {
                  "id": "anonymize_resume",
                  "type": "tool",
                  "name": "anonymize_resume",
                  "children": [
                    { "id": "anonymizer_agent", "type": "agent", "name": "Anonymizer Agent",
                      "model": "ollama/gemma3:4b", "cost": "$0.00" }
                  ]
                },
                {
                  "id": "perform_web_search",
                  "type": "tool",
                  "name": "perform_web_search",
                  "children": [
                    {
                      "id": "web_search_agent",
                      "type": "agent",
                      "name": "Web Search Agent",
                      "model": "gpt-5-mini 2025-08-07",
                      "cost": "$0.008",
                      "children": [
                        { "id": "ws_1", "type": "tool", "name": "web_search" },
                        { "id": "ws_2", "type": "tool", "name": "web_search" },
                        { "id": "ws_3", "type": "tool", "name": "web_search" },
                        { "id": "ws_4", "type": "tool", "name": "web_search" },
                        { "id": "ws_5", "type": "tool", "name": "web_search" },
                        { "id": "ws_6", "type": "tool", "name": "web_search" },
                        { "id": "ws_7", "type": "tool", "name": "web_search" }
                      ]
                    }
                  ]
                },
                {
                  "id": "tune_resume",
                  "type": "tool",
                  "name": "tune_resume",
                  "children": [
                    { "id": "resume_tuner_agent", "type": "agent", "name": "Resume Tuner Agent",
                      "model": "gpt-5-mini 2025-08-07", "cost": "$0.01" }
                  ]
                },
                {
                  "id": "draft_email_1",
                  "type": "tool",
                  "name": "draft_email",
                  "children": [
                    { "id": "terminal_llm_1", "type": "agent", "name": "Terminal LLM",
                      "model": "openai/apple-on-device", "cost": "$0.00" }
                  ]
                },
                {
                  "id": "draft_email_2",
                  "type": "tool",
                  "name": "draft_email",
                  "hasError": true,
                  "children": [
                    { "id": "terminal_llm_2", "type": "agent", "name": "Terminal LLM",
                      "model": "openai/apple-on-device", "cost": "$0.00", "hasError": true }
                  ]
                }
              ]
            }
          ]
        }
        """
        guard let root = AgentNode.from(jsonString: json) else { return }
        emitAgentNodeTree(root, parentId: "")
    }

    private func emitAgentNodeTree(_ node: AgentNode, parentId: String) {
        LLMTracing.emitAgentNode(
            nodeId: node.nodeId,
            parentId: parentId,
            nodeType: node.nodeType.rawValue,
            model: node.model,
            cost: node.cost,
            hasError: node.hasError,
            name: node.name
        )
        for child in node.children {
            emitAgentNodeTree(child, parentId: node.nodeId)
        }
    }

    // MARK: - Tree

    func emitJSONTree() {
        let json = """
        {
          "conversation": {
            "usage":    { "input_tokens": "1024", "output_tokens": "512",  "cache_read": "800"           },
            "identity": { "model": "claude-sonnet-4-6", "id": "conv_abc123", "stop_reason": "end_turn"  }
          },
          "tool_call": {
            "search": { "name": "get_weather", "status": "success", "duration_ms": "84"   },
            "input":  { "location": "Paris",   "units": "celsius"                          },
            "output": { "temperature": "18",   "condition": "Partly cloudy", "humidity": "65" }
          }
        }
        """
        guard let roots = TreeNode.from(jsonString: json) else { return }
        for root in roots {
            emitNode(root, key0: root.key)
            emitTreeNode(root, parentId: "root", path: root.key)
        }
    }

    // Emits every node (branch + leaf) with parent-id for the object graph.
    private func emitTreeNode(_ node: TreeNode, parentId: String, path: String) {
        LLMTracing.emitJSONTreeNode(
            nodeId: path,
            parentId: parentId,
            key: node.key,
            value: node.value ?? ""
        )
        if let children = node.children {
            for child in children {
                emitTreeNode(child, parentId: path, path: "\(path).\(child.key)")
            }
        }
    }

    private func emitNode(_ node: TreeNode, key0: String, key1: String = "") {
        if let children = node.children {
            for child in children {
                if key1.isEmpty {
                    emitNode(child, key0: key0, key1: child.key)
                } else {
                    LLMTracing.emitJSONNode(
                        key0: key0,
                        key1: key1,
                        key2: child.key,
                        value: child.value ?? "[object]"
                    )
                }
            }
        } else {
            LLMTracing.emitJSONNode(
                key0: key0,
                key1: key1.isEmpty ? node.key : key1,
                key2: node.key,
                value: node.value ?? ""
            )
        }
    }

    // MARK: - Playback

    var displayMessages: [DisplayMessage] = []
    var metrics: [MessageMetric] = []
    var isRunning: Bool = false
    var isFinished: Bool = false
    var activeMessageId: UUID? = nil
    
    private var simulationTask: Task<Void, Never>?
    
    // MARK: - Computed
    
    var tokenDelayMs: Double {
        switch speedPreset {
            case .fast:   30
            case .slow:   120
            case .custom: customDelayMs
        }
    }
    
    var asyncDelayMs: Double {
        switch speedPreset {
            case .fast:   300
            case .slow:   1500
            case .custom: customDelayMs
        }
    }
    
    var totalInputTokens:  Int    { metrics.reduce(0) { $0 + $1.inputTokens } }
    var totalOutputTokens: Int    { metrics.reduce(0) { $0 + $1.outputTokens } }
    var totalCost:         Double { metrics.reduce(0.0) { $0 + $1.cost } }
    
    // MARK: - Actions
    
    func start() {
        guard !isRunning, !isFinished else { return }
        isRunning = true
        displayMessages = []
        metrics = []
        simulationTask = Task.detached { [self] in await self.runSimulation() }
    }
    
    func reset() {
        simulationTask?.cancel()
        simulationTask = nil
        displayMessages = []
        metrics = []
        isRunning = false
        isFinished = false
        activeMessageId = nil
    }
    
    func restart() {
        reset()
        start()
    }
    
    func stop() {
        simulationTask?.cancel()
        isRunning = false
        
        if let activeMessageId, let index = displayMessages.firstIndex(where: { $0.id == activeMessageId }) {
            displayMessages[index].isStreaming = false
        }
    }
    
    func loadScenario(_ scenario: Scenario) {
        reset()
        systemPrompt = scenario.systemPrompt
        configTurns = scenario.turns
        toolCallEnabled = scenario.hasToolCalls
    }
    
    // MARK: - Simulation Engine
    
    nonisolated private func runSimulation() async {
        let conversation = LLMTracing.beginConversation()
        defer { LLMTracing.endConversation(conversation) }
        
        let (systemPrompt, configTurns) = await MainActor.run { (self.systemPrompt, self.configTurns) }
        
        let sysId = UUID()
        let sysCost = await MainActor.run {
            MessageMetric(id: sysId, role: .system,
                          inputTokens: estimateTokens(systemPrompt), outputTokens: 0).cost
        }
        let sysActor = LLMTracing.beginActor(.system, on: conversation)
        LLMTracing.emitToken(in: sysActor, content: systemPrompt)

        await MainActor.run {
            self.displayMessages.append(DisplayMessage(id: sysId, role: .system, content: systemPrompt))
            self.metrics.append(MessageMetric(id: sysId, role: .system,
                                              inputTokens: estimateTokens(systemPrompt), outputTokens: 0))
        }
        LLMTracing.endActor(sysActor)
        
        guard await sleep(400) else { await MainActor.run { self.finish() }; return }
        
        for turn in configTurns {
            guard !Task.isCancelled else { await MainActor.run { self.finish() }; return }
            switch turn.role {
                case .user:      await playUser(turn, in: conversation)
                case .assistant: await playAssistant(turn, in: conversation)
                default: break
            }
        }
        
        await loop(in: conversation, count: .zero)
        
        await MainActor.run { self.finish() }
    }
    
    private func finish() {
        isRunning = false
        isFinished = true
        activeMessageId = nil
    }
    
    func loop(in conversation: LLMTracing.Conversation, count: Int) async {
        guard count < 10 else { return }
        
        let actor = LLMTracing.beginActor(.user, on: conversation)
        _ = await sleep(.random(in: 10...500))
        LLMTracing.emitToken(in: actor, content: "count \(count)")
        _ = await sleep(.random(in: 10...500))
        LLMTracing.endActor(actor)
        _ = await sleep(.random(in: 10...500))
        
        await loop(in: conversation, count: count + 1)
    }
    
    nonisolated private func playUser(_ turn: ConversationTurn, in conversation: LLMTracing.Conversation) async {
        let msgId = UUID()
        let cost = await MainActor.run {
            MessageMetric(id: msgId, role: .user,
                          inputTokens: estimateTokens(turn.content), outputTokens: 0).cost
        }
        let actor = LLMTracing.beginActor(.user, on: conversation)
        LLMTracing.emitToken(in: actor, content: turn.content)

        defer { LLMTracing.endActor(actor) }

        await MainActor.run {
            self.displayMessages.append(DisplayMessage(id: msgId, role: .user, content: turn.content))
            self.metrics.append(MessageMetric(
                id: msgId, role: .user,
                inputTokens: estimateTokens(turn.content), outputTokens: 0
            ))
        }
        _ = await sleep(200)
    }
    
    nonisolated private func playAssistant(_ turn: ConversationTurn, in conversation: LLMTracing.Conversation) async {
        let (contextTokens, mode, tokenDelay, asyncDelay, toolEnabled) = await MainActor.run {
            (
                estimateTokens(self.displayMessages.map(\.content).joined()),
                self.simulationMode,
                self.tokenDelayMs,
                self.asyncDelayMs,
                self.toolCallEnabled
            )
        }
        
        let estimatedCost = await MainActor.run {
            MessageMetric(role: .assistant,
                          inputTokens: contextTokens,
                          outputTokens: estimateTokens(turn.content)).cost
        }
        let actor = LLMTracing.beginActor(.assistant, on: conversation)
        
        let msgId = UUID()
        let (idx, metricIdx) = await MainActor.run {
            self.displayMessages.append(DisplayMessage(id: msgId, role: .assistant, content: "", isStreaming: true))
            self.activeMessageId = msgId
            self.metrics.append(MessageMetric(
                id: msgId, role: .assistant,
                inputTokens: contextTokens, outputTokens: 0, isActive: true
            ))
            return (self.displayMessages.count - 1, self.metrics.count - 1)
        }
        
        if mode == .stream {
            for chunk in tokenize(turn.content) {
                guard !Task.isCancelled else { return }
                LLMTracing.emitToken(in: actor, content: chunk)
                await MainActor.run {
                    self.displayMessages[idx].content += chunk
                    self.metrics[metricIdx].outputTokens = estimateTokens(self.displayMessages[idx].content)
                }
                guard await sleep(tokenDelay) else { return }
            }
        } else {
            guard await sleep(asyncDelay) else { return }
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.displayMessages[idx].content = turn.content
                self.metrics[metricIdx].outputTokens = estimateTokens(turn.content)
            }
        }
        
        guard !Task.isCancelled else { return }
        await MainActor.run {
            self.displayMessages[idx].isStreaming = false
            self.metrics[metricIdx].isActive = false
            self.activeMessageId = nil
        }
        
        LLMTracing.endActor(actor)
        
        if toolEnabled, let toolCall = turn.toolCall {
            guard await sleep(500) else { return }
            await playToolCall(toolCall, in: conversation)
        }
        
        _ = await sleep(300)
    }
    
    nonisolated private func playToolCall(_ toolCall: ToolCall, in conversation: LLMTracing.Conversation) async {
        guard !Task.isCancelled else { return }
        
        let estimatedCost = await MainActor.run {
            MessageMetric(role: .tool,
                          inputTokens: 80,
                          outputTokens: estimateTokens(toolCall.result)).cost
        }
        let actor = LLMTracing.beginActor(.tool, on: conversation)
        
        defer { LLMTracing.endActor(actor) }
        
        let (mode, tokenDelay, asyncDelay) = await MainActor.run {
            (self.simulationMode, self.tokenDelayMs, self.asyncDelayMs)
        }
        
        let toolId = UUID()
        let (idx, metricIdx) = await MainActor.run {
            self.displayMessages.append(DisplayMessage(
                id: toolId, role: .tool,
                content: "",
                toolCall: ToolCall(toolName: toolCall.toolName, inputArgs: toolCall.inputArgs, result: ""),
                isStreaming: true
            ))
            self.metrics.append(MessageMetric(
                id: toolId, role: .tool,
                inputTokens: 80, outputTokens: 0, isActive: true
            ))
            return (self.displayMessages.count - 1, self.metrics.count - 1)
        }
        
        if mode == .stream {
            for chunk in tokenize(toolCall.result) {
                guard !Task.isCancelled else { return }
                LLMTracing.emitToken(in: actor, content: chunk)
                await MainActor.run {
                    self.displayMessages[idx].toolCall?.result += chunk
                    self.metrics[metricIdx].outputTokens = estimateTokens(self.displayMessages[idx].toolCall?.result ?? "")
                }
                guard await sleep(tokenDelay) else { return }
            }
        } else {
            guard await sleep(asyncDelay) else { return }
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.displayMessages[idx].toolCall?.result = toolCall.result
                self.metrics[metricIdx].outputTokens = estimateTokens(toolCall.result)
            }
        }
        
        guard !Task.isCancelled else { return }
        await MainActor.run {
            self.displayMessages[idx].isStreaming = false
            self.metrics[metricIdx].isActive = false
        }
        
        _ = await sleep(400)
    }
    
    // Returns false if cancelled/failed
    nonisolated private func sleep(_ ms: Double) async -> Bool {
        do {
            try await Task.sleep(for: .milliseconds(ms))
            return true
        } catch {
            return false
        }
    }
}
