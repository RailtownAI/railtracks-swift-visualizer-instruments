//
//  ContentView.swift
//  JSONTools
//

import SwiftUI
import UniformTypeIdentifiers
import RailtracksInstrumentationKit

struct ContentView: View {

    @State private var isImporting = false
    @State private var urlText = ""
    @State private var sourceName: String? = nil
    @State private var status: EmitStatus = .idle
    @State private var isLoading = false
    @State private var flowNodes: [FlowNode] = []

    var body: some View {
        HSplitView {
            controlPanel
                .frame(minWidth: 280, maxWidth: 320)

            rightPanel
        }
        .frame(minWidth: 680, minHeight: 420)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json]
        ) { result in
            handleFileImport(result)
        }
    }

    // MARK: - Control panel (left)

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Label("Flow Graph Emitter", systemImage: "waveform.path.ecg")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .padding(.top, 4)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("Source").font(.subheadline).foregroundStyle(.secondary)

                Button("Choose File…") { isImporting = true }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    Text("URL").font(.caption).foregroundStyle(.secondary)
                    HStack(spacing: 6) {
                        TextField("https://…", text: $urlText)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { loadFromURL() }
                        Button("Fetch") { loadFromURL() }
                            .buttonStyle(.bordered)
                            .disabled(urlText.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                    }
                }
            }

            Divider()

            if isLoading {
                HStack { ProgressView(); Text("Loading…").foregroundStyle(.secondary) }
            } else {
                statusView
            }

            if let sourceName {
                Text(sourceName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .truncationMode(.middle)
            }

            Spacer()
        }
        .padding(16)
    }

    // MARK: - Right panel (tree / aggregation)

    private var rightPanel: some View {
        FlowNodeTreeView(roots: flowNodes)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Status

    @ViewBuilder
    private var statusView: some View {
        switch status {
        case .idle:
            EmptyView()
        case .success(let counts):
            Label(
                "Emitted \(counts.nodes) nodes, \(counts.edges) edges, \(counts.ioRows) I/O rows",
                systemImage: "checkmark.circle.fill"
            )
            .foregroundStyle(.green)
            .font(.callout)
        case .failure(let message):
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - File

    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }
            process(data: try? Data(contentsOf: url), source: url.lastPathComponent)
        case .failure(let error):
            status = .failure(error.localizedDescription)
        }
    }

    // MARK: - URL

    private func loadFromURL() {
        let raw = urlText.trimmingCharacters(in: .whitespaces)
        guard !raw.isEmpty, let url = URL(string: raw) else {
            status = .failure("Invalid URL")
            return
        }
        isLoading = true
        status = .idle
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                await MainActor.run {
                    process(data: data, source: url.lastPathComponent.isEmpty ? raw : url.lastPathComponent)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    status = .failure(error.localizedDescription)
                    isLoading = false
                }
            }
        }
    }

    // MARK: - Shared

    private func process(data: Data?, source: String) {
        guard let data else { status = .failure("Could not read data"); return }
        do {
            flowNodes = try FlowNode.from(data: data)
            let counts = try FlowGraphMapper.emit(data: data)
            sourceName = source
            status = .success(counts)

            // Replay the JSON's agent hierarchy as begin/end interval
            // signposts so the Agent Runs lane in Instruments shows a
            // nested duration tree. Detached so the UI stays responsive
            // while the walk sleeps to give bars visible width.
            let snapshot = flowNodes
            Task.detached {
                await Self.emitAgentIntervals(roots: snapshot)
            }
        } catch {
            status = .failure(error.localizedDescription)
        }
    }

    // MARK: - AgentRun replay

    /// Walks the parsed FlowNode tree and emits one begin/end AgentRun
    /// interval per Agent node, nested by recursion (a parent's `end`
    /// fires after all descendants' `end`s, so Instruments renders the
    /// parent bar wrapping its children's bars).
    ///
    /// os_signpost intervals always stamp at "now" — there's no API to
    /// forge past timestamps. So we can't replay the exact recorded
    /// timeline; we approximate it by sleeping `latency * scale` (with a
    /// floor) before closing each node's interval. The scale compresses
    /// long real runs (minutes) into seconds while still preserving the
    /// relative proportions between agents.
    nonisolated private static func emitAgentIntervals(roots: [FlowNode]) async {
        let scale: Double = 0.01    // 1% of recorded latency
        let minSleep: Duration = .milliseconds(20)
        let setupSleep: Duration = .milliseconds(15)
        @Sendable func visit(_ node: FlowNode, parentName: String) async {
            // Only Agents get intervals — Tools are point events handled
            // by FlowGraphMapper's FlowTreeNode emission.
            guard node.nodeType == .agent else {
                for child in node.children { await visit(child, parentName: parentName) }
                return
            }
            // Pass a plain name — begin() prepends the SDK-assigned per-run
            // start index so the Agent Runs lane stays ordered.
            let handle = RailtracksSignposts.begin(AgentRun(
                name: node.name,
                nodeId: node.nodeId,
                sessionId: node.sessionId,
                runId: node.runId,
                parentName: parentName
            ))
            // Small lead so the parent bar visibly starts before the first
            // child does on the timeline (otherwise they appear stacked
            // at the same x-coordinate).
            try? await Task.sleep(for: setupSleep)
            for child in node.children { await visit(child, parentName: node.name) }
            // Tail: scaled latency, floored to keep the bar visible for
            // agents whose recorded latency is tiny.
            let scaled = Duration.seconds(node.latency * scale)
            try? await Task.sleep(for: max(minSleep, scaled))
            RailtracksSignposts.end(handle, error: node.error)
        }

        for root in roots { await visit(root, parentName: "") }
    }
}

private enum EmitStatus {
    case idle
    case success(FlowGraphMapper.EmitCounts)
    case failure(String)
}

#Preview {
    ContentView()
}
