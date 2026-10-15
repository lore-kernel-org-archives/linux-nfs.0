Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com [209.85.210.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F14951A157
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 11:33:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792064003; cv=none; b=okapwpZ0M8ig++lasrfy54ZvtFamNou0vzhO36PADWRSGSA5Ybcdd+C23x4wnT4yiJxLYVoD3aK/lr+6zBpeFC9QG4LSr0p1gWQ5MMuPL2VEXpMJadxVytarKrqwaCEd6R+TTAB6yS+CfT2ts5Dma30a5gqVNunbXZPfav7225A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792064003; c=relaxed/simple;
	bh=c4MDUZBPgVm0CNyggPS4c8nx99j1cuI4Hql8Wg2N9pY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ZLpGfW+I3wokEh9uiprAxOz5Fn7iLUybjro8jUz6b/CZceMyCa/dKHXPPq89c0CJhms3jJJblwfSjOm/jymZMYRyTX29vVrhwxdpizMeSp0SwIbBs+wBTY5WBzskzqvLVYsZyQXswIXAIbJKsHt1dZdu83IiDxtPWqDXUVrSJ9A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=gKQ7V9mU; arc=none smtp.client-ip=209.85.210.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="gKQ7V9mU"
Received: by mail-ot1-f50.google.com with SMTP id 46e09a7af769-7f432ac553fso5566511a34.3
        for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 04:33:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792063990; x=1792668790; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=Cm4YdwN13ihPJ3S7PlHZ+th6T9F9W2y2N+okdHhcgEM=;
        b=gKQ7V9mUBkv1JyLgkVWcB2wjTMyM3UfxGToAMz+pCBu7G+SfY09eYo8HrATOvsiWJx
         OgrDTQaDBU3sJMxwaL+TqZY/ZSyG0Ajp2V1vkCAijKNGPBXBDmsDOeCo5Ws1GIIDL6BG
         UfcfkKFrgg+pgDk6pWgul4senEYKV5xbFXXnhkcD6icSPHYsi4HvspCHB7Vd6ihxiuLz
         Dpm0zBG+CeLj6X1HysR7I85VEFN5F73uowCqe+02vXokBCwY85l+E3qB617WfPR7A5pv
         PMnU17+DX64nzMunzauf0Q36MSinc7xXjh4B09P0qSRXO+zffAKoVHOFS3eFdMr0t44z
         TMgQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792063990; x=1792668790;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Cm4YdwN13ihPJ3S7PlHZ+th6T9F9W2y2N+okdHhcgEM=;
        b=GA4njxbqCCtokJGTECWE9h//dKJj3f9uyge4QfcXgRceT92pU+hPEu5jMnzqfZKJAA
         EBnXE9JQveNSjuy8KW2WY7YheSaAxQVTn8z8q9XC3ZWQNnvHZyNSTDMZn5c7WPdcbqtw
         QaLZmrGv0Vilkx1lREOt3pluJKLOy8i68yhPHABDvYTHVxRG8/Dv+50ut18eTmkYujoc
         UmZrPBcBdQzW6uDk8aDAmYUQQCZ8Bt2IJNPtRU6NhmrU0xyljabUpx71cjyVTmLK/kna
         +3iTba/K3LEXJnj2AH8RPN3Jwlc2r5f2SefXlIbnvo8WcbLIGryI25mC/xUH6MJdxGEL
         PEpw==
X-Gm-Message-State: AFq9FYI8U4+QDm0my1EtpaMUM1GdDOWV7CNv3mTcvpYxk/eyB70Jv6yt
	MOnk/V6dmfMODJajAnKN/0eY0P/hnmnp203e8O4cAQzrh6Il87KBz54/AMzcTuQP6VBS7ssJRPM
	MWnzC
X-Gm-Gg: AYBFou35DPIq7EgWV4wcQPRhFjCPs+nf4hVVmy9V6I0vokNmZ3vto7cFE+piChjHbJS
	5oZQf0NbLRqkFqcqL1wA8WCQ/TGTaz4sfi1w2d4vGaISuJx7pM95byzz2U34hHoeSCD7UmcJ1qo
	4+xHTArHWhx/gFG7FwT++3bjGUuVh5Ti8lI4FzCT+p+FcVdMC4PWRTkB0g+MJcAVl3yrmjGcGgr
	YM8rfp7GLOeNj4NR4U6lG4sv1LhjEQlDbdNlYw+mrPLN7MkiDUdQRLPioHvfR4v/Sd8tySj5C78
	NjuouK1A43RJlwIMmKmDVyI7mYADyt7Cpi0inzvhScEX/iqt356bUwqBfsCLiEFl1lU+BknD3xC
	pXxOCsL6bbc8WWiYMRqWI1HGF+y5iBOYqnV3k0l3QfRcAr4SYuWF//fdBn2RHxNiEGsTneMVWkL
	OBjg0LpXdHANuGPakfsegO1vT9HHOo2oanIfZZFkFAZuXBsMLv31cxXDv0B9OP5h/aWjaArAyrT
	bLiZeoWMvaBM9+Q6AbKR0PQE4r96Sgc9/BjA/LNNg==
X-Received: by 2002:a05:6830:4119:b0:80c:6371:21fb with SMTP id 46e09a7af769-830963f878dmr20584388a34.16.1792063989661;
        Thu, 15 Oct 2026 04:33:09 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8303494f64csm16831333a34.3.2026.10.15.04.33.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 15 Oct 2026 04:33:09 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4/flexfiles: fail I/O to the data server once a lock is lost
Date: Thu, 15 Oct 2026 07:33:07 -0400
Message-ID: <fb9fa590f331ecbb38518ad16b407d92d30d9d1e.1792063831.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

When a client loses a byte-range lock, because its lease expired and it
may not recover the lock (nfs.recover_lost_locks=0) or because reclaim
failed, it marks the lock state NFS_LOCK_LOST and fails further I/O by
that lock owner.  Otherwise an application that believes it holds a
lock over a range is never told that the lock is gone, and can
overwrite data that another client has since written under its own
lock on that range.

The NFSv4 READ/WRITE and file layout I/O paths apply this in
rpc_call_prepare, where nfs4_set_rw_stateid() returns -EIO for a lost
lock.  The flexfiles data server I/O path does not: the NFSv3 data
server path never checked, and the check on the NFSv4 path was removed
when the data server stateid began to be taken from the layout.

Fail read and write RPCs to the data server in rpc_call_prepare when the
lock is lost.  The data server path has no use for the stateid that
nfs4_set_rw_stateid() selects, and selecting it looks up a delegation
or open stateid on every I/O.
Instead add nfs4_lock_context_lost(), which only tests NFS_LOCK_LOST,
and check it alongside the open state.  Its lookup,
__nfs4_lookup_lock_state(), is split out of __nfs4_find_lock_state()
and takes no reference: a lock state is only unlinked from
state->lock_states under state->state_lock, so one found while holding
that lock cannot be freed before it is released.  Use it in
nfs4_copy_lock_stateid() as well, which only reads the lock state under
that lock.  That drops a reference get and put from stateid selection
for all NFSv4 I/O without changing the stateid selected.

Terminating the RPC in rpc_call_prepare is not enough on its own.  The
done callback reads the -EIO as a data server connection error, forgets
the device ID, and resets the I/O to pNFS (or, for an NFSv4 data
server, possibly to the MDS).  After a reset to pNFS a new LAYOUTGET is
granted and rpc_call_prepare fails the I/O again, without end.  The
existing NFS_CONTEXT_BAD check does not loop, since the open state is
then invalid and pnfs_update_layout() fails the reset I/O, but it still
forgets the device ID.

So when an RPC that was never sent fails and the open context is bad,
the open state is invalid, or the lock is lost, complete it with -EIO
without error handling.  An RPC that was sent and failed is handled as
before, so a real data server error is still reported to the MDS.

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Fixes: bb21ce0ad227 ("flexfiles: use per-mirror specified stateid for IO")
Cc: stable@vger.kernel.org
Tested-by: Arun Potharaju <arun.potharaju@hammerspace.com>
Assisted-by: LLM
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
This could have been three patches: the fix using nfs4_set_rw_stateid(),
the reference-free lookup, then switching flexfiles to
nfs4_lock_context_lost().  But a backport of only the first would put
the stateid selection cost on the data server I/O path of stable
kernels, and leave them with behaviour upstream would carry for just two
commits, such as marking delegations referenced from data server I/O.
One patch keeps stable and upstream the same.

Tested on a 6.12 backport with a reproducer that partitions a client
from its metadata server, but not its data servers, for longer than the
lease period: without the fix, the client whose lock was lost overwrote
the other client's data in 9 of 9 runs; with it, the data was intact in
6 of 6 runs and the writer got -EIO, for both buffered and O_DIRECT
writes.

 fs/nfs/flexfilelayout/flexfilelayout.c | 25 +++++++++++++++--
 fs/nfs/nfs4_fs.h                       |  2 ++
 fs/nfs/nfs4state.c                     | 38 +++++++++++++++++++++++---
 3 files changed, 59 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fe8b91fa47c..d4b2f32a1b24 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1597,6 +1597,15 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 	dprintk("%s: err %d op %d status %u\n", __func__, err, opnum, status);
 }
 
