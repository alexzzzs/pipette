# Changelog

## v0.1.2

*   Refactor: Renamed code namespace from `PipetteElixir` to `Pipette`.
    *   All modules are now under the `Pipette` namespace (e.g., `Pipette.Control`, `Pipette.Result`).
    *   The main application module is now `Pipette.Application`.
    *   Updated `README.md` and test files to reflect the new namespace.

## v0.1.1

*   Fix: Corrected compilation issues and invalid Hex package name format.

## v0.1.0

Initial release.

*   `Pipette.Control`: `tap/2`, `pipe_when/3`, `pipe_unless/3`, `pipe_case/2`, `dbg_when/2`
*   `Pipette.Result`: `ok/1`, `error/1`, `presence/2`, `bind/2`, `map_ok/2`, `map_error/2`, `with_default/2`, `sequence/1`, `traverse/2`
*   `Pipette.Deep`: `dig_get/3`, `dig_put/3`, `dig_update/3`, `dig_pop/2`
*   `Pipette.Path`: `~p` sigil
*   `Pipette.Parallel`: `pmap/3`, `pmap_reduce/5`, `pfilter/3`
