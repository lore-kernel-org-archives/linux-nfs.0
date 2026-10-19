Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E954C4C7B4D;
	Mon, 19 Oct 2026 14:01:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792418482; cv=none; b=MQSlN/67Vlw+o1q96nLaBuPnoZOgwkr4j1GZ3zALIdR/Gdji9sLwq3nhD6tAJwwhpTgoepN8YyCpp7ovlFiauJrWpQ3pKRMljtGXD7BKHcpPjDa/wQ0jpvaaJVQWxIQr+9ZTuaPojRzxy5C1Q6sVkPj5maap80+j3ZLSoCi/8Qg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792418482; c=relaxed/simple;
	bh=xZ0GKOXh8x9WGqP6vmBTUfaPJb3s+0UeJKGtorZ7qW4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=feTiGI7FfjYhjk91JPJTx28L+XfTWKTTZ8JO1N3xGCihlbbRsIha5TX/9iy/M+ZrUXe2752Yi+vLIgCMCStWt9LJ9c2hTeLAFwREaeXw21A8O4PDHMhWFw87ZLAOaVXqMRq+9HKBcdTjCUOHiyn35EwOyDVH/jHG0xgXmVFq5aI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LZC4EYU9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LZC4EYU9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BC1E11F000C6;
	Mon, 19 Oct 2026 14:01:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792418478;
	bh=00nhwAu83E8hBuqMFbrf6VYVE6dlfM+vizhQijPhzPE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LZC4EYU9wniMyo+j2uEIvP90JiIXMu1QUjR3IKMqOX4eWIzcsH8zSBmimqx9GSmf8
	 hwBsax1quS7L+A3bBVeolxtcgPo5C5x7pUgLfyrpRvO5rqQ2WNypqGmLPuLDQXYqWi
	 nENNrji6ybY6h8FKzIPAXOcyL1a572CxLqSY/3BZKbA3Wciho4ByqyZfENaf+eeXbn
	 p8e4BzIRrS+kiV7UiUDQKd5giB+Vc2sP7uwlVxHir/nx5M3xwEdxI+LPWNUlMmX0pT
	 f96Pd+/1sd6TCkyNAzZyKm/Npp5LImzKZn3p2KaOeU3NxVokcdG43cSDQuj0K8tJB/
	 K6HHH2h3tWcEQ==
From: Sasha Levin <sashal@kernel.org>
To: patches@lists.linux.dev,
	stable@vger.kernel.org
Cc: Jia Zhu <zhujia.zj@bytedance.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Sasha Levin <sashal@kernel.org>,
	trondmy@kernel.org,
	anna@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH AUTOSEL 6.18-6.12] NFSv4: pin the superblock for active state owners
Date: Mon, 19 Oct 2026 09:49:28 -0400
Message-ID: <20261019135441.1420968-277-sashal@kernel.org>
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

From: Jia Zhu <zhujia.zj@bytedance.com>

[ Upstream commit 8cb1ce7aa0e8ac30e55f5bccfb80125f2e43e84a ]

NFSv4 open state can outlive the file and dentry that created it. This
was observed in production when NFSv4 state recovery, such as after a
server reboot or lease expiration, raced with unmount.

The race requires recovery to hold an open state reference while the last
open file is closed and the filesystem is unmounted, allowing the
superblock's active reference to drop to zero between
refcount_inc(&state->count) and nfs4_put_open_state():

    state manager                    umount

    nfs4_run_state_manager()
      nfs4_do_reclaim()
        nfs4_reclaim_open_state()
          refcount_inc(&state->count)
          ...
                                      close last file
                                      generic_shutdown_super()
                                        "Busy inodes after unmount"
                                      nfs_free_server()
          nfs4_put_open_state()
            iput(inode)
              evict()
                nfs_clear_inode()
                  nfs_zap_acl_cache()

The "VFS: Busy inodes after unmount" warning is the visible symptom of
that lifetime mismatch: superblock teardown proceeds even though the NFS
open state still pins an inode. After umount has freed the server, the
state manager can then run nfs4_put_open_state() for the last open-state
reference. The resulting iput(inode) can evict an NFS inode with freed
server data, causing crashes at nfs_zap_acl_cache(). This can be
reproduced by delaying the reclaim path before nfs4_put_open_state(),
then closing the last file and unmounting the NFS mount.

