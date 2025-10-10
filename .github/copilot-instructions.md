# ColdBox Super Simple Template - AI Coding Instructions

This is the **bare minimum** ColdBox application template - perfect for learning, prototyping, or starting a simple application. It provides just the core framework (ColdBox) with basic testing, no modules, no complex structure.

## 🎯 Template Philosophy

**Minimalist by Design**: Single handler (`Main.cfc`), single layout (`Main.cfm`), single view directory. Add complexity only when needed. No routing configuration - uses ColdBox conventions exclusively.

## 📁 Flat Structure

```
/                          - Webroot (everything publicly accessible)
├── Application.cfc       - App bootstrap (sessions, mappings)
├── index.cfm             - Entry point (placeholder, everything in Application.cfc)
├── handlers/             - Event handlers
│   └── Main.cfc         - Single handler with implicit events
├── views/                - View templates
│   └── main/            - Corresponds to Main handler
│       └── index.cfm    - Main.index view
├── layouts/              - Layout wrappers
│   └── Main.cfm         - Default layout
├── config/               - Configuration
│   └── ColdBox.cfc      - Framework settings
└── tests/                - TestBox integration tests
    ├── Application.cfc  - Test app bootstrap (appMapping="/app")
    └── specs/           - BDD test specs
```

**CRITICAL**: No `models/`, no `modules_app/`, no custom routing. Pure conventions-based development.

## 🔧 Handler Pattern (Main.cfc)

All handlers extend `coldbox.system.EventHandler`:

```cfml
component extends="coldbox.system.EventHandler" {

    /**
     * Default action - convention-based routing to /main/index
     */
    function index(event, rc, prc){
        prc.welcomeMessage = "Welcome to ColdBox!";
        event.setView("main/index");
    }

    /**
     * RESTful data rendering - auto-converts array/struct to JSON
     */
    function data(event, rc, prc){
        return [
            { "id": createUUID(), "name": "Luis" }
        ];
    }

    /**
     * Relocation example
     */
    function doSomething(event, rc, prc){
        relocate("main.index");  // Redirects to main.index event
    }

    // ========== Implicit Events ==========
    // MUST be declared in config/ColdBox.cfc to fire

    function onAppInit(event, rc, prc){}
    function onRequestStart(event, rc, prc){}
    function onRequestEnd(event, rc, prc){}
    function onSessionStart(event, rc, prc){}
    function onSessionEnd(event, rc, prc){
        var sessionScope = event.getValue("sessionReference");
        var applicationScope = event.getValue("applicationReference");
    }
    function onException(event, rc, prc){
        event.setHTTPHeader(statusCode=500);
        var exception = prc.exception;  // Placed by ColdBox
    }
}
```

## 🧪 Testing Pattern

Integration tests use `coldbox.system.testing.BaseTestCase` with **virtual app**:

```cfml
component extends="coldbox.system.testing.BaseTestCase" appMapping="/app" {

    function run(){
        describe("Main Handler", function(){
            beforeEach(function(currentSpec){
                setup();  // CRITICAL: Reset for each test
            });

            it("can render the homepage", function(){
                var event = this.get("main.index");
                expect(event.getValue(name="welcomemessage", private=true))
                    .toBe("Welcome to ColdBox!");
            });

            it("can render restful data", function(){
                var event = this.post("main.data");
                expect(event.getRenderedContent()).toBeJSON();
            });

            it("can do relocation", function(){
                var event = execute(event="main.doSomething");
                expect(event.getValue("relocate_event", "")).toBe("main.index");
            });
        });
    }
}
```

**Testing Key Points**:
- `appMapping="/app"` in test component declaration
- `setup()` in `beforeEach()` to reset request context
- Access private RC with `event.getValue(name="key", private=true)`
- Check relocations via `event.getValue("relocate_event")`
- `this.get()`, `this.post()` shortcuts for HTTP methods

## 🚀 Build Commands

```bash
# Install framework
box install

# Start server
box server start

# Code formatting
box run-script format              # Format all CFML
box run-script format:check        # Check formatting
box run-script format:watch        # Auto-format on save

# Testing
box testbox run                    # Run all integration tests
```

