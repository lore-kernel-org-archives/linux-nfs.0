Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:51341 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbaLXHOU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:14:20 -0500
Received: by mail-ie0-f181.google.com with SMTP id rl12so5470228iec.40
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:14:19 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 48/49] nfs41: wait for LAYOUTRETURN before retrying LAYOUTGET
Date: Tue, 23 Dec 2014 23:13:27 -0800
Message-Id: <1419405208-25975-49-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Also take care to stop waiting if someone clears retry bit.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4proc.c |  4 +++-
 fs/nfs/pnfs.c     | 39 ++++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h     |  5 ++++-
 3 files changed, 45 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 72c5e01..f05e965 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7786,7 +7786,9 @@ static void nfs4_layoutreturn_release(void *calldata)
 	spin_lock(&lo->plh_inode->i_lock);
 	if (lrp->res.lrs_present)
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
-	clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
+	clear_bit_unlock(NFS_LAYOUT_RETURN, &lo->plh_flags);
+	smp_mb__after_atomic();
+	wake_up_bit(&lo->plh_flags, NFS_LAYOUT_RETURN);
 	clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags);
 	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
 	lo->plh_block_lgets--;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index fec1d897..8c1440d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1404,6 +1404,26 @@ static bool pnfs_within_mdsthreshold(struct nfs_open_context *ctx,
 	return ret;
 }
 
+/* stop waiting if someone clears NFS_LAYOUT_RETRY_LAYOUTGET bit. */
+static int pnfs_layoutget_retry_bit_wait(struct wait_bit_key *key)
+{
+	if (!test_bit(NFS_LAYOUT_RETRY_LAYOUTGET, key->flags))
+		return 1;
+	return nfs_wait_bit_killable(key);
+}
+
+static bool pnfs_prepare_to_retry_layoutget(struct pnfs_layout_hdr *lo)
+{
+	/*
+	 * send layoutcommit as it can hold up layoutreturn due to lseg
+	 * reference
+	 */
+	pnfs_layoutcommit_inode(lo->plh_inode, false);
+	return !wait_on_bit_action(&lo->plh_flags, NFS_LAYOUT_RETURN,
+				   pnfs_layoutget_retry_bit_wait,
+				   TASK_UNINTERRUPTIBLE);
+}
+
 /*
  * Layout segment is retreived from the server if not cached.
  * The appropriate layout segment is referenced and returned to the caller.
@@ -1450,7 +1470,8 @@ lookup_again:
 	}
 
 	/* if LAYOUTGET already failed once we don't try again */
-	if (pnfs_layout_io_test_failed(lo, iomode))
+	if (pnfs_layout_io_test_failed(lo, iomode) &&
+	    !pnfs_should_retry_layoutget(lo))
 		goto out_unlock;
 
 	first = list_empty(&lo->plh_segs);
@@ -1475,6 +1496,22 @@ lookup_again:
 			goto out_unlock;
 	}
 
+	/*
+	 * Because we free lsegs before sending LAYOUTRETURN, we need to wait
+	 * for LAYOUTRETURN even if first is true.
+	 */
+	if (!lseg && pnfs_should_retry_layoutget(lo) &&
+	    test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags)) {
+		spin_unlock(&ino->i_lock);
+		dprintk("%s wait for layoutreturn\n", __func__);
+		if (pnfs_prepare_to_retry_layoutget(lo)) {
+			pnfs_put_layout_hdr(lo);
+			dprintk("%s retrying\n", __func__);
+			goto lookup_again;
+		}
+		goto out_put_layout_hdr;
+	}
+
 	if (pnfs_layoutgets_blocked(lo, &arg, 0))
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 67a436b..c2b4328 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -358,8 +358,11 @@ static inline void pnfs_set_retry_layoutget(struct pnfs_layout_hdr *lo)
 
 static inline void pnfs_clear_retry_layoutget(struct pnfs_layout_hdr *lo)
 {
-	if (test_and_clear_bit(NFS_LAYOUT_RETRY_LAYOUTGET, &lo->plh_flags))
+	if (test_and_clear_bit(NFS_LAYOUT_RETRY_LAYOUTGET, &lo->plh_flags)) {
 		atomic_dec(&lo->plh_refcount);
+		/* wake up waiters for LAYOUTRETURN as that is not needed */
+		wake_up_bit(&lo->plh_flags, NFS_LAYOUT_RETURN);
+	}
 }
 
 static inline bool pnfs_should_retry_layoutget(struct pnfs_layout_hdr *lo)
-- 
1.9.3

