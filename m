Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:32914 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664AbbLZXVq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:21:46 -0500
Received: by mail-io0-f173.google.com with SMTP id 186so283846712iow.0
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:21:46 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/14] pNFS/flexfiles: Don't prevent flexfiles client from retrying LAYOUTGET
Date: Sat, 26 Dec 2015 18:20:56 -0500
Message-Id: <1451172060-28238-10-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451172060-28238-9-git-send-email-trond.myklebust@primarydata.com>
References: <1451172060-28238-1-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-4-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-5-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-6-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-7-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-8-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-9-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a bug in which flexfiles clients are falling back to I/O through the
MDS even when the FF_FLAGS_NO_IO_THRU_MDS flag is set.

The flexfiles client will always report errors through the LAYOUTRETURN
and/or LAYOUTERROR mechanisms, so it should normally be safe for it
to retry the LAYOUTGET until it fails or succeeds.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    |  4 ----
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 16 ++++------------
 fs/nfs/pnfs.c                             | 18 ++----------------
 fs/nfs/pnfs.h                             | 21 ---------------------
 4 files changed, 6 insertions(+), 53 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 5ede5c26c757..1da19d709458 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1399,11 +1399,9 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 
 	switch (err) {
 	case -NFS4ERR_RESET_TO_PNFS:
-		pnfs_set_retry_layoutget(hdr->lseg->pls_layout);
 		ff_layout_reset_write(hdr, true);
 		return task->tk_status;
 	case -NFS4ERR_RESET_TO_MDS:
-		pnfs_clear_retry_layoutget(hdr->lseg->pls_layout);
 		ff_layout_reset_write(hdr, false);
 		return task->tk_status;
 	case -EAGAIN:
@@ -1438,11 +1436,9 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 
 	switch (err) {
 	case -NFS4ERR_RESET_TO_PNFS:
-		pnfs_set_retry_layoutget(data->lseg->pls_layout);
 		pnfs_generic_prepare_to_resend_writes(data);
 		return -EAGAIN;
 	case -NFS4ERR_RESET_TO_MDS:
-		pnfs_clear_retry_layoutget(data->lseg->pls_layout);
 		pnfs_generic_prepare_to_resend_writes(data);
 		return -EAGAIN;
 	case -EAGAIN:
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index e125e55de86d..bd0327541366 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -429,22 +429,14 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 					 mirror, lseg->pls_range.offset,
 					 lseg->pls_range.length, NFS4ERR_NXIO,
 					 OP_ILLEGAL, GFP_NOIO);
-		if (fail_return) {
-			pnfs_error_mark_layout_for_return(ino, lseg);
-			if (ff_layout_has_available_ds(lseg))
-				pnfs_set_retry_layoutget(lseg->pls_layout);
-			else
-				pnfs_clear_retry_layoutget(lseg->pls_layout);
-
-		} else {
+		if (!fail_return) {
 			if (ff_layout_has_available_ds(lseg))
 				set_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
 					&lseg->pls_layout->plh_flags);
-			else {
+			else
 				pnfs_error_mark_layout_for_return(ino, lseg);
-				pnfs_clear_retry_layoutget(lseg->pls_layout);
-			}
-		}
+		} else
+			pnfs_error_mark_layout_for_return(ino, lseg);
 	}
 out_update_creds:
 	if (ff_layout_update_mirror_cred(mirror, ds))
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 580207bc52a5..6b42362cdbb0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -618,7 +618,6 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 		pnfs_get_layout_hdr(lo);
 		pnfs_layout_clear_fail_bit(lo, NFS_LAYOUT_RO_FAILED);
 		pnfs_layout_clear_fail_bit(lo, NFS_LAYOUT_RW_FAILED);
-		pnfs_clear_retry_layoutget(lo);
 		spin_unlock(&nfsi->vfs_inode.i_lock);
 		pnfs_free_lseg_list(&tmp_list);
 		pnfs_put_layout_hdr(lo);
@@ -1094,7 +1093,6 @@ bool pnfs_roc(struct inode *ino)
 				   &lo->plh_flags))
 		layoutreturn = pnfs_prepare_layoutreturn(lo);
 
