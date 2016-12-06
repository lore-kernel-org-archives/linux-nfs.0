Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36417 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751563AbcLFDxH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2016 22:53:07 -0500
Received: by mail-io0-f193.google.com with SMTP id s82so4265908ioi.3
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2016 19:53:07 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS: Release NFS_LAYOUT_RETURN when invalidating the layout stateid
Date: Mon,  5 Dec 2016 22:53:03 -0500
Message-Id: <20161206035303.14160-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure we release the NFS_LAYOUT_RETURN lock when we invalidate the
layout stateid, so that processes and RPC tasks that are waiting on
the layout return can continue.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 00aba090c847..fc79d2e778aa 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -281,6 +281,15 @@ pnfs_clear_layoutreturn_info(struct pnfs_layout_hdr *lo)
 	clear_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
 }
 
+static void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
+{
+	clear_bit_unlock(NFS_LAYOUT_RETURN, &lo->plh_flags);
+	clear_bit(NFS_LAYOUT_RETURN_LOCK, &lo->plh_flags);
+	smp_mb__after_atomic();
+	wake_up_bit(&lo->plh_flags, NFS_LAYOUT_RETURN);
+	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
+}
+
 static void
 pnfs_clear_lseg_state(struct pnfs_layout_segment *lseg,
 		struct list_head *free_me)
@@ -316,6 +325,9 @@ pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
 		pnfs_clear_lseg_state(lseg, lseg_list);
 	pnfs_free_returned_lsegs(lo, lseg_list, &range, 0);
+	if (test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags) &&
+	    !test_and_set_bit(NFS_LAYOUT_RETURN_LOCK, &lo->plh_flags))
+		pnfs_clear_layoutreturn_waitbit(lo);
 	return !list_empty(&lo->plh_segs);
 }
 
@@ -953,15 +965,6 @@ static void pnfs_clear_layoutcommit(struct inode *inode,
 	}
 }
 
-static void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
-{
-	clear_bit_unlock(NFS_LAYOUT_RETURN, &lo->plh_flags);
-	clear_bit(NFS_LAYOUT_RETURN_LOCK, &lo->plh_flags);
-	smp_mb__after_atomic();
-	wake_up_bit(&lo->plh_flags, NFS_LAYOUT_RETURN);
-	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
-}
-
 void pnfs_layoutreturn_free_lsegs(struct pnfs_layout_hdr *lo,
 		const nfs4_stateid *arg_stateid,
 		const struct pnfs_layout_range *range,
-- 
2.9.3

