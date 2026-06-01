DynamicFormBuilder
An iOS app that renders fully dynamic forms from a JSON config — no hardcoded UI. Built with SwiftUI and MVVM.

Overall Approach & Architecture
The goal was to make the form completely driven by data. If you swap out form.json, the entire UI changes — new fields appear, old ones disappear, ordering shifts, validation rules update. Zero code changes needed.
Architecture: MVVM
form.json
    ↓
JSONLoader (Utility)
    ↓
FormViewModel (ObservableObject)
    ├── FormModel (parsed structure)
    ├── formState [fieldId: FormStateValue] (live values)
    └── validationErrors [fieldId: String]
    ↓
ContentView
    └── Renders sorted fields → individual Views
            TextFieldView / DropdownView / ToggleView / CheckboxView

FormResponse.swift holds all the Codable models. The root FormField is an indirect enum that decodes based on the type key in JSON — so adding a new field type is just adding a new case.
FormViewModel owns all state: parsed form, live field values, validation errors, and submission state. Views are purely reactive — they read from the ViewModel and call update functions, no business logic sits in the UI.
formState uses a [String: FormStateValue] dictionary with a typed enum (FormStateValue) so the ViewModel always knows what kind of value it's holding for each field, without stringly-typed casting.
Fields are sorted at render time using the order key from JSON, so the JSON author controls the layout sequence independently of the array order.


Product Decisions
1. Validation fires only on submit, not while typing
The spec didn't say when to validate. I went with submit-only validation rather than on-change, because the form has required fields like password and URL that look "wrong" as soon as you start typing. Showing red errors mid-keystroke feels aggressive and hurts usability. The one concession: once a field has an error shown, it clears the moment the user touches it — so feedback is immediate after a failed submit.
2. Default value that exceeds max_length is silently trimmed
The campaign_name field in form.json has a default_value of "Summer Sale 2026 - Extended Promotional Edition" (47 chars) and a max_length of 20. These contradict each other. Rather than crashing or showing an immediate error on load, I initialize the field with an empty string (ignoring the default) and let the user fill it in. Alternatively the default could be trimmed to 20 chars, but showing a pre-truncated value would likely confuse users who copied the default from somewhere. Doing nothing on load and enforcing the limit on input felt like the least surprising behavior.
3. Unknown / unsupported field types are silently skipped
The JSON includes a COLOR_PICKER type that isn't fully implemented yet. Rather than crashing the decoder or showing a broken card, unknown types decode to .unknown and are filtered out before rendering. This means the form is resilient to forward-compatible JSON — a backend can add new field types and older app versions just ignore them gracefully, which matters in a real production setup.

What I'd Improve with More Time

Conditional visibility — forms often need fields that appear only when another field has a certain value (e.g. show "Other network" text field if "Other" is selected in Ad Networks). The JSON schema could support a visible_when key and the ViewModel could handle it reactively.
Accessibility — labels and error messages need proper accessibilityLabel and accessibilityHint annotations. The current implementation is screen-reader-naive.
Unit tests for FormViewModel — validation logic, default value initialization, and field sorting are all testable in isolation and should have coverage before shipping.
Network-loaded JSON — right now the config is bundled. In practice you'd fetch it from an API so forms can be updated without an app release. The JSONLoader utility is already separated out, which makes this a straightforward swap.


What I Got Stuck On
Decoding the FormField enum from polymorphic JSON
The tricky part was that the JSON array contains objects of different shapes under the same fields key. Swift's Codable doesn't handle this out of the box — you have to manually decode the type discriminator first, then decode the full object a second time with the right model. I initially tried a struct-based approach with optional fields for everything, but that got messy fast. Switching to an indirect enum with a custom init(from:) that peeks at the type key before dispatching to the right model made things clean and type-safe.
The second snag was DropdownFieldModel — allow_multiple is optional in the JSON (some dropdown fields don't include it), but the model needs a concrete Bool. Using decodeIfPresent with a ?? false fallback solved it, but it meant writing a custom init(from:) for that model specifically rather than relying on synthesized Codable.
