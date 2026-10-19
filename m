Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6626458E2D0;
	Mon, 19 Oct 2026 13:59:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792418389; cv=none; b=XCsm+VenT2rQ03hUaxn4DF2hBrZPgK4GFS2KMTFZZN/U+U1fLnL/qAsGlX5s1/GsuKZLrNM3y6DAzsYzVmk5rmg4eG2upJb8SG3OZHnLUA/VtQLeW1iPZMM7/mqGlfivz+owlq8ZLcqnzX5YbQ/k4so5nKWwhR6sRTfKzI/x1so=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792418389; c=relaxed/simple;
	bh=cgKVFLr0+c/hGzVtMAmQ+i54QNz5vkIE01Ft4DJJccA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=umpmgy3OfcDRf1W8jR61leJjgcXyndk8sSjX3W2aFlVDzSuJw2R+lAgEvMEkPZSbP6Vwf2WqhR1o2xMbeDbxQ4GSFwNQThGy8Cch0/pcdK0mXt1PZqt7Ae8kCigJbmQQlAX7ELEomq6CfqtYAo765YQQmDDGq7WXmCENSGhp0gc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gqZT4QeO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gqZT4QeO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 53C041F000C4;
	Mon, 19 Oct 2026 13:59:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792418387;
	bh=Aw/JLA9/UpFCTx8TsXOKLFf8Hk1exadsPhTfEEqhu14=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gqZT4QeO46FnHXsIJ4PKqil6dmVufbpl8/m58fONPVSIkBHZdwWDFSqBsMuCBbpBw
	 0sFDicuKl0NrUUV81EhDJsXAB7gpOSSXOsQ2DCrnVsISjmDcDIckOgrWrXnGIDfwm5
	 vDLlF+RBDcqEbJh0kFOVH4w1yEHaqt7eimk04to7UOcAzzhhS2jot/NTvte5qnQFB0
	 vr8rf+995SbXPmH9/pthED3pw3dv416BzN6T0KcQppmGMUWEOLYpe6wUonDE255Km0
	 GxsuvSfpBUedqM1khOJ90YqbEVlHhHufMP90a0szu5ZuBqpY8rDPjH7Hkj9m6ZLPHD
	 jMBBa7YpajdCw==
From: Sasha Levin <sashal@kernel.org>
To: patches@lists.linux.dev,
	stable@vger.kernel.org
Cc: ZhangGuoDong <zhangguodong@kylinos.cn>,
	Jackie Liu <liuyun01@kylinos.cn>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Sasha Levin <sashal@kernel.org>,
	trondmy@kernel.org,
	anna@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH AUTOSEL 6.18-6.12] NFS: Verify symlink inode before caching target
Date: Mon, 19 Oct 2026 09:48:24 -0400
Message-ID: <20261019135441.1420968-213-sashal@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261019135441.1420968-1-sashal@kernel.org>
References: <20261019135441.1420968-1-sashal@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
X-stable-base: Linux 6.18.57
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

From: ZhangGuoDong <zhangguodong@kylinos.cn>

[ Upstream commit 3265f1998ae9a9282a8a6ca95467d9572d6ebb82 ]

nfs_symlink() copies the symlink target into a folio before issuing the
SYMLINK RPC.  After a successful reply, it caches that folio in the
instantiated inode mapping and assumes that the dentry now names a
symlink.

If the dentry is instantiated with a non-symlink inode, the raw symlink
target folio can be inserted into the wrong mapping.  When that inode is
a directory, reclaim or unmount later calls nfs_readdir_clear_array()
through nfs_dir_aops and interprets the symlink target as a readdir
cache array, which can lead to invalid kfree() calls.

A vmcore from a 4.19-based kernel showed the crash when reclaiming a
directory mapping on unmount:

  Stack trace:
   nfs_readdir_clear_array+0x4d/0x70 [nfs]
   page_cache_free_page.isra.35+0x1a/0x90
   delete_from_page_cache_batch+0x1cf/0x2c0
   truncate_inode_pages_range+0x24d/0x910
   [...]
   nfs_evict_inode+0x15/0x30 [nfs]
   evict+0x115/0x2b0
   dispose_list+0x48/0x60
   evict_inodes+0x16c/0x1b0
   generic_shutdown_super+0x3f/0x120
   nfs_kill_super+0x1b/0x40 [nfs]
   deactivate_locked_super+0x3f/0x70
   cleanup_mnt+0x3b/0x80

The current code still has the same unchecked cache insertion pattern,
so it may be susceptible to the same failure mode.

Verify that the instantiated inode is a symlink before caching the
target folio.  If the type is wrong, drop the suspect dentry and skip
the cache insertion while preserving the successful SYMLINK result.

