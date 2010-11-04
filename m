Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33439 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493Ab0KDPWz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Nov 2010 11:22:55 -0400
Received: from localhost.localdomain (dnsindia.hq.netapp.com [10.58.52.94] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oA4FMYMa029583
	for <linux-nfs@vger.kernel.org>; Thu, 4 Nov 2010 08:22:48 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 14/18] pnfs-submit: increase number of outstanding CB_LAYOUTRECALLS we can handle
Date: Thu,  4 Nov 2010 11:22:27 -0400
Message-Id: <1288884151-11128-15-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
References: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback.h         |    1 +
 fs/nfs/callback_proc.c    |   35 +++++++++++++++++++++++++++++------
 fs/nfs/pnfs.c             |   24 +++++++++---------------
 fs/nfs/pnfs.h             |    7 +++----
 include/linux/nfs_fs_sb.h |    3 ++-
 5 files changed, 44 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index c1c7f3e..8d3184c 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -163,6 +163,7 @@ extern unsigned nfs4_callback_layoutrecall(
 	void *dummy, struct cb_process_state *cps);
 extern bool matches_outstanding_recall(struct inode *ino,
 				       struct pnfs_layout_range *range);
+extern void notify_drained(struct nfs_client *clp, u64 mask);
 #endif /* CONFIG_NFS_V4_1 */
 
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 583446b..6e21add 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -229,16 +229,28 @@ void nfs_client_return_layouts(struct nfs_client *clp)
 		/* Removing from the list unblocks LAYOUTGETs */
 		list_del(&cb_info->pcl_list);
 		clp->cl_cb_lrecall_count--;
+		clp->cl_drain_notification[1 << cb_info->pcl_notify_bit] = NULL;
 		rpc_wake_up(&clp->cl_rpcwaitq_recall);
 		kfree(cb_info);
 	}
 }
 
-void notify_drained(struct pnfs_cb_lrecall_info *d)
+void notify_drained(struct nfs_client *clp, u64 mask)
 {
-	if (d && atomic_dec_and_test(&d->pcl_count)) {
-		set_bit(NFS4CLNT_LAYOUT_RECALL, &d->pcl_clp->cl_state);
-		nfs4_schedule_state_manager(d->pcl_clp);
+	atomic_t **ptr = clp->cl_drain_notification;
+	bool done = false;
+
+	/* clp lock not needed except to remove used up entries */
+	/* Should probably use functions defined in bitmap.h */
+	while (mask) {
+		if ((mask & 1) && (atomic_dec_and_test(*ptr)))
+			done = true;
+		mask >>= 1;
+		ptr++;
+	}
+	if (done) {
+		set_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
+		nfs4_schedule_state_manager(clp);
 	}
 }
 
@@ -279,7 +291,9 @@ static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
 		if (rv == NFS4_OK) {
 			lo->plh_block_lgets++;
 			nfs4_asynch_forget_layouts(lo, &args->cbl_range,
-						   cb_info, &free_me_list);
+						   cb_info->pcl_notify_bit,
+						   &cb_info->pcl_count,
+						   &free_me_list);
 		}
 		pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 		spin_unlock(&lo->inode->i_lock);
@@ -315,7 +329,9 @@ static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
 					 &recall_list, plh_bulk_recall) {
 			spin_lock(&lo->inode->i_lock);
 			set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
-			nfs4_asynch_forget_layouts(lo, &range, cb_info,
+			nfs4_asynch_forget_layouts(lo, &range,
+						   cb_info->pcl_notify_bit,
+						   &cb_info->pcl_count,
 						   &free_me_list);
 			list_del_init(&lo->plh_bulk_recall);
 			spin_unlock(&lo->inode->i_lock);
@@ -331,6 +347,8 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 				    struct cb_layoutrecallargs *args)
 {
 	struct pnfs_cb_lrecall_info *new;
+	atomic_t **ptr;
+	int bit_num;
 	u32 res;
 
 	dprintk("%s enter, type=%i\n", __func__, args->cbl_recall_type);
@@ -353,12 +371,17 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 	clp->cl_cb_lrecall_count++;
 	/* Adding to the list will block conflicting LGET activity */
 	list_add_tail(&new->pcl_list, &clp->cl_layoutrecalls);
+	for (bit_num = 0, ptr = clp->cl_drain_notification; *ptr; ptr++)
+		bit_num++;
+	*ptr = &new->pcl_count;
+	new->pcl_notify_bit = bit_num;
 	spin_unlock(&clp->cl_lock);
 	res = initiate_layout_draining(new);
 	if (res || atomic_dec_and_test(&new->pcl_count)) {
 		spin_lock(&clp->cl_lock);
 		list_del(&new->pcl_list);
 		clp->cl_cb_lrecall_count--;
+		clp->cl_drain_notification[1 << bit_num] = NULL;
 		rpc_wake_up(&clp->cl_rpcwaitq_recall);
 		spin_unlock(&clp->cl_lock);
 		if (res == NFS4_OK) {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8d04cf2..02f2eb8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -278,7 +278,7 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 	smp_mb();
 	lseg->valid = true;
 	lseg->layout = lo;
-	lseg->drain_notification = NULL;
+	lseg->pls_notify_mask = 0;
 }
 
 static void
@@ -330,12 +330,12 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		atomic_read(&lseg->pls_refcount), lseg->valid);
 	ino = lseg->layout->inode;
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &ino->i_lock)) {
-		struct pnfs_cb_lrecall_info *drain_info = lseg->drain_notification;
+		u64 mask = lseg->pls_notify_mask;
 
 		_put_lseg_common(lseg);
 		spin_unlock(&ino->i_lock);
 		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-		notify_drained(drain_info);
+		notify_drained(NFS_SERVER(ino)->nfs_client, mask);
 		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
 		put_layout_hdr(ino);
 	}
