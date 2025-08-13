# GPT-5 Shadow Mode Implementation - January 13, 2025

## Summary
Successfully implemented GPT-5 shadow mode with feature flags for QAuto answer generation system. The implementation allows for gradual rollout and A/B testing of GPT-5 responses while maintaining GPT-4.1 as a reliable fallback.

## Key Learnings

### 1. Feature Flag Architecture
- **Two-flag approach** is superior to single flag:
  - `QAutoGpt5ShadowMode`: Controls whether to invoke GPT-5 at all (cost control)
  - `QAutoGpt5`: Controls whether to use GPT-5 responses (behavior control)
- **Use `domainHasFeatures`** instead of multiple `domainHasFeature` calls for efficiency
- **Logical combination**: `enableShadowMode = isQAutoGpt5ShadowModeEnabled || isQAutoGpt5Enabled`

### 2. Promise Management Best Practices
- **`PromiseAllWithoutAbandonment`** is better than `Promise.all` for side effects
- **Conditional promise arrays** using spread operator + ternary is cleaner than pushing:
  ```typescript
  const results = await PromiseAllWithoutAbandonment([
    promise1,
    ...(condition ? [promise2] : []),
  ]);
  ```
- **Avoid `.catch()` handlers** when using `PromiseAllWithoutAbandonment` - it returns errors as objects

### 3. Error Handling Evolution
- **Try/catch became obsolete** when switching to `PromiseAllWithoutAbandonment`
- **Check `instanceof Error`** on results instead of catching exceptions
- **Graceful degradation**: Always have GPT-4.1 as fallback, even if both models fail
- **Detailed error logging** with context about which models were attempted

### 4. TypeScript Patterns
- **Union types** from promise utilities require careful type guards
- **Optional chaining** vs explicit null checks - be consistent with linter preferences
- **Array destructuring** works well with `PromiseAllWithoutAbandonment` results

### 5. Model Configuration Requirements
- **GPT-5 must use temperature: 1** (business requirement)
- **GPT-4.1 uses temperature: 0** for deterministic results
- **Different metadata** for tracking: `task: "answer-generation"` vs `task: "answer-generation-gpt5"`

### 6. Code Evolution Insights
- **Started simple**: Single model call with basic error handling
- **Added complexity gradually**: Parallel execution → Feature flags → Conditional invocation
- **Removed complexity**: DataDog metrics, try/catch blocks, unused imports
- **Final result cleaner** than intermediate states due to iterative refinement

### 7. Debugging Techniques
- **Timeout configuration**: Set 10-minute timeout for `turbo typecheck` via tool parameters
- **Import management**: Remeda vs Ramda confusion - always verify library names
- **Function return types**: `doNothing` from remeda returns `void` (undefined)

### 8. Git Workflow
- **Branch naming**: User preferred `ruyan/gpt5/123` over generated `feat/qauto-gpt5-shadow-mode`
- **Commit reverted**: Changes accidentally went to wrong branch initially
- **Cherry-pick unnecessary**: Commit was already on correct branch

### 9. Feature Flag Logic Matrix
```
ShadowMode=OFF, Gpt5=OFF → Only GPT-4.1 runs, use GPT-4.1 result
ShadowMode=ON,  Gpt5=OFF → Both run, use GPT-4.1 result (shadow testing)
ShadowMode=ON,  Gpt5=ON  → Both run, use GPT-5 result with GPT-4.1 fallback
ShadowMode=OFF, Gpt5=ON  → Both run, use GPT-5 result (enableShadowMode logic)
```

## Implementation Highlights
- **Zero behavioral change** when both flags are off
- **Gradual rollout capability** through independent flag control
- **Cost optimization** by completely disabling GPT-5 calls when not needed
- **Reliability maintained** through automatic fallback mechanisms
- **Clean code** with minimal complexity and good separation of concerns

## Files Modified
- `packages/codegen-common/src/features/statsigFeatures.ts`: Added feature flags
- `packages/trust/src/ai/answer-generation/aiAnswerGeneration.ts`: Core implementation

## Success Metrics
- ✅ All TypeScript checks pass
- ✅ Parallel execution working
- ✅ Feature flags integrated
- ✅ Error handling robust
- ✅ Code is clean and maintainable