Pin the superblock while a state owner is active, and drop the pin when
the owner becomes idle again, so the NFS server stays alive until all
open state associated with the owner has been released.

Assisted-by: Codex:GPT-5
Signed-off-by: Jia Zhu <zhujia.zj@bytedance.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---

LLM Generated explanations, may be completely bogus:

This is a real NFSv4 recovery-vs-unmount use-after-free that exists in
this 6.12 tree. The fix is small, uses the existing `nfs_sb_active`
pattern, and should be backported.

---

## PHASE 1: COMMIT MESSAGE FORENSICS

**Step 1.1: PARSE THE SUBJECT LINE**

Record: **[NFSv4] [pin] pin the superblock for active state owners**

Subsystem prefix: `NFSv4`. Action verb: **pin** (lifetime/refcount fix,
same class as “ensure”/“prevent”). Claimed intent: keep the NFS
superblock alive while a state owner is active so umount cannot free
`nfs_server` under recovery.

**Step 1.2: PARSE ALL COMMIT MESSAGE TAGS**

Verified on `8cb1ce7aa0e8ac30e55f5bccfb80125f2e43e84a`:

- **Assisted-by:** Codex:GPT-5
- **Signed-off-by:** Jia Zhu \<zhujia.zj@bytedance.com\> (author)
- **Signed-off-by:** Trond Myklebust \<trond.myklebust@hammerspace.com\>
  (NFS client maintainer; committer)
- **No Fixes:**
- **No Reported-by / Tested-by / Reviewed-by / Acked-by**
- **No Link:**
- **No Cc: stable@vger.kernel.org** (expected for this review pipeline;
  not a negative)

Notable: production report is in the body (“observed in production”),
not a `Reported-by` tag. Maintainer SOB is a strong quality signal.

**Step 1.3: ANALYZE THE COMMIT BODY TEXT**

Record:

- **Bug:** NFSv4 open state can outlive the file/dentry. State recovery
  (`nfs4_reclaim_open_state`) holds `refcount_inc(&state->count)` across
  a window where the last file can be closed and the mount unmounted.
- **Symptom:** `VFS: Busy inodes after unmount`, then crash in
  `nfs_zap_acl_cache()` after `nfs_free_server()`.
- **Failure mode:** umount tears down the superblock/`nfs_server` while
  recovery still pins an inode via open state. Later
  `nfs4_put_open_state()` → `iput()` → `evict()` → `nfs_clear_inode()` →
  `nfs_zap_acl_cache()` → `NFS_PROTO(inode)` dereferences freed
  `nfs_server`.
- **Version info:** none in the message. Race is in long-standing NFSv4
  reclaim/umount code.
- **Root cause:** open-state lifetime is not tied to `s_active` /
  `nfs_server` lifetime.
- **Fix:** `nfs_sb_active()` while a state owner is counted;
  `nfs_sb_deactive()` when `so_count` hits 0.

**Step 1.4: DETECT HIDDEN BUG FIXES**

Record: **Not hidden.** Explicit production crash/UAF with a race
diagram and reproduction (delay reclaim, close last file, umount). Not
cleanup/refactor.

---

## PHASE 2: DIFF ANALYSIS

**Step 2.1: INVENTORY THE CHANGES**

Record:

- **File:** `fs/nfs/nfs4state.c` only (`+33/-7`, 40 lines)
- **Functions:**
  - **Added:** `nfs4_get_state_owner_active_locked()`
  - **Modified:** `nfs4_find_state_owner_locked()`,
    `nfs4_insert_state_owner_locked()`, `nfs4_alloc_state_owner()`,
    `nfs4_get_state_owner()`, `nfs4_put_state_owner()`
- **Scope:** single-file surgical lifetime fix

**Step 2.2: UNDERSTAND THE CODE FLOW CHANGE**

Record:

1. **Idle-owner revival (find/insert, `cl_lock` held):** before: always
   `list_del_init(so_lru)` + `atomic_inc(so_count)`. After: if `so_count
   == 0`, pin SB via `nfs_sb_active()`; if pin fails (umount already
   dropped `s_active`), return NULL instead of reviving.
