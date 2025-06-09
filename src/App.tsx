import { useState, useEffect } from "react";
import { register, unregisterAll } from '@tauri-apps/plugin-global-shortcut';
import "./App.css";

function App() {
  const [notification, setNotification] = useState("");

  useEffect(() => {
    const setupShortcuts = async () => {
      try {
        await register('CommandOrControl+Shift+R', () => {
          setNotification("Shortcut: CommandOrControl+Shift+R triggered");
          setTimeout(() => setNotification(""), 2000);
        });
      } catch (error) {
        console.error("Shortcut registration failed:", error);
      }
    };
    
    setupShortcuts();
    
    return () => { unregisterAll().catch(console.error); };
  }, []);

  return (
    <div className="min-h-screen bg-slate-100 flex flex-col">
      <main className="container mx-auto p-6 flex-grow flex flex-col">
        <h1 className="text-2xl font-bold mb-6 text-slate-800">Rost</h1>
        
        <div className="flex-grow flex flex-col">
          <textarea
            className="w-full flex-grow p-4 bg-white border-0 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:outline-none resize-none"
            placeholder="Enter your code here..."
          />
        </div>

        <footer className="text-sm text-slate-500 mt-6 text-center">
          <p>Shortcuts: Shift+Cmd+O (show), Shift+Cmd+H (hide), Shift+Cmd+R (test)</p>
          {notification && <p className="text-blue-500 font-bold mt-2">{notification}</p>}
        </footer>
      </main>
    </div>
  );
}

export default App;
