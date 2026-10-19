Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 28FE34F183A;
	Mon, 19 Oct 2026 13:59:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792418359; cv=none; b=he7KzJjgFELYExnm83b6TMeCsyDib0t3bCwUANgNI5gcesTIp8/tqidSpnY1B4kBqRs+/QdWTRZrkRFLSnBw/VaOMy89RDtsgTJk1mXB1CTBjQgjhjoGIxz4+eSkqoMhztXQJwUCkXcxymTSvfvRz0pVF8VDP24AciMEb82CTX0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792418359; c=relaxed/simple;
	bh=sIaMVIx2/CeVjggQmKtFTDO92nOiBGIHRXKql9+UEas=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=hnIFhKTEeDr8uBfjUtsQNVPAYrNIrCiMKM19RxQokcYWYlySY1qxXPYmGmhUimTKiPlvnVD4Ehj82tlX93cw8j+fw2SubPe3RaULQfxi49J6ocVkL8zHs8vAegF+OfAfd13O5EmYt1yijhUXl2HtCvrsrqPw4VKVFaAbZptvptI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cd4Rr39g; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cd4Rr39g"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0307A1F000C4;
	Mon, 19 Oct 2026 13:59:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792418356;
	bh=ichSf4TdWpTOdRexvrIgI0skTn5DtcC0xaCxkjGpiiU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=cd4Rr39gN6SkDIvkhPPd7aMLEL6GR+pNTQV8dVQglCqd7QorYwfshKgmcMut3lqNE
	 dp7vTUjbYYoVkg8pgq/oyZZm9qrukKT5YQmYGC2d2TWIkpM/gWQ9ZfjDgkZxHIT1W4
	 0jLNzo2MeGxo+HdGMavyFgLHPFquByj7SpV3Nu7Cv8aRLRjywtSeLLLBVjduRiL+ie
	 CxoY5+xR3Ay5cwWAxaPcc5FVa5JaKZM7Q5BBMENPqAm6254oA2vYXF4DzHbuALsKva
	 T5gTBBFnMtXZHm70yvqKyZlS0H/1rkpEh4+28nfz/BzU3xpX5mgOgxtZVIF3azHPoR
	 5PfYrr1uPhzzg==
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
Subject: [PATCH AUTOSEL 6.18] NFSv4/flexfiles: report cancelled I/O as a layout error
Date: Mon, 19 Oct 2026 09:48:00 -0400
Message-ID: <20261019135441.1420968-189-sashal@kernel.org>
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

[ Upstream commit 4a013b0e881e0466cc2c6a5518d2f6cda3a4f19f ]

When a layout is recalled or revoked the client cancels its in-flight I/O
so the layout can be returned.  The metadata server needs to learn that
this I/O to the storage device did not complete, so that it can reconcile
the affected mirror instance (or, if none remains, take other action).

The cancellation completed with -EAGAIN, which ff_layout_io_track_ds_error()
does not recognise: it fell through the switch and recorded nothing, so no
error was reported to the server.

-EAGAIN is overloaded in the RPC layer, so rather than key the reporting on
it, cancel the I/O with -ECANCELED and map that to NFS4ERR_NXIO in
ff_layout_io_track_ds_error() -- the status the client already reports for
the transport errors that leave an in-flight write incomplete.  The
cancelled I/O is then reported to the server via LAYOUTERROR / LAYOUTRETURN.

Unlike a genuine transport error, though, we aborted the I/O ourselves and
have no evidence the device is at fault, so once the error is recorded we
skip marking the device unreachable and forcing a further layout return.

The retry disposition is unchanged from the original -EAGAIN cancellation:
both NFS4ERR_NXIO and -ECANCELED are no-ops in ff_layout_async_handle_error(),
which still resets the I/O to pNFS (or the MDS), so it is re-driven as before.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---

LLM Generated explanations, may be completely bogus:

The local tree is **6.12.111** (`pending-6.12`). The buggy cancel path
is present here; the candidate is not.

===============================================================
PHASE 1: COMMIT MESSAGE FORENSICS
===============================================================

**Step 1.1: PARSE THE SUBJECT LINE**
Record: `[NFSv4/flexfiles] [report] report cancelled I/O as a layout
error`

