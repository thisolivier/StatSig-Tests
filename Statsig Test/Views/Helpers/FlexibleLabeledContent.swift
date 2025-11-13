//
//  FlexibleLabeledContent.swift
//  Statsig Test
//
//  Created by Olivier Butler on 13/11/2025.
//

import SwiftUI

struct FlexibleLabeledContent<Content: View>: View {
    let label: String
    let content: () -> Content

    var body: some View {
        ViewThatFits {
            // Preferred compact layout (side-by-side)
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .frame(minWidth: 100, alignment: .leading)
                content()
                    .layoutPriority(1)
            }

            // Fallback layout (stacked) when content is long
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                content()
            }
        }
    }
}
