Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 993D656DCF7;
	Mon, 19 Oct 2026 13:58:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792418288; cv=none; b=MTZ70Q1iBfrJsYpfW3c+iT/AkE8yutP/puxZRRWjdnN2sQRZXml/kRv0AFaSKDo4oZv1y1WjF6i7+8Ir8V9jHmIhXGlg9cKzn22Khxb6NYy98vOJUpvdkUnL2CYuz0I2+0dqnmiZbspHC1+WFiKOsYCX/mAWku8g4TlfYH2/OLQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792418288; c=relaxed/simple;
	bh=bLx0EQsBaXAXk0+xThbR7drkUFeTbjNjD0PZXC/Jtkw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=IrBu3r/bB0qyMnGSLbhB2Dw/oR75Lny9EuisodQ7bOdZgFetmPZMLdxy51Ju63ZjUIyGxzUYeIpfxYCQIA1NXrVsAQ/MIFlR0GV/4CgHgPWKl/jhaqFf2LoFRwWqo9cynu4OImZ3ChiV8bTJeSw4LSCRHvnlT9XYWEow6+hn8xs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=W/M4geZ8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="W/M4geZ8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3BC931F000C4;
	Mon, 19 Oct 2026 13:58:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792418285;
	bh=h+RSvhysTAdXPwkQrhApMbjMyRbW3GW1nw+xVeDm3+w=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=W/M4geZ8f89XXHrgeVDzu3Dpxlg6+v1BpnPKTUTEgvM5aWG6Ghl4N5i2Or4vIzy36
	 p81uTEsDhuVsyoSnQrkl1rDMHh4KmyWUFnbJLNmreCDmkFaEmIOhBkYKcGo09M9g5l
	 2cn/ML+O3++cZsK8C1ACkxTRdjjyS7MAWOi+JWCrJqrU5K5A8a8tArzx419iNKsjpa
	 dvKIH59f3pJcZWYriD6c7puwXkWhZZxXNIT48dy+kyBeo7z37a9f63hi4xiLrhCAZ8
	 OHxfNq/VShsjlOR7jqKEoy1LhA0r8pKr0AVJ3nFa+nQKOWLepGuLA4NSJlsrl0t/0c
	 L6VRyHF4CTQRQ==
From: Sasha Levin <sashal@kernel.org>
To: patches@lists.linux.dev,
	stable@vger.kernel.org
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
	Benjamin Coddington <bcodding@hammerspace.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Sasha Levin <sashal@kernel.org>,
	trondmy@kernel.org,
	anna@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH AUTOSEL 6.18-6.12] pNFS: honor clora_changed when recalling a layout
Date: Mon, 19 Oct 2026 09:47:10 -0400
Message-ID: <20261019135441.1420968-139-sashal@kernel.org>
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

From: Benjamin Coddington <ben.coddington@hammerspace.com>

[ Upstream commit aceaa5991bdf744e9c3fa1e5ad73405b1801eaab ]

When the metadata server recalls a layout with clora_changed FALSE, the
layout is not changing and the client may complete its modified writes to
the storage devices before returning the layout (RFC 8881, Section
20.3.3).  Only when clora_changed is TRUE -- the server is restriping, or
a storage device has failed -- should the client stop writing to the
storage devices and redirect through the metadata server.

