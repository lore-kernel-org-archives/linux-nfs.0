Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47286 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab0LOScH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 13:32:07 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/9] Revert "pnfs-submit: wave2: remove cl_layoutrecalls list"
Date: Wed, 15 Dec 2010 20:31:59 +0200
Message-Id: <1292437919-21862-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D0908F9.4060208@panasas.com>
References: <4D0908F9.4060208@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit a7324f1761109d4563dc71b9e03e71440f9f1c4a.

Conflicts:

	fs/nfs/callback_proc.c
	fs/nfs/pnfs.c
---
 fs/nfs/callback.h         |    4 +-
 fs/nfs/callback_proc.c    |  165 +++++++++++++++++++++++++++++++++++++++------
 fs/nfs/client.c           |    1 +
 fs/nfs/nfs4_fs.h          |    1 -
 fs/nfs/nfs4proc.c         |   10 ++-
 fs/nfs/pnfs.c             |   37 ++++++----
 fs/nfs/pnfs.h             |   13 +++-
 include/linux/nfs_fs_sb.h |    4 +
 8 files changed, 193 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index b8cafb5..7f55c7e 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -154,7 +154,6 @@ struct cb_layoutrecallargs {
 	union {
 		struct {
 			struct nfs_fh		cbl_fh;
-			struct inode		*cbl_inode;
 			struct pnfs_layout_range cbl_range;
 			nfs4_stateid		cbl_stateid;
 		};
@@ -165,6 +164,9 @@ struct cb_layoutrecallargs {
 extern unsigned nfs4_callback_layoutrecall(
 	struct cb_layoutrecallargs *args,
 	void *dummy, struct cb_process_state *cps);
+extern bool matches_outstanding_recall(struct inode *ino,
+				       struct pnfs_layout_range *range);
+extern void notify_drained(struct nfs_client *clp, u64 mask);
 
 static inline void put_session_client(struct nfs4_session *session)
 {
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index bc532b0..a9d162f 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -120,16 +120,82 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
 
 #if defined(CONFIG_NFS_V4_1)
 
-static int initiate_layout_draining(struct nfs_client *clp,
-				    struct cb_layoutrecallargs *args)
+static bool
+_recall_matches_lget(struct pnfs_cb_lrecall_info *cb_info,
+		     struct inode *ino, struct pnfs_layout_range *range)
+{
+	struct cb_layoutrecallargs *cb_args = &cb_info->pcl_args;
+
+	switch (cb_args->cbl_recall_type) {
+	case RETURN_ALL:
+		return true;
+	case RETURN_FSID:
+		return !memcmp(&NFS_SERVER(ino)->fsid, &cb_args->cbl_fsid,
+			       sizeof(struct nfs_fsid));
+	case RETURN_FILE:
+		return (ino == cb_info->pcl_ino) &&
+			should_free_lseg(range, &cb_args->cbl_range);
+	default:
+		/* Should never hit here, as decode_layoutrecall_args()
+		 * will verify cb_info from server.
+		 */
+		BUG();
+	}
+}
+
+bool
+matches_outstanding_recall(struct inode *ino, struct pnfs_layout_range *range)
 {
+	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
+	struct pnfs_cb_lrecall_info *cb_info;
+	bool rv = false;
+
+	assert_spin_locked(&clp->cl_lock);
+	list_for_each_entry(cb_info, &clp->cl_layoutrecalls, pcl_list) {
+		if (_recall_matches_lget(cb_info, ino, range)) {
+			rv = true;
+			break;
+		}
+	}
+	return rv;
+}
+
+void notify_drained(struct nfs_client *clp, u64 mask)
+{
+	atomic_t **ptr = clp->cl_drain_notification;
+
+	/* clp lock not needed except to remove used up entries */
+	/* Should probably use functions defined in bitmap.h */
+	while (mask) {
+		if ((mask & 1) && (atomic_dec_and_test(*ptr))) {
+			struct pnfs_cb_lrecall_info *cb_info;
+
+			cb_info = container_of(*ptr,
+					       struct pnfs_cb_lrecall_info,
+					       pcl_count);
+			spin_lock(&clp->cl_lock);
+			/* Removing from the list unblocks LAYOUTGETs */
+			list_del(&cb_info->pcl_list);
+			clp->cl_cb_lrecall_count--;
+			clp->cl_drain_notification[1 << cb_info->pcl_notify_bit] = NULL;
+			spin_unlock(&clp->cl_lock);
+			kfree(cb_info);
+		}
+		mask >>= 1;
+		ptr++;
+	}
+}
+
+static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
+{
+	struct nfs_client *clp = cb_info->pcl_clp;
 	struct pnfs_layout_hdr *lo;
 	int rv = NFS4ERR_NOMATCHING_LAYOUT;
+	struct cb_layoutrecallargs *args = &cb_info->pcl_args;
 
 	if (args->cbl_recall_type == RETURN_FILE) {
 		LIST_HEAD(free_me_list);
 
-		args->cbl_inode = NULL;
 		spin_lock(&clp->cl_lock);
 		list_for_each_entry(lo, &clp->cl_layouts, layouts) {
 			if (nfs_compare_fh(&args->cbl_fh,
@@ -138,12 +204,16 @@ static int initiate_layout_draining(struct nfs_client *clp,
 			if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
 				rv = NFS4ERR_DELAY;
 			else {
+				/* FIXME I need to better understand igrab and
+				 * does having a layout ref keep ino around?
+				 *  It should.
+				 */
 				/* Without this, layout can be freed as soon
 				 * as we release cl_lock.  Matched in
 				 * do_callback_layoutrecall.
 				 */
 				get_layout_hdr(lo);
-				args->cbl_inode = lo->inode;
+				cb_info->pcl_ino = lo->inode;
 				rv = NFS4_OK;
 			}
 			break;
@@ -154,6 +224,8 @@ static int initiate_layout_draining(struct nfs_client *clp,
 		if (rv == NFS4_OK) {
 			lo->plh_block_lgets++;
 			nfs4_asynch_forget_layouts(lo, &args->cbl_range,
+						   cb_info->pcl_notify_bit,
+						   &cb_info->pcl_count,
 						   &free_me_list);
 		}
 		pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
@@ -170,12 +242,18 @@ static int initiate_layout_draining(struct nfs_client *clp,
 		};
 
 		spin_lock(&clp->cl_lock);
+		/* Per RFC 5661, 12.5.5.2.1.5, bulk recall must be serialized */
+		if (!list_is_singular(&clp->cl_layoutrecalls)) {
+			spin_unlock(&clp->cl_lock);
+			return NFS4ERR_DELAY;
+		}
 		list_for_each_entry(lo, &clp->cl_layouts, layouts) {
 			if ((args->cbl_recall_type == RETURN_FSID) &&
 			    memcmp(&NFS_SERVER(lo->inode)->fsid,
 				   &args->cbl_fsid, sizeof(struct nfs_fsid)))
 				continue;
 			get_layout_hdr(lo);
+			/* We could list_del(&lo->layouts) here */
 			BUG_ON(!list_empty(&lo->plh_bulk_recall));
 			list_add(&lo->plh_bulk_recall, &recall_list);
 		}
@@ -184,7 +262,10 @@ static int initiate_layout_draining(struct nfs_client *clp,
 					 &recall_list, plh_bulk_recall) {
 			spin_lock(&lo->inode->i_lock);
 			set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
-			nfs4_asynch_forget_layouts(lo, &range, &free_me_list);
+			nfs4_asynch_forget_layouts(lo, &range,
+						   cb_info->pcl_notify_bit,
+						   &cb_info->pcl_count,
+						   &free_me_list);
 			list_del_init(&lo->plh_bulk_recall);
 			spin_unlock(&lo->inode->i_lock);
 			put_layout_hdr(lo);
@@ -198,29 +279,69 @@ static int initiate_layout_draining(struct nfs_client *clp,
 static u32 do_callback_layoutrecall(struct nfs_client *clp,
 				    struct cb_layoutrecallargs *args)
 {
-	u32 status, res = NFS4ERR_DELAY;
+	struct pnfs_cb_lrecall_info *new;
+	atomic_t **ptr;
+	int bit_num;
+	u32 res;
 
 	dprintk("%s enter, type=%i\n", __func__, args->cbl_recall_type);
-	if (test_and_set_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state))
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (!new) {
+		res = NFS4ERR_DELAY;
 		goto out;
-	atomic_inc(&clp->cl_recall_count);
-	status = initiate_layout_draining(clp, args);
-	if (atomic_dec_and_test(&clp->cl_recall_count))
-		res = NFS4ERR_NOMATCHING_LAYOUT;
-	else
+	}
+	memcpy(&new->pcl_args, args, sizeof(*args));
+	atomic_set(&new->pcl_count, 1);
+	new->pcl_clp = clp;
+	new->pcl_ino = NULL;
+	spin_lock(&clp->cl_lock);
+	if (clp->cl_cb_lrecall_count >= PNFS_MAX_CB_LRECALLS) {
+		kfree(new);
 		res = NFS4ERR_DELAY;
-	if (status)
-		res = status;
-	else if (args->cbl_recall_type == RETURN_FILE) {
-		struct pnfs_layout_hdr *lo;
+		spin_unlock(&clp->cl_lock);
+		goto out;
+	}
+	clp->cl_cb_lrecall_count++;
+	/* Adding to the list will block conflicting LGET activity */
+	list_add_tail(&new->pcl_list, &clp->cl_layoutrecalls);
+	for (bit_num = 0, ptr = clp->cl_drain_notification; *ptr; ptr++)
+		bit_num++;
+	*ptr = &new->pcl_count;
+	new->pcl_notify_bit = bit_num;
+	spin_unlock(&clp->cl_lock);
+	res = initiate_layout_draining(new);
+	if (res || atomic_dec_and_test(&new->pcl_count)) {
+		spin_lock(&clp->cl_lock);
+		list_del(&new->pcl_list);
+		clp->cl_cb_lrecall_count--;
+		clp->cl_drain_notification[1 << bit_num] = NULL;
+		spin_unlock(&clp->cl_lock);
+		if (res == NFS4_OK) {
+			if (args->cbl_recall_type == RETURN_FILE) {
+				struct pnfs_layout_hdr *lo;
+
+				lo = NFS_I(new->pcl_ino)->layout;
+				spin_lock(&lo->inode->i_lock);
+				lo->plh_block_lgets--;
+				spin_unlock(&lo->inode->i_lock);
+				put_layout_hdr(lo);
+			}
+			res = NFS4ERR_NOMATCHING_LAYOUT;
+		}
+		kfree(new);
+	} else {
+		/* We are currently using a referenced layout */
+		if (args->cbl_recall_type == RETURN_FILE) {
+			struct pnfs_layout_hdr *lo;
 
-		lo = NFS_I(args->cbl_inode)->layout;
-		spin_lock(&lo->inode->i_lock);
-		lo->plh_block_lgets--;
-		spin_unlock(&lo->inode->i_lock);
-		put_layout_hdr(lo);
+			lo = NFS_I(new->pcl_ino)->layout;
+			spin_lock(&lo->inode->i_lock);
+			lo->plh_block_lgets--;
+			spin_unlock(&lo->inode->i_lock);
+			put_layout_hdr(lo);
+		}
+		res = NFS4ERR_DELAY;
 	}
-	clear_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state);
 out:
 	dprintk("%s returning %i\n", __func__, res);
 	return res;
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9042a7a..f8e712f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -158,6 +158,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 		clp->cl_machine_cred = cred;
 #if defined(CONFIG_NFS_V4_1)
 	INIT_LIST_HEAD(&clp->cl_layouts);
+	INIT_LIST_HEAD(&clp->cl_layoutrecalls);
 #endif
 	nfs_fscache_get_client_cookie(clp);
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a917872..15fea61 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -44,7 +44,6 @@ enum nfs4_client_state {
 	NFS4CLNT_RECLAIM_REBOOT,
 	NFS4CLNT_RECLAIM_NOGRACE,
 	NFS4CLNT_DELEGRETURN,
-	NFS4CLNT_LAYOUTRECALL,
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5331f28..1c79c09 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5378,9 +5378,14 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 
 	dprintk("--> %s\n", __func__);
 
-	if (!nfs4_sequence_done(task, &lgp->res.seq_res))
+	if (!nfs4_sequence_done(task, &lgp->res.seq_res)) {
+		/* layout code relies on fact that in this case
+		 * code falls back to tk_action=call_start, but not
+		 * back to rpc_prepare_task, to keep plh_outstanding
+		 * correct.
+		 */
 		return;
-
+	}
 	switch (task->tk_status) {
 	case 0:
 		break;
@@ -5402,6 +5407,7 @@ static void nfs4_layoutget_release(void *calldata)
 	struct nfs4_layoutget *lgp = calldata;
 
 	dprintk("--> %s\n", __func__);
+	put_layout_hdr(NFS_I(lgp->args.inode)->layout);
 	if (lgp->res.layout.buf != NULL)
 		free_page((unsigned long) lgp->res.layout.buf);
 	put_nfs_open_context(lgp->args.ctx);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1899dc6..8b44c41 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -277,17 +277,17 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 	smp_mb();
 	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
 	lseg->layout = lo;
-	lseg->pls_recall_count = 0;
+	lseg->pls_notify_mask = 0;
 }
 
 static void free_lseg(struct pnfs_layout_segment *lseg)
 {
 	struct inode *ino = lseg->layout->inode;
-	int count = lseg->pls_recall_count;
+	u64 mask = lseg->pls_notify_mask;
 
 	BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	atomic_sub(count, &NFS_SERVER(ino)->nfs_client->cl_recall_count);
+	notify_drained(NFS_SERVER(ino)->nfs_client, mask);
 	/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
 	put_layout_hdr(NFS_I(ino)->layout);
 }
@@ -544,8 +544,10 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 
 	BUG_ON(ctx == NULL);
 	lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
-	if (lgp == NULL)
+	if (lgp == NULL) {
+		put_layout_hdr(lo);
 		return NULL;
+	}
 	lgp->args.minlength = NFS4_MAX_UINT64;
 	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
 	lgp->args.range.iomode = range->iomode;
@@ -569,6 +571,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 
 void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 				struct pnfs_layout_range *range,
+				int notify_bit, atomic_t *notify_count,
 				struct list_head *tmp_list)
 {
 	struct pnfs_layout_segment *lseg, *tmp;
@@ -576,8 +579,8 @@ void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 	assert_spin_locked(&lo->inode->i_lock);
 	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
 		if (should_free_lseg(&lseg->range, range)) {
-			lseg->pls_recall_count++;
-			atomic_inc(&NFS_SERVER(lo->inode)->nfs_client->cl_recall_count);
+			lseg->pls_notify_mask |= (1 << notify_bit);
+			atomic_inc(notify_count);
 			mark_lseg_invalid(lseg, tmp_list);
 		}
 }
@@ -833,6 +836,13 @@ pnfs_update_layout(struct inode *ino,
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
 		return NULL;
+	spin_lock(&clp->cl_lock);
+	if (matches_outstanding_recall(ino, &arg)) {
+		dprintk("%s matches recall, use MDS\n", __func__);
+		spin_unlock(&clp->cl_lock);
+		return NULL;
+	}
+	spin_unlock(&clp->cl_lock);
 	spin_lock(&ino->i_lock);
 	lo = pnfs_find_alloc_layout(ino);
 	if (lo == NULL) {
@@ -840,12 +850,6 @@ pnfs_update_layout(struct inode *ino,
 		goto out_unlock;
 	}
 
-	/* Do we even need to bother with this? */
-	if (test_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state) ||
-	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
-		dprintk("%s matches recall, use MDS\n", __func__);
-		goto out_unlock;
-	}
 	/* Check to see if the layout for the given range already exists */
 	lseg = pnfs_find_lseg(lo, &arg);
 	if (lseg)
@@ -883,7 +887,7 @@ pnfs_update_layout(struct inode *ino,
 		spin_unlock(&ino->i_lock);
 	}
 	atomic_dec(&lo->plh_outstanding);
-	put_layout_hdr(lo);
+	spin_unlock(&ino->i_lock);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout->plh_flags, lseg);
@@ -927,11 +931,14 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	}
 
 	spin_lock(&ino->i_lock);
-	if (test_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state) ||
-	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
+	/* decrement needs to be done before call to pnfs_layoutget_blocked */
+	spin_lock(&clp->cl_lock);
+	if (matches_outstanding_recall(ino, &res->range)) {
+		spin_unlock(&clp->cl_lock);
 		dprintk("%s forget reply due to recall\n", __func__);
 		goto out_forget_reply;
 	}
+	spin_unlock(&clp->cl_lock);
 
 	if (pnfs_layoutgets_blocked(lo, &res->stateid, 1)) {
 		dprintk("%s forget reply due to state\n", __func__);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 59eb0e8..b011b3c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -31,6 +31,7 @@
 #define FS_NFS_PNFS_H
 
 #include <linux/nfs_page.h>
+#include "callback.h"
 
 enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
@@ -42,7 +43,7 @@ struct pnfs_layout_segment {
 	atomic_t pls_refcount;
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *layout;
-	int pls_recall_count;
+	u64 pls_notify_mask;
 };
 
 enum pnfs_try_status {
@@ -126,6 +127,15 @@ struct pnfs_device {
 	unsigned int  pglen;
 };
 
+struct pnfs_cb_lrecall_info {
+	struct list_head	pcl_list; /* hook into cl_layoutrecalls list */
+	atomic_t		pcl_count;
+	int			pcl_notify_bit;
+	struct nfs_client	*pcl_clp;
+	struct inode		*pcl_ino;
+	struct cb_layoutrecallargs pcl_args;
+};
+
 /*
  * Device ID RCU cache. A device ID is unique per client ID and layout type.
  */
@@ -221,6 +231,7 @@ int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct nfs4_state *open_state);
 void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 				struct pnfs_layout_range *range,
+				int notify_bit, atomic_t *notify_count,
 				struct list_head *tmp_list);
 
 static inline bool
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 5e97d69..b02f486 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -84,6 +84,10 @@ struct nfs_client {
 	struct nfs4_session	*cl_session; 	/* sharred session */
 	struct list_head	cl_layouts;
 	atomic_t		cl_recall_count; /* no. of lsegs in recall */
+	struct list_head	cl_layoutrecalls;
+	unsigned long		cl_cb_lrecall_count;
+#define PNFS_MAX_CB_LRECALLS (64)
+	atomic_t		*cl_drain_notification[PNFS_MAX_CB_LRECALLS];
 	struct pnfs_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.7.2.3

