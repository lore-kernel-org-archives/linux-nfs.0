Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36055 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753641AbeE3SGX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:23 -0400
Received: by mail-io0-f176.google.com with SMTP id d73-v6so22696910iog.3
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:22 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.21
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:21 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/19] pnfs: move allocations out of nfs4_proc_layoutget
Date: Wed, 30 May 2018 14:05:40 -0400
Message-Id: <20180530180553.38769-7-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-6-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com>
 <20180530180553.38769-5-trond.myklebust@hammerspace.com>
 <20180530180553.38769-6-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

They work better in the new alloc_init function.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 15 +++------------
 fs/nfs/pnfs.c     | 12 +++++++++++-
 fs/nfs/pnfs.h     |  4 +++-
 3 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 830569a8d00a..0eaab13dff04 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8694,7 +8694,7 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 	return status;
 }
 
-static size_t max_response_pages(struct nfs_server *server)
+size_t max_response_pages(struct nfs_server *server)
 {
 	u32 max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
 	return nfs_page_array_len(0, max_resp_sz);
@@ -8715,7 +8715,7 @@ static void nfs4_free_pages(struct page **pages, size_t size)
 	kfree(pages);
 }
 
-static struct page **nfs4_alloc_pages(size_t size, gfp_t gfp_flags)
+struct page **nfs4_alloc_pages(size_t size, gfp_t gfp_flags)
 {
 	struct page **pages;
 	int i;
@@ -8761,11 +8761,10 @@ static const struct rpc_call_ops nfs4_layoutget_call_ops = {
 };
 
 struct pnfs_layout_segment *
-nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
+nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout)
 {
 	struct inode *inode = lgp->args.inode;
 	struct nfs_server *server = NFS_SERVER(inode);
-	size_t max_pages = max_response_pages(server);
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTGET],
@@ -8792,14 +8791,6 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
 	/* nfs4_layoutget_release calls pnfs_put_layout_hdr */
 	pnfs_get_layout_hdr(NFS_I(inode)->layout);
 
-	lgp->args.layout.pages = nfs4_alloc_pages(max_pages, gfp_flags);
-	if (!lgp->args.layout.pages) {
-		nfs4_layoutget_release(lgp);
-		return ERR_PTR(-ENOMEM);
-	}
-	lgp->args.layout.pglen = max_pages * PAGE_SIZE;
-
-	lgp->res.layoutp = &lgp->args.layout;
 	nfs4_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0, 0);
 
 	task = rpc_run_task(&task_setup_data);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2c955c389ecf..363420d0f3a0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -924,6 +924,7 @@ pnfs_alloc_init_layoutget_args(struct pnfs_layout_hdr *lo,
 {
 	struct inode *ino = lo->plh_inode;
 	struct nfs_server *server = NFS_SERVER(ino);
+	size_t max_pages = max_response_pages(server);
 	struct nfs4_layoutget *lgp;
 	loff_t i_size;
 
@@ -933,6 +934,15 @@ pnfs_alloc_init_layoutget_args(struct pnfs_layout_hdr *lo,
 	if (lgp == NULL)
 		return NULL;
 
+	lgp->args.layout.pages = nfs4_alloc_pages(max_pages, gfp_flags);
+	if (!lgp->args.layout.pages) {
+		kfree(lgp);
+		return NULL;
+	}
+	lgp->args.layout.pglen = max_pages * PAGE_SIZE;
+	lgp->res.layoutp = &lgp->args.layout;
+
+
 	i_size = i_size_read(ino);
 
 	lgp->args.minlength = PAGE_SIZE;
@@ -1835,7 +1845,7 @@ pnfs_update_layout(struct inode *ino,
 		goto out_put_layout_hdr;
 	}
 
-	lseg = nfs4_proc_layoutget(lgp, &timeout, gfp_flags);
+	lseg = nfs4_proc_layoutget(lgp, &timeout);
 	trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				 PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET);
 	atomic_dec(&lo->plh_outstanding);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f71a55f11b97..964a7227ea97 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -224,10 +224,12 @@ extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
 extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
 
 /* nfs4proc.c */
+extern size_t max_response_pages(struct nfs_server *server);
+extern struct page **nfs4_alloc_pages(size_t size, gfp_t gfp_flags);
 extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev,
 				   struct rpc_cred *cred);
-extern struct pnfs_layout_segment* nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags);
+extern struct pnfs_layout_segment* nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout);
 extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync);
 
 /* pnfs.c */
-- 
2.17.0

