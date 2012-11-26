Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:65420 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975Ab2KZJaS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Nov 2012 04:30:18 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so4338389eek.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 01:30:17 -0800 (PST)
From: Benny Halevy <bhalevy@tonian.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfs: improve debug prints in filelayout_set_layoutcommit
Date: Mon, 26 Nov 2012 11:30:14 +0200
Message-Id: <1353922214-27796-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/nfs4filelayout.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 2e45fd9..5b5ce82 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -266,11 +266,16 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 	struct nfs_pgio_header *hdr = wdata->header;
 
 	if (FILELAYOUT_LSEG(hdr->lseg)->commit_through_mds ||
-	    wdata->res.verf->committed == NFS_FILE_SYNC)
+	    wdata->res.verf->committed == NFS_FILE_SYNC) {
+		dprintk("%s inode %lu commit_through_mds %d committed %d\n",
+			__func__, hdr->inode->i_ino,
+			FILELAYOUT_LSEG(hdr->lseg)->commit_through_mds != 0,
+			wdata->res.verf->committed == NFS_FILE_SYNC);
 		return;
+	}
 
 	pnfs_set_layoutcommit(wdata);
-	dprintk("%s ionde %lu pls_end_pos %lu\n", __func__, hdr->inode->i_ino,
+	dprintk("%s inode %lu pls_end_pos %lu\n", __func__, hdr->inode->i_ino,
 		(unsigned long) NFS_I(hdr->inode)->layout->plh_lwb);
 }
 
-- 
1.7.11.7

