Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2771 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753319Ab0LOQDZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 11:03:25 -0500
Received: from localhost.localdomain (vpn2ntap-71744.hq.netapp.com [10.58.57.236])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBFG3Lov001580
	for <linux-nfs@vger.kernel.org>; Wed, 15 Dec 2010 08:03:24 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/11] wave 2: rename notify fields
Date: Wed, 15 Dec 2010 11:03:06 -0500
Message-Id: <1292428991-30788-6-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
References: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Due to code changes, these no longer are involved in any notification.
Instead, they are just counts, so name appropriately.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c    |    4 ++--
 fs/nfs/pnfs.c             |   10 +++++-----
 fs/nfs/pnfs.h             |    2 +-
 include/linux/nfs_fs_sb.h |    2 +-
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index a5fa786..918d6c5 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -202,9 +202,9 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 	dprintk("%s enter, type=%i\n", __func__, args->cbl_recall_type);
 	if (test_and_set_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state))
 		goto out;
-	atomic_inc(&clp->cl_drain_notify);
+	atomic_inc(&clp->cl_recall_count);
 	status = initiate_layout_draining(clp, args);
-	if (atomic_dec_and_test(&clp->cl_drain_notify))
+	if (atomic_dec_and_test(&clp->cl_recall_count))
 		res = NFS4ERR_NOMATCHING_LAYOUT;
 	else
 		res = NFS4ERR_DELAY;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index dadc113..f2360af 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -277,17 +277,17 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 	smp_mb();
 	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
 	lseg->layout = lo;
-	lseg->pls_notify_count = 0;
+	lseg->pls_recall_count = 0;
 }
 
 static void free_lseg(struct pnfs_layout_segment *lseg)
 {
 	struct inode *ino = lseg->layout->inode;
-	int count = lseg->pls_notify_count;
+	int count = lseg->pls_recall_count;
 
 	BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	atomic_sub(count, &NFS_SERVER(ino)->nfs_client->cl_drain_notify);
+	atomic_sub(count, &NFS_SERVER(ino)->nfs_client->cl_recall_count);
 	/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
 	put_layout_hdr(NFS_I(ino)->layout);
 }
@@ -590,8 +590,8 @@ void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 	assert_spin_locked(&lo->inode->i_lock);
 	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
 		if (should_free_lseg(&lseg->range, range)) {
-			lseg->pls_notify_count++;
-			atomic_inc(&NFS_SERVER(lo->inode)->nfs_client->cl_drain_notify);
+			lseg->pls_recall_count++;
+			atomic_inc(&NFS_SERVER(lo->inode)->nfs_client->cl_recall_count);
 			mark_lseg_invalid(lseg, tmp_list);
 		}
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f77a35b..deedcca 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -44,7 +44,7 @@ struct pnfs_layout_segment {
 	atomic_t pls_refcount;
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *layout;
-	int pls_notify_count;
+	int pls_recall_count;
 };
 
 enum pnfs_try_status {
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 7162c88..e0739a5 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -84,7 +84,7 @@ struct nfs_client {
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
 	struct list_head	cl_layouts;
-	atomic_t		cl_drain_notify;
+	atomic_t		cl_recall_count; /* no. of lsegs in recall */
 	struct pnfs_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.7.2.1

