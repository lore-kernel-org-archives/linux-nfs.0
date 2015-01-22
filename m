Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f44.google.com ([209.85.220.44]:47447 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbbAVXhE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 18:37:04 -0500
Received: by mail-pa0-f44.google.com with SMTP id rd3so3874008pab.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 15:37:03 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 15/51] nfs: allow to specify cred in nfs_initiate_pgio
Date: Thu, 22 Jan 2015 15:35:47 -0800
Message-Id: <1421969783-92997-16-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

so that flexfile layout client can pass in DS credential instead of
using user cred, which will be done in the next patch.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c | 11 ++++++-----
 fs/nfs/internal.h              |  6 +++---
 fs/nfs/pagelist.c              |  8 +++++---
 3 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index e5a3c5b..bfa8547 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -501,8 +501,9 @@ filelayout_read_pagelist(struct nfs_pgio_header *hdr)
 	hdr->mds_offset = offset;
 
 	/* Perform an asynchronous read to ds */
-	nfs_initiate_pgio(ds_clnt, hdr, NFS_PROTO(hdr->inode),
-			    &filelayout_read_call_ops, 0, RPC_TASK_SOFTCONN);
+	nfs_initiate_pgio(ds_clnt, hdr, hdr->cred,
+			  NFS_PROTO(hdr->inode), &filelayout_read_call_ops,
+			  0, RPC_TASK_SOFTCONN);
 	return PNFS_ATTEMPTED;
 }
 
@@ -542,9 +543,9 @@ filelayout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	hdr->args.offset = filelayout_get_dserver_offset(lseg, offset);
 
 	/* Perform an asynchronous write */
-	nfs_initiate_pgio(ds_clnt, hdr, NFS_PROTO(hdr->inode),
-				    &filelayout_write_call_ops, sync,
-				    RPC_TASK_SOFTCONN);
+	nfs_initiate_pgio(ds_clnt, hdr, hdr->cred,
+			  NFS_PROTO(hdr->inode), &filelayout_write_call_ops,
+			  sync, RPC_TASK_SOFTCONN);
 	return PNFS_ATTEMPTED;
 }
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 98dee83..e9305e9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -250,9 +250,9 @@ struct nfs_pgio_header *nfs_pgio_header_alloc(const struct nfs_rw_ops *);
 void nfs_pgio_header_free(struct nfs_pgio_header *);
 void nfs_pgio_data_destroy(struct nfs_pgio_header *);
 int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
-int nfs_initiate_pgio(struct rpc_clnt *, struct nfs_pgio_header *,
-		      const struct nfs_rpc_ops *,
-		      const struct rpc_call_ops *, int, int);
+int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
+		      struct rpc_cred *cred, const struct nfs_rpc_ops *rpc_ops,
+		      const struct rpc_call_ops *call_ops, int how, int flags);
 void nfs_free_request(struct nfs_page *req);
 
 static inline void nfs_iocounter_init(struct nfs_io_counter *c)
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 35a2626..c4d1758 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -597,14 +597,14 @@ static void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
 }
 
 int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
-		      const struct nfs_rpc_ops *rpc_ops,
+		      struct rpc_cred *cred, const struct nfs_rpc_ops *rpc_ops,
 		      const struct rpc_call_ops *call_ops, int how, int flags)
 {
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &hdr->args,
 		.rpc_resp = &hdr->res,
-		.rpc_cred = hdr->cred,
+		.rpc_cred = cred,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = clnt,
@@ -793,7 +793,9 @@ static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret == 0)
 		ret = nfs_initiate_pgio(NFS_CLIENT(hdr->inode),
-					hdr, NFS_PROTO(hdr->inode),
+					hdr,
+					hdr->cred,
+					NFS_PROTO(hdr->inode),
 					desc->pg_rpc_callops,
 					desc->pg_ioflags, 0);
 	return ret;
-- 
1.9.3

