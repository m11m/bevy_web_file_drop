use bevy::{asset::AssetMetaCheck, prelude::*};

mod plugin;

fn main() {
    App::new()
        .add_plugins((
            bevy_web_file_drop::WebFileDropPlugin,
            DefaultPlugins.set(AssetPlugin {
                meta_check: AssetMetaCheck::Never,
                ..default()
            }),
            plugin::ExamplePlugin,
        ))
        .run();
}