2. **New owner alloc:** after `kzalloc`, call
   `nfs_sb_active(server->super)`; fail allocation if umount is
   underway.
3. **Duplicate insert:** if insert returns an existing owner, free the
   new one **and** drop the extra pin taken in alloc.
4. **Last put:** save `sb` before dropping `so_count`; on 0, put on LRU,
   drop `cl_lock`, then `nfs_sb_deactive(sb)` (may call
   `deactivate_super()`).

Pin is 0/1 per owner: taken on 0→1, dropped on 1→0. Extra `so_count`
bumps (reclaim, close, opendata) do not take extra pins.

**Step 2.3: IDENTIFY THE BUG MECHANISM**

Record: **[Use-after-free / lifetime race] [superblock and `nfs_server`
freed while NFSv4 open state still holds an inode]**

Verified crash path in this tree:

- `nfs4_reclaim_open_state()` does `refcount_inc(&state->count)` then
  later `nfs4_put_open_state()` (`fs/nfs/nfs4state.c`).
- `nfs4_put_open_state()` does `iput(inode)` then
  `nfs4_put_state_owner()`.
- `nfs_kill_super()` calls `nfs_free_server()` even if inodes remain.
- `nfs_clear_inode()` → `nfs_zap_acl_cache()` → `NFS_PROTO(inode)` →
  `NFS_SERVER(inode)->nfs_client->rpc_ops` (`include/linux/nfs_fs.h`),
  which is UAF if `s_fs_info` was already freed.

Category: **race + UAF**. Same established NFS pattern as
delegation/unlink/`opendata` SB pins.

**Step 2.4: ASSESS THE FIX QUALITY**

Record:

- **Quality:** high. Pin/unpin is balanced (alloc pin, duplicate-insert
  deactive, last-put deactive). `nfs_sb_active()` is atomics-only, so it
  is safe under `cl_lock`. `nfs_sb_deactive()` runs after dropping
  `cl_lock` because `deactivate_super()` can sleep.
- **Regression risk:** low–medium. Umount now waits until owners go idle
  (intended; matches other NFS pins). New OPEN during umount can fail if
  `s_active==0` (correct). Imbalance would hang umount or leak
  `s_active`; the get/put pairing is straightforward.
- **Red flags:** none for APIs/features. AI-assisted, but maintainer-
  committed with unchanged v1.

---

## PHASE 3: GIT HISTORY INVESTIGATION

**Step 3.1: BLAME THE CHANGED LINES**

Record:

- Idle LRU + `atomic_inc(so_count)` in find/insert: `0aaaf5c424c7ff`
  (“NFS: Cache state owners after files are closed”, Chuck Lever, 2011)
  — **is an ancestor of HEAD**.
- `nfs4_put_state_owner` LRU move: `7bf97bc27308cf` (2012).
- `nfs4_alloc_state_owner`: structure since `d1e284d50a1506` (2012);
  `kzalloc(sizeof(*sp))` still used in **this** 6.12 tree.
- Reclaim extra open-state ref: long-standing
  `nfs4_reclaim_open_state()`.

Bug is in code present for many years, not post-6.12.

**Step 3.2: FOLLOW THE FIXES: TAG**

Record: **No Fixes: tag.** Introducer is the 2011 LRU caching plus
reclaim holding open-state refs without an SB pin. Both exist in this
tree.

**Step 3.3: CHECK FILE HISTORY FOR RELATED CHANGES**

Record: recent `fs/nfs/nfs4state.c` work is other recovery/hang fixes
(`71e07bb1556c7`, `a848c29e34861`, `8f6a7c9467eaf`). No prerequisite
refactor for this pin. **Standalone**, not `patch X/Y`.

Parent of `8cb1ce7aa0e8` is `932a8cf6abb2b` (unrelated sunrpc pipefs
UAF). Not required here.

**Step 3.4: CHECK THE AUTHOR'S OTHER COMMITS**

Record: Jia Zhu has no other commits on `fs/nfs/` in this tree. Trond
(maintainer) committed it. Related historical pin: `9f0f8e12c48e4`
“NFSv4: Pin the superblock while we're returning the delegation” (2015)
**is** in this tree.

**Step 3.5: CHECK FOR DEPENDENT/PREREQUISITE COMMITS**

