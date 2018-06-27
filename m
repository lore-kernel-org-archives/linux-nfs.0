Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:37154 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965557AbeF0SSz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jun 2018 14:18:55 -0400
Received: by mail-it0-f65.google.com with SMTP id p17-v6so3845572itc.2
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jun 2018 11:18:55 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([50.105.87.45])
        by smtp.gmail.com with ESMTPSA id x5-v6sm2105233ioa.65.2018.06.27.11.18.53
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Jun 2018 11:18:54 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] pNFS: Wait for stale layoutget calls to complete in pnfs_update_layout()
Date: Wed, 27 Jun 2018 14:18:28 -0400
Message-Id: <20180627181828.27680-5-trond.myklebust@hammerspace.com>
In-Reply-To: <20180627181828.27680-4-trond.myklebust@hammerspace.com>
References: <20180627181828.27680-1-trond.myklebust@hammerspace.com>
 <20180627181828.27680-2-trond.myklebust@hammerspace.com>
 <20180627181828.27680-3-trond.myklebust@hammerspace.com>
 <20180627181828.27680-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the old layout was recalled, and we returned NFS4ERR_NOMATCHINGLAYOUT
then we need to wait for all outstanding layoutget calls to complete
before we can send a new one.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 36 +++++++++++++++++++++++++++++++-----
 1 file changed, 31 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bf7f0b21066d..030c39c107c2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1740,6 +1740,17 @@ static bool pnfs_prepare_to_retry_layoutget(struct pnfs_layout_hdr *lo)
 				   TASK_UNINTERRUPTIBLE);
 }
 
+static void nfs_layoutget_begin(struct pnfs_layout_hdr *lo)
+{
+	atomic_inc(&lo->plh_outstanding);
+}
+
+static void nfs_layoutget_end(struct pnfs_layout_hdr *lo)
+{
+	if (atomic_dec_and_test(&lo->plh_outstanding))
+		wake_up_var(&lo->plh_outstanding);
+}
+
 static void pnfs_clear_first_layoutget(struct pnfs_layout_hdr *lo)
 {
 	unsigned long *bitlock = &lo->plh_flags;
@@ -1839,6 +1850,21 @@ pnfs_update_layout(struct inode *ino,
 		goto out_unlock;
 	}
 
+	/*
+	 * If the layout segment list is empty, but there are outstanding
+	 * layoutget calls, then they might be subject to a layoutrecall.
+	 */
+	if (list_empty(&lo->plh_segs) &&
+	    atomic_read(&lo->plh_outstanding) != 0) {
+		spin_unlock(&ino->i_lock);
+		if (wait_var_event_killable(&lo->plh_outstanding,
+					atomic_read(&lo->plh_outstanding) == 0
+					|| !list_empty(&lo->plh_segs)))
+			goto out_put_layout_hdr;
+		pnfs_put_layout_hdr(lo);
+		goto lookup_again;
+	}
+
 	lseg = pnfs_find_lseg(lo, &arg, strict_iomode);
 	if (lseg) {
 		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
@@ -1912,7 +1938,7 @@ pnfs_update_layout(struct inode *ino,
 				PNFS_UPDATE_LAYOUT_BLOCKED);
 		goto out_unlock;
 	}
-	atomic_inc(&lo->plh_outstanding);
+	nfs_layoutget_begin(lo);
 	spin_unlock(&ino->i_lock);
 
 	_add_to_server_list(lo, server);
@@ -1929,14 +1955,14 @@ pnfs_update_layout(struct inode *ino,
 	if (!lgp) {
 		trace_pnfs_update_layout(ino, pos, count, iomode, lo, NULL,
 					 PNFS_UPDATE_LAYOUT_NOMEM);
-		atomic_dec(&lo->plh_outstanding);
+		nfs_layoutget_end(lo);
 		goto out_put_layout_hdr;
 	}
 
 	lseg = nfs4_proc_layoutget(lgp, &timeout);
 	trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				 PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET);
-	atomic_dec(&lo->plh_outstanding);
+	nfs_layoutget_end(lo);
 	if (IS_ERR(lseg)) {
 		switch(PTR_ERR(lseg)) {
 		case -EBUSY:
@@ -2031,7 +2057,7 @@ _pnfs_grab_empty_layout(struct inode *ino, struct nfs_open_context *ctx)
 		goto out_unlock;
 	if (test_and_set_bit(NFS_LAYOUT_FIRST_LAYOUTGET, &lo->plh_flags))
 		goto out_unlock;
-	atomic_inc(&lo->plh_outstanding);
+	nfs_layoutget_begin(lo);
 	spin_unlock(&ino->i_lock);
 	_add_to_server_list(lo, NFS_SERVER(ino));
 	return lo;
@@ -2172,8 +2198,8 @@ void nfs4_lgopen_release(struct nfs4_layoutget *lgp)
 		struct inode *inode = lgp->args.inode;
 		if (inode) {
 			struct pnfs_layout_hdr *lo = NFS_I(inode)->layout;
-			atomic_dec(&lo->plh_outstanding);
 			pnfs_clear_first_layoutget(lo);
+			nfs_layoutget_end(lo);
 		}
 		pnfs_layoutget_free(lgp);
 	}
-- 
2.17.1

