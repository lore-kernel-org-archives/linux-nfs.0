Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:34682 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755882AbcEQQ3J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2016 12:29:09 -0400
Received: by mail-qg0-f66.google.com with SMTP id e35so1832176qge.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 May 2016 09:29:08 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Thomas Haynes <loghyr@primarydata.com>, linux-nfs@vger.kernel.org,
        hch@lst.de
Subject: [PATCH v4 12/13] pnfs: rework LAYOUTGET retry handling
Date: Tue, 17 May 2016 12:28:47 -0400
Message-Id: <1463502528-11519-13-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
References: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are several problems in the way a stateid is selected for a
LAYOUTGET operation:

We pick a stateid to use in the RPC prepare op, but that makes
it difficult to serialize LAYOUTGETs that use the open stateid. That
serialization is done in pnfs_update_layout, which occurs well before
the rpc_prepare operation.

Between those two events, the i_lock is dropped and reacquired.
pnfs_update_layout can find that the list has lsegs in it and not do any
serialization, but then later pnfs_choose_layoutget_stateid ends up
choosing the open stateid.

This patch changes the client to select the stateid to use in the
LAYOUTGET earlier, when we're searching for a usable layout segment.
This way we can do it all while holding the i_lock the first time, and
ensure that we serialize any LAYOUTGET call that uses a non-layout
stateid.

This also means a rework of how LAYOUTGET replies are handled, as we
must now get the latest stateid if we want to retransmit in response
to a retryable error.

Most of those errors boil down to the fact that the layout state has
changed in some fashion. Thus, what we really want to do is to re-search
for a layout when it fails with a retryable error, so that we can avoid
reissuing the RPC at all if possible.

While the LAYOUTGET RPC is async, the initiating thread always waits for
it to complete, so it's effectively synchronous anyway. Currently, when
we need to retry a LAYOUTGET because of an error, we drive that retry
via the rpc state machine.

This means that once the call has been submitted, it runs until it
completes. So, we must move the error handling for this RPC out of the
rpc_call_done operation and into the caller.

In order to handle errors like NFS4ERR_DELAY properly, we must also
pass a pointer to the sliding timeout, which is now moved to the stack
in pnfs_update_layout.

The complicating errors are -NFS4ERR_RECALLCONFLICT and
-NFS4ERR_LAYOUTTRYLATER, as those involve a timeout after which we give
up and return NULL back to the caller. So, there is some special
handling for those errors to ensure that the layers driving the retries
can handle that appropriately.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 115 ++++++++++++++++----------------------
 fs/nfs/nfs4trace.h      |  10 +++-
 fs/nfs/pnfs.c           | 144 +++++++++++++++++++++++++-----------------------
 fs/nfs/pnfs.h           |   6 +-
 include/linux/errno.h   |   1 +
 include/linux/nfs4.h    |   2 +
 include/linux/nfs_xdr.h |   2 -
 7 files changed, 136 insertions(+), 144 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c0d75be8cb69..c2583ca6c8b6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -416,6 +416,7 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
+		case -NFS4ERR_RECALLCONFLICT:
 			exception->delay = 1;
 			return 0;
 
@@ -7824,40 +7825,34 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 	struct nfs4_layoutget *lgp = calldata;
 	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
 	struct nfs4_session *session = nfs4_get_session(server);
-	int ret;
 
 	dprintk("--> %s\n", __func__);
-	/* Note the is a race here, where a CB_LAYOUTRECALL can come in
-	 * right now covering the LAYOUTGET we are about to send.
-	 * However, that is not so catastrophic, and there seems
-	 * to be no way to prevent it completely.
-	 */
-	if (nfs41_setup_sequence(session, &lgp->args.seq_args,
-				&lgp->res.seq_res, task))
-		return;
-	ret = pnfs_choose_layoutget_stateid(&lgp->args.stateid,
-					  NFS_I(lgp->args.inode)->layout,
-					  &lgp->args.range,
-					  lgp->args.ctx->state);
-	if (ret < 0)
-		rpc_exit(task, ret);
+	nfs41_setup_sequence(session, &lgp->args.seq_args,
+				&lgp->res.seq_res, task);
+	dprintk("<-- %s\n", __func__);
 }
 
 static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutget *lgp = calldata;