Co-developed-by: Jackie Liu <liuyun01@kylinos.cn>
Signed-off-by: Jackie Liu <liuyun01@kylinos.cn>
Signed-off-by: ZhangGuoDong <zhangguodong@kylinos.cn>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---

LLM Generated explanations, may be completely bogus:

## Phase 1: Commit message forensics

**Step 1.1: Subject line**
Record: **[NFS]** **[Verify]** Verify the instantiated inode is a
symlink before inserting the SYMLINK target folio into the page cache.

**Step 1.2: Tags**
Record:
- Co-developed-by: Jackie Liu \<liuyun01@kylinos.cn\>
- Signed-off-by: Jackie Liu \<liuyun01@kylinos.cn\>
- Signed-off-by: ZhangGuoDong \<zhangguodong@kylinos.cn\>
- Signed-off-by: Trond Myklebust \<trond.myklebust@hammerspace.com\>
  (NFS client maintainer)
- No Fixes:, Reported-by:, Tested-by:, Reviewed-by:, Acked-by:, Link:,
  or Cc: stable (absence is expected for this review)
- Mainline SHA: `3265f1998ae9a9282a8a6ca95467d9572d6ebb82` (authored
  2026-07-03, committed by Trond 2026-08-17, merged to Linus in `nfs-
  for-7.3-1`)

**Step 1.3: Body**
Record: After a successful SYMLINK RPC, `nfs_symlink()` inserts the pre-
copied target folio into `d_inode(dentry)->i_mapping` without checking
that the dentry is actually a symlink. If that inode is a directory,
later reclaim/unmount runs `nfs_readdir_clear_array()` via
`nfs_dir_aops.free_folio` and treats the symlink text as a readdir cache
array, leading to invalid `kfree()`. A 4.19 vmcore showed exactly that
stack on unmount. The author states the same unchecked insertion still
exists. Failure mode: invalid free / memory corruption / crash during
unmount or mapping reclaim.

**Step 1.4: Hidden bug fix?**
Record: Not hidden. This is an explicit crash/corruption fix. The
“verify before caching” wording is a missing type check, not cleanup.

## Phase 2: Diff analysis

**Step 2.1: Inventory**
Record: One file, `fs/nfs/dir.c`. **+6 / −0**. Function:
`nfs_symlink()`. Single-file surgical fix.

**Step 2.2: Control-flow change**
Record: After `NFS_PROTO(dir)->symlink()` returns 0, the old code always
set the dentry verifier and tried
`filemap_add_folio(d_inode(dentry)->i_mapping, folio, 0, …)`. After the
change, `unlikely(!d_is_symlink(dentry))` causes `d_drop(dentry)`,
`folio_put(folio)`, and `return 0` (RPC still succeeded). The success
path is unchanged for real symlinks.

**Step 2.3: Bug mechanism**
Record: **Memory safety / type confusion.** A folio of symlink text is
inserted into a directory mapping whose `a_ops->free_folio` is
`nfs_readdir_clear_array()`. That function maps the folio as `struct
nfs_cache_array` and `kfree()`s `array[i].name` for `i < array->size`.
Path-string bytes as `size`/pointers yield invalid `kfree()`. Also
avoids a possible NULL deref if `d_inode(dentry)` is NULL (negative
dentry after splice).

**Step 2.4: Fix quality**
Record: Obviously correct and minimal. `d_is_symlink()` is the right VFS
helper. Skipping cache insert is already treated as non-fatal (“READLINK
will get the missing page from the server”). `d_drop()` avoids leaving a
wrong-type dentry hashed with a verifier. Regression risk is low: the
common success path is unchanged; the new path only runs on a type
mismatch.

## Phase 3: Git history

**Step 3.1: Blame**
Record: Unchecked cache insertion comes from `873101b337767` (“NFS: copy
symlinks into page cache before sending NFS SYMLINK request”,
2006-09-22). That commit is an ancestor of this tree (`git merge-base
--is-ancestor` exit 0). Folio conversion is `f003a717ae908` (2023); same
pattern, `add_to_page_cache` → `filemap_add_folio`. Directory
`free_folio = nfs_readdir_clear_array` is present at
`fs/nfs/dir.c:71-73`.

**Step 3.2: Fixes: tag**
Record: None. Introducer is `873101b337767`, present here since 2.6-era
NFS.

**Step 3.3: File history**
Record: Recent `fs/nfs/dir.c` work is readdir/verifier/`atomic_open`
(including `df214a74b5f2a` ENXIO on O_CREAT of an existing symlink).
Those are related NFS type-confusion issues but not prerequisites. This
patch is standalone.