+static bool ff_layout_io_state_lost(const struct nfs_pgio_header *hdr)
+{
+	struct nfs_open_context *ctx = hdr->args.context;
+
+	return test_bit(NFS_CONTEXT_BAD, &ctx->flags) ||
+	       !nfs4_valid_open_stateid(ctx->state) ||
+	       nfs4_lock_context_lost(ctx->state, hdr->args.lock_context);
+}
+
 /* NFS_PROTO call done callback routines */
 static int ff_layout_read_done_cb(struct rpc_task *task,
 				struct nfs_pgio_header *hdr)
@@ -1608,6 +1617,12 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 		hdr->args.offset);
 	int err;
 
+	if (task->tk_status < 0 && !RPC_WAS_SENT(task) &&
+	    ff_layout_io_state_lost(hdr)) {
+		task->tk_status = -EIO;
+		return 0;
+	}
+
 	if (task->tk_status < 0) {
 		ff_layout_io_track_ds_error(hdr->lseg,
 					    hdr->pgio_mirror_idx, dss_id,
@@ -1724,7 +1739,7 @@ static void ff_layout_read_record_layoutstats_done(struct rpc_task *task,
 static int ff_layout_read_prepare_common(struct rpc_task *task,
 					 struct nfs_pgio_header *hdr)
 {
-	if (unlikely(test_bit(NFS_CONTEXT_BAD, &hdr->args.context->flags))) {
+	if (unlikely(ff_layout_io_state_lost(hdr))) {
 		rpc_exit(task, -EIO);
 		return -EIO;
 	}
@@ -1813,6 +1828,12 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 	loff_t end_offs = 0;
 	int err;
 
+	if (task->tk_status < 0 && !RPC_WAS_SENT(task) &&
+	    ff_layout_io_state_lost(hdr)) {
+		task->tk_status = -EIO;
+		return 0;
+	}
+
 	if (task->tk_status < 0) {
 		ff_layout_io_track_ds_error(hdr->lseg,
 					    hdr->pgio_mirror_idx, dss_id,
@@ -1950,7 +1971,7 @@ static void ff_layout_write_record_layoutstats_done(struct rpc_task *task,
 static int ff_layout_write_prepare_common(struct rpc_task *task,
 					  struct nfs_pgio_header *hdr)
 {
-	if (unlikely(test_bit(NFS_CONTEXT_BAD, &hdr->args.context->flags))) {
+	if (unlikely(ff_layout_io_state_lost(hdr))) {
 		rpc_exit(task, -EIO);
 		return -EIO;
 	}
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b48e5b87cb2a..29e2fb695953 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -526,6 +526,8 @@ extern int nfs4_select_rw_stateid(struct nfs4_state *, fmode_t,
 		const struct cred **);
 extern bool nfs4_copy_open_stateid(nfs4_stateid *dst,
 		struct nfs4_state *state);
+extern bool nfs4_lock_context_lost(struct nfs4_state *state,
+		const struct nfs_lock_context *l_ctx);
 
 extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
 extern int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a5dec0473e22..78270037059c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -812,10 +812,13 @@ void nfs4_close_sync(struct nfs4_state *state, fmode_t fmode)
  * be made.  Failing that, a "consistent" choice is preferable.  The
  * consistent choice we make is to prefer the first owner, that of a
  * Posix lock.
+ *
+ * Called with state->state_lock held.  No reference is taken: a lock
+ * state is freed only after it is unlinked under state->state_lock.
  */
 static struct nfs4_lock_state *
-__nfs4_find_lock_state(struct nfs4_state *state,
-		       fl_owner_t owner, fl_owner_t owner2)
+__nfs4_lookup_lock_state(struct nfs4_state *state,
+			 fl_owner_t owner, fl_owner_t owner2)
 {
 	struct nfs4_lock_state *pos, *ret = NULL;
 	list_for_each_entry(pos, &state->lock_states, ls_locks) {
@@ -826,6 +829,16 @@ __nfs4_find_lock_state(struct nfs4_state *state,
 		if (pos->ls_owner == owner2)
 			ret = pos;
 	}
+	return ret;
+}
+
+static struct nfs4_lock_state *
+__nfs4_find_lock_state(struct nfs4_state *state,
+		       fl_owner_t owner, fl_owner_t owner2)
+{
+	struct nfs4_lock_state *ret;
+
+	ret = __nfs4_lookup_lock_state(state, owner, owner2);
 	if (ret)
 		refcount_inc(&ret->ls_count);
 	return ret;
@@ -968,7 +981,7 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 	fl_flock_owner = l_ctx->open_context->flock_owner;
 
 	spin_lock(&state->state_lock);
-	lsp = __nfs4_find_lock_state(state, owner, fl_flock_owner);
+	lsp = __nfs4_lookup_lock_state(state, owner, fl_flock_owner);
 	if (lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
 		ret = -EIO;
 	else if (lsp != NULL && test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) != 0) {
@@ -976,11 +989,28 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 		ret = 0;
 	}
 	spin_unlock(&state->state_lock);
-	nfs4_put_lock_state(lsp);
 out:
 	return ret;
 }
 
+bool nfs4_lock_context_lost(struct nfs4_state *state,
+			    const struct nfs_lock_context *l_ctx)
+{
+	struct nfs4_lock_state *lsp;
+	bool ret;
+
+	if (!test_bit(LK_STATE_IN_USE, &state->flags))
+		return false;
+
+	spin_lock(&state->state_lock);
+	lsp = __nfs4_lookup_lock_state(state, l_ctx->lockowner,
+				       l_ctx->open_context->flock_owner);
+	ret = lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags);
+	spin_unlock(&state->state_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(nfs4_lock_context_lost);
+
 bool nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 {
 	bool ret;
-- 
2.53.0

