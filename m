From: andros@netapp.com
Subject: [PATCH 5/5] pnfs: set failed layout bit per iomode
Date: Fri,  5 Feb 2010 12:10:13 -0500
Message-ID: <1265389813-6823-6-git-send-email-andros@netapp.com>
References: <1265389813-6823-1-git-send-email-andros@netapp.com>
 <1265389813-6823-2-git-send-email-andros@netapp.com>
 <1265389813-6823-3-git-send-email-andros@netapp.com>
 <1265389813-6823-4-git-send-email-andros@netapp.com>
 <1265389813-6823-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16541 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933525Ab0BERJh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 12:09:37 -0500
In-Reply-To: <1265389813-6823-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c          |    6 +++---
 fs/nfs/pnfs.h          |    6 ++++++
 include/linux/nfs_fs.h |    5 +++--
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3a05422..596cfce 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1119,11 +1119,11 @@ pnfs_update_layout(struct inode *ino,
 	}
 
 	/* if get layout already failed once goto out */
-	if (test_bit(NFS_INO_LAYOUT_FAILED, &nfsi->pnfs_layout_state)) {
+	if (test_bit(lo_fail_bit(iomode), &nfsi->pnfs_layout_state)) {
 		if (unlikely(nfsi->pnfs_layout_suspend &&
 		    get_seconds() >= nfsi->pnfs_layout_suspend)) {
 			dprintk("%s: layout_get resumed\n", __func__);
-			clear_bit(NFS_INO_LAYOUT_FAILED,
+			clear_bit(lo_fail_bit(iomode),
 				  &nfsi->pnfs_layout_state);
 			nfsi->pnfs_layout_suspend = 0;
 		} else {
@@ -1247,7 +1247,7 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
 get_out:
 	/* remember that get layout failed and suspend trying */
 	nfsi->pnfs_layout_suspend = suspend;
-	set_bit(NFS_INO_LAYOUT_FAILED, &nfsi->pnfs_layout_state);
+	set_bit(lo_fail_bit(lgp->args.lseg.iomode), &nfsi->pnfs_layout_state);
 	dprintk("%s: layout_get suspended until %ld\n",
 		__func__, suspend);
 out:
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 379e67d..312c4ef 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -94,6 +94,12 @@ void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 				     (srv)->pnfs_curr_ld->ld_policy_ops && \
 				     (srv)->pnfs_curr_ld->ld_policy_ops->opname)
 
+static inline int lo_fail_bit(u32 iomode)
+{
+	return iomode == IOMODE_RW ?
+			 NFS_INO_RW_LAYOUT_FAILED : NFS_INO_RO_LAYOUT_FAILED;
+}
+
 /* Return true if a layout driver is being used for this mountpoint */
 static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index fc0990a..dd57a6a 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -201,8 +201,9 @@ struct nfs_inode {
 	struct list_head	lo_inodes;
 
 	unsigned long pnfs_layout_state;
-#define NFS_INO_LAYOUT_FAILED	0	/* get layout failed, stop trying */
-#define NFS_INO_LAYOUT_ALLOC	1	/* bit lock for layout allocation */
+#define NFS_INO_RO_LAYOUT_FAILED 0 	/* get ro layout failed stop trying */
+#define NFS_INO_RW_LAYOUT_FAILED 1 	/* get rw layout failed stop trying */
+#define NFS_INO_LAYOUT_ALLOC     2	/* bit lock for layout allocation */
 	time_t pnfs_layout_suspend;
 	wait_queue_head_t lo_waitq;
 	spinlock_t lo_lock;
-- 
1.6.6

