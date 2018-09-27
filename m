Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f195.google.com ([209.85.166.195]:50969 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727556AbeI0V7t (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Sep 2018 17:59:49 -0400
Received: by mail-it1-f195.google.com with SMTP id j81-v6so8492796ite.0
        for <linux-nfs@vger.kernel.org>; Thu, 27 Sep 2018 08:40:58 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id d11-v6sm689072iok.77.2018.09.27.08.40.57
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Sep 2018 08:40:57 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] NFSv3: Improve NFSv3 performance when server returns no post-op attributes
Date: Thu, 27 Sep 2018 11:40:01 -0400
Message-Id: <20180927154003.11825-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

When the server fails to return post-op attributes, the client's
attempt to place read data directly in the page cache fails, and
so we have to do an extra copy in order to realign the data with
page borders.
This patch attempts to detect servers that don't return post-op
attributes on read (e.g. for pNFS) and adjusts the placement
calculation accordingly.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs3proc.c         | 5 +++++
 fs/nfs/nfs3xdr.c          | 6 +++++-
 include/linux/nfs_fs_sb.h | 3 +++
 include/linux/nfs_xdr.h   | 3 ++-
 4 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index ec8a9efa268f..71bc16225b98 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -786,6 +786,7 @@ nfs3_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 static int nfs3_read_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 {
 	struct inode *inode = hdr->inode;
+	struct nfs_server *server = NFS_SERVER(inode);
 
 	if (hdr->pgio_done_cb != NULL)
 		return hdr->pgio_done_cb(task, hdr);
@@ -793,6 +794,9 @@ static int nfs3_read_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 	if (nfs3_async_handle_jukebox(task, inode))
 		return -EAGAIN;
 
+	if (task->tk_status >= 0 && !server->read_hdrsize)
+		cmpxchg(&server->read_hdrsize, 0, hdr->res.replen);
+
 	nfs_invalidate_atime(inode);
 	nfs_refresh_inode(inode, &hdr->fattr);
 	return 0;
@@ -802,6 +806,7 @@ static void nfs3_proc_read_setup(struct nfs_pgio_header *hdr,
 				 struct rpc_message *msg)
 {
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_READ];
+	hdr->args.replen = NFS_SERVER(hdr->inode)->read_hdrsize;
 }
 
 static int nfs3_proc_pgio_rpc_prepare(struct rpc_task *task,
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index d8c4c10b15f7..78df4eb60f85 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -983,10 +983,11 @@ static void nfs3_xdr_enc_read3args(struct rpc_rqst *req,
 				   const void *data)
 {
 	const struct nfs_pgio_args *args = data;
+	unsigned int replen = args->replen ? args->replen : NFS3_readres_sz;
 
 	encode_read3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
-					args->count, NFS3_readres_sz);
+					args->count, replen);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
 }
 
@@ -1675,9 +1676,11 @@ static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 				 void *data)
 {
 	struct nfs_pgio_res *result = data;
+	unsigned int pos;
 	enum nfs_stat status;
 	int error;
 
+	pos = xdr_stream_pos(xdr);
 	error = decode_nfsstat3(xdr, &status);
 	if (unlikely(error))
 		goto out;
@@ -1687,6 +1690,7 @@ static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
 	result->op_status = status;
 	if (status != NFS3_OK)
 		goto out_status;
+	result->replen = 3 + ((xdr_stream_pos(xdr) - pos) >> 2);
 	error = decode_read3resok(xdr, result);
 out:
 	return error;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index bf39d9c92201..0fc0b9135d46 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -228,6 +228,9 @@ struct nfs_server {
 	unsigned short		mountd_port;
 	unsigned short		mountd_protocol;
 	struct rpc_wait_queue	uoc_rpcwaitq;
+
+	/* XDR related information */
+	unsigned int		read_hdrsize;
 };
 
 /* Server capabilities */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index bd1c889a9ed9..7f5535e5e852 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -608,6 +608,7 @@ struct nfs_pgio_args {
 	__u32			count;
 	unsigned int		pgbase;
 	struct page **		pages;
+	unsigned int		replen;		/* used by read */
 	const u32 *		bitmask;	/* used by write */
 	enum nfs3_stable_how	stable;		/* used by write */
 };
@@ -618,9 +619,9 @@ struct nfs_pgio_res {
 	__u32			count;
 	__u32			op_status;
 	int			eof;		/* used by read */
+	unsigned int		replen;		/* used by read */
 	struct nfs_writeverf *	verf;		/* used by write */
 	const struct nfs_server *server;	/* used by write */
-
 };
 
 /*
-- 
2.17.1
