import SwiftUI

/// A text field that normalizes and validates user input using a provided transformation.
///
/// This view is designed to avoid the common duplication pattern where you first capture
/// raw input and then maintain a separate processed value (often seen with a standard
/// `onChange` approach). Instead, it keeps a single source of truth by applying the
/// transformation on every change and synchronizing both the internal field state and
/// the external binding with the transformed value.
///
/// Use this view when you want to restrict or normalize text as the user types, e.g.:
/// - Limiting length: `{ String($0.prefix(4)) }`
/// - Trimming whitespace: `{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }`
/// - Allowing only digits: a closure that filters out non-digit characters.
public struct FormattingTextField: View {
    /// The localized placeholder/title shown by the underlying `TextField`.
    private let title: LocalizedStringKey
    
    /// The external binding that receives the transformed value.
    /// Assignments to this binding also flow back into the field after transformation.
    @Binding private var text: String

    /// Transforms raw user input into the value allowed to leave this component.
    ///
    /// The closure is applied on every change, both for user edits and external updates.
    /// Ensure the transformation is idempotent (applying it multiple times yields the
    /// same result) to avoid feedback loops.
    private let transform: (String) -> String

    /// Internal source of truth for the `TextField`. Always kept in sync with `text` via `transform`.
    @State private var internalText: String = ""

    /// Creates a formatting text field.
    /// - Parameters:
    ///   - title: The localized placeholder/title of the field.
    ///   - text: A binding to the external value. Receives transformed text.
    ///   - transform: A closure that normalizes/validates text. Should be fast and idempotent.
    public init(
        _ title: LocalizedStringKey,
        text: Binding<String>,
        transform: @escaping (String) -> String
    ) {
        self.title = title
        self._text = text
        self.transform = transform
    }

    public var body: some View {
        // Underlying SwiftUI TextField bound to the internal state.
        TextField(title, text: $internalText)
            .onAppear {
                apply(text)
            }

            // When the user types, propagate changes:
            // 1) Take `internalText` (raw)
            // 2) Apply `transform`
            // 3) Update both `internalText` and external `text` if needed
            .onChange(of: internalText) { newValue in
                apply(newValue)
            }

            // When the external binding changes, normalize it and reflect back into `internalText`.
            .onChange(of: text) { newValue in
                apply(newValue)
            }
    }

    /// Applies the transformation to a raw string and synchronizes both internal and external states.
    ///
    /// This method avoids redundant assignments to prevent unnecessary view updates and feedback loops.
    private func apply(_ raw: String) {
        let processed = transform(raw)

        if internalText != processed {
            internalText = processed
        }
        if text != processed {
            text = processed
        }
    }
}
