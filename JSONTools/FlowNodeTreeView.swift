//
//  FlowNodeTreeView.swift
//  JSONTools
//

import SwiftUI
import RailtracksInstrumentationKit

struct FlowNodeTreeView: View {
    let roots: [FlowNode]

    var body: some View {
        VStack(spacing: 0) {
            if !roots.isEmpty {
                FlowTotalsHeader(totals: roots.totals)
                Divider()
            }
            List(roots, children: \.optionalChildren) { node in
                FlowNodeRow(node: node)
            }
            .listStyle(.sidebar)
        }
    }
}

// MARK: - Totals header

private struct FlowTotalsHeader: View {
    let totals: FlowTotals

    var body: some View {
        HStack(spacing: 24) {
            metric("Latency", String(format: "%.3fs", totals.latency))
            metric("In Tokens", totals.inputTokens.formatted())
            metric("Out Tokens", totals.outputTokens.formatted())
            if totals.cost > 0 {
                metric("Cost", String(format: "$%.4f", totals.cost))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func metric(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.callout.monospacedDigit().weight(.semibold))
        }
    }
}

// MARK: - Row

private struct FlowNodeRow: View {
    let node: FlowNode

    private var isAgent: Bool { node.nodeType == .agent }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isAgent ? "cpu" : "hammer")
                .foregroundStyle(isAgent ? .purple : .blue)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(node.name)
                    .font(.body)
                    .lineLimit(1)
                if !node.model.isEmpty {
                    Text(node.model)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            HStack(spacing: 12) {
                if node.latency > 0 {
                    Text(String(format: "%.3fs", node.latency))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                if node.cost > 0 {
                    Text(String(format: "$%.4f", node.cost))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 1)
    }
}

extension FlowNode {
    var optionalChildren: [FlowNode]? {
        children.isEmpty ? nil : children
    }
}
