Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36075 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753659AbeE3SG1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:27 -0400
Received: by mail-it0-f66.google.com with SMTP id e20-v6so24660018itc.1
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:27 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.25
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:25 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/19] pnfs: Add LAYOUTGET to OPEN of an existing file
Date: Wed, 30 May 2018 14:05:45 -0400
Message-Id: <20180530180553.38769-12-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-11-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 90 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 73 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a0a2484c3aed..258b68110277 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -921,9 +921,9 @@ pnfs_find_server(struct inode *inode, struct nfs_open_context *ctx)
 {
 	struct nfs_server *server;
 
-	if (inode)
+	if (inode) {
 		server = NFS_SERVER(inode);
-	else {
+	} else {
 		struct dentry *parent_dir = dget_parent(ctx->dentry);
 		server = NFS_SERVER(parent_dir->d_inode);
 		dput(parent_dir);
@@ -1686,6 +1686,22 @@ static void pnfs_clear_first_layoutget(struct pnfs_layout_hdr *lo)
 	wake_up_bit(bitlock, NFS_LAYOUT_FIRST_LAYOUTGET);
 }
 
+static void _add_to_server_list(struct pnfs_layout_hdr *lo,
+				struct nfs_server *server)
+{
+	if (list_empty(&lo->plh_layouts)) {
+		struct nfs_client *clp = server->nfs_client;
+
+		/* The lo must be on the clp list if there is any
+		 * chance of a CB_LAYOUTRECALL(FILE) coming in.
+		 */
+		spin_lock(&clp->cl_lock);
+		if (list_empty(&lo->plh_layouts))
+			list_add_tail(&lo->plh_layouts, &server->layouts);
+		spin_unlock(&clp->cl_lock);
+	}
+}
+
 /*
  * Layout segment is retreived from the server if not cached.
  * The appropriate layout segment is referenced and returned to the caller.
@@ -1836,15 +1852,7 @@ pnfs_update_layout(struct inode *ino,
 	atomic_inc(&lo->plh_outstanding);
 	spin_unlock(&ino->i_lock);
 
-	if (list_empty(&lo->plh_layouts)) {
-		/* The lo must be on the clp list if there is any
-		 * chance of a CB_LAYOUTRECALL(FILE) coming in.
-		 */
-		spin_lock(&clp->cl_lock);
-		if (list_empty(&lo->plh_layouts))
-			list_add_tail(&lo->plh_layouts, &server->layouts);
-		spin_unlock(&clp->cl_lock);
-	}
+	_add_to_server_list(lo, server);
 
 	pg_offset = arg.offset & ~PAGE_MASK;
 	if (pg_offset) {
@@ -1943,12 +1951,62 @@ pnfs_sanity_check_layout_range(struct pnfs_layout_range *range)
 	return true;
 }
 
+static struct pnfs_layout_hdr *
+_pnfs_grab_empty_layout(struct inode *ino, struct nfs_open_context *ctx)
+{
+	struct pnfs_layout_hdr *lo;
+
+	spin_lock(&ino->i_lock);
+	lo = pnfs_find_alloc_layout(ino, ctx, GFP_KERNEL);
+	if (!lo)
+		goto out_unlock;
+	if (!test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags))
+		goto out_unlock;
+	if (test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
+		goto out_unlock;
+	if (pnfs_layoutgets_blocked(lo))
+		goto out_unlock;
+	if (test_and_set_bit(NFS_LAYOUT_FIRST_LAYOUTGET, &lo->plh_flags))
+		goto out_unlock;
+	atomic_inc(&lo->plh_outstanding);
+	spin_unlock(&ino->i_lock);
+	_add_to_server_list(lo, NFS_SERVER(ino));
+	return lo;
+
+out_unlock:
+	spin_unlock(&ino->i_lock);
+	pnfs_put_layout_hdr(lo);
+	return NULL;
+}
+
 extern const nfs4_stateid current_stateid;
 
 static void _lgopen_prepare_attached(struct nfs4_opendata *data,
 				     struct nfs_open_context *ctx)
 {
-	/* STUB */
+	struct inode *ino = data->dentry->d_inode;
+	struct pnfs_layout_range rng = {
+		.iomode = (data->o_arg.fmode & FMODE_WRITE) ?
+			  IOMODE_RW: IOMODE_READ,
+		.offset = 0,
+		.length = NFS4_MAX_UINT64,
+	};
+	struct nfs4_layoutget *lgp;
+	struct pnfs_layout_hdr *lo;
+
+	lo = _pnfs_grab_empty_layout(ino, ctx);
+	if (!lo)
+		return;
+	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &current_stateid,
+					     &rng, GFP_KERNEL);
+	if (!lgp) {
+		pnfs_clear_first_layoutget(lo);
+		pnfs_put_layout_hdr(lo);
+		return;
+	}
+	data->lgp = lgp;
+	data->o_arg.lg_args = &lgp->args;
+	data->o_res.lg_res = &lgp->res;
 }
 
 static void _lgopen_prepare_floating(struct nfs4_opendata *data,
@@ -1996,11 +2054,9 @@ void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
 	if (!lgp || lgp->res.layoutp->len == 0)
 		return;
 	if (!lgp->args.inode) {
-		/* Need to grab lo */
-		spin_lock(&ino->i_lock);
-		lo = pnfs_find_alloc_layout(ino, ctx, GFP_KERNEL);
-		atomic_inc(&lo->plh_outstanding);
-		spin_unlock(&ino->i_lock);
+		lo = _pnfs_grab_empty_layout(ino, ctx);
+		if (!lo)
+			return;
 		lgp->args.inode = ino;
 	} else
 		lo = NFS_I(lgp->args.inode)->layout;
-- 
2.17.0

