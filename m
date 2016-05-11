Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:36618 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932114AbcEKKVc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 May 2016 06:21:32 -0400
Received: by mail-qg0-f67.google.com with SMTP id f74so2627645qge.3
        for <linux-nfs@vger.kernel.org>; Wed, 11 May 2016 03:21:32 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 9/9] pnfs: rework LAYOUTGET retry handling
Date: Wed, 11 May 2016 06:21:14 -0400
Message-Id: <1462962074-6989-10-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1462962074-6989-1-git-send-email-jeff.layton@primarydata.com>
References: <1462962074-6989-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are several problems in the way a stateid is selected for a
LAYOUTGET operation:

First, the list_empty test in pnfs_update_layout is not reliable. We may
have lsegs on the list that are in the process of being returned.

Also, we pick a stateid to use in the rpc_prepare op, but that makes
it difficult to serialize LAYOUTGETs that use the open stateid. That
serialization is done in pnfs_update_layout, which occurs well before
rpc_prepare.

Between those two events, the i_lock is dropped and reacquired.
pnfs_update_layout can find that the list has lsegs in it and not do any
serialization, but then later pnfs_choose_layoutget_stateid ends up
choosing the open stateid.

Fix this by selecting the stateid to use in the LAYOUTGET earlier,
when we're searching for a usable layout segment. This way we can
do it all while holding the i_lock the first time, and ensure that
we serialize any LAYOUTGET call that uses a non-layout stateid.

This also means a rework of how retryable errors are handled as we must
update the stateid if we need to retransmit.

Currently, when we need to retry a LAYOUTGET because of an error, we
drive that retry via the rpc state machine. That's not really ideal
though. Most of those errors boil down to the fact that the layout state
has changed in some fashion. Thus, what we really want to do is to
re-search for a layout and take it from there.

Fix nfs4_layoutget_done not to requeue the rpc_task on a retryable
error, but rather to just set the tk_status to -EAGAIN. This tells the
upper layers to retry the whole thing from scratch, searching for an
lseg, and then re-driving the LAYOUTGET.

In order to handle errors like NFS4ERR_DELAY properly, we must also pass
a pointer to the timeout field, that is now moved to the stack in
pnfs_update_layout.

The complicating factor is -NFS4ERR_RECALLCONFLICT, as that involves a
timeout after which we give up and return NULL back to the caller. So,
take special care not to clobber that error with -EAGAIN, so the upper
layers can distinguish between the two.

Finally, when send_layoutget gets back an -EAGAIN, and the timeout is
set, have it just sleep that long via schedule_timeout.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4proc.c       |  63 +++++++-----------------------
 fs/nfs/pnfs.c           | 102 ++++++++++++++++++++++++------------------------
 fs/nfs/pnfs.h           |   4 --
 include/linux/nfs_xdr.h |   3 +-
 4 files changed, 67 insertions(+), 105 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c0d75be8cb69..4359217ba813 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -416,6 +416,7 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
+		case -NFS4ERR_RECALLCONFLICT:
 			exception->delay = 1;
 			return 0;
 
@@ -7824,23 +7825,11 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
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
@@ -7850,7 +7839,6 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct pnfs_layout_hdr *lo;
 	struct nfs4_state *state = NULL;
-	unsigned long timeo, now, giveup;
 
 	dprintk("--> %s tk_status => %d\n", __func__, -task->tk_status);
 
@@ -7883,35 +7871,9 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 	case -NFS4ERR_LAYOUTTRYLATER:
 		if (lgp->args.minlength == 0)
 			goto out_overflow;
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
-		}
-		break;
 	case -NFS4ERR_EXPIRED:
 	case -NFS4ERR_BAD_STATEID:
+		*lgp->timeout = 0;
 		spin_lock(&inode->i_lock);
 		if (nfs4_stateid_match(&lgp->args.stateid,
 					&lgp->args.ctx->state->stateid)) {
@@ -7937,15 +7899,21 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 			spin_unlock(&inode->i_lock);
 		goto out_restart;
 	}
-	if (nfs4_async_handle_error(task, server, state, &lgp->timeout) == -EAGAIN)
+
+	/*
+	 * Don't clobber -NFS4ERR_RECALLCONFLICT, as we want the upper layers
+	 * to be able to distinguish between that and -EAGAIN so that we can
+	 * properly give up in the RECALLCONFLICT case.
+	 */
+	if (nfs4_async_handle_error(task, server, state, lgp->timeout) == -EAGAIN &&
+	    task->tk_status != -NFS4ERR_RECALLCONFLICT)
 		goto out_restart;
 out:
 	dprintk("<-- %s\n", __func__);
 	return;
 out_restart:
