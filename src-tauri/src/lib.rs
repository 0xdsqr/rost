// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/
use tauri::Manager;

#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            #[cfg(desktop)]
            {
                use tauri_plugin_global_shortcut::{Code, GlobalShortcutExt, Modifiers, Shortcut, ShortcutState};
                
                // Create shortcuts with explicit modifiers and keys
                let show_shortcut = Shortcut::new(
                    Some(if cfg!(target_os = "macos") {
                        Modifiers::META | Modifiers::SHIFT
                    } else {
                        Modifiers::CONTROL | Modifiers::SHIFT
                    }),
                    Code::KeyO
                );
                
                let hide_shortcut = Shortcut::new(
                    Some(if cfg!(target_os = "macos") {
                        Modifiers::META | Modifiers::SHIFT
                    } else {
                        Modifiers::CONTROL | Modifiers::SHIFT
                    }),
                    Code::KeyH
                );
                
                // Register the plugin with a handler
                let app_handle = app.handle().clone();
                app.handle().plugin(
                    tauri_plugin_global_shortcut::Builder::new()
                        .with_handler(move |_app, shortcut, event| {
                            if shortcut == &show_shortcut && event.state() == ShortcutState::Pressed {
                                if let Some(window) = app_handle.get_webview_window("main") {
                                    if window.is_visible().unwrap_or(false) {
                                        let _ = window.set_focus();
                                    } else {
                                        let _ = window.show();
                                        let _ = window.set_focus();
                                    }
                                }
                            } else if shortcut == &hide_shortcut && event.state() == ShortcutState::Pressed {
                                if let Some(window) = app_handle.get_webview_window("main") {
                                    let _ = window.hide();
                                }
                            }
                        })
                        .build(),
                )?;
                
                // Register the shortcuts
                app.global_shortcut().register(show_shortcut)?;
                app.global_shortcut().register(hide_shortcut)?;
            }
            
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![greet])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