+
+	dprintk("--> %s\n", __func__);
+	nfs41_sequence_done(task, &lgp->res.seq_res);
+	dprintk("<-- %s\n", __func__);
+}
+
+static int
+nfs4_layoutget_handle_exception(struct rpc_task *task,
+		struct nfs4_layoutget *lgp, struct nfs4_exception *exception)
+{
 	struct inode *inode = lgp->args.inode;
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct pnfs_layout_hdr *lo;
-	struct nfs4_state *state = NULL;
-	unsigned long timeo, now, giveup;
+	int status = task->tk_status;
 
 	dprintk("--> %s tk_status => %d\n", __func__, -task->tk_status);
 
-	if (!nfs41_sequence_done(task, &lgp->res.seq_res))
-		goto out;
-
-	switch (task->tk_status) {
+	switch (status) {
 	case 0:
 		goto out;
 
@@ -7867,57 +7862,43 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 	 * retry go inband.
 	 */
 	case -NFS4ERR_LAYOUTUNAVAILABLE:
-		task->tk_status = -ENODATA;
+		status = -ENODATA;
 		goto out;
 	/*
 	 * NFS4ERR_BADLAYOUT means the MDS cannot return a layout of
 	 * length lgp->args.minlength != 0 (see RFC5661 section 18.43.3).
 	 */
 	case -NFS4ERR_BADLAYOUT:
-		goto out_overflow;
+		status = -EOVERFLOW;
+		goto out;
 	/*
 	 * NFS4ERR_LAYOUTTRYLATER is a conflict with another client
 	 * (or clients) writing to the same RAID stripe except when
 	 * the minlength argument is 0 (see RFC5661 section 18.43.3).
+	 *
+	 * Treat it like we would RECALLCONFLICT -- we retry for a little
+	 * while, and then eventually give up.
 	 */
 	case -NFS4ERR_LAYOUTTRYLATER:
-		if (lgp->args.minlength == 0)
-			goto out_overflow;
-	/*
-	 * NFS4ERR_RECALLCONFLICT is when conflict with self (must recall
-	 * existing layout before getting a new one).
-	 */
-	case -NFS4ERR_RECALLCONFLICT:
-		timeo = rpc_get_timeout(task->tk_client);
-		giveup = lgp->args.timestamp + timeo;
-		now = jiffies;
-		if (time_after(giveup, now)) {
-			unsigned long delay;
-
-			/* Delay for:
-			 * - Not less then NFS4_POLL_RETRY_MIN.
-			 * - One last time a jiffie before we give up
-			 * - exponential backoff (time_now minus start_attempt)
-			 */
-			delay = max_t(unsigned long, NFS4_POLL_RETRY_MIN,
-				    min((giveup - now - 1),
-					now - lgp->args.timestamp));
-
-			dprintk("%s: NFS4ERR_RECALLCONFLICT waiting %lu\n",
-				__func__, delay);
-			rpc_delay(task, delay);
-			/* Do not call nfs4_async_handle_error() */
-			goto out_restart;
+		if (lgp->args.minlength == 0) {
+			status = -EOVERFLOW;
+			goto out;
 		}
-		break;
+		/* Fallthrough */
+	case -NFS4ERR_RECALLCONFLICT:
+		nfs4_handle_exception(server, -NFS4ERR_RECALLCONFLICT,
+					exception);
+		status = -ERECALLCONFLICT;
+		goto out;
 	case -NFS4ERR_EXPIRED:
 	case -NFS4ERR_BAD_STATEID:
+		exception->timeout = 0;
 		spin_lock(&inode->i_lock);
 		if (nfs4_stateid_match(&lgp->args.stateid,
 					&lgp->args.ctx->state->stateid)) {
 			spin_unlock(&inode->i_lock);
 			/* If the open stateid was bad, then recover it. */
-			state = lgp->args.ctx->state;
+			exception->state = lgp->args.ctx->state;
 			break;
 		}
 		lo = NFS_I(inode)->layout;
@@ -7935,20 +7916,16 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 			pnfs_free_lseg_list(&head);
 		} else
 			spin_unlock(&inode->i_lock);
-		goto out_restart;
+		status = -EAGAIN;
+		goto out;
 	}
-	if (nfs4_async_handle_error(task, server, state, &lgp->timeout) == -EAGAIN)
-		goto out_restart;
+
+	status = nfs4_handle_exception(server, status, exception);
+	if (exception->retry)
+		status = -EAGAIN;
 out:
 	dprintk("<-- %s\n", __func__);
-	return;
-out_restart:
-	task->tk_status = 0;
-	rpc_restart_call_prepare(task);
-	return;
-out_overflow:
-	task->tk_status = -EOVERFLOW;
-	goto out;
+	return status;
 }
 
 static size_t max_response_pages(struct nfs_server *server)
@@ -8017,7 +7994,7 @@ static const struct rpc_call_ops nfs4_layoutget_call_ops = {
 };
 
 struct pnfs_layout_segment *
-nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
+nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
 {
 	struct inode *inode = lgp->args.inode;
 	struct nfs_server *server = NFS_SERVER(inode);
@@ -8037,6 +8014,7 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 		.flags = RPC_TASK_ASYNC,
 	};
 	struct pnfs_layout_segment *lseg = NULL;
+	struct nfs4_exception exception = { .timeout = *timeout };
 	int status = 0;
 
 	dprintk("--> %s\n", __func__);
@@ -8050,7 +8028,6 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 		return ERR_PTR(-ENOMEM);
 	}
 	lgp->args.layout.pglen = max_pages * PAGE_SIZE;
