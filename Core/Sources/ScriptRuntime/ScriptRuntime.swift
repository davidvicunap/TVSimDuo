#if canImport(JavaScriptCore)
import JavaScriptCore

/// Sandboxed JavaScriptCore runtime for user indicators (implemented in Phase 6).
public enum ScriptRuntime {
    /// Evaluates a pure expression in a throwaway context with no host bindings.
    public static func evaluateExpression(_ source: String) -> Double? {
        guard let context = JSContext() else { return nil }
        guard let value = context.evaluateScript(source), value.isNumber else { return nil }
        return value.toDouble()
    }
}
#endif