Since commit b739a5bd9d9f ("NFSv4/flexfiles: Cancel I/O if the layout is
recalled or revoked") the client cancels in-flight I/O on every recall,
regardless of clora_changed.  For an unchanged recall this abandons
writes whose data may already have reached the storage device; such a
write can then land after the LAYOUTRETURN, which the server sees as a
write without a layout.

Pass the recall's clora_changed value through
pnfs_mark_matching_lsegs_return() and only cancel in-flight I/O when the
layout is actually changing.  When it is not, the existing deferred
return path waits for the in-flight writes to drain before sending the
LAYOUTRETURN.  Other callers, which are tearing down or returning the
layout for their own reasons, continue to cancel as before.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---

LLM Generated explanations, may be completely bogus:

The local tree is **6.12.111** (`pending-6.12`). The buggy cancel-on-
every-recall path is present here; the fix is not. It is a small
protocol/data-integrity correction and applies cleanly.

---

## PHASE 1: COMMIT MESSAGE FORENSICS

**Step 1.1: PARSE THE SUBJECT LINE**

Record: **[pNFS] [honor] honor `clora_changed` when recalling a layout**

Subsystem: NFS pNFS client. Verb “honor” is a correctness/protocol fix,
not a feature add.

**Step 1.2: PARSE ALL COMMIT MESSAGE TAGS**

Record:
- **Signed-off-by:** Benjamin Coddington `<bcodding@hammerspace.com>`
  (author; Hammerspace)
- **Signed-off-by:** Trond Myklebust `<trond.myklebust@hammerspace.com>`
  (NFS client maintainer)
- **No Fixes:** (expected; body names `b739a5bd9d9f`)
- **No Cc: stable** (expected)
- **No Reported-by / Tested-by / Reviewed-by / Link / Acked-by**

Mainline SHA (verified on `origin/master`):
`aceaa5991bdf744e9c3fa1e5ad73405b1801eaab`

**Step 1.3: ANALYZE THE COMMIT BODY TEXT**

Record:
- **Bug:** Since `b739a5bd9d9f`, CB_LAYOUTRECALL always cancels in-
  flight DS I/O, including when `clora_changed` is FALSE.
- **RFC 8881 §20.3.3:** FALSE means the layout is not changing; the
  client may finish modified writes to storage before LAYOUTRETURN. TRUE
  means restriping/device failure; cancel and go through the MDS.
- **Failure mode:** Cancelled writes may already have reached the DS,
  then complete after LAYOUTRETURN → server sees a write with no layout.
- **Fix:** Pass `clora_changed` into
  `pnfs_mark_matching_lsegs_return()`; cancel only when the layout is
  changing. Unchanged recalls use the existing drain-then-return path.
  Other callers still cancel.
- **Version info:** Bug since the 2022 cancel-I/O commit (`v6.1-rc1`).

**Step 1.4: DETECT HIDDEN BUG FIXES**

Record: **Not a disguised cleanup.** It is an explicit
protocol/correctness fix. The extra `bool cancel_io` on other call sites
preserves existing teardown behavior.

---

## PHASE 2: DIFF ANALYSIS

**Step 2.1: INVENTORY THE CHANGES**

Record:
- `fs/nfs/callback_proc.c`: +2 / −1 (`initiate_file_draining`)
- `fs/nfs/pnfs.c`: +13 / −9 (declaration, all callers, cancel gate)
- `fs/nfs/pnfs.h`: +1 / −1 (prototype)
- **Net: +16 / −11**, three files. Surgical, single-subsystem.

Functions: `initiate_file_draining`, `nfs4_layout_refresh_old_stateid`,
`pnfs_mark_layout_stateid_return`, `pnfs_layout_io_set_failed`,
`_pnfs_return_layout`, `pnfs_layout_process`,
`pnfs_mark_matching_lsegs_return`, `pnfs_mark_layout_for_return`,
`pnfs_layout_return_unused_byserver`.

**Step 2.2: UNDERSTAND THE CODE FLOW CHANGE**

Record:
- **Recall path (`initiate_file_draining`):** passes
  `args->cbl_layoutchanged` instead of always cancelling.
- **`pnfs_mark_matching_lsegs_return`:** `pnfs_lseg_cancel_io()` only if
  `cancel_io`.
- **All other callers:** pass `true` → same as today.
- **Unchanged recall with I/O in flight:** still marks lsegs for return,
  returns `-EBUSY`, callback still `NFS4_OK`; deferred return waits for
  refs to drop (existing `pnfs_put_lseg` / LAYOUTRETURN path).
  `nfs_commit_inode()` after unlock is unchanged.

**Step 2.3: IDENTIFY THE BUG MECHANISM**

Record: **[Logic / protocol correctness]** Unconditional I/O cancel on
every recall. That races completed-on-wire writes vs LAYOUTRETURN. The
fix restores RFC drain-before-return when `clora_changed` is false.

Not a leak, UAF, lock, or new API.

**Step 2.4: ASSESS THE FIX QUALITY**

Record: **Obviously correct and minimal.** Only the CB_LAYOUTRECALL file
path changes behavior. `cbl_layoutchanged` is already decoded
(`callback_xdr.c`). Risk: unchanged recalls return the layout more
slowly if DS I/O is stuck (RFC-intended; server may recall again). Tear-
down still cancels. `pnfs_mark_matching_lsegs_invalid()` still always
cancels (revoke). No public API change.

---

## PHASE 3: GIT HISTORY INVESTIGATION

**Step 3.1: BLAME THE CHANGED LINES**

Record: Unconditional `pnfs_lseg_cancel_io()` at `fs/nfs/pnfs.c:2678` is
from **`b739a5bd9d9f`** (“NFSv4/flexfiles: Cancel I/O if the layout is
recalled or revoked”), 2022-10-05. `git describe --contains`:
**`v6.1-rc1`**. Present for the whole 6.12 lifetime.

**Step 3.2: FOLLOW THE FIXES: TAG**

Record: No `Fixes:` tag. Named commit **`b739a5bd9d9f` is an ancestor of
HEAD** (`git merge-base --is-ancestor` exit 0). That commit added cancel
in both `pnfs_mark_matching_lsegs_return` and
`pnfs_mark_matching_lsegs_invalid`; this patch only gates the return
path.

**Step 3.3: CHECK FILE HISTORY FOR RELATED CHANGES**

Record: Recent 6.12 pNFS work (`layout segment leak`, `EBUSY check`,
DRAIN wakeups) does not replace this fix. On `origin/master` this is
**v2 2/3** of “pNFS/flexfiles: honor clora_changed and report cancelled
I/O”:
- 1/3 `ba0f097418c7d` — tracepoint only; **not required**
- 2/3 **this commit**
- 3/3 `4a013b0e881e0` — report cancelled I/O as LAYOUTERROR; **not
  required** for this behavior

Standalone for the recall-cancel bug.

**Step 3.4: CHECK THE AUTHOR'S OTHER COMMITS**

Record: Benjamin Coddington is a regular NFS/pNFS contributor
(Hammerspace). Trond applied it. Anna’s v1 comments (kerneldoc,
`FILE_INODE`) were addressed in v2.

**Step 3.5: CHECK FOR DEPENDENT/PREREQUISITE COMMITS**

Record: Needs existing `cbl_layoutchanged`, `pnfs_lseg_cancel_io()`, and
`cancel_io` on flexfiles — all in this tree. No new helpers. **Applies
standalone.**

---

## PHASE 4: MAILING LIST AND EXTERNAL RESEARCH

**Step 4.1: FIND THE ORIGINAL PATCH DISCUSSION**

Record:
- Lore/msgid: https://patch.msgid.link/05e93230d2f58d9d8b23b083d8d89b21c
  b9f5184.1782388900.git.bcodding@hammerspace.com
- **v1 → v2**; applied version is v2.
- Cover: client has decoded `cbl_layoutchanged` but ignored it since
  `b739a5bd9d9f`; cancel can leave a DS write incomplete with no write
  layout.
- Saved mbox: cover + 1/3 + 2/3 + 3/3 only; **no NAK, no extra review
  mail in that match**.
- Trond’s `nfs-for-7.3-1` pull listed it as *“Avoid cancelling in-flight
  I/O during a layout recall if the server doesn't require it”* under
  **Other bugfixes** (not the Cc:stable subset). That is tagging, not a
  NAK.

**Step 4.2: CHECK WHO REVIEWED THE PATCH**

Record (`b4 dig -w`): To/Cc Trond Myklebust, Anna Schumaker, `linux-
nfs@vger.kernel.org`. Maintainer SOB on the commit.

**Step 4.3: SEARCH FOR THE BUG REPORT**

Record: No syzbot/bugzilla. Vendor/protocol analysis (Hammerspace), not
a crash repro.

**Step 4.4: CHECK FOR RELATED PATCHES AND SERIES**

Record: 1/3 observability, 3/3 error reporting when cancel still
happens. Neither is a functional prerequisite. Follow-ups on `pnfs.c`
after this SHA (`2035820177749` EBUSY, `ee5a386cfe60f` lseg leak) are
independent.

**Step 4.5: CHECK STABLE MAILING LIST HISTORY**

Record: **UNVERIFIED** — `lore.kernel.org/stable/?q=clora_changed`
returned 403. No evidence this was rejected for stable.

---

## PHASE 5: CODE SEMANTIC ANALYSIS

**Step 5.1: KEY FUNCTIONS**

Record: listed in 2.1. Behavioral change is
**`pnfs_mark_matching_lsegs_return` + `initiate_file_draining`**.

**Step 5.2: TRACE CALLERS**

Record:
- File recall: `nfs4_callback_layoutrecall` → `do_callback_layoutrecall`
  → `initiate_file_draining` (MDS CB_LAYOUTRECALL, RETURN_FILE).
- Only flexfiles implements `cancel_io` (`ff_layout_cancel_io` →
  `rpc_cancel_tasks` / `rpc_clnt_disconnect`). Other layout types: no-op
  today.
- Remaining callers keep `cancel_io=true` (return/teardown/failure/new
  stateid).

**Step 5.3: TRACE CALLEES**

Record: `pnfs_match_lseg_recall`, `mark_lseg_invalid`,
`pnfs_lseg_cancel_io` → layout-driver `cancel_io`. Flexfiles cancels
matching RPCs with `-EAGAIN` and disconnects the DS client.

**Step 5.4: FOLLOW THE CALL CHAIN**

Record: Reachable in production: MDS sends CB_LAYOUTRECALL while the
client has DS writes in flight. Common for pNFS flexfiles (layout recall
on close, space management, etc.). Not a rare debug path. Unprivileged
write traffic plus server recall.

**Step 5.5: SEARCH FOR SIMILAR PATTERNS**

Record: Second cancel site in `pnfs_mark_matching_lsegs_invalid()` is
left unconditional (correct for invalidate/revoke). `cbl_layoutchanged`
is stored but otherwise unused in this tree — this patch is the first
user for I/O policy.

---

## PHASE 6: CROSS-REFERENCING AGAINST THE LOCAL TREE

**Step 6.1: DOES THE BUGGY CODE EXIST IN THIS TREE?**

Record: **Yes.** `pending-6.12` / **6.12.111**. `pnfs_lseg_cancel_io()`
is unconditional in `pnfs_mark_matching_lsegs_return()`.
`cbl_layoutchanged` is decoded. `git merge-base --is-ancestor
aceaa5991bdf7 HEAD` → **not an ancestor**. Bug since **v6.1-rc1**.

**Step 6.2: CHECK FOR BACKPORT COMPLICATIONS**

Record: `git show aceaa5991bdf7 | git apply --check` **succeeded** (hunk
offsets only). **Clean apply.** All current callers are updated by the
patch.

**Step 6.3: CHECK IF RELATED FIXES ARE ALREADY HERE**

Record: No `honor clora_changed` commit. No alternate fix. 6.12 already
has later unrelated pNFS fixes (`2ef79f5aa107a` EBUSY, `7c5b0e813efd9`
lseg leak).

---

## PHASE 7: SUBSYSTEM AND MAINTAINER CONTEXT

**Step 7.1: SUBSYSTEM AND CRITICALITY**

Record: **fs/nfs pNFS client**. **IMPORTANT** for NFSv4.1 pNFS
(especially flexfiles). `PNFS_FLEXFILE_LAYOUT` **defaults to `NFS_V4`**.
Not core mm/VFS, but production clustered NFS.

**Step 7.2: SUBSYSTEM ACTIVITY**

Record: Actively maintained; this is a targeted fix in mature recall
code, not churn in new code.

---

## PHASE 8: IMPACT AND RISK ASSESSMENT

**Step 8.1: WHO IS AFFECTED**

Record: **Config/driver-specific:** NFSv4.1 pNFS flexfiles clients under
CB_LAYOUTRECALL with in-flight DS writes. Enterprise/scale-out NFS (e.g.
Hammerspace). Filesystems/block/files layouts without `cancel_io` are
unchanged.

**Step 8.2: TRIGGER CONDITIONS**

Record: Server file layout recall with `clora_changed=FALSE` while DS
writes are in flight. Common operational recall, not only device
failure. Userspace writes plus MDS callback; timing-dependent.

**Step 8.3: FAILURE MODE SEVERITY**

Record: **Write-after-LAYOUTRETURN / write with no layout** → protocol
violation, possible rejected/unaccounted DS write, MDS/DS inconsistency.
Cover letter: incomplete DS write with no write layout. **Severity:
HIGH** (data integrity), not a panic.

**Step 8.4: RISK-BENEFIT RATIO**

Record:
- **Benefit: high** for pNFS flexfiles — stops abandoning in-flight
  writes on unchanged recalls.
- **Risk: low** — ~16 lines, one gated call, other paths unchanged, RFC-
  aligned, maintainer-acked, applies cleanly.
- **Ratio: favorable.**

---

## PHASE 9: FINAL SYNTHESIS

**Step 9.1: COMPILE THE EVIDENCE**

**FOR:**
- Real protocol/data-integrity bug in this 6.12 tree
- Introduced v6.1, still present
- Small, obviously correct, RFC 8881 §20.3.3
- Maintainer SOB; described as a bugfix in nfs-for-7.3-1
- Clean apply; no prerequisites
- Flexfiles enabled by default with NFS v4

**AGAINST:**
- No crash/syzbot; pNFS-specific
- Series 2/3 (siblings not required)
- Not in the pull’s “Stable fixes” list (no Cc: stable)
- Unchanged recalls return the layout more slowly if DS I/O is stuck
  (intended)

**UNRESOLVED:** Stable-list archives (HTTP 403); no public review
replies beyond v1→v2.

**Step 9.2: STABLE RULES CHECKLIST**

1. Obviously correct and tested? **PASS** — RFC behavior, maintainer
   SOB, mainline
2. Real bug affecting users? **PASS** — writes after LAYOUTRETURN on
   flexfiles
3. Important (crash/security/corruption/deadlock)? **PASS** —
   data/protocol integrity (HIGH)
4. Small and contained? **PASS** — +16/−11, three NFS files
5. No new features/APIs? **PASS** — uses existing decoded flag
6. Can apply to this tree? **PASS** — `git apply --check` clean

**Step 9.3: EXCEPTION CATEGORIES**

Record: None (not a device ID/quirk/DT/build/doc-only patch). Qualifies
as a normal important bugfix.

**Step 9.4: DECISION**

Backport to this 6.12 tree. The cancel-always path is here; the fix is
small and restores RFC drain-before-return for unchanged recalls, which
otherwise can complete DS writes after LAYOUTRETURN.

---

### What the commit solves for 6.12 users

On pNFS flexfiles, every layout recall currently cancels in-flight DS
I/O (`ff_layout_cancel_io`). For `clora_changed=FALSE` that is wrong:
those writes may already be on the DS and then finish after
LAYOUTRETURN, which the server treats as I/O without a layout. The patch
only stops cancelling in that recall case and lets the existing deferred
LAYOUTRETURN wait for I/O to drain.

### Risk vs benefit

Benefit is data/protocol correctness for a default NFSv4.1 layout type.
Risk is low: teardown still cancels; only the already-decoded recall
flag changes the file-recall path; the patch applies without rework.

---

### Verification

- **[Phase 1]** Parsed tags: two SOBs (Coddington, Myklebust); no
  Fixes/Cc:stable; mainline `aceaa5991bdf7`
- **[Phase 2]** Diff: 16 insertions / 11 deletions; cancel gated; recall
  passes `cbl_layoutchanged`; other callers pass `true`
- **[Phase 3]** Blame: cancel line from `b739a5bd9d9f` (`v6.1-rc1`);
  ancestor of HEAD
- **[Phase 3]** `git merge-base --is-ancestor aceaa5991bdf7 HEAD` → not
  in this tree
- **[Phase 4]** `b4 dig -c aceaa5991bdf7`: v2 2/3, msgid above; v1→v2
  (Anna: kerneldoc/FILE_INODE)
- **[Phase 4]** `b4 dig -w`: Trond, Anna, linux-nfs
- **[Phase 4]** `b4 dig -m`: series only, no NAK
- **[Phase 4]** Trond pull nfs-for-7.3-1 lists this under Other bugfixes
- **[Phase 5]** Call chain: CB_LAYOUTRECALL → `initiate_file_draining`;
  cancel only implemented in flexfiles
- **[Phase 5]** `cbl_layoutchanged` decoded in `callback_xdr.c`, unused
  for I/O policy in this tree
- **[Phase 6]** `git describe HEAD`: `p-6.12-3-gc504cf0baa3d8`; `make
  kernelversion`: 6.12.111
- **[Phase 6]** `git apply --check` of `aceaa5991bdf7`: success
- **[Phase 6]** 1/3 and 3/3 not required
- **[Phase 7]** `PNFS_FLEXFILE_LAYOUT` default `NFS_V4`
- **[Phase 8]** Failure: write without layout / incomplete DS write;
  HIGH integrity, not panic
- **UNVERIFIED:** lore.kernel.org/stable search (403)

**YES**

 fs/nfs/callback_proc.c |  3 ++-
 fs/nfs/pnfs.c          | 22 +++++++++++++---------
 fs/nfs/pnfs.h          |  2 +-
 3 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 4f41986b875e8..72c25b8864fe5 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -288,7 +288,8 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	pnfs_set_layout_stateid(lo, &args->cbl_stateid, NULL, true);
 	switch (pnfs_mark_matching_lsegs_return(lo, &free_me_list,
 				&args->cbl_range,
-				be32_to_cpu(args->cbl_stateid.seqid))) {
+				be32_to_cpu(args->cbl_stateid.seqid),
+				args->cbl_layoutchanged)) {
 	case 0:
 	case -EBUSY:
 		/* There are layout segments that need to be returned */
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cf0dcf9e35d75..e2c723e21cb72 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -432,7 +432,8 @@ bool nfs4_layout_refresh_old_stateid(nfs4_stateid *dst,
 			goto out;
 		}
 		/* Try to update the seqid to the most recent */
-		err = pnfs_mark_matching_lsegs_return(lo, &head, &range, 0);
+		err = pnfs_mark_matching_lsegs_return(lo, &head, &range, 0,
+						      true);
 		if (err != -EBUSY) {
 			dst->seqid = lo->plh_stateid.seqid;
 			*dst_range = range;
@@ -486,7 +487,7 @@ static int pnfs_mark_layout_stateid_return(struct pnfs_layout_hdr *lo,
 		.length = NFS4_MAX_UINT64,
 	};
 
-	return pnfs_mark_matching_lsegs_return(lo, lseg_list, &range, seq);
+	return pnfs_mark_matching_lsegs_return(lo, lseg_list, &range, seq, true);
 }
 
 static int
@@ -524,7 +525,7 @@ pnfs_layout_io_set_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 
 	spin_lock(&inode->i_lock);
 	pnfs_layout_set_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
-	pnfs_mark_matching_lsegs_return(lo, &head, &range, 0);
+	pnfs_mark_matching_lsegs_return(lo, &head, &range, 0, true);
 	spin_unlock(&inode->i_lock);
 	pnfs_free_lseg_list(&head);
 	dprintk("%s Setting layout IOMODE_%s fail bit\n", __func__,
@@ -1461,7 +1462,7 @@ _pnfs_return_layout(struct inode *ino)
 	}
 	valid_layout = pnfs_layout_is_valid(lo);
 	pnfs_clear_layoutcommit(ino, &tmp_list);
-	pnfs_mark_matching_lsegs_return(lo, &tmp_list, &range, 0);
+	pnfs_mark_matching_lsegs_return(lo, &tmp_list, &range, 0, true);
 
 
 	/* Don't send a LAYOUTRETURN if list was initially empty */
@@ -2603,7 +2604,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 			.iomode = IOMODE_ANY,
 			.length = NFS4_MAX_UINT64,
 		};
