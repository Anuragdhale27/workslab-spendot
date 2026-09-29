#![cfg_attr(not(debug_assertions), windows_subsystem = "windows_subsystem")]

use tauri::{
    CustomMenuItem, Icon, Manager, SystemTray, SystemTrayEvent, SystemTrayMenu,
};

const TRAY_GREEN: &[u8] = include_bytes!("../icons/tray-green.png");
const TRAY_AMBER: &[u8] = include_bytes!("../icons/tray-amber.png");
const TRAY_RED: &[u8] = include_bytes!("../icons/tray-red.png");

// Called from the frontend (app.js -> syncTrayIcon) every time the
// spend status changes, so the real menu bar dot matches the popover.
#[tauri::command]
fn set_tray_icon(app_handle: tauri::AppHandle, level: String) -> Result<(), String> {
    let bytes = match level.as_str() {
        "amber" => TRAY_AMBER,
        "red" => TRAY_RED,
        _ => TRAY_GREEN,
    };
    app_handle
        .tray_handle()
        .set_icon(Icon::Raw(bytes.to_vec()))
        .map_err(|e| e.to_string())
}

fn main() {
    let quit = CustomMenuItem::new("quit".to_string(), "Quit Spendot");
    let tray_menu = SystemTrayMenu::new().add_item(quit);
    let tray = SystemTray::new().with_menu(tray_menu);

    tauri::Builder::default()
        .system_tray(tray)
        .on_system_tray_event(|app, event| match event {
            SystemTrayEvent::LeftClick { .. } => {
                if let Some(window) = app.get_window("main") {
                    let visible = window.is_visible().unwrap_or(false);
                    if visible {
                        let _ = window.hide();
                    } else {
                        let _ = window.show();
                        let _ = window.set_focus();
                    }
                }
            }
            SystemTrayEvent::MenuItemClick { id, .. } => {
                if id.as_str() == "quit" {
                    std::process::exit(0);
                }
            }
            _ => {}
        })
        .invoke_handler(tauri::generate_handler![set_tray_icon])
        .run(tauri::generate_context!())
        .expect("error while running Spendot");
}
