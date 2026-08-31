Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2590E589CC1;
	Mon, 31 Aug 2026 13:50:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788184224; cv=none; b=uW6GlbEMM8GBKu7Tlf3uEbJRcTnQVVrnknt52hfLaWpQcJOb/6XCrhK9lEZQ8QK70BjAU+OMSbC9/8+80AU294Ru0FOVxJ9rm3dwYB1NWHHMszNI4Gh5yzr6tk7zO1H1rbHWC61d1HgoSJHaRapW7R8H5nIJDhdVXD5wjRZpXfY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788184224; c=relaxed/simple;
	bh=KNa1THaUSyt56pXGSy8yMm0KnaiTO8+3E0gaYYCSaGY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=WrVS/17MPbD2zdkm6zaI6mrkdrvBp15Louq7byhC71Q9MAKTiIZPcVm4b8loxEiQn7MGtiCRc6NGcoNCsv+9QdUc4we0QowuogbSHx21F2e5yWzxNWMEo6wdtqMzSPpCkCx1t1lckKUtQby6gUTv4VOtJaAsTOmViI6QnTa7cS0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hhTqhG1E; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hhTqhG1E"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9951C1F00A3E;
	Mon, 31 Aug 2026 13:50:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788184221;
	bh=QTzcanro8ITVqpZzn141aZobdiNxHOVfWm3HAW0Umas=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hhTqhG1EGdDqW8wfvbPvRoyAT3TgXV9ybTpQDgdtlGBGZ6Dj5333TX4mLAYMCRqYc
	 ckgIvHGE+mmXcu+RVWNUg8WdowMTvS30uPnA8MRimNuI+IIP9xyHdhEsDTvTT33UA9
	 wsfn8Gkq+pjZXhxNq7UaBb3uUxZyoDA3Aist7aVPfPFxSd1NJkcMw/3gjeQF5vnsS7
	 jtrA+icq2b+qPEAzap4b40/cFxq+f0qdp3V4s/EC0XR2nkaCKqNJ3bc6aogU5kiKgC
	 zqS2ToOeK1HWM2wBFmfFNtRfoaYRYlae1oYjs6L3SXNMzj5lFN/1aa0DxYhqvAS8OD
	 a4fqBSLDI6MKQ==
From: Sasha Levin <sashal@kernel.org>
To: patches@lists.linux.dev,
	stable@vger.kernel.org
Cc: Dai Ngo <dai.ngo@oracle.com>,
	Anna Schumaker <anna.schumaker@hammerspace.com>,
	Sasha Levin <sashal@kernel.org>,
	trondmy@kernel.org,
	anna@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH AUTOSEL 6.18-6.1] NFS: fix eof updates after NFSv4.2 fallocate/zero-range
Date: Mon, 31 Aug 2026 09:29:52 -0400
Message-ID: <20260831133314.4125787-564-sashal@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260831133314.4125787-1-sashal@kernel.org>
References: <20260831133314.4125787-1-sashal@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
X-stable-base: Linux 6.18.48
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

From: Dai Ngo <dai.ngo@oracle.com>

[ Upstream commit 35168eb947f230aaa35fd8416a30563ef89f5421 ]

Generic/075 reliably exposes a regression when the client holds an
NFSv4 write delegation: ZERO_RANGE/ALLOCATE extends the file on the
server, but the local inode keeps the old i_size. The test then fails
with 'Size error' because the post-op attribute refresh refuses to
touch i_size while a delegation is outstanding, and the cached EOF
was never marked stale.

Update _nfs42_proc_fallocate() so that on success it:

- bumps i_size when the operation extends the file, and
- marks NFS_INO_INVALID_BLOCKS since the block count can also change

Tested with xfstests generic/075 over NFSv4.2.

Signed-off-by: Dai Ngo <dai.ngo@oracle.com>
Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---

LLM Generated explanations, may be completely bogus:

# Stable Backport Analysis: NFS: fix eof updates after NFSv4.2
fallocate/zero-range