## ⚙️ Configuration (config/ColdBox.cfc)

```cfml
coldbox = {
    appName: getSystemSetting("APPNAME", "Your app name here"),
    
    // Conventions-only routing (no Router.cfc)
    defaultEvent: "",  // Defaults to "main.index" by convention
    
    // Implicit event handlers (must declare to activate)
    requestStartHandler: "Main.onRequestStart",
    applicationStartHandler: "Main.onAppInit",
    exceptionHandler: "main.onException",
    
    // Auto-reload during development
    handlersIndexAutoReload: true,
    
    // Auto-map models (no models/ folder yet, but ready)
    autoMapModels: true,
    
    // Auto-convert JSON body to RC
    jsonPayloadToRC: true
};
```

**No Routing File**: Template relies entirely on ColdBox conventions. URLs map to `handler.action` automatically.

## 📐 Conventions

1. **URL to Event**: `/main/index` → `Main.cfc.index()`
2. **View Resolution**: `event.setView("main/index")` → `/views/main/index.cfm`
3. **Layout Resolution**: No layout specified → uses `/layouts/Main.cfm`
4. **Handler Discovery**: All CFCs in `/handlers/` auto-discovered
5. **Event Arguments**: `event` (request context), `rc` (request collection), `prc` (private request collection)

## 🎨 View/Layout Pattern

**View** (`views/main/index.cfm`):
```cfml
<cfoutput><h1>#prc.welcomeMessage#</h1></cfoutput>
```

**Layout** (`layouts/Main.cfm`):
```cfml
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Welcome to Coldbox!</title>
</head>
<body>
    <div class="container">#view()#</div>
</body>
</html>
</cfoutput>
```

**Key**: `#view()#` in layout renders the view content.

## 🔑 Common Patterns

```cfml
// Setting variables for views
prc.myData = "value";          // Private RC (not in URL)
rc.publicData = "value";       // Public RC (can be in URL)

// Rendering views
event.setView("main/index");              // Use layout
event.setView(view="main/index", nolayout=true);  // Skip layout

// RESTful responses (auto-JSON)
return { "message": "success" };          // Array/struct auto-converts
event.renderData(type="json", data=myData);  // Explicit rendering

// Relocations
relocate("main.index");                   // Internal redirect
relocate(url="/some/url");                // External URL

// Dependency injection (when you add models/)
property name="myService" inject="MyService";
```

## 📦 When to Graduate

Add complexity as needed:

- **Add models/**: When you need services/business logic → Use `autoMapModels=true`
- **Add Router.cfc**: When you need custom routes → Create `config/Router.cfc`
- **Add modules**: When you need HMVC separation → Create `modules_app/`
- **Switch templates**: For security (modern), APIs (rest), or structure (flat)

## 🚨 Common Pitfalls

1. **Missing `setup()`**: Always call `setup()` in test `beforeEach()` - each test needs clean request
2. **Implicit Events Not Firing**: Must declare in `config/ColdBox.cfc` (e.g., `requestStartHandler`)
3. **Private RC Access**: Use `event.getValue(name="key", private=true)` not `prc.key` in tests
4. **View Not Found**: Ensure view path matches handler name (`Main.cfc` → `views/main/`)
5. **Testing appMapping**: Test `Application.cfc` must have `appMapping="/app"` - maps to root

## 📚 Key Files

- `handlers/Main.cfc` - Single handler with lifecycle events
- `config/ColdBox.cfc` - Framework configuration (no routing)
- `tests/Application.cfc` - Test bootstrap with `VirtualApp`
- `tests/specs/integration/MainSpec.cfc` - Integration test examples

## 📖 Documentation

- ColdBox Conventions: https://coldbox.ortusbooks.com/getting-started/conventions
- Event Handlers: https://coldbox.ortusbooks.com/the-basics/event-handlers
- Testing: https://coldbox.ortusbooks.com/testing/testing-coldbox-applications
- TestBox BDD: https://testbox.ortusbooks.com/primers/bdd