Record: **None.** Needs existing `nfs_sb_active`/`nfs_sb_deactive`
(`fs/nfs/super.c`; present). `kzalloc_obj` in the mainline hunk is
**not** used in this tree’s `nfs4_alloc_state_owner` (still
`kzalloc(sizeof(*sp))`). Backport keeps `kzalloc` and adds the
`nfs_sb_active` check. `kzalloc_obj` the macro exists in 6.12
`include/linux/slab.h` but is not a dependency of the fix.

---

## PHASE 4: MAILING LIST AND EXTERNAL RESEARCH

**Step 4.1: FIND THE ORIGINAL PATCH DISCUSSION**

Record:

- `b4 dig -c 8cb1ce7aa0e8` → https://patch.msgid.link/20260707133623.230
  78-1-zhujia.zj@bytedance.com
- `b4 dig -a`: **v1 only**, 2026-07-07, Jia Zhu. Applied version **is**
  v1.
- `b4 mbox`: **1 message, no replies, no NAK, no v2.**
- Merged via Trond’s NFS pull for Linux 7.3 (`tags/nfs-for-7.3-1`), into
  Linus as part of `73e3f0710014`. SHA `8cb1ce7aa0e8`, 2026-08-17.
- Pull letter lists it under Jia Zhu and describes “NFSv4: Fix another
  state manager race with umount” under **Other bugfixes** (not the
  “Stable fixes” bullet list). That is description of this race, not a
  second patch in the shortlog.

**Step 4.2: CHECK WHO REVIEWED THE PATCH**

Record (`b4 dig -w`): To Trond Myklebust, Anna Schumaker; Cc linux-nfs,
linux-kernel. No on-list review comments. Maintainer applied it (~6
weeks later).

**Step 4.3: SEARCH FOR THE BUG REPORT**

Record: no syzbot/bugzilla. Author states **production** observation and
a concrete repro (delay reclaim, close last file, umount). Verified
reclaim/`put_open_state`/`nfs_zap_acl_cache` code matches the diagram.

**Step 4.4: CHECK FOR RELATED PATCHES AND SERIES**

Record: standalone. Same 7.3 pull also has `cf616096a0f3` “NFS: Pin the
`struct nfs_server` during a FREE_STATEID call” — **different bug**,
**not** an ancestor of this HEAD, **not** required for this patch.

**Step 4.5: CHECK STABLE MAILING LIST HISTORY**

Record: lore.kernel.org/stable search returned **403**. **UNVERIFIED**
whether it was discussed on stable@. No evidence it was rejected.
Absence of Cc: stable is expected.

---

## PHASE 5: CODE SEMANTIC ANALYSIS

**Step 5.1: KEY FUNCTIONS**

Record: `nfs4_get_state_owner_active_locked` (new),
`nfs4_find_state_owner_locked`, `nfs4_insert_state_owner_locked`,
`nfs4_alloc_state_owner`, `nfs4_get_state_owner`,
`nfs4_put_state_owner`. Related unchanged: `nfs4_reclaim_open_state`,
`nfs4_do_reclaim`, `nfs4_put_open_state`.

**Step 5.2: TRACE CALLERS**

Record:

- `nfs4_get_state_owner()`: `nfs4_do_open()` (`nfs4proc.c`),
  `nfs4file.c` (copy/open context). Userspace OPEN on NFSv4.
- `nfs4_put_state_owner()`: `nfs4_put_open_state`, `__nfs4_close`,
  `nfs4_do_reclaim`, opendata free, several `nfs4proc.c` paths.
  Process/workqueue context (`iput`, RPC completion).
  `nfs_sb_deactive()` → `deactivate_super()` is sleepable; those paths
  already sleep.
- `nfs4_do_reclaim()` uses `atomic_inc_not_zero(&sp->so_count)`
  (already-active owners only). With this patch those owners already
  hold the SB pin from the original get.

**Step 5.3: TRACE CALLEES**

Record: `nfs_sb_active` / `nfs_sb_deactive` (`super.c`): first pin keeps
an extra `s_active`; last `nfs_sb_deactive` calls `deactivate_super()`.
Same helpers as unlink, pnfs, delegation, callback, opendata.

**Step 5.4: FOLLOW THE CALL CHAIN**