@@ -401,14 +401,14 @@ pnfs_free_lseg_list(struct list_head *free_me)
 {
 	struct pnfs_layout_segment *lseg, *tmp;
 	struct inode *ino;
-	struct pnfs_cb_lrecall_info *drain_info;
+	u64 mask;
 
 	list_for_each_entry_safe(lseg, tmp, free_me, fi_list) {
 		BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
 		ino = lseg->layout->inode;
-		drain_info = lseg->drain_notification;
+		mask = lseg->pls_notify_mask;
 		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-		notify_drained(drain_info);
+		notify_drained(NFS_SERVER(ino)->nfs_client, mask);
 		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
 		put_layout_hdr(ino);
 	}
@@ -594,7 +594,7 @@ has_layout_to_return(struct pnfs_layout_hdr *lo,
 
 void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 				struct pnfs_layout_range *range,
-				struct pnfs_cb_lrecall_info *drain_info,
+				int notify_bit, atomic_t *notify_count,
 				struct list_head *tmp_list)
 {
 	struct pnfs_layout_segment *lseg, *tmp;
@@ -602,14 +602,8 @@ void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 	assert_spin_locked(&lo->inode->i_lock);
 	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
 		if (should_free_lseg(&lseg->range, range)) {
-			/* FIXME - need to change to something like a
-			 * notification bitmap to remove the restriction
-			 * of only being able to process a single
-			 * CB_LAYOUTRECALL at a time.
-			 */
-			BUG_ON(lseg->drain_notification);
-			lseg->drain_notification = drain_info;
-			atomic_inc(&drain_info->pcl_count);
+			lseg->pls_notify_mask |= (1 << notify_bit);
+			atomic_inc(notify_count);
 			mark_lseg_invalid(lseg, tmp_list);
 		}
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 810714a..b84e362 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -39,7 +39,7 @@ struct pnfs_layout_segment {
 	atomic_t pls_refcount;
 	bool valid;
 	struct pnfs_layout_hdr *layout;
-	struct pnfs_cb_lrecall_info *drain_notification;
+	u64 pls_notify_mask;
 };
 
 enum pnfs_try_status {
@@ -126,6 +126,7 @@ struct pnfs_device {
 struct pnfs_cb_lrecall_info {
 	struct list_head	pcl_list; /* hook into cl_layoutrecalls list */
 	atomic_t		pcl_count;
+	int			pcl_notify_bit;
 	struct nfs_client	*pcl_clp;
 	struct inode		*pcl_ino;
 	struct cb_layoutrecallargs pcl_args;
@@ -232,10 +233,8 @@ int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct nfs4_state *open_state);
 void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 				struct pnfs_layout_range *range,
-				struct pnfs_cb_lrecall_info *drain_info,
+				int notify_bit, atomic_t *notify_count,
 				struct list_head *tmp_list);
-/* FIXME - this should be in callback.h, but pnfs_cb_lrecall_info needs to be there too */
-extern void notify_drained(struct pnfs_cb_lrecall_info *d);
 
 static inline bool
 has_layout(struct nfs_inode *nfsi)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 80dcc00..295d449 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -85,7 +85,8 @@ struct nfs_client {
 	struct list_head	cl_layouts;
 	struct list_head	cl_layoutrecalls;
 	unsigned long		cl_cb_lrecall_count;
-#define PNFS_MAX_CB_LRECALLS (1)
+#define PNFS_MAX_CB_LRECALLS (64)
+	atomic_t		*cl_drain_notification[PNFS_MAX_CB_LRECALLS];
 	struct rpc_wait_queue	cl_rpcwaitq_recall;
 	struct pnfs_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.7.2.1

