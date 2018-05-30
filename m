Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:54808 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753659AbeE3SGd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:33 -0400
Received: by mail-it0-f68.google.com with SMTP id 76-v6so9077597itx.4
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:32 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.31
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:31 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 18/19] pnfs: Don't call commit on failed layoutget-on-open
Date: Wed, 30 May 2018 14:05:52 -0400
Message-Id: <20180530180553.38769-19-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-18-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com>
 <20180530180553.38769-5-trond.myklebust@hammerspace.com>
 <20180530180553.38769-6-trond.myklebust@hammerspace.com>
 <20180530180553.38769-7-trond.myklebust@hammerspace.com>
 <20180530180553.38769-8-trond.myklebust@hammerspace.com>
 <20180530180553.38769-9-trond.myklebust@hammerspace.com>
 <20180530180553.38769-10-trond.myklebust@hammerspace.com>
 <20180530180553.38769-11-trond.myklebust@hammerspace.com>
 <20180530180553.38769-12-trond.myklebust@hammerspace.com>
 <20180530180553.38769-13-trond.myklebust@hammerspace.com>
 <20180530180553.38769-14-trond.myklebust@hammerspace.com>
 <20180530180553.38769-15-trond.myklebust@hammerspace.com>
 <20180530180553.38769-16-trond.myklebust@hammerspace.com>
 <20180530180553.38769-17-trond.myklebust@hammerspace.com>
 <20180530180553.38769-18-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the layoutget on open call failed, we can't really commit the inode,
so don't bother calling it.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5fc4d84d9326..545e9e2c6201 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2098,10 +2098,7 @@ void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
 				lgp->callback_count))
 		return;
 	lseg = pnfs_layout_process(lgp);
-	if (IS_ERR(lseg)) {
-		/* ignore lseg, but would like to mark not to try lgopen */
-		/* clear some lo flags - first and fail ???? */
-	} else {
+	if (!IS_ERR(lseg)) {
 		iomode = lgp->args.range.iomode;
 		pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
 		pnfs_put_lseg(lseg);
@@ -2173,8 +2170,6 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	spin_unlock(&ino->i_lock);
 	lseg->pls_layout = lo;
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	if (!pnfs_layout_is_valid(lo))
-		nfs_commit_inode(ino, 0);
 	return ERR_PTR(-EAGAIN);
 }
 
-- 
2.17.0