Record: reachable from NFSv4 OPEN + lease recovery + umount. State
manager is a kthread (`nfs4_run_state_manager`). Unprivileged users with
an NFSv4 mount can close the last file and umount (typically admin for
umount). Recovery after server reboot/lease expiry is a **common**
enterprise path. **Yes, user-triggerable on any NFSv4 client.**

**Step 5.5: SEARCH FOR SIMILAR PATTERNS**

Record: `nfs_sb_active` already used in `unlink.c`, `pnfs.c`,
`nfs4proc.c` (opendata), `inode.c`, `delegation.c`, `callback_proc.c`.
`9f0f8e12c48e4` is the same class of fix. This extends that pattern to
state owners.

---

## PHASE 6: CROSS-REFERENCING AGAINST THE LOCAL TREE

**Step 6.1: DOES THE BUGGY CODE EXIST IN THIS TREE?**

Record: **Yes.** Tree is **6.12.111** (`pending-6.12`,
`p-6.12-3-gc504cf0baa3d8`).

`git merge-base --is-ancestor 8cb1ce7aa0e8 HEAD` → **not an ancestor**.

Local `nfs4_find_state_owner_locked` still does unpinned `atomic_inc`;
`nfs4_put_state_owner` has no `nfs_sb_deactive`; reclaim still
`refcount_inc` + `nfs4_put_open_state`. Bug is here.

**Step 6.2: CHECK FOR BACKPORT COMPLICATIONS**

Record: **minor context only.** Same function bodies except alloc uses
`kzalloc(sizeof(*sp), gfp_flags)` here vs `kzalloc_obj(*sp, gfp_flags)`
upstream. Rest should apply with fuzz or a one-line context tweak. No
structural conflict.

**Step 6.3: CHECK IF RELATED FIXES ARE ALREADY HERE**

Record: no `nfs4_get_state_owner_active_locked`. Delegation SB pin is
present; it does not cover this reclaim/open-state race. No alternate
fix found.

---

## PHASE 7: SUBSYSTEM AND MAINTAINER CONTEXT

**Step 7.1: SUBSYSTEM AND CRITICALITY**

Record: **[fs/nfs NFSv4 client] [IMPORTANT]**

Not core mm/VFS, but NFSv4 is widely used (enterprise NAS, diskless,
containers). Crash is in client umount/recovery.

**Step 7.2: SUBSYSTEM ACTIVITY**

Record: mature, still actively fixed. State-owner LRU dates to 2011;
this is a long-standing lifetime hole, not a new-subsystem issue.

---

## PHASE 8: IMPACT AND RISK ASSESSMENT

**Step 8.1: WHO IS AFFECTED**

Record: **NFSv4 client users** (`CONFIG_NFS_V4`). Trigger: recovery
(reboot/lease expiry) racing last close + umount. Production report from
ByteDance.

**Step 8.2: TRIGGER CONDITIONS**

Record: needs NFSv4 state recovery overlapping last-file close and
umount. Timing-dependent but **reproduced** (delay before
`nfs4_put_open_state`) and seen in production. Umount is typically
privileged; recovery is not a syzbot syscall gadget, but the crash is
real.

**Step 8.3: FAILURE MODE SEVERITY**

Record: **UAF → kernel oops/crash after “Busy inodes after unmount”.**
`NFS_PROTO()` loads `nfs_client` from freed `nfs_server`. **Severity:
HIGH/CRITICAL.**

**Step 8.4: RISK-BENEFIT RATIO**

Record:

- **Benefit:** high — prevents production NFSv4 umount crash/UAF.
- **Risk:** low–medium — ~33 lines, one file, established helpers.
  Umount waits for idle owners (correct). Pin imbalance would hang
  umount; pairing is clear.
- **Ratio:** benefit outweighs risk.

---

## PHASE 9: FINAL SYNTHESIS

**Step 9.1: COMPILE THE EVIDENCE**

**FOR:**

- Production crash/UAF with a clear race diagram and repro.
- Buggy code is in this 6.12 tree; fix is not.
- Small, one-file, uses existing `nfs_sb_active`/`nfs_sb_deactive`.
- NFS maintainer (Trond) committed it; merged to mainline for 7.3.
- Same class as prior NFS SB-pin fixes already in this tree.
- Reclaim path verified: extra open-state ref without SB pin;
  `nfs_kill_super` frees server with busy inodes.