-	lgp->args.timestamp = jiffies;
 
 	lgp->res.layoutp = &lgp->args.layout;
 	lgp->res.seq_res.sr_slot = NULL;
@@ -8060,13 +8037,17 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 	if (IS_ERR(task))
 		return ERR_CAST(task);
 	status = nfs4_wait_for_completion_rpc_task(task);
-	if (status == 0)
-		status = task->tk_status;
+	if (status == 0) {
+		status = nfs4_layoutget_handle_exception(task, lgp, &exception);
+		*timeout = exception.timeout;
+	}
+
 	trace_nfs4_layoutget(lgp->args.ctx,
 			&lgp->args.range,
 			&lgp->res.range,
 			&lgp->res.stateid,
 			status);
+
 	/* if layoutp->len is 0, nfs4_layoutget_prepare called rpc_exit */
 	if (status == 0 && lgp->res.layoutp->len)
 		lseg = pnfs_layout_process(lgp);
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 2c8d05dae5b1..9c150b153782 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1520,6 +1520,8 @@ DEFINE_NFS4_INODE_EVENT(nfs4_layoutreturn_on_close);
 		{ PNFS_UPDATE_LAYOUT_FOUND_CACHED, "found cached" },	\
 		{ PNFS_UPDATE_LAYOUT_RETURN, "layoutreturn" },		\
 		{ PNFS_UPDATE_LAYOUT_BLOCKED, "layouts blocked" },	\
