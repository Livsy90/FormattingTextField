## FormattingTextField

`FormattingTextField` is a SwiftUI text input component that applies a formatting rule **before** publishing changes to your model.

Unlike the common `TextField` + `onChange` approach (where the raw value is written first and corrected afterwards), this component uses an internal input buffer. The user edits a local `@State` string, the input is processed through a transformation closure, and only the processed result is written to the external `@Binding`.

This guarantees that observers (e.g. `@Published` with `didSet`, validation logic, or side effects) never receive intermediate unformatted values. It is especially useful when the text drives logic such as validation, networking, or state transitions.

Typical use cases include:

* limiting input length
* trimming whitespace
* allowing digits only
* normalizing separators and casing
* applying any custom text transformation without noisy intermediate updates

```swift
struct ContentView: View {
    @State var vm: ViewModel = .init()
    
    var body: some View {
        FormattingTextField("Name", text: $vm.name) {
            String($0.prefix(30))
        }
    }
}
```

### Read more here:

https://livsycode.com/swiftui/how-to-avoid-double-updates-when-filtering-swiftui-textfield-input/
