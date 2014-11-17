Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f182.google.com ([209.85.192.182]:64029 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbaKQDFf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Nov 2014 22:05:35 -0500
Received: by mail-pd0-f182.google.com with SMTP id g10so5129614pdj.41
        for <linux-nfs@vger.kernel.org>; Sun, 16 Nov 2014 19:05:35 -0800 (PST)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH] nfs41: fix nfs4_proc_layoutget error handling
Date: Mon, 17 Nov 2014 11:05:17 +0800
Message-Id: <1416193517-14815-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_layoutget_release() drops layout hdr refcnt. Grab the refcnt
early so that it is safe to call .release in case nfs4_alloc_pages
fails.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4proc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 405bd95..d14b1f6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7709,6 +7709,9 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 
 	dprintk("--> %s\n", __func__);
 
+	/* nfs4_layoutget_release calls pnfs_put_layout_hdr */
+	pnfs_get_layout_hdr(NFS_I(inode)->layout);
+
 	lgp->args.layout.pages = nfs4_alloc_pages(max_pages, gfp_flags);
 	if (!lgp->args.layout.pages) {
 		nfs4_layoutget_release(lgp);
@@ -7721,9 +7724,6 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 	lgp->res.seq_res.sr_slot = NULL;
 	nfs4_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0);
 
-	/* nfs4_layoutget_release calls pnfs_put_layout_hdr */
-	pnfs_get_layout_hdr(NFS_I(inode)->layout);
-
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return ERR_CAST(task);
-- 
1.9.1