+		{ PNFS_UPDATE_LAYOUT_INVALID_OPEN, "invalid open" },	\
+		{ PNFS_UPDATE_LAYOUT_RETRY, "retrying" },	\
 		{ PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET, "sent layoutget" })
 
 TRACE_EVENT(pnfs_update_layout,
@@ -1528,9 +1530,10 @@ TRACE_EVENT(pnfs_update_layout,
 			u64 count,
 			enum pnfs_iomode iomode,
 			struct pnfs_layout_hdr *lo,
+			struct pnfs_layout_segment *lseg,
 			enum pnfs_update_layout_reason reason
 		),
-		TP_ARGS(inode, pos, count, iomode, lo, reason),
+		TP_ARGS(inode, pos, count, iomode, lo, lseg, reason),
 		TP_STRUCT__entry(
 			__field(dev_t, dev)
 			__field(u64, fileid)
@@ -1540,6 +1543,7 @@ TRACE_EVENT(pnfs_update_layout,
 			__field(enum pnfs_iomode, iomode)
 			__field(int, layoutstateid_seq)
 			__field(u32, layoutstateid_hash)
+			__field(long, lseg)
 			__field(enum pnfs_update_layout_reason, reason)
 		),
 		TP_fast_assign(
@@ -1559,11 +1563,12 @@ TRACE_EVENT(pnfs_update_layout,
 				__entry->layoutstateid_seq = 0;
 				__entry->layoutstateid_hash = 0;
 			}
+			__entry->lseg = (long)lseg;
 		),
 		TP_printk(
 			"fileid=%02x:%02x:%llu fhandle=0x%08x "
 			"iomode=%s pos=%llu count=%llu "
-			"layoutstateid=%d:0x%08x (%s)",
+			"layoutstateid=%d:0x%08x lseg=0x%lx (%s)",
 			MAJOR(__entry->dev), MINOR(__entry->dev),
 			(unsigned long long)__entry->fileid,
 			__entry->fhandle,
@@ -1571,6 +1576,7 @@ TRACE_EVENT(pnfs_update_layout,
 			(unsigned long long)__entry->pos,
 			(unsigned long long)__entry->count,
 			__entry->layoutstateid_seq, __entry->layoutstateid_hash,
+			__entry->lseg,
 			show_pnfs_update_layout_reason(__entry->reason)
 		)
 );
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bc2c3ec98d32..e97895b427c0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -796,45 +796,18 @@ pnfs_layoutgets_blocked(const struct pnfs_layout_hdr *lo)
 		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 }
 
-int
-pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
-			      const struct pnfs_layout_range *range,
-			      struct nfs4_state *open_state)
-{
-	int status = 0;
-
-	dprintk("--> %s\n", __func__);
-	spin_lock(&lo->plh_inode->i_lock);
-	if (pnfs_layoutgets_blocked(lo)) {
-		status = -EAGAIN;
-	} else if (!nfs4_valid_open_stateid(open_state)) {
-		status = -EBADF;
-	} else if (list_empty(&lo->plh_segs) ||
-		   test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags)) {
-		int seq;
-
-		do {
-			seq = read_seqbegin(&open_state->seqlock);
-			nfs4_stateid_copy(dst, &open_state->stateid);
-		} while (read_seqretry(&open_state->seqlock, seq));
-	} else
-		nfs4_stateid_copy(dst, &lo->plh_stateid);
-	spin_unlock(&lo->plh_inode->i_lock);
-	dprintk("<-- %s\n", __func__);
-	return status;
-}
-
 /*
-* Get layout from server.
-*    for now, assume that whole file layouts are requested.
-*    arg->offset: 0
-*    arg->length: all ones
-*/
+ * Get layout from server.
+ *    for now, assume that whole file layouts are requested.
+ *    arg->offset: 0
+ *    arg->length: all ones
+ */
 static struct pnfs_layout_segment *
 send_layoutget(struct pnfs_layout_hdr *lo,
 	   struct nfs_open_context *ctx,
+	   nfs4_stateid *stateid,
 	   const struct pnfs_layout_range *range,
-	   gfp_t gfp_flags)
+	   long *timeout, gfp_t gfp_flags)
 {
 	struct inode *ino = lo->plh_inode;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -868,10 +841,11 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	lgp->args.type = server->pnfs_curr_ld->id;
 	lgp->args.inode = ino;
 	lgp->args.ctx = get_nfs_open_context(ctx);
+	nfs4_stateid_copy(&lgp->args.stateid, stateid);
 	lgp->gfp_flags = gfp_flags;
 	lgp->cred = lo->plh_lc_cred;
 
-	return nfs4_proc_layoutget(lgp, gfp_flags);
+	return nfs4_proc_layoutget(lgp, timeout, gfp_flags);
 }
 
 static void pnfs_clear_layoutcommit(struct inode *inode,
@@ -1511,27 +1485,30 @@ pnfs_update_layout(struct inode *ino,
 		.offset = pos,
 		.length = count,
 	};
-	unsigned pg_offset;
+	unsigned pg_offset, seq;
 	struct nfs_server *server = NFS_SERVER(ino);
 	struct nfs_client *clp = server->nfs_client;
-	struct pnfs_layout_hdr *lo;
+	struct pnfs_layout_hdr *lo = NULL;
 	struct pnfs_layout_segment *lseg = NULL;
+	nfs4_stateid stateid;
+	long timeout = 0;
+	unsigned long giveup = jiffies + rpc_get_timeout(server->client);
 	bool first;
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino))) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, NULL,
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				 PNFS_UPDATE_LAYOUT_NO_PNFS);
 		goto out;
 	}
 
 	if (iomode == IOMODE_READ && i_size_read(ino) == 0) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, NULL,
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				 PNFS_UPDATE_LAYOUT_RD_ZEROLEN);
 		goto out;
 	}
 
 	if (pnfs_within_mdsthreshold(ctx, ino, iomode)) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, NULL,
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				 PNFS_UPDATE_LAYOUT_MDSTHRESH);
 		goto out;
 	}
