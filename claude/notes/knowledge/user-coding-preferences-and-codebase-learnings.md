# User Coding Preferences & Codebase Learnings

*Last updated: 2025-08-09*

## 🎯 User's Coding Philosophy & Preferences

### **Dependency Injection Approach**
- **Strongly dislikes complex dependency injection patterns** - considers them "overly complex" and "difficult to work with and maintain"
- **Prefers simple, direct dependency creation** over function injection abstractions
- **Values app-level control** - prefers to instantiate dependencies (like AIClient) at the application level where configuration is available, then pass as clean parameters
- **Favors interface-based parameters** (e.g., `IAIClient` vs `AIClient`) for easier testing and mocking

### **Function Signature Preferences**
- **Prefers positional arguments over nested objects** when practical
- **Specific parameter ordering preference** - when given choice, preferred AIClient as second positional argument rather than first
- **Values clean separation** - likes packages to not know about configuration details, keeping that at app level

### **Refactoring Approach**
- **Strongly prefers incremental changes** over large refactors - when I suggested a complex multi-phase refactor, requested to "take a step back" and focus on smaller pieces
- **Values safety over speed** - appreciates step-by-step approaches with testing at each phase
- **Requests detailed explanations** of changes and their benefits

### **Code Quality Values**
- **Maintainability over cleverness** - explicitly called out "unnecessary abstractions" as problematic
- **Simplicity over sophistication** - prefers direct, obvious code paths
- **Testability focus** - specifically requested interface types to make mocking easier

## 🏗️ Codebase Architecture Insights

### **AI Answer Generation System (packages/trust/src/ai/)**
- **Major architectural risk**: Complex dependency injection patterns make code nearly untestable and hard to debug
- **Key files analyzed**:
  - `packages/trust/src/ai/legacy/runAiAnswerGeneration.ts` - Main AI answer generation function
  - `packages/trust/src/ai/legacy/generateQAutoAnswer.ts` - Caller/wrapper function
  - `packages/trust/src/ai/answer-generation/aiAnswerGeneration.ts` - Core AI logic

### **Problematic Patterns Found**
1. **Function Injection Complexity**:
   - `generateObjectCompletionLlmSdk` was being injected as a function parameter
   - `retrievalFn` abstraction added unnecessary indirection
   - Made testing extremely difficult (complex mocking required)

2. **Error Handling Issues**:
   - Silent failures converted to `null` returns
   - Critical errors swallowed in try/catch blocks
   - No circuit breakers or retry logic for LLM calls

3. **Data Transformation Complexity**:
   - 5+ transformation layers for data flow
   - Multiple utility functions like `zipScoresToDocs`, `flattenAnswerLibraryAnswers`
   - Each transformation added mutation risk

4. **Configuration Coupling**:
   - Complex dynamic config resolution with multiple fallback layers
   - Feature flags scattered throughout
   - AI preferences, dynamic configs, and feature flags interacted unpredictably

### **Successful Refactoring Pattern Applied**
- **Removed `generateObjectCompletionLlmSdk` injection** → Direct AIClient parameter
- **App-level AIClient creation** → Package-level usage
- **Interface-based typing** (`IAIClient`) → Better testability
- **Maintained identical behavior** → All tests passed throughout

### **Testing Infrastructure**
- Uses Jest/Mocha for unit tests
- Has `just unit-test <path>` command for running specific tests
- Uses `turbo typecheck -F <workspace>` for TypeScript checking
- Tests are co-located with source files (`*.test.ts`)

## 🔧 Development Workflow Patterns

### **Preferred Refactoring Process**
1. **Start small** - focus on one specific problem (e.g., single dependency injection point)
2. **Incremental changes** - make one change at a time with testing
3. **Safety first** - ensure tests pass at each step
4. **Clear documentation** - appreciate comments explaining the changes and rationale

### **Communication Style**
- **Appreciates detailed explanations** of why changes are beneficial
- **Values concrete examples** over abstract descriptions
- **Likes to understand trade-offs** and architectural decisions
- **Prefers "show don't tell"** - wants to see actual code changes with explanations

## 🎓 Key Takeaways for Future Interactions

1. **Always suggest incremental approaches** over large refactors
2. **Focus on simplification** rather than adding new abstractions
3. **Explain the "why"** behind architectural decisions
4. **Test frequently** and show that tests pass
5. **Respect parameter ordering preferences** and ask for clarification
6. **Use interface types** when providing flexibility for testing
7. **Keep configuration concerns at app level** when possible
8. **Document changes clearly** with comments explaining the transition

This user values **maintainable, simple, well-tested code** over clever or sophisticated patterns. They appreciate thoughtful architectural decisions that make code easier to understand and modify.