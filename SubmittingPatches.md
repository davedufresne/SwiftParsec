# Git Commit

Some wise advice gathered from multiple sources on submitting patches.

## Describe your changes

Describe your problem.  Whether your patch is a one-line bug fix or 5000 lines of a new feature, there must be an underlying problem that motivated you to do this work.

Describe user-visible impact.  Straight up crashes and lockups are pretty convincing, but not all bugs are that blatant.  Even if the problem was spotted during code review, describe the impact you think it can have on users.

Quantify optimizations and trade-offs.  If you claim improvements in performance, memory consumption, stack footprint, or binary size, include numbers that back them up.  But also describe non-obvious costs.  Optimizations usually aren't free but trade-offs between CPU, memory, and readability; or, when it comes to heuristics, between different workloads.  Describe the expected downsides of your optimization so that the reviewer can weigh costs against benefits.

Once the problem is established, describe what you are actually doing about it in technical detail.  It's important to describe the change in plain English for the reviewer to verify that the code is behaving as you intend it to.

The maintainer will thank you if you write your patch description in a form which can be easily pulled into git, as a "commit log”. Here’s a model Git commit message:

> Capitalized, short (50 chars or less) summary
>
> More detailed explanatory text, if necessary. Wrap it to about 72
> characters or so. In some contexts, the first line is treated as the
> subject of an email and the rest of the text as the body. The blank
> line separating the summary from the body is critical (unless you omit
> the body entirely); tools like rebase can get confused if you run the
> two together.

Write your commit message in the imperative: "Fix bug" and not "Fixed bug"
or "Fixes bug." This convention matches up with commit messages generated
by commands like git merge and git revert.

Further paragraphs come after blank lines.

- Bullet points are okay, too

- Typically a hyphen or asterisk is used for the bullet, followed by a
  single space, with blank lines in between, but conventions vary here

- Use a hanging indent

Solve only one problem per patch.  If your description starts to get long, that's a sign that you probably need to split up your patch.

Describe your changes in imperative mood, e.g. "make xyzzy do frotz” instead of "[This patch] makes xyzzy do frotz" or "[I] changed xyzzy to do frotz", as if you are giving orders to the codebase to change its behaviour.

If the patch fixes a logged bug entry, refer to that bug entry by number and URL.  If the patch follows from a mailing list discussion, give a URL to the mailing list archive.

However, try to make your explanation understandable without external resources.  In addition to giving a URL to a mailing list archive or bug, summarize the relevant points of the discussion that led to the patch as submitted.

If you want to refer to a specific commit, don't just refer to the SHA-1 ID of the commit. Please also include the one-line summary of the commit, to make it easier for reviewers to know what it is about. Example:

> Commit e21d2170f36602ae2708 ("video: remove unnecessary
> platform_set_drvdata()") removed the unnecessary
> platform_set_drvdata(), but left the variable "dev" unused,
> delete it.

If your patch fixes a bug in a specific commit, e.g. you found an issue using git-bisect, please use the 'Fixes:' tag with the first 12 characters of the SHA-1 ID, and the one line summary.  For example:

> Fixes: e21d2170f366 ("video: remove unnecessary platform_set_drvdata()”)

## Separate your changes

Separate each **logical change** into a separate patch.

For example, if your changes include both bug fixes and performance enhancements for a single entity, separate those changes into two or more patches.  If your changes include an API update, and a addition which uses that new API, separate those into two patches.

On the other hand, if you make a single change to numerous files, group those changes into a single patch.  Thus a single logical change is contained within a single patch.

The point to remember is that each patch should make an easily understood change that can be verified by reviewers.  Each patch should be justifiable on its own merits.

If one patch depends on another patch in order for a change to be complete, that is OK.  Simply note "this patch depends on patch X” in your patch description.

When dividing your change into a series of patches, take special care to ensure that the program builds and runs properly after each patch in the series.  Developers using "git bisect" to track down a problem can end up splitting your patch series at any point; they will not thank you if you introduce bugs in the middle.

Sources:
https://www.kernel.org/doc/Documentation/SubmittingPatches
https://github.com/torvalds/linux/pull/17#issuecomment-5659933
http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
https://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message