@@ -1542,14 +1519,14 @@ lookup_again:
 	lo = pnfs_find_alloc_layout(ino, ctx, gfp_flags);
 	if (lo == NULL) {
 		spin_unlock(&ino->i_lock);
-		trace_pnfs_update_layout(ino, pos, count, iomode, NULL,
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				 PNFS_UPDATE_LAYOUT_NOMEM);
 		goto out;
 	}
 
 	/* Do we even need to bother with this? */
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, lo,
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				 PNFS_UPDATE_LAYOUT_BULK_RECALL);
 		dprintk("%s matches recall, use MDS\n", __func__);
 		goto out_unlock;
@@ -1557,14 +1534,34 @@ lookup_again:
 
 	/* if LAYOUTGET already failed once we don't try again */
 	if (pnfs_layout_io_test_failed(lo, iomode)) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, lo,
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				 PNFS_UPDATE_LAYOUT_IO_TEST_FAIL);
 		goto out_unlock;
 	}
 
-	first = list_empty(&lo->plh_segs);
-	if (first) {
-		/* The first layoutget for the file. Need to serialize per
+	lseg = pnfs_find_lseg(lo, &arg);
+	if (lseg) {
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
+				PNFS_UPDATE_LAYOUT_FOUND_CACHED);
+		goto out_unlock;
+	}
+
+	if (!nfs4_valid_open_stateid(ctx->state)) {
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
+				PNFS_UPDATE_LAYOUT_INVALID_OPEN);
+		goto out_unlock;
+	}
+
+	/*
+	 * Choose a stateid for the LAYOUTGET. If we don't have a layout
+	 * stateid, or it has been invalidated, then we must use the open
+	 * stateid.
+	 */
+	if (lo->plh_stateid.seqid == 0 ||
+	    test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags)) {
+
+		/*
+		 * The first layoutget for the file. Need to serialize per
 		 * RFC 5661 Errata 3208.
 		 */
 		if (test_and_set_bit(NFS_LAYOUT_FIRST_LAYOUTGET,
@@ -1573,18 +1570,17 @@ lookup_again:
 			wait_on_bit(&lo->plh_flags, NFS_LAYOUT_FIRST_LAYOUTGET,
 				    TASK_UNINTERRUPTIBLE);
 			pnfs_put_layout_hdr(lo);
+			dprintk("%s retrying\n", __func__);
 			goto lookup_again;
 		}
+
+		first = true;
+		do {
+			seq = read_seqbegin(&ctx->state->seqlock);
+			nfs4_stateid_copy(&stateid, &ctx->state->stateid);
+		} while (read_seqretry(&ctx->state->seqlock, seq));
 	} else {
-		/* Check to see if the layout for the given range
-		 * already exists
-		 */
-		lseg = pnfs_find_lseg(lo, &arg);
-		if (lseg) {
-			trace_pnfs_update_layout(ino, pos, count, iomode, lo,
-					PNFS_UPDATE_LAYOUT_FOUND_CACHED);
-			goto out_unlock;
-		}
+		nfs4_stateid_copy(&stateid, &lo->plh_stateid);
 	}
 
 	/*
@@ -1599,15 +1595,17 @@ lookup_again:
 				pnfs_clear_first_layoutget(lo);
 			pnfs_put_layout_hdr(lo);
 			dprintk("%s retrying\n", __func__);
+			trace_pnfs_update_layout(ino, pos, count, iomode, lo,
+					lseg, PNFS_UPDATE_LAYOUT_RETRY);
 			goto lookup_again;
 		}
-		trace_pnfs_update_layout(ino, pos, count, iomode, lo,
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				PNFS_UPDATE_LAYOUT_RETURN);
 		goto out_put_layout_hdr;
 	}
 
 	if (pnfs_layoutgets_blocked(lo)) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, lo,
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				PNFS_UPDATE_LAYOUT_BLOCKED);
 		goto out_unlock;
 	}
@@ -1632,26 +1630,36 @@ lookup_again:
 	if (arg.length != NFS4_MAX_UINT64)
 		arg.length = PAGE_ALIGN(arg.length);
 
-	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
+	lseg = send_layoutget(lo, ctx, &stateid, &arg, &timeout, gfp_flags);
+	trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
+				 PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET);
 	if (IS_ERR(lseg)) {
-		if (lseg == ERR_PTR(-EAGAIN)) {
+		switch(PTR_ERR(lseg)) {
+		case -ERECALLCONFLICT:
+			if (time_after(jiffies, giveup))
+				lseg = NULL;
+			/* Fallthrough */
+		case -EAGAIN:
+			pnfs_put_layout_hdr(lo);
 			if (first)
 				pnfs_clear_first_layoutget(lo);
-			pnfs_put_layout_hdr(lo);
-			goto lookup_again;
-		}
-
-		if (!nfs_error_is_fatal(PTR_ERR(lseg))) {
-			pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
-			lseg = NULL;
+			if (lseg) {
+				trace_pnfs_update_layout(ino, pos, count,
+					iomode, lo, lseg, PNFS_UPDATE_LAYOUT_RETRY);
+				goto lookup_again;
+			}
+			/* Fallthrough */
+		default:
+			if (!nfs_error_is_fatal(PTR_ERR(lseg))) {
+				pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
+				lseg = NULL;
+			}
 		}
 	} else {
 		pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
 	}
 
 	atomic_dec(&lo->plh_outstanding);