**AGAINST:**

- No Fixes:/Cc: stable (expected; not a reason to reject).
- No on-list review replies; AI-assisted. Mitigated by maintainer SOB.
- Pull letter put it under “Other bugfixes” not “Stable fixes” (likely
  because it lacked Cc: stable).
- Umount may wait longer while owners drain — intended, same as other
  NFS pins.
- Tiny backport context (`kzalloc` vs `kzalloc_obj`).

**UNRESOLVED:**

- lore.kernel.org/stable returned 403; no confirmed stable@ thread.
- No public `Tested-by` besides the author’s production/repro claim
  (unverified independently, but code path matches).

**Step 9.2: STABLE RULES CHECKLIST**

1. Obviously correct and tested? **PASS** — pin/unpin is balanced;
   production + explicit repro; maintainer applied v1 unchanged.
2. Fixes a real bug that affects users? **PASS** — production UAF/crash.
3. Important (crash/security/corruption/deadlock)? **PASS** — crash/UAF
   on umount during recovery. **HIGH/CRITICAL**.
4. Small and contained? **PASS** — +33/-7, one file.
5. No new features or APIs? **PASS**
6. Can apply to the local tree? **PASS** — same functions; minor
   `kzalloc` context only.

**Step 9.3: EXCEPTION CATEGORIES**

Record: none of device-ID/quirk/DT/build/docs. Qualifies as a normal
important bugfix.

**Step 9.4: DECISION**

Backport to this 6.12.y tree. The lifetime hole is here, the failure is
a real crash, and the fix is the same SB-pin pattern NFS already uses.

---

### What this solves for stable users

On NFSv4, lease recovery can hold an open-state ref while the last file
is closed and the mount is unmounted. VFS then warns `Busy inodes after
unmount`, `nfs_free_server()` frees `nfs_server`, and the later `iput`
in `nfs4_put_open_state()` oopses in `nfs_zap_acl_cache()` via
`NFS_PROTO()`. Pinning the superblock for the life of an active state
owner keeps `nfs_server` alive until that state is dropped.

### Risk vs benefit

Benefit is high (production oops). Risk is low: ~30 lines, existing
helpers, umount waits instead of tearing down under live state. Backport
may need to keep `kzalloc(sizeof(*sp), gfp_flags)` instead of
`kzalloc_obj`.

---

### Verification

- **[Phase 1]** `git describe HEAD` / Makefile: **6.12.111**, branch
  `pending-6.12`. Tags on `8cb1ce7aa0e8`: Assisted-by Codex, SOB Jia Zhu
  + Trond; no Fixes/Cc stable/Reported-by.
- **[Phase 2]** Diff: +33/-7 in `fs/nfs/nfs4state.c`. Local
  reclaim/`put_open_state`/`nfs_clear_inode`/`NFS_PROTO` match the crash
  story.
- **[Phase 2]** `nfs_sb_active`/`nfs_sb_deactive` in `fs/nfs/super.c`
  confirmed (atomics; last deactive → `deactivate_super`).
- **[Phase 3]** `git blame` on find/put: LRU caching `0aaaf5c424c7ff`
  (2011) **is** ancestor. `git merge-base --is-ancestor 8cb1ce7aa0e8
  HEAD` → **false**.
- **[Phase 3]** Parent `932a8cf6abb2b` is unrelated sunrpc UAF; not a
  prerequisite.
- **[Phase 4]** `b4 dig -c 8cb1ce7aa0e8`: lore msgid
  `20260707133623.23078-1-zhujia.zj@bytedance.com`. `-a`: v1 only. `-w`:
  Trond + Anna + linux-nfs. `b4 mbox`: 1 message, no replies.
- **[Phase 4]** LKML GIT PULL 2026-08-26: Jia Zhu commit listed; merged
  to Linus (`73e3f0710014`).
- **[Phase 4]** lore.kernel.org and lore stable search: **403** —
  UNVERIFIED stable@ discussion.
- **[Phase 5]** Callers: `nfs4_do_open`, `nfs4file.c`, reclaim,
  opendata, close. `nfs4_do_reclaim` uses `atomic_inc_not_zero` (active
  owners only → pin already held).
