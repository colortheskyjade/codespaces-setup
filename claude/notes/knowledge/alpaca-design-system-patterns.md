# Alpaca Design System - Component Patterns & Common Issues

## Component Inheritance Patterns

### Layout Components
- **Row** extends **Flex** → uses `align` prop (not `alignItems`)
- **Column** extends **Flex** → uses `align` prop 
- **Center** extends **AlpacaStyleProps** → inherits BoxProps
- **Flex** has `align` prop mapped to CSS `align-items`

### Icon Components  
- **FAIcon** extends **CenterProps** → inherits **AlpacaStyleProps** → inherits **BoxProps**
- Available style props: `padTop`, `padBottom`, `padLeft`, `padRight`, `padX`, `padY`, `pad`
- Available props: `margin`, `marginTop`, `width`, `height`, etc.

### Typography Component Migration
- **Legacy variants**: Use `legacyVariant` prop (e.g., `legacyVariant="titleMedium"`)
- **New variants**: Use `variant` prop (e.g., `variant="Heading/L"`)
- Feature flag: `StatsigFeatureFlag.AlpacaTypographyVariantMigration` controls which variant system to use
- Common legacy variants: `titleMedium`, `titleSmallPlus`, `bodySmall`, `bodyRegular`, etc.

### Badge Components
- **BadgeV2**: Valid intents defined in `BADGE_INTENTS` array: `"neutral"`, `"success"`, `"warning"`, `"danger"`, `"info"`
- **BadgeV2**: Valid variants: `"primary"`, `"secondary"`

## Common TypeScript Issues & Solutions

### 1. Message Role Type Filtering (Vercel AI SDK)
**Problem**: Messages from useChat include roles like "system", "data" that don't match UI component expectations
```typescript
// ❌ Wrong: Type assertion
messages.map(message => <Component role={message.role as "user" | "assistant"}>)

// ✅ Correct: Type guard with filtering
messages
  .filter((message): message is typeof message & { role: "user" | "assistant" } => 
    message.role === "user" || message.role === "assistant"
  )
  .map(message => <Component role={message.role}>)
```

### 2. Vercel AI SDK Status Values
**Problem**: Using wrong status values for loading states
```typescript
// ❌ Wrong: "in_progress" doesn't exist
status === "in_progress"

// ✅ Correct: Actual status values
status === "streaming" // for loading
status === "ready"     // for idle  
status === "error"     // for error
```

### 3. Layout Component Props
**Problem**: Using CSS property names instead of component-specific props
```typescript
// ❌ Wrong: alignItems is CSS property
<Row alignItems="center">

// ✅ Correct: align is the actual prop
<Row align="center">
```

### 4. Typography Variant Migration
**Problem**: Using old variant system without legacy prop
```typescript
// ❌ Wrong: Old variants without legacyVariant
<Typography variant="titleMedium">

// ✅ Correct: Use legacyVariant for old variants  
<Typography legacyVariant="titleMedium">

// ✅ Also correct: Use new variant system
<Typography variant="Heading/L">
```

## Component Prop Investigation Process

### When you encounter TypeScript prop errors:

1. **Find the component export**:
   ```bash
   # Find component file
   find apps/web-client/src/alpaca -name "*component-name*"
   ```

2. **Check component definition**:
   - Look for interfaces (e.g., `ComponentNameProps`)
   - Check if it extends other interfaces
   - Look for const arrays defining valid values

3. **Check inheritance chain**:
   - If extends `AlpacaStyleProps` → has BoxProps (padding, margin, etc.)
   - If extends `FlexProps` → uses `align` not `alignItems`
   - If extends `CenterProps` → has box model props

4. **Look for validation patterns**:
   - Arrays like `BADGE_INTENTS`, `TYPOGRAPHY_BODY_VARIANTS`
   - Feature flags for migration (e.g., typography variants)
   - Legacy prop patterns (e.g., `legacyVariant`)

## ESLint Patterns to Watch

### Type Assertions
- Avoid `as SomeType` for string unions → use type guards
- ESLint rule: `vanta/no-string-union-type-assertion`

### React Patterns  
- Use explicit function types: `(): React.JSX.Element` instead of `React.FC`
- Avoid deprecated props like `isLoading` from old useChat versions

## Architecture Insights

### Import Patterns
- Route files follow consistent pattern matching existing routes exactly
- Use `#web-client/` path mapping for internal imports
- Use `@vanta/package-name` for cross-package imports

### Component Structure
- Alpaca components have consistent inheritance patterns
- Many components extend base interfaces with style props
- Feature flags control component behavior migration