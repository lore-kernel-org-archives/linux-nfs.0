Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32865 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753014AbcGVTeh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2016 15:34:37 -0400
Received: by mail-io0-f194.google.com with SMTP id y195so8011958iod.0
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2016 12:34:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] pNFS: Ensure layoutreturn acts as a completion for layout callbacks
Date: Fri, 22 Jul 2016 15:33:54 -0400
Message-Id: <1469216038-71882-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469216038-71882-2-git-send-email-trond.myklebust@primarydata.com>
References: <1469216038-71882-1-git-send-email-trond.myklebust@primarydata.com>
 <1469216038-71882-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we return NFS_OK to the CB_LAYOUTRECALL, we are required to
send a layoutreturn that "completes" that layout recall request, using
the correct stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 40 +++++++++++++++++++++++++---------------
 1 file changed, 25 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 27052d4b46ef..7a29598d8ab0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -880,12 +880,28 @@ pnfs_clear_layoutreturn_info(struct pnfs_layout_hdr *lo)
 }
 
 static bool
-pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo)
+pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo,
+		nfs4_stateid *stateid,
+		enum pnfs_iomode *iomode)
 {
 	if (test_and_set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
 		return false;
 	pnfs_get_layout_hdr(lo);
-	pnfs_clear_layoutreturn_info(lo);
+	if (test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags)) {
+		if (stateid != NULL) {
+			nfs4_stateid_copy(stateid, &lo->plh_stateid);
+			if (lo->plh_return_seq != 0)
+				stateid->seqid = cpu_to_be32(lo->plh_return_seq);
+		}
+		if (iomode != NULL)
+			*iomode = lo->plh_return_iomode;
+		pnfs_clear_layoutreturn_info(lo);
+		return true;
+	}
+	if (stateid != NULL)
+		nfs4_stateid_copy(stateid, &lo->plh_stateid);
+	if (iomode != NULL)
+		*iomode = IOMODE_ANY;
 	return true;
 }
 
@@ -953,10 +969,7 @@ static void pnfs_layoutreturn_before_put_layout_hdr(struct pnfs_layout_hdr *lo)
 		enum pnfs_iomode iomode;
 		bool send;
 
-		nfs4_stateid_copy(&stateid, &lo->plh_stateid);
-		stateid.seqid = cpu_to_be32(lo->plh_return_seq);
-		iomode = lo->plh_return_iomode;
-		send = pnfs_prepare_layoutreturn(lo);
+		send = pnfs_prepare_layoutreturn(lo, &stateid, &iomode);
 		spin_unlock(&inode->i_lock);
 		if (send) {
 			/* Send an async layoutreturn so we dont deadlock */
@@ -993,7 +1006,6 @@ _pnfs_return_layout(struct inode *ino)
 		dprintk("NFS: %s no layout to return\n", __func__);
 		goto out;
 	}
-	nfs4_stateid_copy(&stateid, &nfsi->layout->plh_stateid);
 	/* Reference matched in nfs4_layoutreturn_release */
 	pnfs_get_layout_hdr(lo);
 	empty = list_empty(&lo->plh_segs);
@@ -1017,7 +1029,7 @@ _pnfs_return_layout(struct inode *ino)
 	}
 
 	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
-	send = pnfs_prepare_layoutreturn(lo);
+	send = pnfs_prepare_layoutreturn(lo, &stateid, NULL);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 	if (send)
@@ -1084,11 +1096,10 @@ bool pnfs_roc(struct inode *ino)
 			goto out_noroc;
 	}
 
-	nfs4_stateid_copy(&stateid, &lo->plh_stateid);
 	/* always send layoutreturn if being marked so */
-	if (test_and_clear_bit(NFS_LAYOUT_RETURN_REQUESTED,
-				   &lo->plh_flags))
-		layoutreturn = pnfs_prepare_layoutreturn(lo);
+	if (test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags))
+		layoutreturn = pnfs_prepare_layoutreturn(lo,
+				&stateid, NULL);
 
 	list_for_each_entry_safe(lseg, tmp, &lo->plh_segs, pls_list)
 		/* If we are sending layoutreturn, invalidate all valid lsegs */
@@ -1869,10 +1880,9 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 	if (!pnfs_mark_matching_lsegs_return(lo, &free_me,
 						&range, lseg->pls_seq)) {
 		nfs4_stateid stateid;
-		enum pnfs_iomode iomode = lo->plh_return_iomode;
+		enum pnfs_iomode iomode;
 
-		nfs4_stateid_copy(&stateid, &lo->plh_stateid);
-		return_now = pnfs_prepare_layoutreturn(lo);
+		return_now = pnfs_prepare_layoutreturn(lo, &stateid, &iomode);
 		spin_unlock(&inode->i_lock);
 		if (return_now)
 			pnfs_send_layoutreturn(lo, &stateid, iomode, false);
-- 
2.7.4