**Step 1.2: PARSE ALL COMMIT MESSAGE TAGS**
Record:
- Signed-off-by: Benjamin Coddington `<bcodding@hammerspace.com>`
  (author)
- Signed-off-by: Trond Myklebust `<trond.myklebust@hammerspace.com>`
  (NFS maintainer)
- No Fixes:, Reported-by:, Tested-by:, Reviewed-by:, Acked-by:, Link:,
  or Cc: stable (absence expected)
- Author in git: Benjamin Coddington `<ben.coddington@hammerspace.com>`
- Upstream SHA (on `all-next`, not in this tree):
  `4a013b0e881e0466cc2c6a5518d2f6cda3a4f19f` (2026-06-25)

**Step 1.3: ANALYZE THE COMMIT BODY TEXT**
Record:
- Bug: on layout recall/revoke the client cancels in-flight DS I/O so
  the layout can be returned. Cancellation used `-EAGAIN`, which
  `ff_layout_io_track_ds_error()` does not recognize, so it records
  nothing and the MDS never learns the I/O did not complete.
- Symptom: MDS cannot reconcile the affected flexfiles mirror (or take
  other action if no instance remains). Incomplete writes can sit on a
  DS with no write layout held.
- Root cause: `-EAGAIN` is overloaded in the RPC layer and is not in the
  tracked-error switch (default: return).
- Fix: cancel with `-ECANCELED`, map that to `NFS4ERR_NXIO` (same status
  already used for transport errors that leave a write incomplete),
  report via LAYOUTERROR / LAYOUTRETURN, but skip marking the device
  unreachable and skip forcing another layout return.
- Retry path: unchanged; both `NFS4ERR_NXIO` and `-ECANCELED` fall
  through `ff_layout_async_handle_error()` to RESET_TO_PNFS /
  RESET_TO_MDS.

**Step 1.4: DETECT HIDDEN BUG FIXES**
Record: Not disguised. This is an explicit protocol/correctness fix:
cancelled I/O was silently dropped instead of being reported to the MDS.

===============================================================
PHASE 2: DIFF ANALYSIS - LINE BY LINE
===============================================================

**Step 2.1: INVENTORY THE CHANGES**
Record:
- File: `fs/nfs/flexfilelayout/flexfilelayout.c` (+22 / -1)
- Functions: `ff_layout_io_track_ds_error()`, `ff_layout_cancel_io()`
- Scope: single-file surgical fix

**Step 2.2: UNDERSTAND THE CODE FLOW CHANGE**
Record:
- Hunk 1 (switch): `-ECANCELED` now maps to `NFS4ERR_NXIO` and continues
  into `ff_layout_track_ds_error()` instead of hitting `default:
  return`.
- Hunk 2: after recording the error, `if (error == -ECANCELED) goto
  out;` skips `ff_layout_mark_ds_unreachable()` and
  `pnfs_error_mark_layout_for_return()`.
- Hunk 3: `rpc_cancel_tasks(clnt, -EAGAIN, ...)` becomes
  `rpc_cancel_tasks(clnt, -ECANCELED, ...)`.
- Prepare paths (`ff_layout_*_prepare_common`) still `rpc_exit(task,
  -EAGAIN)` for invalid lsegs. That is I/O that was never sent; it is
  correctly left alone.

**Step 2.3: IDENTIFY THE BUG MECHANISM**
Record:
- Category: logic / protocol correctness (missing error reporting), with
  data-integrity impact on flexfiles mirrors.
- Mechanism: cancelled in-flight RPC completed with an unrecognized
  errno, so no `nfs4_ff_layout_ds_err` was queued and LAYOUTERROR /
  LAYOUTRETURN carried no I/O error.

**Step 2.4: ASSESS THE FIX QUALITY**
Record:
- Obviously correct: use a dedicated errno, record it as the same NXIO
  the client already reports for incomplete writes, and do not condemn
  the device for a client-initiated abort.
- Minimal; no API or structural change.
- Regression risk: low. `nfs_pgio_result()` treats any non-zero
  `rw_done()` return the same, so `-ECANCELED` vs `-EAGAIN` does not
  change the resend path. Verified in
  `ff_layout_async_handle_error_v4()`: `NFS4ERR_NXIO` is a no-op in the
  op_status switch; `-ECANCELED` is not a connection error, then
  RESET_TO_PNFS/MDS. v3 already deleted the deviceid on `-EAGAIN`
  (default) and still does so on `-ECANCELED`.

