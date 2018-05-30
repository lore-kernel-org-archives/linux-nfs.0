Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36214 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932091AbeE3SGZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:25 -0400
Received: by mail-io0-f194.google.com with SMTP id d73-v6so22697071iog.3
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:25 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.24
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:24 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/19] pnfs: Change pnfs_alloc_init_layoutget_args call signature
Date: Wed, 30 May 2018 14:05:43 -0400
Message-Id: <20180530180553.38769-10-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-9-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com>
 <20180530180553.38769-5-trond.myklebust@hammerspace.com>
 <20180530180553.38769-6-trond.myklebust@hammerspace.com>
 <20180530180553.38769-7-trond.myklebust@hammerspace.com>
 <20180530180553.38769-8-trond.myklebust@hammerspace.com>
 <20180530180553.38769-9-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

Don't send in a layout, instead use the (possibly NULL) inode.

This is needed for LAYOUTGET attached to an OPEN where the inode is not
yet set.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 40 ++++++++++++++++++++++++++++------------
 1 file changed, 28 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 11148414b9b6..07f1bbd9100c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -916,18 +916,31 @@ pnfs_layoutgets_blocked(const struct pnfs_layout_hdr *lo)
 		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 }
 
+static struct nfs_server *
+pnfs_find_server(struct inode *inode, struct nfs_open_context *ctx)
+{
+	struct nfs_server *server;
+
+	if (inode)
+		server = NFS_SERVER(inode);
+	else {
+		struct dentry *parent_dir = dget_parent(ctx->dentry);
+		server = NFS_SERVER(parent_dir->d_inode);
+		dput(parent_dir);
+	}
+	return server;
+}
+
 static struct nfs4_layoutget *
-pnfs_alloc_init_layoutget_args(struct pnfs_layout_hdr *lo,
+pnfs_alloc_init_layoutget_args(struct inode *ino,
 	   struct nfs_open_context *ctx,
 	   nfs4_stateid *stateid,
 	   const struct pnfs_layout_range *range,
 	   gfp_t gfp_flags)
 {
-	struct inode *ino = lo->plh_inode;
-	struct nfs_server *server = NFS_SERVER(ino);
+	struct nfs_server *server = pnfs_find_server(ino, ctx);
 	size_t max_pages = max_response_pages(server);
 	struct nfs4_layoutget *lgp;
-	loff_t i_size;
 
 	dprintk("--> %s\n", __func__);
 
@@ -944,16 +957,19 @@ pnfs_alloc_init_layoutget_args(struct pnfs_layout_hdr *lo,
 	lgp->res.layoutp = &lgp->args.layout;
 
 
-	i_size = i_size_read(ino);
 
 	lgp->args.minlength = PAGE_SIZE;
 	if (lgp->args.minlength > range->length)
 		lgp->args.minlength = range->length;
-	if (range->iomode == IOMODE_READ) {
-		if (range->offset >= i_size)
-			lgp->args.minlength = 0;
-		else if (i_size - range->offset < lgp->args.minlength)
-			lgp->args.minlength = i_size - range->offset;
+	if (ino) {
+		loff_t i_size = i_size_read(ino);
+
+		if (range->iomode == IOMODE_READ) {
+			if (range->offset >= i_size)
+				lgp->args.minlength = 0;
+			else if (i_size - range->offset < lgp->args.minlength)
+				lgp->args.minlength = i_size - range->offset;
+		}
 	}
 	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
 	pnfs_copy_range(&lgp->args.range, range);
@@ -962,7 +978,7 @@ pnfs_alloc_init_layoutget_args(struct pnfs_layout_hdr *lo,
 	lgp->args.ctx = get_nfs_open_context(ctx);
 	nfs4_stateid_copy(&lgp->args.stateid, stateid);
 	lgp->gfp_flags = gfp_flags;
-	lgp->cred = lo->plh_lc_cred;
+	lgp->cred = ctx->cred;
 	return lgp;
 }
 
@@ -1838,7 +1854,7 @@ pnfs_update_layout(struct inode *ino,
 	if (arg.length != NFS4_MAX_UINT64)
 		arg.length = PAGE_ALIGN(arg.length);
 
-	lgp = pnfs_alloc_init_layoutget_args(lo, ctx, &stateid, &arg, gfp_flags);
+	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &stateid, &arg, gfp_flags);
 	if (!lgp) {
 		trace_pnfs_update_layout(ino, pos, count, iomode, lo, NULL,
 					 PNFS_UPDATE_LAYOUT_NOMEM);
-- 
2.17.0

