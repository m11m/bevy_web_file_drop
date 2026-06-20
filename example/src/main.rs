use bevy::{asset::AssetMetaCheck, prelude::*};

mod plugin;

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins.set(AssetPlugin {
                meta_check: AssetMetaCheck::Never,
                ..default()
            }),
            bevy_web_file_drop::WebFileDropPlugin,
            plugin::ExamplePlugin,
        ))
        .run();
}
