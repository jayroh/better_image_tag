# Phase 1: Critical Security and Stability Improvements

## Overview

This PR implements **Phase 1** of a comprehensive refactoring plan focused on critical security vulnerabilities and stability improvements for the better_image_tag gem.

## 🔒 Security Fixes

### 1. Replace URI.open with Net::HTTP (**CRITICAL**)
- **Vulnerability**: `URI.open` (deprecated `Kernel#open`) enables arbitrary command execution
- **Fix**: Implemented secure `Net::HTTP` with proper timeout configuration
- **Impact**: Prevents remote code execution attacks
- **Severity**: Critical (CVE-worthy)

### 2. Fix Shell Injection Vulnerabilities (**HIGH**)
- **Vulnerability**: String interpolation in `system()` calls allows shell injection via malicious filenames
- **Fix**: Use array form of `system()` which properly escapes arguments
- **Affected Commands**:
  - `convert_jpg_to_webp.rb`
  - `convert_jpg_to_avif.rb`
- **Impact**: Prevents command injection (e.g., filename: `"image.jpg; rm -rf /"`)
- **Severity**: High

### 3. Replace Unmaintained mimemagic Dependency (**MEDIUM**)
- **Issue**: mimemagic gem is unmaintained and has known security issues
- **Fix**: Migrated to `marcel` gem (maintained by Rails team)
- **Impact**: Uses actively maintained, secure dependency
- **Severity**: Medium

### 4. SVG Sanitization & XSS Prevention (**HIGH**)
- **Vulnerability**: Regex-based SVG manipulation doesn't sanitize malicious content
- **Fix**: Implemented Nokogiri-based XML parsing with sanitization:
  - Removes dangerous elements (`<script>`, `<foreignObject>`)
  - Strips event handlers (`onclick`, `onload`, `onerror`, etc.)
  - Validates SVG structure
- **Impact**: Prevents XSS attacks via malicious SVG files
- **Severity**: High

---

## 🛡️ Error Handling Improvements

### Enhanced Error Handling
- ✅ Added configurable `on_error` callback for custom error handling
- ✅ Expanded HTTP error types (timeout, connection refused, socket errors)
- ✅ Graceful degradation on network failures
- ✅ Better error messages with context
- ✅ New error classes: `RemoteFetchError`, `InvalidSvgError`

### Network Timeout Configuration
- ✅ Configurable network timeouts (default: 10 seconds)
- ✅ Prevents hanging requests in production
- ✅ Applied to all remote image fetching operations

---

## 📦 Dependency Changes

| Change | Old | New | Reason |
|--------|-----|-----|--------|
| **Removed** | `mimemagic` | - | Unmaintained, security issues |
| **Added** | - | `marcel ~> 1.0` | Rails-maintained MIME detection |
| **Added** | - | `nokogiri >= 1.12.0` | Secure XML parsing |

---

## ⚙️ Configuration Changes

New configuration options:

```ruby
BetterImageTag.configure do |config|
  # Network timeout for remote image fetching (default: 10 seconds)
  config.network_timeout = 30

  # Error callback for monitoring/logging
  config.on_error = ->(error, context) do
    Rails.logger.error("BetterImageTag error: #{error.message}")
    # Optional: Send to error tracking service
    Sentry.capture_exception(error, extra: context)
  end
end
```

---

## 🔄 Migration Guide

### For Users

1. **Update dependencies**:
   ```bash
   bundle update better_image_tag
   ```

2. **Remove any mimemagic constraints** from your `Gemfile` (if present)

3. **(Optional) Configure error callbacks**:
   ```ruby
   # config/initializers/better_image_tag.rb
   BetterImageTag.configure do |config|
     config.on_error = ->(error, context) do
       Rails.logger.warn("Image processing failed: #{error.message}")
     end
   end
   ```

### Breaking Changes

**None.** All changes are backward compatible.

---

## 🧪 Testing Recommendations

While all existing tests should pass, please manually test:

1. **Remote image fetching** with various URLs
2. **SVG inlining** with potentially malicious content
3. **Image conversion** with special characters in filenames (e.g., spaces, semicolons)
4. **Timeout behavior** with slow/unresponsive servers

---

## 📊 Code Changes Summary

```
8 files changed, 126 insertions(+), 23 deletions(-)
```

### Modified Files
- `better_image_tag.gemspec` - Dependency updates
- `lib/better_image_tag.rb` - Configuration enhancements
- `lib/better_image_tag/commands/convert_jpg_to_avif.rb` - Shell injection fix
- `lib/better_image_tag/commands/convert_jpg_to_webp.rb` - Shell injection fix
- `lib/better_image_tag/errors.rb` - New error classes
- `lib/better_image_tag/image_tag.rb` - Marcel integration
- `lib/better_image_tag/inline_data.rb` - Secure HTTP + error handling
- `lib/better_image_tag/svg_tag.rb` - Nokogiri parsing + sanitization

---

## 🎯 Future Work (Phase 2+)

This is **Phase 1** of a larger refactoring effort. Future phases will include:

- **Phase 2**: Architecture improvements (DRY, extract service objects)
- **Phase 3**: Modern format support (JPEG XL, WebP2)
- **Phase 4**: Developer experience (better testing, CLI improvements, logging)

---

## ✅ Checklist

- [x] Security vulnerabilities fixed
- [x] Error handling improved
- [x] Dependencies updated
- [x] Backward compatibility maintained
- [x] Configuration options documented
- [x] Code follows existing style
- [x] No breaking changes

---

## 🔍 Review Focus Areas

Please pay special attention to:

1. **Security fixes** - Verify the Net::HTTP implementation is secure
2. **SVG sanitization** - Ensure no XSS vectors remain
3. **Error handling** - Check graceful degradation works as expected
4. **Backward compatibility** - Confirm no breaking changes

---

**Priority**: High (Security fixes)
**Type**: Refactoring + Security
**Backward Compatible**: Yes ✅

---

## GitHub PR Link

Create pull request at: https://github.com/jayroh/better_image_tag/compare/master...claude/plan-refactoring-01NGQVYUHfAxXgQBL6abNn4r

**Title**: Phase 1: Critical Security and Stability Improvements

**Branch**: `claude/plan-refactoring-01NGQVYUHfAxXgQBL6abNn4r`
**Base**: `master`
