Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34599 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753817AbcLAWTa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:30 -0500
Received: by mail-io0-f195.google.com with SMTP id r94so3916882ioe.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:30 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/26] pNFS: On error, do not send LAYOUTGET until the LAYOUTRETURN has completed
Date: Thu,  1 Dec 2016 17:19:01 -0500
Message-Id: <20161201221922.15657-6-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-5-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there is an I/O error, we should not call LAYOUTGET until the
LAYOUTRETURN that reports the error is complete.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org # v4.8+
---
 fs/nfs/pnfs.c | 6 +++++-
 fs/nfs/pnfs.h | 1 +
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9b7e88b7edfc..06bfcd277006 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -947,6 +947,7 @@ static void pnfs_clear_layoutcommit(struct inode *inode,
 void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
 {
 	clear_bit_unlock(NFS_LAYOUT_RETURN, &lo->plh_flags);
+	clear_bit(NFS_LAYOUT_RETURN_LOCK, &lo->plh_flags);
 	smp_mb__after_atomic();
 	wake_up_bit(&lo->plh_flags, NFS_LAYOUT_RETURN);
 	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
@@ -960,8 +961,9 @@ pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo,
 	/* Serialise LAYOUTGET/LAYOUTRETURN */
 	if (atomic_read(&lo->plh_outstanding) != 0)
 		return false;
-	if (test_and_set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
+	if (test_and_set_bit(NFS_LAYOUT_RETURN_LOCK, &lo->plh_flags))
 		return false;
+	set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
 	pnfs_get_layout_hdr(lo);
 	if (test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags)) {
 		if (stateid != NULL) {
@@ -1954,6 +1956,8 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 
 	spin_lock(&inode->i_lock);
 	pnfs_set_plh_return_info(lo, range.iomode, 0);
+	/* Block LAYOUTGET */
+	set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
 	/*
 	 * mark all matching lsegs so that we are sure to have no live
 	 * segments at hand when sending layoutreturn. See pnfs_put_lseg()
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5c295512c967..44cad8afda0e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -96,6 +96,7 @@ enum {
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_RETURN,		/* layoutreturn in progress */
+	NFS_LAYOUT_RETURN_LOCK,		/* Serialise layoutreturn */
 	NFS_LAYOUT_RETURN_REQUESTED,	/* Return this layout ASAP */
 	NFS_LAYOUT_INVALID_STID,	/* layout stateid id is invalid */
 	NFS_LAYOUT_FIRST_LAYOUTGET,	/* Serialize first layoutget */
-- 
2.9.3

