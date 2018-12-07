# MAKING A RELEASE

* `bundle install --without development`
* `bundle exec rake module:bump:minor` (or ...`:patch` or ...`:major`)
* `github_changelog_generator --future-release $(bundle exec rake module:version) --user` _<GitHub-username>_
* `git add CHANGELOG.md metadata.json`
* `git commit -m "Bump commit to $(bundle exec rake module:version)"`
* `bundle exec rake module:tag`
* `git push origin --tags`
* _(Let Travis deploy to the forge?)_
