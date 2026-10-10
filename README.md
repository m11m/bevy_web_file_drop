# bevy_web_file_drop

Bevy plugin adding better support for drag and drop files in the web.
Bevy has built in [drag and drop events](https://docs.rs/bevy/latest/bevy/prelude/enum.FileDragAndDrop.html), but they cause a panic when used in a web build and don't cancel the default browser behavior.
This plugin adds some custom JavaScript glue around the canvas to catch these events and relay them to Bevy.

## Testing

View the example on web with `trunk serve`.
View the example on native with `cargo run -p example`.

Drop in `.png` files to see the texture change.

### Linux/Wayland

`winit`'s Wayland backend does not emit drag-and-drop events (only X11, Windows and macOS do), so on a Wayland session the native example receives nothing.
Run it under X11 instead:

```sh
env -u WAYLAND_DISPLAY cargo run -p example
```
