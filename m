Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33061 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752472AbcLAWTm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:42 -0500
Received: by mail-io0-f194.google.com with SMTP id j92so3935843ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:42 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 18/26] pNFS: Clean up - add a helper to initialise struct layoutreturn_args
Date: Thu,  1 Dec 2016 17:19:14 -0500
Message-Id: <20161201221922.15657-19-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-18-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d7b5ad437b14..a93afdd37203 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1014,6 +1014,23 @@ pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo,
 	return true;
 }
 
+static void
+pnfs_init_layoutreturn_args(struct nfs4_layoutreturn_args *args,
+		struct pnfs_layout_hdr *lo,
+		const nfs4_stateid *stateid,
+		enum pnfs_iomode iomode)
+{
+	struct inode *inode = lo->plh_inode;
+
+	args->layout_type = NFS_SERVER(inode)->pnfs_curr_ld->id;
+	args->inode = inode;
+	args->range.iomode = iomode;
+	args->range.offset = 0;
+	args->range.length = NFS4_MAX_UINT64;
+	args->layout = lo;
+	nfs4_stateid_copy(&args->stateid, stateid);
+}
+
 static int
 pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, const nfs4_stateid *stateid,
 		       enum pnfs_iomode iomode, bool sync)
@@ -1032,13 +1049,7 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, const nfs4_stateid *stateid,
 		goto out;
 	}
 
-	nfs4_stateid_copy(&lrp->args.stateid, stateid);
-	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
-	lrp->args.inode = ino;
-	lrp->args.range.iomode = iomode;
-	lrp->args.range.offset = 0;
-	lrp->args.range.length = NFS4_MAX_UINT64;
-	lrp->args.layout = lo;
+	pnfs_init_layoutreturn_args(&lrp->args, lo, stateid, iomode);
 	lrp->clp = NFS_SERVER(ino)->nfs_client;
 	lrp->cred = lo->plh_lc_cred;
 
-- 
2.9.3

