Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33111 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759812AbcLAWTs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:48 -0500
Received: by mail-io0-f193.google.com with SMTP id j92so3936338ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:47 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 25/26] pNFS: Wait on outstanding layoutreturns to complete in pnfs_roc()
Date: Thu,  1 Dec 2016 17:19:21 -0500
Message-Id: <20161201221922.15657-26-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-25-trond.myklebust@primarydata.com>
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
 <20161201221922.15657-23-trond.myklebust@primarydata.com>
 <20161201221922.15657-24-trond.myklebust@primarydata.com>
 <20161201221922.15657-25-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 57ec46b57364..550010826bdd 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1245,11 +1245,20 @@ bool pnfs_roc(struct inode *ino,
 
 	if (!nfs_have_layout(ino))
 		return false;
+retry:
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
 	if (!lo || !pnfs_layout_is_valid(lo) ||
 	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
 		goto out_noroc;
+	if (test_bit(NFS_LAYOUT_RETURN_LOCK, &lo->plh_flags)) {
+		pnfs_get_layout_hdr(lo);
+		spin_unlock(&ino->i_lock);
+		wait_on_bit(&lo->plh_flags, NFS_LAYOUT_RETURN,
+				TASK_UNINTERRUPTIBLE);
+		pnfs_put_layout_hdr(lo);
+		goto retry;
+	}
 
 	/* no roc if we hold a delegation */
 	if (nfs4_check_delegation(ino, FMODE_READ))
-- 
2.9.3

