; extends

; `func f(_ call: Call, withId callUUID: UUID)`:
; the argument label (`_`, `withId`) stays @variable.parameter (blue),
; the internal parameter name (`call`, `callUUID`) gets its own group so
; ui.lua can color it as plain text, like Xcode.
((parameter
  external_name: (simple_identifier)
  name: (simple_identifier) @variable.parameter.internal)
  (#set! priority 101))
