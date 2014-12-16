Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f51.google.com ([209.85.220.51]:44326 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbaLPTCy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:54 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so14711303pad.38
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:53 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 27/50] nfs41: send layoutreturn in last put_lseg
Date: Tue, 16 Dec 2014 11:01:30 -0800
Message-Id: <1418756513-95187-28-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

If current lseg is the last lseg marked with NFS_LSEG_LAYOUTRETURN,
send layoutreturn.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/pnfs.c | 38 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 37 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 853b544..e9acfcf 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -50,6 +50,10 @@ static DEFINE_SPINLOCK(pnfs_spinlock);
  */
 static LIST_HEAD(pnfs_modules_tbl);
 
+static int
+pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
+		       enum pnfs_iomode iomode);
+
 /* Return the registered pnfs layout driver module matching given id */
 static struct pnfs_layoutdriver_type *
 find_pnfs_driver_locked(u32 id)
@@ -337,6 +341,29 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
 
+/* Return true if layoutreturn is needed */
+static bool
+pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
+			struct pnfs_layout_segment *lseg,
+			nfs4_stateid *stateid, enum pnfs_iomode *iomode)
+{
+	struct pnfs_layout_segment *s;
+
+	if (!test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
+		return false;
+
+	list_for_each_entry(s, &lo->plh_segs, pls_list)
+		if (test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
+			return false;
+
+	*stateid = lo->plh_stateid;
+	*iomode = lo->plh_return_iomode;
+	/* decreased in pnfs_send_layoutreturn() */
+	lo->plh_block_lgets++;
+	lo->plh_return_iomode = 0;
+	return true;
+}
+
 void
 pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 {
@@ -352,11 +379,20 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 	lo = lseg->pls_layout;
 	inode = lo->plh_inode;
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
+		bool need_return;
+		nfs4_stateid stateid;
+		enum pnfs_iomode iomode;
+
 		pnfs_get_layout_hdr(lo);
 		pnfs_layout_remove_lseg(lo, lseg);
+		need_return = pnfs_layout_need_return(lo, lseg,
+						      &stateid, &iomode);
 		spin_unlock(&inode->i_lock);
 		pnfs_free_lseg(lseg);
-		pnfs_put_layout_hdr(lo);
+		if (need_return)
+			pnfs_send_layoutreturn(lo, stateid, iomode);
+		else
+			pnfs_put_layout_hdr(lo);
 	}
 }
 EXPORT_SYMBOL_GPL(pnfs_put_lseg);
-- 
1.9.3

