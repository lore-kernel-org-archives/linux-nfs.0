Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:41883 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727267AbeIEWj1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 18:39:27 -0400
Received: by mail-io0-f193.google.com with SMTP id q4-v6so6698987iob.8
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 11:08:08 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] pNFS: Ensure we return the error if someone kills a waiting layoutget
Date: Wed,  5 Sep 2018 14:07:12 -0400
Message-Id: <20180905180715.99485-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If someone interrupts a wait on one or more outstanding layoutgets in
pnfs_update_layout() then return the ERESTARTSYS/EINTR error.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e8f232de484f..7d9a51e6b847 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1740,16 +1740,16 @@ static bool pnfs_within_mdsthreshold(struct nfs_open_context *ctx,
 	return ret;
 }
 
-static bool pnfs_prepare_to_retry_layoutget(struct pnfs_layout_hdr *lo)
+static int pnfs_prepare_to_retry_layoutget(struct pnfs_layout_hdr *lo)
 {
 	/*
 	 * send layoutcommit as it can hold up layoutreturn due to lseg
 	 * reference
 	 */
 	pnfs_layoutcommit_inode(lo->plh_inode, false);
-	return !wait_on_bit_action(&lo->plh_flags, NFS_LAYOUT_RETURN,
+	return wait_on_bit_action(&lo->plh_flags, NFS_LAYOUT_RETURN,
 				   nfs_wait_bit_killable,
-				   TASK_UNINTERRUPTIBLE);
+				   TASK_KILLABLE);
 }
 
 static void nfs_layoutget_begin(struct pnfs_layout_hdr *lo)
@@ -1830,7 +1830,9 @@ pnfs_update_layout(struct inode *ino,
 	}
 
 lookup_again:
-	nfs4_client_recover_expired_lease(clp);
+	lseg = ERR_PTR(nfs4_client_recover_expired_lease(clp));
+	if (IS_ERR(lseg))
+		goto out;
 	first = false;
 	spin_lock(&ino->i_lock);
 	lo = pnfs_find_alloc_layout(ino, ctx, gfp_flags);
@@ -1863,9 +1865,9 @@ pnfs_update_layout(struct inode *ino,
 	if (list_empty(&lo->plh_segs) &&
 	    atomic_read(&lo->plh_outstanding) != 0) {
 		spin_unlock(&ino->i_lock);
-		if (wait_var_event_killable(&lo->plh_outstanding,
-					atomic_read(&lo->plh_outstanding) == 0
-					|| !list_empty(&lo->plh_segs)))
+		lseg = ERR_PTR(wait_var_event_killable(&lo->plh_outstanding,
+					atomic_read(&lo->plh_outstanding)));
+		if (IS_ERR(lseg) || !list_empty(&lo->plh_segs))
 			goto out_put_layout_hdr;
 		pnfs_put_layout_hdr(lo);
 		goto lookup_again;
@@ -1898,8 +1900,11 @@ pnfs_update_layout(struct inode *ino,
 		if (test_and_set_bit(NFS_LAYOUT_FIRST_LAYOUTGET,
 				     &lo->plh_flags)) {
 			spin_unlock(&ino->i_lock);
-			wait_on_bit(&lo->plh_flags, NFS_LAYOUT_FIRST_LAYOUTGET,
-				    TASK_UNINTERRUPTIBLE);
+			lseg = ERR_PTR(wait_on_bit(&lo->plh_flags,
+						NFS_LAYOUT_FIRST_LAYOUTGET,
+						TASK_KILLABLE));
+			if (IS_ERR(lseg))
+				goto out_put_layout_hdr;
 			pnfs_put_layout_hdr(lo);
 			dprintk("%s retrying\n", __func__);
 			goto lookup_again;
@@ -1925,7 +1930,8 @@ pnfs_update_layout(struct inode *ino,
 	if (test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags)) {
 		spin_unlock(&ino->i_lock);
 		dprintk("%s wait for layoutreturn\n", __func__);
-		if (pnfs_prepare_to_retry_layoutget(lo)) {
+		lseg = ERR_PTR(pnfs_prepare_to_retry_layoutget(lo));
+		if (!IS_ERR(lseg)) {
 			if (first)
 				pnfs_clear_first_layoutget(lo);
 			pnfs_put_layout_hdr(lo);
-- 
2.17.1
