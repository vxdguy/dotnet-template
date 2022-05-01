
# 🇼​​​​​🇷​🇮​🇹​🇪​🇸​🇴​🇲​🇪​🇨​🇴​🇩​🇪​.🇳​🇪​🇹​​​​​

![img](.assets/TemplateLogo.png)

## Template README.md

This is my opinionated layout for C# projects. If this template is useful to you, great, if not feel free to take what you like.

## [CHANGELOG](CHANGELOG.md)

I chose to have one changelog per release.  Older changelogs have a footer link, which leads to a table of previous changelogs.

My changelogs have four sections, breaking changes, added features, fixed bugs, and changes.

- Breaking changes force a minor version bump per the SEMVAR standards.
- Added feature is new completed feature ready for use.  This typically bumps the minor version.
- Fixed bugs is exactly that.  Bumps the patch version.
- Changes are internal changes.  The user facing api hasn't changed, but a dependency may have changed or a compiler option was altered.

## [CODE OF CONDUCT](CODE_OF_CONDUCT.md)

Boilerplate provided by Github.

## [CODE COVERAGE](CODECOVERAGE.md)

This is the most extensive changes I added to the template.  CTRL-SHIFT-T give the choice of running "Coverage", "Publish"," or "Test" tasks.

Coverage task uses the `runcoverage.sh` script to go into the `test` folder and runs `dotnet test` while collecting Coverlet coverage information.  