-	trace_pnfs_update_layout(ino, pos, count, iomode, lo,
-				 PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET);
 out_put_layout_hdr:
 	if (first)
 		pnfs_clear_first_layoutget(lo);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 971068b58647..f9f3331bef49 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -228,7 +228,7 @@ extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
 extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev,
 				   struct rpc_cred *cred);
-extern struct pnfs_layout_segment* nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags);
+extern struct pnfs_layout_segment* nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags);
 extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync);
 
 /* pnfs.c */
@@ -260,10 +260,6 @@ void pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			     const nfs4_stateid *new,
 			     bool update_barrier);
-int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
-				  struct pnfs_layout_hdr *lo,
-				  const struct pnfs_layout_range *range,
-				  struct nfs4_state *open_state);
 int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				const struct pnfs_layout_range *recall_range,
diff --git a/include/linux/errno.h b/include/linux/errno.h
index 89627b9187f9..7ce9fb1b7d28 100644
--- a/include/linux/errno.h
+++ b/include/linux/errno.h
@@ -28,5 +28,6 @@
 #define EBADTYPE	527	/* Type not supported by server */
 #define EJUKEBOX	528	/* Request initiated, but will not complete before timeout */
 #define EIOCBQUEUED	529	/* iocb queued, will get completion event */
+#define ERECALLCONFLICT	530	/* conflict with recalled state */
 
 #endif
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 011433478a14..f4870a330290 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -621,7 +621,9 @@ enum pnfs_update_layout_reason {
 	PNFS_UPDATE_LAYOUT_IO_TEST_FAIL,
 	PNFS_UPDATE_LAYOUT_FOUND_CACHED,
 	PNFS_UPDATE_LAYOUT_RETURN,
+	PNFS_UPDATE_LAYOUT_RETRY,
 	PNFS_UPDATE_LAYOUT_BLOCKED,
+	PNFS_UPDATE_LAYOUT_INVALID_OPEN,
 	PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET,
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index cb9982d8f38f..a4cb8a33ae2c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -233,7 +233,6 @@ struct nfs4_layoutget_args {
 	struct inode *inode;
 	struct nfs_open_context *ctx;
 	nfs4_stateid stateid;
-	unsigned long timestamp;
 	struct nfs4_layoutdriver_data layout;
 };
 
@@ -251,7 +250,6 @@ struct nfs4_layoutget {
 	struct nfs4_layoutget_res res;
 	struct rpc_cred *cred;
 	gfp_t gfp_flags;
-	long timeout;
 };
 
 struct nfs4_getdeviceinfo_args {
-- 
2.5.5

