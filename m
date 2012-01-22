Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:53668 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab2AVODo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jan 2012 09:03:44 -0500
Received: by werb13 with SMTP id b13so1529515wer.19
        for <linux-nfs@vger.kernel.org>; Sun, 22 Jan 2012 06:03:43 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH] pnfs: clean up initiate_file_draining layout lookup
Date: Sun, 22 Jan 2012 16:03:39 +0200
Message-Id: <1327241019-7863-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes the following compiler warning:

fs/nfs/callback_proc.c: In function 'do_callback_layoutrecall':
fs/nfs/callback_proc.c:115:26: warning: 'lo' may be used uninitialized in this function

Reported-by: Jim Rees <rees@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/callback_proc.c |   56 ++++++++++++++++++++++++++++++++---------------
 1 files changed, 38 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 43926ad..e8d83a7 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -108,42 +108,62 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
 
 #if defined(CONFIG_NFS_V4_1)
 
-static u32 initiate_file_draining(struct nfs_client *clp,
-				  struct cb_layoutrecallargs *args)
+/*
+ * Lookup a layout by filehandle.
+ *
+ * Note: gets a refcount on the layout hdr and on its respective inode.
+ * Caller must put the layout hdr and the inode.
+ *
+ * TODO: keep track of all layouts (and delegations) in a hash table
+ * hashed by filehandle.
+ */
+static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp, struct nfs_fh *fh)
 {
 	struct nfs_server *server;
-	struct pnfs_layout_hdr *lo;
 	struct inode *ino;
-	bool found = false;
-	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
-	LIST_HEAD(free_me_list);
+	struct pnfs_layout_hdr *lo;
 
-	spin_lock(&clp->cl_lock);
-	rcu_read_lock();
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		list_for_each_entry(lo, &server->layouts, plh_layouts) {
-			if (nfs_compare_fh(&args->cbl_fh,
-					   &NFS_I(lo->plh_inode)->fh))
+			if (nfs_compare_fh(fh, &NFS_I(lo->plh_inode)->fh))
 				continue;
 			ino = igrab(lo->plh_inode);
 			if (!ino)
 				continue;
-			found = true;
-			/* Without this, layout can be freed as soon
-			 * as we release cl_lock.
-			 */
 			get_layout_hdr(lo);
-			break;
+			return lo;
 		}
-		if (found)
-			break;
 	}
+
+	return NULL;
+}
+
+static struct pnfs_layout_hdr * get_layout_by_fh(struct nfs_client *clp, struct nfs_fh *fh)
+{
+	struct pnfs_layout_hdr *lo;
+
+	spin_lock(&clp->cl_lock);
+	rcu_read_lock();
+	lo = get_layout_by_fh_locked(clp, fh);
 	rcu_read_unlock();
 	spin_unlock(&clp->cl_lock);
 
-	if (!found)
+	return lo;
+}
+
+static u32 initiate_file_draining(struct nfs_client *clp,
+				  struct cb_layoutrecallargs *args)
+{
+	struct inode *ino;
+	struct pnfs_layout_hdr *lo;
+	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
+	LIST_HEAD(free_me_list);
+
+	lo = get_layout_by_fh(clp, &args->cbl_fh);
+	if (!lo)
 		return NFS4ERR_NOMATCHING_LAYOUT;
 
+	ino = lo->plh_inode;
 	spin_lock(&ino->i_lock);
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 	    mark_matching_lsegs_invalid(lo, &free_me_list,
-- 
1.7.6.5

