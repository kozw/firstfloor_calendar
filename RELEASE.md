# Release Policy

This document defines the release process for `firstfloor_calendar`.

## Scope

Use this process for every published version (for example, `1.0.12`).

## Rules

1. Never push directly to `main`; release changes must go through PRs.
2. `pubspec.yaml` version and changelog entry must be updated together.
3. Publish is triggered by a Git tag matching the semantic version (`X.Y.Z`).
4. The tag must point at the exact commit on `origin/main` that contains release metadata.
5. Do not move release tags unless there is a confirmed release mistake.
6. Whenever a remote branch is deleted, delete the matching local branch in the same flow.

## Release Preparation

1. Create a release prep branch from `origin/main` (for example, `prepare-1-0-12`).
2. Update:
   - `pubspec.yaml` version
   - `CHANGELOG.md` entry for the new version
   - version links at the bottom of `CHANGELOG.md`
3. Open a PR with title `Prepare <version> release metadata`.
4. Ensure CI is green for the PR:
   - formatting
   - analysis
   - tests

## Merge and Publish

1. Squash-merge the release PR into `main`.
2. Delete the release prep branch.
3. Fetch latest refs and resolve `origin/main` SHA.
4. Create annotated tag `<version>` on that SHA.
5. Push the tag to `origin` to trigger publish workflow.

## Verification

1. Confirm GitHub publish workflow starts from tag push.
2. Confirm publish workflow succeeds.
3. Confirm version appears on pub.dev.

## Branch Hygiene

After successful publish:

1. Delete temporary feature/release branches on remote and local together.
2. Keep only long-lived branches (`main`).
