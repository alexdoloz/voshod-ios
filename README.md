#  Voshod 

## About
Currently this framework is very work-in-progress, APIs can change any time without any notice.

**Voshod** will let you quickly add Lua scripting capabilities to your app. Usually such frameworks go one of two ways: either provide glorified object-oriented facade to Lua stack manipulation functions or translates all host platform class hierarchies into Lua (see [LuaCocoa](https://github.com/SolaWing/luacocoa)). **Voshod** takes different approach.
It provides abstractions for Lua virtual machine (`VM`) and for Lua<->Native bindings (`Plugin`). **Voshod** is written in Swift with direct calls to Lua C API (no ObjC middleman).

## Why?
1. To use Lua scripts as crossplatform (see [Global roadmap](#global-project-roadmap)) config files (colors, fonts, localization strings, etc.)
1. To use Lua scripts as library for code reuse – validators, calculators, etc.
1. To allow big project make clean separation between hardcore "engine" code (native, compiled, hard to learn language, interacts with platform, provides clean API for scripters) and easy "script" code (Lua, interpreted, can be downloaded from server even after app already in store, very easy language suitable for describing business logic with DSLs).

## Why Lua?
1. I like Lua.
1. Easiest language I've seen given its power.
1. Easy to sandbox for potentially unsafe code (`setfenv`, `print = nil`, etc.)
1. Small
1. Fast
1. It's so easy to use C API in Swift
1. Very good data description language (like JSON, but with ifs and functions)

## What are Plugins?
Plugin lets you create communication channel between Lua and Native code. You can pass JSON-like types as `nil`, `Int`, `Bool`, `String`, `Double`, pointers to native objects (as lightuserdata) and `Array`s and `Dictionary`s of the above. Communication works both ways. When you call `send` on the plugin, its counterpart gets `receive` called with the same value.
When you `send`, you can get return value from the counterpart. Plugins works synchronously on the same thread the `VM` operates (btw, the `VM` is not meant to be called from multiple threads).
Plugins have installation script – Lua code called when importing this plugin. It's purpose to provide nice clean interface to the caller code and hide all `receive` logic stuff.
Plugins are imported in Lua with custom `import` function (similar to `require`). It can inject plugin-created symbols into caller's environment or write them to the table passed as second argument (you can make namespacing this way).

## About LuaJIT
**Voshod** is powered by [LuaJIT 2.1.0](https://luajit.org) which, ironically, [doesn't quite JIT](https://9to5mac.com/2020/11/06/ios-14-2-brings-jit-compilation-support-which-enables-emulation-apps-at-full-performance/) on iOS. It has its pros: speed is decent even without JIT, also it has built-in FFI library. On the other side, it's stuck with mix of 5.1 and 5.2 Lua API and it's not so clear when it will keep up to current official 5.4.4 if ever. So I'm considering to replace LuaJIT with Lua 5.4.4 if tests will show the speed is ok. 

## Local project roadmap
What I'm going to do in the nearest time:
- [ ] Implement versioning system. Plugins will have versions adhering to [SemVer](https://semver.org) standard and will be able to depend on one another.
- [ ] Think about passing native objects across the bridge and memory management. Who owns the objects? Do I use `Unmanaged` right? 🤣
- [ ] Think about using plugins with coroutines. Coroutines are pain in the ass since it's separate `lua_State` not created explicitly in native code. Should I provide separate plugin instances for main script thread and for each coroutines?
- [ ] Think about minimum framework version and supported platforms. I will need Xcode 9 (probably) to compile library for 32bit devices so I need to consider tradeoffs.
- [ ] Think about building in simple templating engine. Because end users will probably want to pass some data to scripts via string substitution but keep scripts in separate files, not string literals.
- [ ] Reconsider which data types can and can't go through the bridge. Maybe allow to pass native callbacks to scripts
- [ ] Add support for cancellation of cpu or memory intensive tasks. This is possible via debug hooks
- [ ] Clean up code, add tests, add docs
- [ ] Deploy on SPM, CocoaPods, Carthage

## Global project roadmap
Looks like a lot of work ;)
- Do the same on other Apple platforms.
- Do the same on Android.
- Make (or borrow) testing framework.
- Make (or borrow) documentation tool.
- Make (or borrow) package management tool.
- Make some sort of standard library with classes, `:map()` for arrays and other conveniences everybody expects from the language.
- Make IDE-like extension for VSCode with code completion and debugger.
- Make app like Expo for React Native.
- Invent some script/bytecode packaging format.
- Make plugin for safe execution of scripts so they can't harm or steal data
- Make other plugins: remote script loading, JSON, XML, file system, networking, multithreading, etc.
- Plugin for crossplatform UI.


