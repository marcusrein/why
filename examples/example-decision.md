---
date: 2026-03-15
time: 14:32
branch: feature/user-auth
files:
  - src/auth/session.ts
  - src/auth/middleware.ts
tags: [dependency, architecture, security]
---

# Custom session handler over express-session

## 1. What problem were you solving?
We needed session management for authenticated routes. The app handles ~200 concurrent users max and sessions need to store a custom permission object that maps to our internal RBAC system.

## 2. What did Claude suggest that you rejected, and why?
Claude suggested using express-session with connect-redis as the store. It scaffolded the full setup including Redis connection pooling, session serialization config, and a cleanup cron. That's a lot of infrastructure for what we actually need. Redis is another service to run, monitor, and pay for. Our sessions don't need to survive server restarts and we don't have multi-instance deployment. It was the "correct" general answer but wrong for our context.

## 3. What did you decide and what was your reasoning?
I wrote a simple in-memory session Map with a 24-hour TTL and a setInterval cleanup. ~40 lines of code. No dependencies. The reasoning: our user count is small and known, we deploy as a single instance, and if the server restarts, re-login is fine. I'd rather have code I fully understand and can debug in 30 seconds than a dependency chain I have to read docs for when something breaks at 2am.

## 4. What parts of the output did you write or override yourself?
I wrote the entire session.ts file from scratch. I kept Claude's middleware structure for attaching the session to the request object, but replaced the express-session calls with my Map lookups. I also wrote the permission serialization myself because it maps to our specific RBAC shape and I didn't want Claude guessing at the types.

## 5. What would break this, and do you understand why?
If we go multi-instance, sessions won't be shared between servers. I know this. The fix would be to move to Redis at that point, and the interface is clean enough that it's a one-file swap. If memory pressure becomes an issue with large session objects, the Map could grow unbounded between cleanup cycles. I've set a max session count of 500 with a hard reject after that, which is 2.5x our expected max. If we hit that, we have bigger problems.
