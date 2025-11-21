/**
 * @file Bootstrap.res
 * @description Zotero 7 Bootstrapped Add-on entry point.
 * Replaces bootstrap.ts, calling the MakeItRed module compiled from Rescript.
 */

@module("./MakeItRed.js") external makeItRed: {
  ..
  "init": ({
    "id": string,
    "version": string,
    "rootURI": string,
  }) => unit,
  "addToAllWindows": () => unit,
  "main": () => Js.Promise.t<unit>,
  "removeFromAllWindows": () => unit,
  "addToWindow": ({ "window": Js.t<'a> }) => unit,
  "removeFromWindow": ({ "window": Js.t<'a> }) => unit,
} = "MakeItRed"

@module("zotero") @val
external zotero: {
  "debug": string => unit,
  "PreferencePanes": {
    "register": ({
      "pluginID": string,
      "src": string,
      "scripts": array<string>,
    }) => unit,
  },
} = "Zotero"

@module("services") @val
external services: { "scriptloader": { "loadSubScript": string => unit } } = "Services"

let log = (msg: string): unit => {
  zotero["debug"](`Make It Red: ${msg}`)
}

let install = (): unit => {
  log("Installed 2.0 (Rescript)")
}

let startup = ({id, version, rootURI}: {id: string, version: string, rootURI: string}): Js.Promise.t<unit> => {
  log("Starting 2.0 (Rescript)")

  zotero["PreferencePanes"]["register"]({
    pluginID: "make-it-red@example.com",
    src: rootURI + "preferences.xhtml",
    scripts: [rootURI + "preferences.js"],
  })

  // Load the main Rescript-compiled module. Note: This assumes MakeItRed.js exists.
  services["scriptloader"]["loadSubScript"](rootURI + "MakeItRed.js")

  makeItRed["init"]({id: id, version: version, rootURI: rootURI})
  makeItRed["addToAllWindows"]()

  // Wait for the main logic to run
  makeItRed["main"]()
}

let onMainWindowLoad = ({window}: {window: Js.t<'a>}): unit => {
  makeItRed["addToWindow"]({window: window})
}

let onMainWindowUnload = ({window}: {window: Js.t<'a>}): unit => {
  makeItRed["removeFromWindow"]({window: window})
}

let shutdown = (): unit => {
  log("Shutting down 2.0 (Rescript)")
  makeItRed["removeFromAllWindows"]()
}

let uninstall = (): unit => {
  log("Uninstalled 2.0 (Rescript)")
}

// Export functions for Zotero's bootstrap loader (The names must match the Zotero API)
let install_ = install
let startup_ = startup
let onMainWindowLoad_ = onMainWindowLoad
let onMainWindowUnload_ = onMainWindowUnload
let shutdown_ = shutdown
let uninstall_ = uninstall
