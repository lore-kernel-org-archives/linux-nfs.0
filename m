Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47208 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab1BUWaw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 17:30:52 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 7/9] pnfs: fix cl_drain_notification indexing
Date: Mon, 21 Feb 2011 14:30:48 -0800
Message-Id: <1298327448-8993-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D62E6F3.8000304@panasas.com>
References: <4D62E6F3.8000304@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

cl_drain_notification is an actual index into cl_drain_notification
and a bit index into pls_notify_mask.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |   27 ++++++++++++++++-----------
 fs/nfs/pnfs.c          |    4 ++--
 fs/nfs/pnfs.h          |    2 +-
 3 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 5e4b5d1..dd295e2 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -197,8 +197,10 @@ void nfs_client_return_layouts(struct nfs_client *clp)
 					   struct pnfs_cb_lrecall_info,
 					   pcl_list);
 		spin_unlock(&clp->cl_lock);
+		/* Were all recalled lsegs already forgotten */
 		if (atomic_read(&cb_info->pcl_count) != 0)
 			break;
+
 		/* What do on error return?  These layoutreturns are
 		 * required by the protocol.  So if do not get
 		 * successful reply, probably have to do something
@@ -209,7 +211,7 @@ void nfs_client_return_layouts(struct nfs_client *clp)
 		/* Removing from the list unblocks LAYOUTGETs */
 		list_del(&cb_info->pcl_list);
 		clp->cl_cb_lrecall_count--;
-		clp->cl_drain_notification[1 << cb_info->pcl_notify_bit] = NULL;
+		clp->cl_drain_notification[cb_info->pcl_notify_idx] = NULL;
 		spin_unlock(&clp->cl_lock);
 		rpc_wake_up(&clp->cl_rpcwaitq_recall);
 		kfree(cb_info);
@@ -224,7 +226,7 @@ void notify_drained(struct nfs_client *clp, u64 mask)
 	/* clp lock not needed except to remove used up entries */
 	/* Should probably use functions defined in bitmap.h */
 	while (mask) {
-		if ((mask & 1) && (atomic_dec_and_test(*ptr)))
+		if ((mask & 1) && atomic_dec_and_test(*ptr))
 			done = true;
 		mask >>= 1;
 		ptr++;
@@ -272,7 +274,7 @@ static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
 		if (rv == NFS4_OK) {
 			lo->plh_block_lgets++;
 			if (nfs4_asynch_forget_layouts(lo, &args->cbl_range,
-						       cb_info->pcl_notify_bit,
+						       cb_info->pcl_notify_idx,
 						       &cb_info->pcl_count,
 						       &free_me_list))
 				rv = NFS4ERR_DELAY;
@@ -314,7 +316,7 @@ static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
 			spin_lock(&lo->inode->i_lock);
 			set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 			if (nfs4_asynch_forget_layouts(lo, &range,
-						       cb_info->pcl_notify_bit,
+						       cb_info->pcl_notify_idx,
 						       &cb_info->pcl_count,
 						       &free_me_list))
 				rv = NFS4ERR_DELAY;
@@ -334,8 +336,7 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 				    struct cb_layoutrecallargs *args)
 {
 	struct pnfs_cb_lrecall_info *new;
-	atomic_t **ptr;
-	int bit_num;
+	int i;
 	u32 res;
 
 	dprintk("%s enter, type=%i\n", __func__, args->cbl_recall_type);
@@ -353,22 +354,26 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 		kfree(new);
 		res = NFS4ERR_DELAY;
 		spin_unlock(&clp->cl_lock);
+		dprintk("%s: too many layout recalls\n", __func__);
 		goto out;
 	}
 	clp->cl_cb_lrecall_count++;
 	/* Adding to the list will block conflicting LGET activity */
 	list_add_tail(&new->pcl_list, &clp->cl_layoutrecalls);
-	for (bit_num = 0, ptr = clp->cl_drain_notification; *ptr; ptr++)
-		bit_num++;
-	*ptr = &new->pcl_count;
-	new->pcl_notify_bit = bit_num;
+	for (i = 0; i < PNFS_MAX_CB_LRECALLS; i++)
+		if (!clp->cl_drain_notification[i]) {
+			clp->cl_drain_notification[i] = &new->pcl_count;
+			break;
+		}
+	BUG_ON(i >= PNFS_MAX_CB_LRECALLS);
+	new->pcl_notify_idx = i;
 	spin_unlock(&clp->cl_lock);
 	res = initiate_layout_draining(new);
 	if (res || atomic_dec_and_test(&new->pcl_count)) {
 		spin_lock(&clp->cl_lock);
 		list_del(&new->pcl_list);
 		clp->cl_cb_lrecall_count--;
-		clp->cl_drain_notification[1 << bit_num] = NULL;
+		clp->cl_drain_notification[new->pcl_notify_idx] = NULL;
 		rpc_wake_up(&clp->cl_rpcwaitq_recall);
 		spin_unlock(&clp->cl_lock);
 		if (res == NFS4_OK) {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7507054..8c5f4b4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -642,7 +642,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 
 bool nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 				struct pnfs_layout_range *range,
-				int notify_bit, atomic_t *notify_count,
+				int notify_idx, atomic_t *notify_count,
 				struct list_head *tmp_list)
 {
 	bool rv = false;
@@ -652,7 +652,7 @@ bool nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 	dprintk("%s\n", __func__);
 	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
 		if (should_free_lseg(&lseg->range, range)) {
-			lseg->pls_notify_mask |= (1 << notify_bit);
+			lseg->pls_notify_mask |= (1 << notify_idx);
 			atomic_inc(notify_count);
 			mark_lseg_invalid(lseg, tmp_list);
 			rv = true;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 11c6ee4..092559b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -179,7 +179,7 @@ struct pnfs_device {
 struct pnfs_cb_lrecall_info {
 	struct list_head	pcl_list; /* hook into cl_layoutrecalls list */
 	atomic_t		pcl_count;
-	int			pcl_notify_bit;
+	int			pcl_notify_idx;
 	struct nfs_client	*pcl_clp;
 	struct inode		*pcl_ino;
 	struct cb_layoutrecallargs pcl_args;
-- 
1.7.3.4