**Local tree:** `v6.18.44` (Linux 6.18.44)

---

## PHASE 1: COMMIT MESSAGE FORENSICS

### Step 1.1: Subject line
**Record:** `[NFS] [fix] eof updates after NFSv4.2 fallocate/zero-range`
— explicit bug fix in NFSv4.2 fallocate/zero-range path.

### Step 1.2: Tags
**Record:**
- **Signed-off-by:** Dai Ngo `<dai.ngo@oracle.com>` (author)
- **Signed-off-by:** Anna Schumaker `<anna.schumaker@hammerspace.com>`
  (NFS maintainer)
- No `Fixes:`, `Reported-by:`, `Cc: stable@vger.kernel.org`, `Link:`,
  `Tested-by:`, `Reviewed-by:`, or `Acked-by:` tags
- Notable: maintainer sign-off; xfstests validation mentioned in body
  (not as a tag)

### Step 1.3: Body analysis
**Record:**
- **Bug:** With an NFSv4 write delegation held, `ZERO_RANGE`/`ALLOCATE`
  extends the file on the server but the client inode keeps stale
  `i_size`.
- **Symptom:** xfstests `generic/075` fails with `'Size error'`.
- **Root cause:** Post-op attribute refresh
  (`nfs_post_op_update_inode_force_wcc`) refuses to update `i_size`
  while a delegation is outstanding; EOF was never marked stale or
  updated locally.
- **Fix:** On success in `_nfs42_proc_fallocate()`, bump `i_size` when
  the operation extends the file and mark `NFS_INO_INVALID_BLOCKS`.
- **Testing:** `generic/075` over NFSv4.2.

### Step 1.4: Hidden bug fix?
**Record:** No — this is an explicit correctness fix, not disguised
cleanup. The delegation + stale `i_size` interaction is a real metadata
bug.

---

## PHASE 2: DIFF ANALYSIS

### Step 2.1: Inventory
**Record:**
- **Files:** `fs/nfs/nfs42proc.c` (+10 / -5)
- **Function:** `_nfs42_proc_fallocate()`
- **Scope:** Single-file surgical fix

### Step 2.2: Code flow change
**Record:**
- **Before:** On RPC success, only handled `nfs_should_remove_suid()`
  under `i_lock`; then called `nfs_post_op_update_inode_force_wcc()`.
- **After:** On success, computes `newsize = offset + len`, takes
  `i_lock`, conditionally updates `i_size`, always marks
  `NFS_INO_INVALID_BLOCKS`, then handles suid stripping under the same
  lock, unlocks, then calls post-op WCC update.
- **Path:** Success path of NFSv4.2 `ALLOCATE`, `DEALLOCATE`, and
  `ZERO_RANGE` (all go through `_nfs42_proc_fallocate()`).

### Step 2.3: Bug mechanism
**Record:** **Logic / correctness fix (delegation-aware cache
coherency).**

When `nfs_have_delegated_attributes(inode)` is true,
`nfs_update_inode()` at line 2399 skips `i_size` updates from server
attributes:

```2395:2408:fs/nfs/inode.c
        /* Check if our cached file size is stale */
        if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
                new_isize = nfs_size_to_loff_t(fattr->size);
                cur_isize = i_size_read(inode);
                if (new_isize != cur_isize && !have_delegation) {
                        /* Do we perhaps have any outstanding writes, or
has
    - the file grown beyond our last write? */
                        if (!nfs_have_writebacks(inode) || new_isize >
cur_isize) {
                                trace_nfs_size_update(inode, new_isize);
                                i_size_write(inode, new_isize);
```

The client initiated the size change via fallocate, but never updated
local `i_size` first. The fix mirrors the pattern used elsewhere (e.g.
writeback paths) of locally updating metadata when delegation blocks
server-driven refresh.

For `DEALLOCATE`, `newsize > i_size_read(inode)` is false when punching
holes, so no incorrect extension.

