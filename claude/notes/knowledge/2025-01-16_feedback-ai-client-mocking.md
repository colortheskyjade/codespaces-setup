# Feedback Session: AI Client Mocking & Test Patterns

**Date**: 2025-01-16
**Context**: Fixing AI client test mocking patterns in questionnaire generation tests

## Major Feedback Points

### 1. **Proper AI Client Mocking Patterns**
- **Initial Approach**: Used complex manual stubbing of `AIClient.create` with nested `generateObject` functions
- **Feedback**: Use hybrid approach - `createMockAIClient` + `AIClient.create` stub
- **Correct Pattern**: 
  ```ts
  const mockAIClient = createMockAIClient({
    generateObject: (args) => ({ /* return expected data based on args */ })
  });
  sandbox.stub(AIClient, "create").resolves(mockAIClient);
  ```
- **Key Insight**: Configure the mock upfront with expected behavior rather than complex runtime logic

### 2. **Understanding Implementation vs Test Mocking**
- **Issue**: Tests were trying to pass non-existent parameters like `findQuestionSemanticMatchFn`
- **Learning**: Must understand actual function signatures and how the real implementation works
- **Solution**: Traced through actual code to see that `generateAnswer` calls `getExactSemanticMatch` which uses `aiClient.generateObject` directly

### 3. **Test Structure & Cleanliness**
- **Feedback**: Remove extraneous comments that don't add value
- **Before**: Heavy commenting explaining obvious mocking setup
- **After**: Clean, focused test code without redundant explanations

### 4. **Function Signature Alignment**
- **Problem**: Tests included parameters that don't exist in actual function signatures
- **Removed**: `findQuestionSemanticMatchFn`, `documentSearch`, `questionEmbedding` parameters
- **Lesson**: Always verify actual function signatures before writing tests

## Technical Insights

### AI Client Test Patterns
1. **createMockAIClient** is the recommended approach over manual stubbing
2. Configure expected behavior in the mock creation, not in runtime stubs
3. Stub `AIClient.create` to return the pre-configured mock

### Test Debugging Process
1. Read the actual implementation to understand data flow
2. Identify which functions are called with what parameters  
3. Mock at the right level (e.g., `aiClient.generateObject` not intermediate functions)
4. Verify function signatures match between test and implementation

## Patterns to Remember
- **Hybrid mocking**: `createMockAIClient()` + `AIClient.create` stub
- **Schema-based responses**: Mock can return different data based on input schema
- **Parameter cleanup**: Remove non-existent parameters from test args
- **Comment reduction**: Focus on code clarity over excessive explanation

## Files Improved
- `apps/api-external/src/rest/vanta-api/routes/questionnaire-generated-answers/index.test.ts`
- `packages/trust/src/ai/legacy/runAiAnswerGeneration.test.ts`

Both files now use proper AI client mocking patterns and have cleaner, more maintainable test code.