-	pnfs_clear_retry_layoutget(lo);
 	list_for_each_entry_safe(lseg, tmp, &lo->plh_segs, pls_list)
 		/* If we are sending layoutreturn, invalidate all valid lsegs */
 		if (layoutreturn || test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
@@ -1457,25 +1455,15 @@ static bool pnfs_within_mdsthreshold(struct nfs_open_context *ctx,
 	return ret;
 }
 
-/* stop waiting if someone clears NFS_LAYOUT_RETRY_LAYOUTGET bit. */
-static int pnfs_layoutget_retry_bit_wait(struct wait_bit_key *key, int mode)
-{
-	if (!test_bit(NFS_LAYOUT_RETRY_LAYOUTGET, key->flags))
-		return 1;
-	return nfs_wait_bit_killable(key, mode);
-}
-
 static bool pnfs_prepare_to_retry_layoutget(struct pnfs_layout_hdr *lo)
 {
-	if (!pnfs_should_retry_layoutget(lo))
-		return false;
 	/*
 	 * send layoutcommit as it can hold up layoutreturn due to lseg
 	 * reference
 	 */
 	pnfs_layoutcommit_inode(lo->plh_inode, false);
 	return !wait_on_bit_action(&lo->plh_flags, NFS_LAYOUT_RETURN,
-				   pnfs_layoutget_retry_bit_wait,
+				   nfs_wait_bit_killable,
 				   TASK_UNINTERRUPTIBLE);
 }
 
@@ -1550,8 +1538,7 @@ lookup_again:
 	}
 
 	/* if LAYOUTGET already failed once we don't try again */
-	if (pnfs_layout_io_test_failed(lo, iomode) &&
-	    !pnfs_should_retry_layoutget(lo)) {
+	if (pnfs_layout_io_test_failed(lo, iomode)) {
 		trace_pnfs_update_layout(ino, pos, count, iomode, lo,
 				 PNFS_UPDATE_LAYOUT_IO_TEST_FAIL);
 		goto out_unlock;
@@ -1628,7 +1615,6 @@ lookup_again:
 		arg.length = PAGE_CACHE_ALIGN(arg.length);
 
 	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
-	pnfs_clear_retry_layoutget(lo);
 	atomic_dec(&lo->plh_outstanding);
 	trace_pnfs_update_layout(ino, pos, count, iomode, lo,
 				 PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d1990e90e7a0..6916ff4e86f9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -98,7 +98,6 @@ enum {
 	NFS_LAYOUT_RETURN_BEFORE_CLOSE,	/* Return this layout before close */
 	NFS_LAYOUT_INVALID_STID,	/* layout stateid id is invalid */
 	NFS_LAYOUT_FIRST_LAYOUTGET,	/* Serialize first layoutget */
-	NFS_LAYOUT_RETRY_LAYOUTGET,	/* Retry layoutget */
 };
 
 enum layoutdriver_policy_flags {
@@ -379,26 +378,6 @@ nfs4_get_deviceid(struct nfs4_deviceid_node *d)
 	return d;
 }
 
-static inline void pnfs_set_retry_layoutget(struct pnfs_layout_hdr *lo)
-{
-	if (!test_and_set_bit(NFS_LAYOUT_RETRY_LAYOUTGET, &lo->plh_flags))
-		atomic_inc(&lo->plh_refcount);
-}
-
-static inline void pnfs_clear_retry_layoutget(struct pnfs_layout_hdr *lo)
-{
-	if (test_and_clear_bit(NFS_LAYOUT_RETRY_LAYOUTGET, &lo->plh_flags)) {
-		atomic_dec(&lo->plh_refcount);
-		/* wake up waiters for LAYOUTRETURN as that is not needed */
-		wake_up_bit(&lo->plh_flags, NFS_LAYOUT_RETURN);
-	}
-}
-
-static inline bool pnfs_should_retry_layoutget(struct pnfs_layout_hdr *lo)
-{
-	return test_bit(NFS_LAYOUT_RETRY_LAYOUTGET, &lo->plh_flags);
-}
-
 static inline struct pnfs_layout_segment *
 pnfs_get_lseg(struct pnfs_layout_segment *lseg)
 {
-- 
2.5.0