**Step 3.4: Author**
Record: ZhangGuoDong / Jackie Liu (Kylin). Not subsystem maintainers.
Trond (maintainer) signed off and put it in `nfs-for-7.3-1`. Same author
also has `pnfs/blocklayout` leak fixes in this tree.

**Step 3.5: Dependencies**
Record: Needs `d_is_symlink()` (in `include/linux/dcache.h` here) and
folio-based `nfs_symlink()` (present via `f003a717ae908`). No other
commits required. Insertion context around `nfs_set_verifier()` is
unique in this file.

## Phase 4: Mailing list / external

**Step 4.1: Original submission**
Record: `b4 dig -c 3265f1998ae9a9282a8a6ca95467d9572d6ebb82` →
https://patch.msgid.link/20260703065448.210255-1-zhang.guodong@linux.dev
v1 only (2026-07-03). Saved mbox has the patch and **no replies**. Trond
applied it as-is (same +6 hunk). Lore HTML was 403 (Anubis); discussion
content was recovered via b4.

**Step 4.2: Recipients (`b4 dig -w`)**
Record: Trond Myklebust, Anna Schumaker, linux-nfs@vger.kernel.org,
ZhangGuoDong, Jackie Liu. Right maintainers/list.

**Step 4.3: Bug report**
Record: No public bugzilla/syzbot link. Evidence is a 4.19 vmcore stack
in the commit message (unmount → `nfs_readdir_clear_array`).

**Step 4.4: Series**
Record: Standalone `[PATCH]`, not `n/m`. Same 7.3 NFS pull also has
NFSv3 symlink/`atomic_open` fixes; those are separate.

**Step 4.5: Stable list**
Record: Lore stable search 403. Trond’s 7.3 pull listed this under
**“Other bugfixes”**, not “Stable fixes”. That is categorization, not a
NAK. No stable-thread rejection found.

## Phase 5: Semantic / call graph

**Step 5.1: Functions**
Record: `nfs_symlink()` only.

**Step 5.2: Callers**
Record: `nfs_dir_inode_operations.symlink`,
`nfs3_dir_inode_operations.symlink`, `nfs4_dir_inode_operations.symlink`
all point at `nfs_symlink`. `vfs_symlink()` → `dir->i_op->symlink()`
from `do_symlinkat` / `symlink(2)`.

**Step 5.3: Callees**
Record: `NFS_PROTO(dir)->symlink` (`nfs_proc_symlink` /
`nfs3_proc_symlink` / `nfs4_proc_symlink`) instantiate via
`nfs_instantiate` / `nfs_add_or_obtain` → `nfs_fhget` +
`d_splice_alias`. Then `filemap_add_folio`. Directory inodes get
`i_data.a_ops = &nfs_dir_aops` in `fs/nfs/inode.c` (`S_ISDIR` branch).

**Step 5.4: Reachability**
Record: Yes — unprivileged `symlink(2)` on an NFS mount. Crash is later
(reclaim/unmount), not at syscall return.

**Step 5.5: Similar patterns**
Record: Same class as `nfs_atomic_open_v23()` not checking `d_is_reg()`
after CREATE (fixed in this tree by `df214a74b5f2a`). NFS create paths
can attach a different type than the client assumed.

## Phase 6: This tree (pending-6.12 / 6.12.111)

**Step 6.1: Buggy code present?**
Record: **Yes.** `nfs_symlink()` at `fs/nfs/dir.c:2612-2665` has the
unchecked `filemap_add_folio(d_inode(dentry)->i_mapping, …)` after RPC
success. `nfs_dir_aops.free_folio = nfs_readdir_clear_array` still
`kfree`s names from folio contents. `3265f1998ae9` is **not** an
ancestor of HEAD.

**Step 6.2: Backport difficulty**
Record: **Clean apply.** Hunk context is the `return error;` /
`nfs_set_verifier()` sequence, identical here. Later mainline `%llu` for
`i_ino` is outside this hunk.

**Step 6.3: Related fixes already here?**
Record: No `d_is_symlink()` guard in `nfs_symlink()`. `df214a74b5f2a` is
a different type-check (open/CREATE), not this cache-insert bug.

## Phase 7: Subsystem

**Step 7.1:** NFS client (`fs/nfs/`). **IMPORTANT** — common networked
filesystem; not core mm/VFS, but widely deployed
(enterprise/Android/embedded).

**Step 7.2:** Actively maintained; this is a long-standing pattern, not
a brand-new subsystem.

## Phase 8: Impact and risk

**Step 8.1:** NFS client users who create symlinks (`symlink(2)`). All
of NFSv2/v3/v4 client.

