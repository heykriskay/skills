# 0004: Ship as a plugin and as copyable files

- **Status:** Accepted
- **Date:** 2026-11-16

## Context

A Claude Code plugin installs with one command and updates itself, but it can only carry skills,
agents, hooks and a few settings. Rules, the status line and personal settings can't be shipped in a
plugin, and plugin skills get a prefix (`/kriskay-skills:commit`).

## Decision

The repo root is both a plugin (`kriskay-skills`, in the `heykriskay` marketplace) and a plain folder
that `install.sh` copies into `~/.claude/`. The plugin ships skills, agents and the lint hook. The
copy install adds rules, the status line and the command log. Users pick one, not both.

## Consequences

- Most people get a one-line install; people who want everything can still have it.
- One set of files serves both, so there is nothing to keep in sync.
- The README has to explain two install paths.