- **[Phase 6]** Local find/insert/put still unpinned. Alloc still
  `kzalloc(sizeof(*sp))` vs upstream `kzalloc_obj`.
- **[Phase 7]** `CONFIG_NFS_V4` exists; NFSv4 client is important for
  LTS.
- **[Phase 8]** Failure: UAF/oops after busy-inodes warning. Severity
  HIGH/CRITICAL.
- **UNVERIFIED:** independent tester beyond author; stable@ archive
  contents.

**YES**

 fs/nfs/nfs4state.c | 40 +++++++++++++++++++++++++++++++++-------
 1 file changed, 33 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 01179f7de3225..6147d8c0ee111 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -403,6 +403,26 @@ const struct cred *nfs4_get_clid_cred(struct nfs_client *clp)
 	return cred;
 }
 
+static bool
+nfs4_get_state_owner_active_locked(struct nfs4_state_owner *sp)
+{
+	struct nfs_server *server = sp->so_server;
+
+	/*
+	 * A counted state owner may dereference so_server until the final
+	 * nfs4_put_state_owner().  Pin the superblock when reviving an idle
+	 * owner so umount cannot free the server underneath it.
+	 */
+	if (atomic_read(&sp->so_count) == 0) {
+		if (!nfs_sb_active(server->super))
+			return false;
+		if (!list_empty(&sp->so_lru))
+			list_del_init(&sp->so_lru);
+	}
+	atomic_inc(&sp->so_count);
+	return true;
+}
+
 static struct nfs4_state_owner *
 nfs4_find_state_owner_locked(struct nfs_server *server, const struct cred *cred)
 {
@@ -421,9 +441,8 @@ nfs4_find_state_owner_locked(struct nfs_server *server, const struct cred *cred)
 		else if (cmp > 0)
 			p = &parent->rb_right;
 		else {
-			if (!list_empty(&sp->so_lru))
-				list_del_init(&sp->so_lru);
-			atomic_inc(&sp->so_count);
+			if (!nfs4_get_state_owner_active_locked(sp))
+				return NULL;
 			return sp;
 		}
 	}
@@ -449,9 +468,8 @@ nfs4_insert_state_owner_locked(struct nfs4_state_owner *new)
 		else if (cmp > 0)
 			p = &parent->rb_right;
 		else {
-			if (!list_empty(&sp->so_lru))
-				list_del_init(&sp->so_lru);
-			atomic_inc(&sp->so_count);
+			if (!nfs4_get_state_owner_active_locked(sp))
+				return NULL;
 			return sp;
 		}
 	}
@@ -501,6 +519,10 @@ nfs4_alloc_state_owner(struct nfs_server *server,
 	sp = kzalloc(sizeof(*sp), gfp_flags);
 	if (!sp)
 		return NULL;
+	if (!nfs_sb_active(server->super)) {
+		kfree(sp);
+		return NULL;
+	}
 	sp->so_seqid.owner_id = atomic64_inc_return(&server->owner_ctr);
 	sp->so_server = server;
 	sp->so_cred = get_cred(cred);
@@ -586,8 +608,10 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
 	spin_lock(&clp->cl_lock);
 	sp = nfs4_insert_state_owner_locked(new);
 	spin_unlock(&clp->cl_lock);
-	if (sp != new)
+	if (sp != new) {
 		nfs4_free_state_owner(new);
+		nfs_sb_deactive(server->super);
+	}
 out:
 	nfs4_gc_state_owners(server);
 	return sp;
@@ -609,6 +633,7 @@ void nfs4_put_state_owner(struct nfs4_state_owner *sp)
 {
 	struct nfs_server *server = sp->so_server;
 	struct nfs_client *clp = server->nfs_client;
+	struct super_block *sb = server->super;
 
 	if (!atomic_dec_and_lock(&sp->so_count, &clp->cl_lock))
 		return;
@@ -616,6 +641,7 @@ void nfs4_put_state_owner(struct nfs4_state_owner *sp)
 	sp->so_expires = jiffies;
 	list_add_tail(&sp->so_lru, &server->state_owners_lru);
 	spin_unlock(&clp->cl_lock);
+	nfs_sb_deactive(sb);
 }
 
 /**
-- 
2.53.0

