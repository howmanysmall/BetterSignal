---
sidebar_position: 3
---

# Justification

Alright, I know that there are TOO many Signal modules, so that's why I've decided to add this justification page.

## Differences from `sleitnick/signal`

I've added quite a few different things compared to the module this was based on. I'll list them here.

- `--!native` - My module is running in native mode. This does in fact make a difference for performance, even if it is a minor one.
- `--!strict` - I've retyped the entire thing so it works on strict mode.
- New features - I have actually added a lot of new features to the library.
  - `Connection.disconnect` - Back when I was working at Ping/Crime Kitchen, a lot of things were using `disconnect`, so I added that for consistency reasons.
  - Better types - I got really used to having the parameter names like how TypeScript would allow, so I added a `Function` parameter to the `Signal` type which allows you to specify it. It is unfortunately more work to do, but the `ClassicSignal` type does exist for this.
  - `Signal.IsConnectedTo` - There was no way for me to check if something was connected to the signal, so I added this function. You probably won't need it though.
  - Removed the unnecessary ultra strict metatables - I don't think this was necessary. It is a weird design choice.
  - `Signal.FireDeferredUnsafe` - There was technically a way to make `Signal.FireDeferred` faster, so I implemented it as an unsafe function. Don't know if it's exactly the same, but it should be.
  - `Signal.FireBindable` - Sometimes, you do want to replicate how a `BindableEvent` would behave in the current `SignalBehavior` mode, so I added this.
  - `Signal.FireBindableUnsafe` - Same justification.
  - `Signal.DebugMode` - I just really don't like unnecessary output logging in `Signal.DisconnectAll`, so I made this optional property to toggle it.
  - `Signal.Destroy` - This actually sets the metatable to nil now. Consistent with all my other stuff.
  - `Signal.instanceof` - Another holdover from TypeScript.
- Performance optimizations - I did optimize this a bit. Should be a bit faster than the original library, and maybe faster than the other Signal libraries.
