# 🎬 What Was That Called Again?

A personal film & TV watchlist that **remembers what you watched** — and, crucially,
*what it was called*. One click on any entry and you get the full rundown: cast,
director, synopsis, release date, ratings, and — for TV shows — every episode's
synopsis, ready to jog your memory.

- **No build step.** A single `index.html` — host it on GitHub Pages and you're done.
- **Persistent storage.** Optional free [Supabase](https://supabase.com) account
  syncs your list to the cloud; until you configure it, entries are saved in your
  browser's local storage (works offline).
- **Private.** Email/password sign-in; each user only ever sees their own list
  (Supabase Row Level Security).
- **Info on demand.** [OMDB](http://www.omdbapi.com/) for search, cast & crew,
  synopsis, release dates and critic scores — plus [TVmaze](https://www.tvmaze.com/)
  for per-episode synopses of TV shows (free, no key).

---

## 🚀 Quick start (host on GitHub Pages)

1. Create a repository on GitHub named **`whatwasthatcalledagain`** (matches this
   repo's name).
2. Push these files (or use the GitHub web UI → *Add file* → *Upload files*):
   - `index.html`
   - `supabase.sql`
   - `README.md`
3. In the repo: **Settings → Pages → Source: Deploy from a branch → main → Save**.
4. Open `https://<your-username>.github.io/whatwasthatcalledagain/`.
   - *Tip:* GitHub Pages paths (…/repo/) load fine since the app is a single
     self-contained file.
5. Click **＋ Add**, search for the film/show you watched, rate it 1–5 stars,
   add a comment if you like, save.

> To run locally: just double-click `index.html` (or `python -m http.server`).

---

## ☁️ Step 1 — Cloud sync with Supabase (free, no credit card)

1. Create a free project at [supabase.com](https://supabase.com) (takes ~1 min).
2. In the left sidebar open the **SQL Editor**, paste the whole contents of
   `supabase.sql`, and click **Run**. This creates the `watched` table with Row
   Level Security so each account only sees its own rows.
3. Go to **Project Settings → API**. Copy the **Project URL** and the **anon /
   public** key.
4. In the app, click **⚙ Settings**, paste both values, save. The page reloads
   and now shows the **Sign in / Create account** screen.
5. Create your account — your watchlist is now backed up to the cloud and will
   follow you across devices/browsers.

The anon key is deliberately safe to expose in a client-side app — it's a public
identifier, and RLS is what actually protects your data.

> **Troubleshooting:** if saving shows *"new row violates row-level security"*,
> the table or its policies aren't set up correctly (or the auth user was
> deleted/recreated). Re-run `supabase.sql` (safe to re-run — it drops and
> recreates the policies), then sign out of the app and back in. You can also
> use **⚙ Settings → Run connection diagnostics** in the app to see exactly
> which layer is failing, and run the read-only SQL diagnostic at the bottom of
> `supabase.sql` to check the policy state.

---

## 🔌 Step 2 — APIs used

| API | Purpose | Key needed? |
| --- | --- | --- |
| [OMDB](http://www.omdbapi.com/) | Title search, posters, cast & crew, synopsis, release dates, critic scores | Yes — free API key from [omdbapi.com/apikey.aspx](https://www.omdbapi.com/apikey.aspx). Your key is pre-filled in Settings (⚙) and can be changed there. |
| [TVmaze](https://www.tvmaze.com/api) | Per-episode titles, air dates, ratings & synopses for TV shows | No — free public API, no key. Can be toggled in Settings. |

Note: OMDB's free tier doesn't return per-episode synopses (only episode titles),
so TVmaze fills that gap. If a show isn't on TVmaze, the app simply skips episode
details rather than breaking.

---

## ✨ Features

- **Add with one search** — live OMDB results with posters; full details pre-filled.
- **Three statuses** — ✅ Watched, 🔥 Currently watching, or 🍿 Want to watch
  (save things people mention to watch later). Filter tabs for each, with counts.
- **Guided "mark as watched"** — when you finish something from your to-watch
  list, tap the button and add the date, a 1–5 star rating and a comment in one go.
- **1–5 star rating** + optional comment + date watched, for every title.
- **Click any card** to open the detail view:
  - Cast, director, writer, synopsis, runtime, genre, release date, MPAA rating
  - Rotten Tomatoes / Metacritic / IMDb scores (from OMDB)
  - IMDb link
  - For TV: season selector + expandable per-episode synopses
  - Edit your rating/comment/date or remove the title, right there
- **Dashboard** — counts (total / movies / TV), average rating, filters, search,
  and sort by recently watched, oldest, highest rated, or title A–Z.
- **Works before you configure anything** — localStorage fallback means you can
  start tracking immediately, then enable cloud sync later (existing local
  entries stay in that browser).
- **Mobile-friendly** — works great on phones: floating ＋ button, bottom-sheet
  dialogs, thumb-friendly touch targets, no iOS zoom-on-focus, safe-area support
  for notched screens. Three tiles across with big posters, large stat numbers
  and headings. Desktop layout is unchanged.
- **Keyboard friendly** — `/` focuses search, `Esc` closes dialogs.

---

## 📁 Files

| File | Purpose |
| --- | --- |
| `index.html` | The entire app (HTML + CSS + JS, zero dependencies) |
| `supabase.sql` | One-time schema + policies (safe to re-run; adds the `status` column) |
| `README.md` | This file |

---

## 🔒 Privacy notes

- The app talks **directly** to your Supabase project — there is no third-party
  server in between, and no analytics/tracking code.
- Supabase's free tier includes auth, database and the anon key; Row Level
  Security guarantees users can only read/write their own rows.
- OMDB requests are sent from your browser with your key — the key is visible in
  the page source (normal for client-side apps; it's only used for search and
  has a generous free quota).
- If you'd rather keep everything local, never enter Supabase details — the app
  just stays in local mode.
