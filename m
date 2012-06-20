Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52992 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757789Ab2FTTDu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:03:50 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 3/4] NFSv4.1 mark layout when already returned
Date: Wed, 20 Jun 2012 15:03:33 -0400
Message-Id: <1340219014-5749-4-git-send-email-andros@netapp.com>
In-Reply-To: <1340219014-5749-1-git-send-email-andros@netapp.com>
References: <1340219014-5749-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

When the file layout driver is fencing a DS, _pnfs_return_layout can be
called mulitple times per inode due to in-flight i/o referencing lsegs on it's
plh_segs list.

Remember that LAYOUTRETURN has been called, and do not call it again.
Allow LAYOUTRETURNs after a subsequent LAYOUTGET.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   10 ++++++++--
 fs/nfs/pnfs.h |   19 +++++++++++++++++++
 2 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bbc49ca..3dfd0a6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -662,11 +662,11 @@ _pnfs_return_layout(struct inode *ino)
 	nfs4_stateid stateid;
 	int status = 0;
 
-	dprintk("--> %s\n", __func__);
+	dprintk("NFS: %s for inode %lu\n", __func__, ino->i_ino);
 
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
-	if (!lo) {
+	if (!lo || pnfs_test_layout_returned(lo)) {
 		spin_unlock(&ino->i_lock);
 		dprintk("%s: no layout to return\n", __func__);
 		return status;
@@ -676,6 +676,7 @@ _pnfs_return_layout(struct inode *ino)
 	get_layout_hdr(lo);
 	mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
 	lo->plh_block_lgets++;
+	pnfs_mark_layout_returned(lo);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 
@@ -686,6 +687,7 @@ _pnfs_return_layout(struct inode *ino)
 		status = -ENOMEM;
 		set_bit(NFS_LAYOUT_RW_FAILED, &lo->plh_flags);
 		set_bit(NFS_LAYOUT_RO_FAILED, &lo->plh_flags);
+		pnfs_clear_layout_returned(lo);
 		put_layout_hdr(lo);
 		goto out;
 	}
@@ -1075,6 +1077,10 @@ pnfs_update_layout(struct inode *ino,
 	get_layout_hdr(lo);
 	if (list_empty(&lo->plh_segs))
 		first = true;
+
+	/* Enable LAYOUTRETURNs */
+	pnfs_clear_layout_returned(lo);
+
 	spin_unlock(&ino->i_lock);
 	if (first) {
 		/* The lo must be on the clp list if there is any
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 64f90d8..f9bc98c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -64,6 +64,7 @@ enum {
 	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
 	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
 	NFS_LAYOUT_INVALID,		/* layout is being destroyed */
+	NFS_LAYOUT_RETURNED,		/* layout has already been returned */
 };
 
 enum layoutdriver_policy_flags {
@@ -255,6 +256,24 @@ struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct nfs4_deviceid_node *
 bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
 void nfs4_deviceid_purge_client(const struct nfs_client *);
 
+static inline void
+pnfs_mark_layout_returned(struct pnfs_layout_hdr *lo)
+{
+	set_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
+}
+
+static inline void
+pnfs_clear_layout_returned(struct pnfs_layout_hdr *lo)
+{
+	clear_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
+}
+
+static inline bool
+pnfs_test_layout_returned(struct pnfs_layout_hdr *lo)
+{
+	return test_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
+}
+
 static inline int lo_fail_bit(u32 iomode)
 {
 	return iomode == IOMODE_RW ?
-- 
1.7.6.4

