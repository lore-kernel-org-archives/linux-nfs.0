Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36763 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759884AbcLAWTp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:45 -0500
Received: by mail-io0-f193.google.com with SMTP id s82so3822195ioi.3
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:45 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 22/26] pNFS: Fix bugs in _pnfs_return_layout
Date: Thu,  1 Dec 2016 17:19:18 -0500
Message-Id: <20161201221922.15657-23-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-22-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
 <20161201221922.15657-9-trond.myklebust@primarydata.com>
 <20161201221922.15657-10-trond.myklebust@primarydata.com>
 <20161201221922.15657-11-trond.myklebust@primarydata.com>
 <20161201221922.15657-12-trond.myklebust@primarydata.com>
 <20161201221922.15657-13-trond.myklebust@primarydata.com>
 <20161201221922.15657-14-trond.myklebust@primarydata.com>
 <20161201221922.15657-15-trond.myklebust@primarydata.com>
 <20161201221922.15657-16-trond.myklebust@primarydata.com>
 <20161201221922.15657-17-trond.myklebust@primarydata.com>
 <20161201221922.15657-18-trond.myklebust@primarydata.com>
 <20161201221922.15657-19-trond.myklebust@primarydata.com>
 <20161201221922.15657-20-trond.myklebust@primarydata.com>
 <20161201221922.15657-21-trond.myklebust@primarydata.com>
 <20161201221922.15657-22-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to honour the NFS_LAYOUT_RETURN_REQUESTED bit regardless of
whether or not there are layout segments pending.
Furthermore, we should ensure that we leave the plh_return_segs list
empty.

This patch fixes a memory leak of the layout segments on plh_return_segs.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 76b18518881e..a3a51860563c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1145,7 +1145,7 @@ _pnfs_return_layout(struct inode *ino)
 	struct nfs_inode *nfsi = NFS_I(ino);
 	LIST_HEAD(tmp_list);
 	nfs4_stateid stateid;
-	int status = 0, empty;
+	int status = 0;
 	bool send;
 
 	dprintk("NFS: %s for inode %lu\n", __func__, ino->i_ino);
@@ -1159,7 +1159,14 @@ _pnfs_return_layout(struct inode *ino)
 	}
 	/* Reference matched in nfs4_layoutreturn_release */
 	pnfs_get_layout_hdr(lo);
-	empty = list_empty(&lo->plh_segs);
+	/* Is there an outstanding layoutreturn ? */
+	if (test_bit(NFS_LAYOUT_RETURN_LOCK, &lo->plh_flags)) {
+		spin_unlock(&ino->i_lock);
+		if (wait_on_bit(&lo->plh_flags, NFS_LAYOUT_RETURN,
+					TASK_UNINTERRUPTIBLE))
+			goto out_put_layout_hdr;
+		spin_lock(&ino->i_lock);
+	}
 	pnfs_clear_layoutcommit(ino, &tmp_list);
 	pnfs_mark_matching_lsegs_invalid(lo, &tmp_list, NULL, 0);
 
@@ -1173,7 +1180,7 @@ _pnfs_return_layout(struct inode *ino)
 	}
 
 	/* Don't send a LAYOUTRETURN if list was initially empty */
-	if (empty) {
+	if (!test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags)) {
 		spin_unlock(&ino->i_lock);
 		dprintk("NFS: %s no layout segments to return\n", __func__);
 		goto out_put_layout_hdr;
-- 
2.9.3