### Step 2.4: Fix quality
**Record:** Obviously correct, minimal, low regression risk. Uses
existing `i_lock` discipline. Consolidates suid handling into the same
lock region. No API changes.

---

## PHASE 3: GIT HISTORY INVESTIGATION

### Step 3.1: Blame
**Record:** Success-path structure in `_nfs42_proc_fallocate()` dates to
Anna Schumaker (2022, commit `d7a5118635e725` — "NFSv4.2: Update mode
bits after ALLOCATE and DEALLOCATE"). Post-op WCC call from Trond
Myklebust (2021). Bug is longstanding whenever delegations are held;
more visible after `FALLOC_FL_ZERO_RANGE` support landed in this tree
(`d2e1d783f2c61`, April 2025).

### Step 3.2: Fixes: tag
**Record:** N/A — no `Fixes:` tag present.

### Step 3.3: Related file history
**Record:** Recent related commits in this tree:
- `94413a84067c3` — size read races in truncate/fallocate (different
  bug, already in 6.18.44)
- `d2e1d783f2c61` — `FALLOC_FL_ZERO_RANGE` support
- `b1817b18ff20e` — EOF page pollution protection

This fix is standalone; no series dependency.

### Step 3.4: Author context
**Record:** Dai Ngo is an active NFS contributor (`f588d72bd95f7` suid
stripping after ALLOCATE, etc.). Anna Schumaker is NFS maintainer and
signed off.

### Step 3.5: Prerequisites
**Record:** Requires `_nfs42_proc_fallocate()`, NFSv4.2 fallocate/zero-
range, and delegation attribute handling — all present in 6.18.44.
Applies standalone.

---

## PHASE 4: MAILING LIST AND EXTERNAL RESEARCH

### Step 4.1: Original discussion
**Record:** `b4 dig -c 35168eb947f230aaa35fd8416a30563ef89f5421` found:
- https://patch.msgid.link/20260423175233.4175269-1-dai.ngo@oracle.com
- Single v1 patch (no v2/v3 revisions)
- Lore thread content could not be fetched (Anubis bot protection on
  lore.kernel.org)

### Step 4.2: Reviewers
**Record:** `b4 dig -w` CC'd: `trondmy@kernel.org`, `anna@kernel.org`,
`linux-nfs@vger.kernel.org` — appropriate NFS maintainer coverage.

### Step 4.3: Bug report
**Record:** Reproducible via xfstests `generic/075` with NFSv4.2 write
delegation. No syzbot or Bugzilla link. Failure mode: stale `i_size` /
size mismatch.

### Step 4.4: Related patches
**Record:** Standalone 1/1 patch. Upstream commit:
`35168eb947f230aaa35fd8416a30563ef89f5421`. Not yet in local 6.18.44
tree.

### Step 4.5: Stable list history
**Record:** Could not search stable@ lore (same fetch blocker). No
evidence of prior stable rejection found.

---

## PHASE 5: CODE SEMANTIC ANALYSIS

### Step 5.1: Key functions
**Record:** `_nfs42_proc_fallocate()`, called from
`nfs42_proc_fallocate()` → `nfs42_proc_allocate()`,
`nfs42_proc_deallocate()`, `nfs42_proc_zero_range()`.

### Step 5.2: Callers
**Record:**
- `nfs42_proc_allocate()` / `nfs42_proc_zero_range()` /
  `nfs42_proc_deallocate()` — from `nfs42_fallocate()` in `nfs4file.c`
- Reachable from userspace via `fallocate(2)` on NFSv4.2 mounts

### Step 5.3: Callees
**Record:** `nfs4_call_sync()`, `i_size_read()`/`i_size_write()`,
`nfs_set_cache_invalid()`, `nfs_post_op_update_inode_force_wcc()`.

### Step 5.4: Reachability
**Record:** Userspace `fallocate()` on NFSv4.2 with write delegations
(common on NFSv4 servers). Trigger is deterministic when extending a
file via `ALLOCATE` or `ZERO_RANGE`.

### Step 5.5: Similar patterns
**Record:** `nfs_writeback_update_inode()` in `write.c` handles
delegated-attribute cases by locally invalidating/updating cache state
rather than relying on server post-op refresh — same design principle.

---

## PHASE 6: CROSS-REFERENCE AGAINST LOCAL TREE (6.18.44)

### Step 6.1: Buggy code present?
**Record:** **YES.** Current tree at `fs/nfs/nfs42proc.c:83-91` lacks
the `i_size` bump and `NFS_INO_INVALID_BLOCKS` invalidation:

```83:91:fs/nfs/nfs42proc.c
        if (status == 0) {
                if (nfs_should_remove_suid(inode)) {
                        spin_lock(&inode->i_lock);
                        nfs_set_cache_invalid(inode,
                                NFS_INO_REVAL_FORCED |
NFS_INO_INVALID_MODE);
                        spin_unlock(&inode->i_lock);
                }
                status = nfs_post_op_update_inode_force_wcc(inode,
res.falloc_fattr);
```

`FALLOC_FL_ZERO_RANGE` support confirmed in tree (`d2e1d783f2c61` is
ancestor of HEAD).

### Step 6.2: Backport difficulty
**Record:** **Clean apply expected** — small hunk in
`_nfs42_proc_fallocate()`, no structural conflicts observed.

### Step 6.3: Already fixed?
**Record:** **NO** — commit `35168eb947f230aaa35fd8416a30563ef89f5421`
not in tree; no equivalent fix found via grep/log.

---

## PHASE 7: SUBSYSTEM CONTEXT

### Step 7.1: Subsystem criticality
**Record:** **IMPORTANT** — NFS client (`fs/nfs/`), affects file
metadata correctness for networked filesystem users.

### Step 7.2: Activity
**Record:** Actively maintained; recent fallocate/delegation fixes in
6.18.y.

---

## PHASE 8: IMPACT AND RISK ASSESSMENT

### Step 8.1: Who is affected
**Record:** NFSv4.2 clients using write delegations and `fallocate()`
(`ALLOCATE`/`ZERO_RANGE` extending files). Enterprise and shared-storage
NFS deployments.

### Step 8.2: Trigger conditions
**Record:** `fallocate()` extend operation + outstanding write
delegation. Not timing-dependent; reproducible via `generic/075`.
Unprivileged users can trigger on files they can write.

### Step 8.3: Failure severity
**Record:** **MEDIUM-HIGH** — stale `i_size` causes incorrect size
reporting and test failures; can lead to application misbehavior (wrong
reads/truncates/assumptions about file length). Not a kernel oops, but
real metadata corruption from the client’s perspective.

### Step 8.4: Risk-benefit
**Record:**
- **Benefit:** HIGH for NFSv4.2 + delegation users
- **Risk:** LOW — 10-line, well-understood pattern
- **Ratio:** Strongly favors backport

---

## PHASE 9: FINAL SYNTHESIS

### Step 9.1: Evidence summary

**FOR backport:**
- Real, reproducible bug (`generic/075`)
- Incorrect `i_size` with write delegations
- Small, surgical, maintainer-reviewed fix
- Buggy code and prerequisites exist in 6.18.44
- Matches existing delegation cache-handling patterns

**AGAINST backport:**
- No kernel crash/panic (metadata correctness, not memory safety)
- Only affects NFSv4.2 fallocate paths with delegations
- Lore review thread not readable (bot protection)

**Unresolved:** Full mailing-list review thread content unavailable.

### Step 9.2: Stable rules checklist
1. Obviously correct and tested? **PASS** — logic is clear; tested with
   `generic/075`; maintainer SOB
2. Fixes real bug affecting users? **PASS** — stale `i_size` with
   delegations
3. Important issue? **PASS** — metadata correctness on a widely used
   filesystem protocol
4. Small and contained? **PASS** — 1 file, ~10 lines
5. No new features/APIs? **PASS**
6. Can apply to local tree? **PASS** — code present, clean apply
   expected

### Step 9.3: Exception categories
**Record:** None (standard bug fix, not device ID/quirk/build/doc).

### Step 9.4: Decision rationale

For **Linux 6.18.44**, this commit fixes a real NFS client bug where
`fallocate()` operations that extend a file leave `i_size` stale when a
write delegation is held. The post-op attribute path intentionally skips
`i_size` updates under delegation, so the fallocate success path must
update it locally — exactly what this patch does. The fix is minimal,
follows existing NFS patterns, and the affected code exists in this
tree. Stale file size is a meaningful correctness issue for NFS users,
not merely a test-only nit.

---

## Verification

- **[Phase 1]** Parsed subject, tags, body from user-provided commit
  message
- **[Phase 2]** Diff analysis: `_nfs42_proc_fallocate()` success path;
  conditional `i_size` update + `NFS_INO_INVALID_BLOCKS`
- **[Phase 3]** `git blame -L 83,92 fs/nfs/nfs42proc.c`: lines from
  `d7a5118635e725` (2022), `f588d72bd95f74` (2023)
- **[Phase 3]** `git log --oneline -20 -- fs/nfs/nfs42proc.c`: related
  commits identified
- **[Phase 3]** `git merge-base --is-ancestor d2e1d783f2c61 HEAD`:
  ZERO_RANGE support confirmed in tree
- **[Phase 4]** `b4 dig -c 35168eb947f230aaa35fd8416a30563ef89f5421`:
  lore URL found
- **[Phase 4]** `b4 dig -w`: CC list includes Trond Myklebust, Anna
  Schumaker, linux-nfs
- **[Phase 4]** `b4 dig -a`: single v1 revision only
- **[Phase 4]** WebFetch lore URL: **FAILED** (Anubis bot protection)
- **[Phase 5]** Read `fs/nfs/inode.c:2395-2408`: delegation blocks
  `i_size` update from server attrs
- **[Phase 5]** Read `fs/nfs/write.c:1461-1476`: similar delegated-
  attribute handling pattern
- **[Phase 5]** Read call chain: `nfs4file.c` → `nfs42_proc_*` →
  `_nfs42_proc_fallocate()`
- **[Phase 6]** `git describe HEAD`: v6.18.44
- **[Phase 6]** Read current `fs/nfs/nfs42proc.c:83-91`: buggy code
  confirmed present
- **[Phase 6]** `git log --grep="fix eof updates"`: no match — fix not
  yet applied
- **[Phase 8]** Confirmed `nfs42_proc_allocate()`/`zero_range()` call
  `nfs_truncate_last_folio()` at caller level but do not fix `i_size`
  themselves

**YES**

 fs/nfs/nfs42proc.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index c08520828708b..1c66e1bb19652 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -81,12 +81,17 @@ static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 	status = nfs4_call_sync(server->client, server, msg,
 				&args.seq_args, &res.seq_res, 0);
 	if (status == 0) {
-		if (nfs_should_remove_suid(inode)) {
-			spin_lock(&inode->i_lock);
+		loff_t newsize = offset + len;
+
+		spin_lock(&inode->i_lock);
+		if (newsize > i_size_read(inode))
+			i_size_write(inode, newsize);
+		nfs_set_cache_invalid(inode, NFS_INO_INVALID_BLOCKS);
+		if (nfs_should_remove_suid(inode))
 			nfs_set_cache_invalid(inode,
-				NFS_INO_REVAL_FORCED | NFS_INO_INVALID_MODE);
-			spin_unlock(&inode->i_lock);
-		}
+					      NFS_INO_REVAL_FORCED |
+					      NFS_INO_INVALID_MODE);
+		spin_unlock(&inode->i_lock);
 		status = nfs_post_op_update_inode_force_wcc(inode,
 							    res.falloc_fattr);
 	}
-- 
2.53.0

