# Frontend Planning Document

## 🎯 Goal

Create a production‑ready React frontend for the **NeMo Agentic Assistant** that follows the scaffold provided earlier. The UI should support:

- Real‑time chat with the agent (user messages, agent thoughts, tool calls, final responses)
- Layout with a header, sidebar (chat history), and main container for the chat view
- Reusable UI components (buttons, loading spinners, tool call display)
- Custom hooks for state management and WebSocket communication
- Tailwind CSS with a glass‑morphism theme
- Dockerfile for containerized deployment
- Full TypeScript/JavaScript support (using `.jsx`/`.js` files)

## 📂 Folder Structure

```
frontend/
├─ public/
│   ├─ index.html
│   └─ favicon.ico
├─ src/
│   ├─ components/
│   │   ├─ Layout/
│   │   │   ├─ Header.jsx
│   │   │   ├─ Sidebar.jsx
│   │   │   └─ MainContainer.jsx
│   │   ├─ Chat/
│   │   │   ├─ MessageList.jsx
│   │   │   ├─ MessageBubble.jsx
│   │   │   └─ InputBox.jsx
│   │   └─ UI/
│   │       ├─ LoadingSpinner.jsx
│   │       └─ ToolCall.jsx
│   ├─ hooks/
│   │   ├─ useChat.js
│   │   └─ useWebSocket.js   (optional – for future real‑time WS)
│   ├─ services/
│   │   ├─ api.js
│   │   └─ websocket.js      (optional)
│   ├─ styles/
│   │   └─ index.css
│   ├─ App.jsx
│   └─ main.jsx
├─ package.json
├─ vite.config.js
├─ tailwind.config.js
└─ Dockerfile
```

## 🗂️ Key Files & Responsibilities

| File | Purpose |
|------|---------|
| **public/index.html** | Root HTML page; mounts React app to `<div id="root">`. |
| **src/main.jsx** | Entry point – renders `<App />` into the DOM. |
| **src/App.jsx** | Top‑level component that wraps the whole UI with `ChatProvider`. |
| **components/Layout/Header.jsx** | Top navigation bar with branding and status indicator. |
| **components/Layout/Sidebar.jsx** | Chat history list, new‑chat button, session selector. |
| **components/Layout/MainContainer.jsx** | Container for the chat view (MessageList + InputBox). |
| **components/Chat/MessageList.jsx** | Scrollable list of messages; auto‑scrolls on new messages. |
| **components/Chat/MessageBubble.jsx** | Renders a single message with appropriate styling based on type (`user`, `agent_thought`, `tool_call`, `agent_response`, `error`). |
| **components/Chat/InputBox.jsx** | Textarea + send button; handles Enter/Shift+Enter behavior. |
| **components/UI/LoadingSpinner.jsx** | Simple animated spinner shown while the agent is thinking. |
| **components/UI/ToolCall.jsx** | Displays tool call metadata (name, input, output, status). |
| **hooks/useChat.js** | Context + reducer handling chat state, API calls (`sendMessage`, `getChatHistory`), loading/error handling. |
| **services/api.js** | Axios wrapper for backend endpoints (`/chat`, `/sessions`). |
| **styles/index.css** | Tailwind imports + custom global styles (glass‑morphism, scrollbar). |
| **tailwind.config.js** | Tailwind CSS configuration (content paths, theme extensions). |
| **Dockerfile** | Multi‑stage build: `node` → `vite build` → `nginx` to serve static files. |
| **package.json** | Dependencies: `react`, `react-dom`, `axios`, `lucide-react`, `tailwindcss`, `vite`, etc. |

## 🎨 Design System

- **Colors**: Gradient from purple → blue for primary accents, dark slate background.
- **Glass‑morphism**: `bg-slate-800/30` + `backdrop-blur-sm` on panels.
- **Icons**: `lucide-react` for consistent SVG icons.
- **Responsive**: Flex layout; sidebar collapses on small screens (future improvement).

## 🛠️ Implementation Steps (Checklist)

- [x] Write `docs/frontend.md` (this document).
- [ ] Create `frontend/public/index.html` and `favicon.ico`.
- [ ] Add `frontend/src/main.jsx`.
- [ ] Add `frontend/src/App.jsx`.
- [ ] Scaffold `components/Layout` (Header, Sidebar, MainContainer).
- [ ] Scaffold `components/Chat` (MessageList, MessageBubble, InputBox).
- [ ] Scaffold `components/UI` (LoadingSpinner, ToolCall).
- [ ] Implement `hooks/useChat.js`.
- [ ] Implement `services/api.js`.
- [ ] Add global stylesheet `styles/index.css`.
- [ ] Add Tailwind config `tailwind.config.js`.
- [ ] Add `vite.config.js` (basic Vite + React plugin).
- [ ] Add `Dockerfile` for production build.
- [ ] Verify `package.json` scripts (`dev`, `build`, `preview`).
- [ ] Run `npm install` and `npm run dev` locally to ensure no compile errors.
- [ ] Commit all files.

## 📦 Build & Run Commands

```bash
# Install dependencies
npm install

# Development server
npm run dev

# Production build
npm run build

# Preview built app
npm run preview

# Docker build & run
docker build -t nemo-agent-frontend .
docker run -p 3000:80 nemo-agent-frontend
```

## 📌 Next Actions

1. **Create the folder hierarchy** under `frontend/src`.
2. **Populate each file** with the exact code snippets from the scaffold (provided in the original task description).
3. **Run the dev server** to validate the UI renders correctly.
4. **Iterate** on any missing components (e.g., `MainContainer.jsx` referenced by `App.jsx` but not yet defined).

---

*This plan is intended to be a single source of truth for the frontend implementation. Follow the checklist step‑by‑step, updating the status as you complete each file.*
