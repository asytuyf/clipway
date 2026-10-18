// Phase 0 spikes: can a Mac app see Universal Clipboard items, and do its own writes reach the iPhone?
//
//   swift spikes/pasteboard.swift watch          # then copy something on the iPhone
//   swift spikes/pasteboard.swift write "hello"  # then paste on the iPhone within ~2 minutes

import AppKit

let pasteboard = NSPasteboard.general

// Marker Apple adds to items that arrived from another device via Universal Clipboard.
let remoteType = NSPasteboard.PasteboardType("com.apple.is-remote-clipboard")
// Marker password managers add (see nspasteboard.org).
let concealedType = NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")

func timestamp() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSS"
    return formatter.string(from: Date())
}

func describeCurrentItem() {
    let types = pasteboard.types ?? []
    let isRemote = types.contains(remoteType)
    let isConcealed = types.contains(concealedType)

    print("[\(timestamp())] change #\(pasteboard.changeCount)  remote=\(isRemote)  concealed=\(isConcealed)")
    print("  types: \(types.map(\.rawValue).joined(separator: ", "))")

    // Reading the data is what pulls a remote item over from the other device, so time it.
    let start = Date()
    if let text = pasteboard.string(forType: .string) {
        let preview = text.count > 80 ? String(text.prefix(80)) + "…" : text
        print("  text: \(preview.debugDescription)")
    } else if let image = NSImage(pasteboard: pasteboard) {
        print("  image: \(Int(image.size.width))x\(Int(image.size.height))")
    } else {
        print("  (no text or image)")
    }
    print("  read took \(Int(Date().timeIntervalSince(start) * 1000)) ms")
}

func watch() {
    print("Watching the pasteboard (Ctrl+C to stop). Copy something on the iPhone now.")
    var lastChangeCount = pasteboard.changeCount
    // macOS has no clipboard-changed event, so every clipboard manager polls changeCount like this.
    Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        describeCurrentItem()
    }
    RunLoop.main.run()
}

func write(_ text: String) {
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
    print("Wrote \(text.debugDescription) to the pasteboard. Paste on the iPhone within ~2 minutes.")
}

let args = CommandLine.arguments.dropFirst()
switch args.first {
case "watch":
    watch()
case "write" where args.count >= 2:
    write(args.dropFirst().joined(separator: " "))
default:
    print("usage: swift spikes/pasteboard.swift watch | write <text>")
    exit(1)
}