-		pnfs_mark_matching_lsegs_return(lo, &free_me, &range, 0);
+		pnfs_mark_matching_lsegs_return(lo, &free_me, &range, 0, true);
 		goto out_forget;
 	} else {
 		/* We have a completely new layout */
@@ -2635,6 +2636,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
  * @tmp_list: list header to be used with pnfs_free_lseg_list()
  * @return_range: describe layout segment ranges to be returned
  * @seq: stateid seqid to match
+ * @cancel_io: signal io be cancelled
  *
  * This function is mainly intended for use by layoutrecall. It attempts
  * to free the layout segment immediately, or else to mark it for return
@@ -2649,7 +2651,7 @@ int
 pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				const struct pnfs_layout_range *return_range,
-				u32 seq)
+				u32 seq, bool cancel_io)
 {
 	struct pnfs_layout_segment *lseg, *next;
 	struct nfs_server *server = NFS_SERVER(lo->plh_inode);
@@ -2675,7 +2677,8 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				continue;
 			remaining++;
 			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
-			pnfs_lseg_cancel_io(server, lseg);
+			if (cancel_io)
+				pnfs_lseg_cancel_io(server, lseg);
 		}
 
 	if (remaining) {
@@ -2710,7 +2713,8 @@ pnfs_mark_layout_for_return(struct inode *inode,
 	 * segments at hand when sending layoutreturn. See pnfs_put_lseg()
 	 * for how it works.
 	 */
-	if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs, range, 0) != -EBUSY) {
+	if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs, range, 0,
+					    true) != -EBUSY) {
 		const struct cred *cred;
 		nfs4_stateid stateid;
 		enum pnfs_iomode iomode;
@@ -2825,7 +2829,7 @@ static int pnfs_layout_return_unused_byserver(struct nfs_server *server,
 		pnfs_get_layout_hdr(lo);
 		pnfs_set_plh_return_info(lo, range->iomode, 0);
 		if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs,
-						    range, 0) != 0 ||
+						    range, 0, true) != 0 ||
 		    !pnfs_prepare_layoutreturn(lo, &stateid, &cred, &iomode)) {
 			spin_unlock(&inode->i_lock);
 			rcu_read_unlock();
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7b3ba2e64e6f3..14d2a91250f24 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -301,7 +301,7 @@ int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 int pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				const struct pnfs_layout_range *recall_range,
-				u32 seq);
+				u32 seq, bool cancel_io);
 int pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 		struct list_head *lseg_list);
 bool pnfs_roc(struct inode *ino, struct nfs4_layoutreturn_args *args,
-- 
2.53.0