===============================================================
PHASE 3: GIT HISTORY INVESTIGATION
===============================================================

**Step 3.1: BLAME THE CHANGED LINES**
Record:
- Error switch introduced in `dd52128afdde` (Trond, 2015-08-20) — never
  handled `-EAGAIN`.
- `ff_layout_cancel_io()` and the `-EAGAIN` cancel introduced in
  `b739a5bd9d9f18` ("NFSv4/flexfiles: Cancel I/O if the layout is
  recalled or revoked", 2022-10-05, first in v6.1-rc1).
- That cancel commit is an ancestor of HEAD.

**Step 3.2: FOLLOW THE FIXES: TAG**
Record: No Fixes: tag. The introducing commit is `b739a5bd9d9f18`,
present in this tree.

**Step 3.3: CHECK FILE HISTORY FOR RELATED CHANGES**
Record:
- Same pattern already in this tree: `1630224189cc4` (ENETDOWN),
  `dd7d7ee3ba2a7` (EINVAL), `7836d75467e9d` (RDMA) — all add cases to
  this switch so the MDS is told.
- This commit is patch 3/3 of "pNFS/flexfiles: honor clora_changed and
  report cancelled I/O".
- Patch 2 (`aceaa5991bdf7` "honor clora_changed when recalling a
  layout") is **not** in this tree. It only changes *when* cancel runs
  (skip cancel if `clora_changed` is false). This commit does not call
  any new helper from patch 2.

**Step 3.4: CHECK THE AUTHOR'S OTHER COMMITS**
Record: Benjamin Coddington (Hammerspace) is a regular NFS/pNFS
contributor. Trond (NFS maintainer, also Hammerspace) applied it.

**Step 3.5: CHECK FOR DEPENDENT/PREREQUISITE COMMITS**
Record:
- Semantic fix is standalone: change the cancel errno and handle it in
  the existing switch.
- Clean apply is **not** standalone against this tree. Mainline added
  `dss_id` via later striped-layout commits (`8a8e0f5566edc`,
  `a1491919c8805`, `20b1d75fb840c`, …). Those are **not** in HEAD. This
  tree only has `d1830d0740d72` (data-structure support) and still uses
  `mirror->dss[0]` / no `dss_id` argument.
- `git apply --check` of the mainline diff: hunk 1 applied (offset
  -177); hunk 2 failed on the `dss_id` argument. A 6.12 backport is a
  small context edit, not a rewrite.

===============================================================
PHASE 4: MAILING LIST AND EXTERNAL RESEARCH
===============================================================

**Step 4.1: FIND THE ORIGINAL PATCH DISCUSSION**
Record:
- `b4 dig -c 4a013b0e881e0` → https://patch.msgid.link/b5ed2050a2fa573ad
  9a2bcf7769f23397e480f2a.1782388900.git.bcodding@hammerspace.com
- Series: v1 (2026-06-24) then v2 (2026-06-25). Applied version is v2
  3/3.
- Cover letter: RFC 8881 §20.3.3; since `b739a5bd9d9f` the client
  cancels DS I/O on every recall; when it *does* cancel (changed recall
  or revoke), report `NFS4ERR_NXIO` so the MDS can reconcile.
- v2 changes were only for patches 1–2 (Anna: kerneldoc, `FILE_INODE` /
  `inode->i_ino`). Patch 3 was unchanged.

**Step 4.2: CHECK WHO REVIEWED THE PATCH**
Record:
- Recipients: Trond Myklebust, Anna Schumaker, linux-nfs@vger.kernel.org
- Anna reviewed v1 1/3 and 2/3 only (tracepoint inode id; kerneldoc for
  `cancel_io`). No NAK. No comments on 3/3.
- Trond applied the series (Signed-off-by).
- No reviewer Cc: stable.

**Step 4.3: SEARCH FOR THE BUG REPORT**
Record: No syzbot, bugzilla, or external user report. The description is
a vendor/protocol failure (Hammerspace flexfiles MDS cannot reconcile
after cancel). WebFetch to lore returned 403; discussion was recovered
via `b4 dig -m`.

**Step 4.4: CHECK FOR RELATED PATCHES AND SERIES**
Record:
- 1/3: tracepoint only — not required for this fix.
- 2/3: stop cancelling on unchanged recalls — complementary RFC
  behavior, not a compile/runtime dependency of 3/3. Without it, 6.12
  still cancels on every recall, so this fix would send NXIO on more
  recalls than post-series mainline. That is more conservative for the
  MDS (reconcile), not a crash path.
- Other cancel callers (`pnfs_mark_matching_lsegs_invalid`,
  teardown/return with cancel) remain even after 2/3.

**Step 4.5: CHECK STABLE MAILING LIST HISTORY**
Record: No stable-list discussion found (lore.kernel.org/stable search
via WebFetch was 403). UNVERIFIED: whether anyone already requested or
rejected this for stable.

===============================================================
PHASE 5: CODE SEMANTIC ANALYSIS
===============================================================

**Step 5.1: IDENTIFY KEY FUNCTIONS IN THE DIFF**
Record: `ff_layout_io_track_ds_error()`, `ff_layout_cancel_io()`.

**Step 5.2: TRACE CALLERS**
Record:
- `ff_layout_io_track_ds_error()`: `ff_layout_read_done_cb()`,
  `ff_layout_write_done_cb()`, `ff_layout_commit_done_cb()` — DS I/O
  completion.
- `ff_layout_cancel_io()`: registered as
  `pnfs_layoutdriver_type.cancel_io`.
- `pnfs_lseg_cancel_io()` → `pnfs_mark_matching_lsegs_invalid()` (line
  744) and `pnfs_mark_matching_lsegs_return()` (line 2678).
- Those run on CB_LAYOUTRECALL, layout return, revoke, and teardown.

**Step 5.3: TRACE CALLEES**
Record: `ff_layout_track_ds_error()` queues `nfs4_ff_layout_ds_err`;
`ff_layout_send_layouterror()` / `ff_layout_encode_ioerr()` send
LAYOUTERROR / LAYOUTRETURN. `rpc_cancel_tasks()` →
`rpc_task_try_cancel()`.

**Step 5.4: FOLLOW THE CALL CHAIN**
Record: Reachable from normal pNFS flexfiles file I/O plus MDS
CB_LAYOUTRECALL. Not a raw syscall crash path; it is a common path for
any flexfiles mount under layout recall/return.

**Step 5.5: SEARCH FOR SIMILAR PATTERNS**
Record: Same switch already maps transport failures to `NFS4ERR_NXIO`.
This is the same class of fix, for a client-initiated cancel that
previously fell on the floor.

===============================================================
PHASE 6: CROSS-REFERENCING AGAINST THE LOCAL TREE
===============================================================

**Step 6.1: DOES THE BUGGY CODE EXIST IN THIS TREE?**
Record: Yes.
- Tree: `p-6.12-3-gc504cf0baa3d8`, `VERSION=6 PATCHLEVEL=12
  SUBLEVEL=111`.
- `git merge-base --is-ancestor 4a013b0e881e0 HEAD` → not an ancestor
  (fix not present).
- `ff_layout_cancel_io()` still uses `-EAGAIN` (line 2196).
- `ff_layout_io_track_ds_error()` has no `-ECANCELED` case; default
  returns without recording (lines 1369–1370).
- Bug introduced in v6.1 (`b739a5bd9d9f18`); present for the whole 6.12
  lifetime.

**Step 6.2: CHECK FOR BACKPORT COMPLICATIONS**
Record: Minor conflicts. Need to drop `dss_id` from
`ff_layout_track_ds_error()` / `ff_layout_mark_ds_unreachable()` and
keep the single `dss[0]` cancel loop. Not a semantic rewrite.

**Step 6.3: CHECK IF RELATED FIXES ARE ALREADY HERE**
Record: No equivalent cancel-reporting fix. Related NXIO mappings
(ENETDOWN, EINVAL, EPROTO/ENODEV) are already here and do not cover
cancel.

===============================================================
PHASE 7: SUBSYSTEM AND MAINTAINER CONTEXT
===============================================================

**Step 7.1: IDENTIFY THE SUBSYSTEM AND ITS CRITICALITY**
Record: `fs/nfs/flexfilelayout` — NFSv4.1 pNFS flexfiles client.
**IMPORTANT** (not core VFS; production for flexfiles MDS deployments).
`CONFIG_PNFS_FLEXFILE_LAYOUT` defaults to `NFS_V4`.

**Step 7.2: ASSESS SUBSYSTEM ACTIVITY**
Record: Active. Recent 6.12 backports include NO_IO_THRU_MDS, zero-FH
rejection, NFS-level error handling, ENETDOWN reporting.

===============================================================
PHASE 8: IMPACT AND RISK ASSESSMENT
===============================================================

**Step 8.1: DETERMINE WHO IS AFFECTED**
Record: Flexfiles pNFS clients (`CONFIG_PNFS_FLEXFILE_LAYOUT`). Not
universal; real production users (Hammerspace and other flexfiles MDS).

**Step 8.2: DETERMINE THE TRIGGER CONDITIONS**
Record: Layout recall, revoke, or return while DS read/write/commit RPCs
are in flight. Common on flexfiles (recall on close, lease recovery,
restriping). Not an unprivileged local exploit; it is a networked MDS
callback plus in-flight I/O.

**Step 8.3: DETERMINE THE FAILURE MODE SEVERITY**
Record: MDS is not told that in-flight writes did not complete, so it
may not reconcile a mirror. Later reads can see a stale or incomplete
replica. **HIGH** (data integrity / stale data), not a kernel oops.

**Step 8.4: CALCULATE RISK-BENEFIT RATIO**
Record:
- Benefit: HIGH for flexfiles — MDS can reconcile after cancel/revoke.
- Risk: LOW — +22 lines, contained, retry path unchanged. Extra NXIO
  reports on 6.12’s still-unconditional cancel are conservative, not a
  hang/crash.
- Ratio: benefit outweighs risk.

===============================================================
PHASE 9: FINAL SYNTHESIS
===============================================================

**Step 9.1: COMPILE THE EVIDENCE**

FOR:
- Real bug: cancelled DS I/O is invisible to the MDS.
- Data-integrity impact on flexfiles mirrors.
- Code is in this 6.12 tree since v6.1.
- Small, obviously correct, maintainer-applied.
- Same reporting pattern already backported here (ENETDOWN, EINVAL,
  RDMA).
- Retry disposition verified unchanged.

AGAINST:
- Patch 3/3 of a series; 2/3 (narrower cancel) is not here.
- Mainline diff needs a small `dss_id`-free backport.
- No crash/UAF/CVE; flexfiles-specific.
- No Fixes:/Cc: stable/user report (expected for this queue).

UNRESOLVED:
- Stable-list history (lore/stable WebFetch 403).
- How every flexfiles MDS implementation reacts to extra NXIO on
  unchanged recalls (without patch 2). Conservative, not a kernel
  regression.

**Step 9.2: APPLY THE STABLE RULES CHECKLIST**
1. Obviously correct and tested? **PASS** — mapped like existing
   transport errors; applied by the NFS maintainer.
2. Fixes a real bug that affects users? **PASS** — MDS cannot reconcile
   after cancel.
3. Important issue? **PASS** — data integrity / stale flexfiles mirrors
   (HIGH, not oops).
4. Small and contained? **PASS** — +22/-1, one file.
5. No new features or APIs? **PASS**
6. Can apply to the local tree? **PASS** — needs a trivial context
   backport (no `dss_id`); buggy code is here.

**Step 9.3: CHECK FOR EXCEPTION CATEGORIES**
Record: None (not a device ID, quirk, DT, build, or docs fix). Qualifies
as a normal important bugfix.

**Step 9.4: MAKE YOUR DECISION**
This should be backported to this 6.12 tree. The cancel path exists, the
MDS is not told, and the fix is small. Adapt the hunks to the `dss[0]` /
no-`dss_id` signatures; do not pull the striped-layout series.

What it solves for stable users: after layout recall/revoke, in-flight
flexfiles I/O is cancelled so the layout can return, but 6.12 records
nothing. The MDS then cannot reconcile the mirror. Mapping cancel to
`NFS4ERR_NXIO` and sending LAYOUTERROR / LAYOUTRETURN closes that hole
without marking the device dead or changing retry.

Risk vs benefit: low risk, high benefit on flexfiles. Companion patch 2
(honor `clora_changed`) is a separate RFC behavior change and is not
required for this reporting fix to work.

Verification:
- [Phase 1] Tags: only author + Trond SOBs; no Fixes/Reported-by/Cc
  stable
- [Phase 1] Upstream SHA `4a013b0e881e0` on all-next; `git merge-base
  --is-ancestor` → not in HEAD
- [Phase 2] Diff: +22/-1 in one file; `-EAGAIN` → `-ECANCELED`; new NXIO
  case; skip unreachable/return
- [Phase 2] `NFS4ERR_NXIO` and `NFSERR_NXIO` both equal 6
- [Phase 2] `nfs_pgio_result()`: non-zero `rw_done()` skips
  `nfs_set_pgio_error` for both errnos
- [Phase 2] v4/v3 async handlers: retry disposition matches the commit
  text
- [Phase 3] Blame: switch from `dd52128afdde` (2015); cancel from
  `b739a5bd9d9f18` (v6.1), ancestor of HEAD
- [Phase 3] Similar backports already here: `1630224189cc4`,
  `dd7d7ee3ba2a7`, `7836d75467e9d`
- [Phase 3] Patch 2 `aceaa5991bdf7` is not an ancestor of HEAD
- [Phase 4] `b4 dig -c 4a013b0e881e0`: v2 3/3 at the msgid.link above
- [Phase 4] `b4 dig -a`: v1 then v2; 3/3 unchanged
- [Phase 4] `b4 dig -w`: Trond, Anna, linux-nfs
- [Phase 4] Anna v1 review: nits on 1/3 and 2/3 only; no NAK of 3/3
- [Phase 4] Cover letter recovered from `/tmp/ff-cancel-thread.mbox`
- [Phase 5] Callers: read/write/commit done_cb; cancel via
  `pnfs_lseg_cancel_io` from recall/return/invalidate
- [Phase 6] `git describe HEAD` → `p-6.12-3-gc504cf0baa3d8`; `make
  kernelversion` → 6.12.111
- [Phase 6] Local cancel still `-EAGAIN` at flexfilelayout.c:2196; no
  `-ECANCELED` in `fs/nfs`
- [Phase 6] `git apply --check` failed on `dss_id` hunk; striped error-
  path commits not in HEAD
- [Phase 8] Failure mode: unreported incomplete DS I/O →
  unreconciliation / stale mirror, HIGH
- UNVERIFIED: stable@ discussion (lore 403)

**YES**

 fs/nfs/flexfilelayout/flexfilelayout.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 8099bfc4fe2f8..c708724bb53f2 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1546,6 +1546,17 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 		case -EACCES:
 			*op_status = status = NFS4ERR_ACCESS;
 			break;
+		case -ECANCELED:
+			/*
+			 * In-flight I/O we cancelled to return a recalled or
+			 * revoked layout.  Report it as a failure to reach the
+			 * device (NFS4ERR_NXIO), like the transport errors
+			 * above, so the server can reconcile the affected mirror
+			 * instance.  We aborted the I/O ourselves rather than
+			 * observe the device fail, so don't condemn it below.
+			 */
+			*op_status = status = NFS4ERR_NXIO;
+			break;
 		default:
 			return;
 		}
@@ -1556,6 +1567,15 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 				       mirror, dss_id, offset, length, status, opnum,
 				       nfs_io_gfp_mask());
 
+	/*
+	 * I/O we cancelled ourselves to return a recalled or revoked layout
+	 * is reported above so the server can reconcile the mirror, but we
+	 * have no evidence the device is at fault: don't mark it unreachable
+	 * or force a return.
+	 */
+	if (error == -ECANCELED)
+		goto out;
+
 	switch (status) {
 	case NFS4ERR_DELAY:
 	case NFS4ERR_GRACE:
@@ -1575,6 +1595,7 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 						  lseg);
 	}
 
+out:
 	dprintk("%s: err %d op %d status %u\n", __func__, err, opnum, status);
 }
 
@@ -2465,7 +2486,7 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
 			clnt = ds_clp->cl_rpcclient;
 			if (!clnt)
 				continue;
-			if (!rpc_cancel_tasks(clnt, -EAGAIN,
+			if (!rpc_cancel_tasks(clnt, -ECANCELED,
 					      ff_layout_match_io, lseg))
 				continue;
 			rpc_clnt_disconnect(clnt);
-- 
2.53.0

