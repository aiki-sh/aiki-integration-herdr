# aiki herdr integration (herdr plugin)

A [herdr](https://herdr.dev) plugin (for herdr's 0.7.x plugin marketplace) that
makes [aiki](https://aiki.sh) a first-class citizen inside herdr. It does two
things:

1. **Bootstraps the aiki-side hook at install.** Its `[[build]]` step wires up
   aiki's session-identity plugin (`plugins/herdr/` in this monorepo, published
   as `aiki-sh/herdr`).
2. **Surfaces aiki's active epics** in a herdr pane (`render-epics.sh`).

This is the **storefront**, not the mechanism. A herdr plugin reacts to herdr's
own events (`worktree.created`, ...), never to a harness starting a session, so
it cannot do the session-identity reporting itself. That is the job of the
companion aiki plugin. This integration is the marketplace distribution channel
plus a herdr-native surface.

## Active epics pane

```bash
herdr plugin link .
herdr plugin pane open --plugin aiki --entrypoint epics \
  --placement split --direction right --env AIKI_REPO="$PWD"
herdr pane swap --direction left      # pin it as a left sidebar
```

Notes:
- herdr runs pane commands from the plugin dir, so the pane resolves the target
  aiki repo from `AIKI_REPO` (pass `--env AIKI_REPO=<repo>` or `--cwd <repo>`),
  not its own cwd.
- herdr has no native "left" placement; open with `--direction right` and then
  `herdr pane swap --direction left` to pin a left sidebar. A `--direction down`
  split cannot swap left.

## Requirements

- herdr >= 0.7.0 (the plugin system; `min_herdr_version` in the manifest).

## Marketplace

Published with the `herdr-plugin` GitHub topic so it appears in herdr's
auto-indexed marketplace. The listing's description carries the neutral-hub
framing. (Topic added at publish time, not while monorepo-staged.)

## Status

Staged in the aiki monorepo under `integrations/herdr/`. To be published as the
public repo `aiki-sh/in-herdr`, tagged with the `herdr-plugin` topic.
