Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37805 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbcA2Edw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jan 2016 23:33:52 -0500
Received: by mail-ig0-f179.google.com with SMTP id h5so26615567igh.0
        for <linux-nfs@vger.kernel.org>; Thu, 28 Jan 2016 20:33:52 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] pNFS: Fix missing layoutreturn calls
Date: Thu, 28 Jan 2016 23:33:13 -0500
Message-Id: <1454041994-58090-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The layoutreturn code currently relies on pnfs_put_lseg() to initiate the
RPC call when conditions are right. A problem arises when we want to
free the layout segment from inside an inode->i_lock section (e.g. in
pnfs_clear_request_commit()), since we cannot sleep.

The workaround is to move the actual call to pnfs_send_layoutreturn()
to pnfs_put_layout_hdr(), which doesn't have this restriction.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 118 ++++++++++++++++++++++++++++------------------------------
 1 file changed, 56 insertions(+), 62 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a3592cc34a20..9c20685d4961 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -52,9 +52,7 @@ static DEFINE_SPINLOCK(pnfs_spinlock);
  */
 static LIST_HEAD(pnfs_modules_tbl);
 
-static int
-pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, const nfs4_stateid *stateid,
-		       enum pnfs_iomode iomode, bool sync);
+static void pnfs_layoutreturn_before_put_layout_hdr(struct pnfs_layout_hdr *lo);
 
 /* Return the registered pnfs layout driver module matching given id */
 static struct pnfs_layoutdriver_type *
@@ -243,6 +241,8 @@ pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo)
 {
 	struct inode *inode = lo->plh_inode;
 
+	pnfs_layoutreturn_before_put_layout_hdr(lo);
+
 	if (atomic_dec_and_lock(&lo->plh_refcount, &inode->i_lock)) {
 		if (!list_empty(&lo->plh_segs))
 			WARN_ONCE(1, "NFS: BUG unfreed layout segments.\n");
@@ -345,58 +345,6 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
 
-/* Return true if layoutreturn is needed */
-static bool
-pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
-			struct pnfs_layout_segment *lseg)
-{
-	struct pnfs_layout_segment *s;
-
-	if (!test_and_clear_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
-		return false;
-
-	list_for_each_entry(s, &lo->plh_segs, pls_list)
-		if (s != lseg && test_bit(NFS_LSEG_LAYOUTRETURN, &s->pls_flags))
-			return false;
-
-	return true;
-}
-
-static bool
-pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo)
-{
-	if (test_and_set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
-		return false;
-	lo->plh_return_iomode = 0;
-	pnfs_get_layout_hdr(lo);
-	clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags);
-	return true;
-}
-
-static void pnfs_layoutreturn_before_put_lseg(struct pnfs_layout_segment *lseg,
-		struct pnfs_layout_hdr *lo, struct inode *inode)
-{
-	lo = lseg->pls_layout;
-	inode = lo->plh_inode;
-
-	spin_lock(&inode->i_lock);
-	if (pnfs_layout_need_return(lo, lseg)) {
-		nfs4_stateid stateid;
-		enum pnfs_iomode iomode;
-		bool send;
-
-		nfs4_stateid_copy(&stateid, &lo->plh_stateid);
-		iomode = lo->plh_return_iomode;
-		send = pnfs_prepare_layoutreturn(lo);
-		spin_unlock(&inode->i_lock);
-		if (send) {
-			/* Send an async layoutreturn so we dont deadlock */
-			pnfs_send_layoutreturn(lo, &stateid, iomode, false);
-		}
-	} else
-		spin_unlock(&inode->i_lock);
-}
-
 void
 pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 {
@@ -410,15 +358,8 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 		atomic_read(&lseg->pls_refcount),
 		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 
-	/* Handle the case where refcount != 1 */
-	if (atomic_add_unless(&lseg->pls_refcount, -1, 1))
-		return;
-
 	lo = lseg->pls_layout;
 	inode = lo->plh_inode;
-	/* Do we need a layoutreturn? */
-	if (test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
-		pnfs_layoutreturn_before_put_lseg(lseg, lo, inode);
 
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags)) {
@@ -937,6 +878,17 @@ void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
 	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
 }
 
+static bool
+pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo)
+{
+	if (test_and_set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
+		return false;
+	lo->plh_return_iomode = 0;
+	pnfs_get_layout_hdr(lo);
+	clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags);
+	return true;
+}
+
 static int
 pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, const nfs4_stateid *stateid,
 		       enum pnfs_iomode iomode, bool sync)
@@ -971,6 +923,48 @@ out:
 	return status;
 }
 
+/* Return true if layoutreturn is needed */
+static bool
+pnfs_layout_need_return(struct pnfs_layout_hdr *lo)
+{
+	struct pnfs_layout_segment *s;
+
+	if (!test_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags))
+		return false;
+
+	/* Defer layoutreturn until all lsegs are done */
+	list_for_each_entry(s, &lo->plh_segs, pls_list) {
+		if (test_bit(NFS_LSEG_LAYOUTRETURN, &s->pls_flags))
+			return false;
+	}
+
+	return true;
+}
+
+static void pnfs_layoutreturn_before_put_layout_hdr(struct pnfs_layout_hdr *lo)
+{
+	struct inode *inode= lo->plh_inode;
+
+	if (!test_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags))
+		return;
+	spin_lock(&inode->i_lock);
+	if (pnfs_layout_need_return(lo)) {
+		nfs4_stateid stateid;
+		enum pnfs_iomode iomode;
+		bool send;
+
+		nfs4_stateid_copy(&stateid, &lo->plh_stateid);
+		iomode = lo->plh_return_iomode;
+		send = pnfs_prepare_layoutreturn(lo);
+		spin_unlock(&inode->i_lock);
+		if (send) {
+			/* Send an async layoutreturn so we dont deadlock */
+			pnfs_send_layoutreturn(lo, &stateid, iomode, false);
+		}
+	} else
+		spin_unlock(&inode->i_lock);
+}
+
 /*
  * Initiates a LAYOUTRETURN(FILE), and removes the pnfs_layout_hdr
  * when the layout segment list is empty.
-- 
2.5.0