-	task->tk_status = 0;
-	rpc_restart_call_prepare(task);
-	return;
+	task->tk_status = -EAGAIN;
+	goto out;
 out_overflow:
 	task->tk_status = -EOVERFLOW;
 	goto out;
@@ -8050,7 +8018,6 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 		return ERR_PTR(-ENOMEM);
 	}
 	lgp->args.layout.pglen = max_pages * PAGE_SIZE;
-	lgp->args.timestamp = jiffies;
 
 	lgp->res.layoutp = &lgp->args.layout;
 	lgp->res.seq_res.sr_slot = NULL;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ed3ab3e81f38..80259bfefec4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -796,45 +796,12 @@ pnfs_layoutgets_blocked(const struct pnfs_layout_hdr *lo)
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
-/*
-* Get layout from server.
-*    for now, assume that whole file layouts are requested.
-*    arg->offset: 0
-*    arg->length: all ones
-*/
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
@@ -868,8 +835,10 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	lgp->args.type = server->pnfs_curr_ld->id;
 	lgp->args.inode = ino;
 	lgp->args.ctx = get_nfs_open_context(ctx);
+	nfs4_stateid_copy(&lgp->args.stateid, stateid);
 	lgp->gfp_flags = gfp_flags;
 	lgp->cred = lo->plh_lc_cred;
+	lgp->timeout = timeout;
 
 	return nfs4_proc_layoutget(lgp, gfp_flags);
 }
@@ -1511,11 +1480,14 @@ pnfs_update_layout(struct inode *ino,
 		.offset = pos,
 		.length = count,
 	};
-	unsigned pg_offset;
+	unsigned pg_offset, seq;
 	struct nfs_server *server = NFS_SERVER(ino);
 	struct nfs_client *clp = server->nfs_client;
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg = NULL;
+	nfs4_stateid stateid;
+	long timeout = 0;
+	unsigned long giveup = jiffies + rpc_get_timeout(server->client);
 	bool first;
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino))) {
@@ -1562,9 +1534,28 @@ lookup_again:
 		goto out_unlock;
 	}
 
-	first = list_empty(&lo->plh_segs);
-	if (first) {
-		/* The first layoutget for the file. Need to serialize per
+	lseg = pnfs_find_lseg(lo, &arg);
+	if (lseg) {
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo,
+				PNFS_UPDATE_LAYOUT_FOUND_CACHED);
+		goto out_unlock;
+	}
+
+	if (!nfs4_valid_open_stateid(ctx->state)) {
+		lseg = ERR_PTR(-EBADF);
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
@@ -1575,16 +1566,14 @@ lookup_again:
 			pnfs_put_layout_hdr(lo);
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
@@ -1632,13 +1621,24 @@ lookup_again:
 	if (arg.length != NFS4_MAX_UINT64)
 		arg.length = PAGE_ALIGN(arg.length);
 
-	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
+	lseg = send_layoutget(lo, ctx, &stateid, &arg, &timeout, gfp_flags);
 	if (IS_ERR(lseg)) {
-		if (lseg == ERR_PTR(-EAGAIN)) {
+		if (lseg == ERR_PTR(-EAGAIN) ||
+		    lseg == ERR_PTR(-NFS4ERR_RECALLCONFLICT)) {
 			if (first)
 				pnfs_clear_first_layoutget(lo);
 			pnfs_put_layout_hdr(lo);
-			goto lookup_again;
+			if (timeout) {
+				if (lseg == ERR_PTR(-NFS4ERR_RECALLCONFLICT) &&
+				    time_after(jiffies + timeout, giveup)) {
+					lseg = NULL;
+				} else {
+					schedule_timeout(timeout);
+					goto lookup_again;
+				}
+			} else {
+				goto lookup_again;
+			}
 		}
 
 		if (!nfs_error_is_fatal(PTR_ERR(lseg)))
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 971068b58647..02d27cb90dd2 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
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
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index cb9982d8f38f..bdcf0262efc3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -233,7 +233,6 @@ struct nfs4_layoutget_args {
 	struct inode *inode;
 	struct nfs_open_context *ctx;
 	nfs4_stateid stateid;
-	unsigned long timestamp;
 	struct nfs4_layoutdriver_data layout;
 };
 
@@ -251,7 +250,7 @@ struct nfs4_layoutget {
 	struct nfs4_layoutget_res res;
 	struct rpc_cred *cred;
 	gfp_t gfp_flags;
-	long timeout;
+	long *timeout;
 };
 
 struct nfs4_getdeviceinfo_args {
-- 
2.5.5