**Step 8.2:** Trigger is **not** every `symlink()`. It needs the post-
RPC dentry to not be a symlink: NFSv2 LOOKUP-after-SYMLINK race, missing
fh/attrs then LOOKUP, server wrong type, or fh alias onto a directory
inode. Unprivileged users can call `symlink(2)`; the crash is delayed to
reclaim/unmount.

**Step 8.3:** Failure mode: invalid `kfree` / memory corruption / oops
on unmount. **CRITICAL**.

**Step 8.4:** Benefit **high** (prevents unmount crash/corruption). Risk
**very low** (6 lines, success path unchanged, cache skip already
defined as optional). Ratio strongly favors backport.

## Phase 9: Synthesis

**For:**
- Real crash with vmcore stack (`nfs_readdir_clear_array` on unmount).
- Same insertion vs directory `free_folio` pattern is in this 6.12 tree.
- Bug dates to 2006 (`873101b337767`).
- 6-line type check; NFS maintainer signed off.
- Userspace-reachable via `symlink(2)`.
- Also avoids NULL `d_inode` if instantiation left a non-
  symlink/negative dentry.
- Applies cleanly; no new APIs.

**Against:**
- Trigger is uncommon (race/server/fh mismatch), not every symlink.
- No Fixes:/Cc: stable (expected; not a NO reason).
- Trond grouped it as “other bugfixes” in the 7.3 pull, not “stable
  fixes”.
- Mailing list had no public review comments (silent apply).
- Crash evidence is 4.19; current kernels are folio-based but the type-
  confusion is unchanged.

**Unresolved:** Exact 4.19 race vs this tree is not re-reproduced here.
The local code still matches the described mechanism.

**Stable rules:**
1. Obviously correct and tested? **PASS** — type check + drop/skip
   cache; maintainer applied v1 unchanged.
2. Real user-visible bug? **PASS** — production vmcore.
3. Important (crash/corruption)? **PASS** — invalid `kfree` on unmount.
4. Small/contained? **PASS** — +6 lines, one function.
5. No new features/APIs? **PASS**.
6. Applies to this tree? **PASS**.

**Exception category:** None needed; it is a normal bugfix.

This tree is **6.12.111** (`pending-6.12`). The buggy path is here, the
fix is surgical, and the failure is a crash with memory corruption. It
should be backported.

Verification:
- [Phase 1] Tags parsed from provided message and GitHub `3265f1998ae9`;
  no Fixes/Cc:stable; Trond SOB confirmed.
- [Phase 2] Diff is +6 in `nfs_symlink()` only; compared to local
  `fs/nfs/dir.c:2612-2665`.
- [Phase 3] `git blame` on `nfs_symlink`; introducer `873101b337767` is
  ancestor; `git merge-base --is-ancestor 3265f1998ae9 HEAD` → not in
  this tree.
- [Phase 3] `nfs_dir_aops.free_folio = nfs_readdir_clear_array` at lines
  71-73; `nfs_readdir_clear_array` kfree loop at 221-231; directory
  `a_ops` set in `inode.c` ~501-505.
- [Phase 4] `b4 dig -c 3265f1998ae9` → lore msgid
  `20260703065448.210255-1-zhang.guodong@linux.dev`; `-a` v1 only; `-w`
  Trond+Anna+linux-nfs; mbox has no replies.
- [Phase 4] Openwall 7.3 pull lists this under other bugfixes:
  https://lists.openwall.net/linux-kernel/2026/08/26/1997
- [Phase 4] Lore HTML 403; used b4 mbox instead.
- [Phase 5] Grep: v2/v3/v4 dir `i_op->symlink = nfs_symlink`;
  `vfs_symlink` in `fs/namei.c`.
- [Phase 6] `make kernelversion` → 6.12.111; `git describe HEAD` →
  `p-6.12-3-gc504cf0baa3d8`; insertion context unique; `d_is_symlink`
  exists.
- [Phase 8] Failure mode from vmcore + local `nfs_readdir_clear_array`
  code: invalid kfree, CRITICAL.
- UNVERIFIED: Could not re-run the 4.19 workload; mechanism match is
  from code, not a new repro.

**YES**

 fs/nfs/dir.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 38b0834e3ebf1..0d8ac9a7448af 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2632,6 +2632,12 @@ int nfs_symlink(struct mnt_idmap *idmap, struct inode *dir,
 		return error;
 	}
 
+	if (unlikely(!d_is_symlink(dentry))) {
+		d_drop(dentry);
+		folio_put(folio);
+		return 0;
+	}
+
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 
 	/*
-- 
2.53.0

