Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:40311 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983AbaDQVJu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Apr 2014 17:09:50 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 01/17] NFS: Create a common argument structure for reads and writes
Date: Thu, 17 Apr 2014 17:09:25 -0400
Message-ID: <1397768981-12856-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

Reads and writes have very similar arguments.  This patch combines them
together and documents the few fields used only by write.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs2xdr.c        |  8 ++++----
 fs/nfs/nfs3xdr.c        |  8 ++++----
 fs/nfs/nfs4proc.c       |  4 ++--
 fs/nfs/nfs4xdr.c        | 10 ++++++----
 fs/nfs/read.c           |  2 +-
 fs/nfs/write.c          |  2 +-
 include/linux/nfs_xdr.h | 47 +++++++++++++++++++----------------------------
 7 files changed, 37 insertions(+), 44 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 62db136..461cd8b 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -613,7 +613,7 @@ static void nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req,
  *	};
  */
 static void encode_readargs(struct xdr_stream *xdr,
-			    const struct nfs_readargs *args)
+			    const struct nfs_pgio_args *args)
 {
 	u32 offset = args->offset;
 	u32 count = args->count;
@@ -629,7 +629,7 @@ static void encode_readargs(struct xdr_stream *xdr,
 
 static void nfs2_xdr_enc_readargs(struct rpc_rqst *req,
 				  struct xdr_stream *xdr,
-				  const struct nfs_readargs *args)
+				  const struct nfs_pgio_args *args)
 {
 	encode_readargs(xdr, args);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
@@ -649,7 +649,7 @@ static void nfs2_xdr_enc_readargs(struct rpc_rqst *req,
  *	};
  */
 static void encode_writeargs(struct xdr_stream *xdr,
-			     const struct nfs_writeargs *args)
+			     const struct nfs_pgio_args *args)
 {
 	u32 offset = args->offset;
 	u32 count = args->count;
@@ -669,7 +669,7 @@ static void encode_writeargs(struct xdr_stream *xdr,
 
 static void nfs2_xdr_enc_writeargs(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfs_writeargs *args)
+				   const struct nfs_pgio_args *args)
 {
 	encode_writeargs(xdr, args);
 	xdr->buf->flags |= XDRBUF_WRITE;
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index fa6d721..02f16c2 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -953,7 +953,7 @@ static void nfs3_xdr_enc_readlink3args(struct rpc_rqst *req,
  *	};
  */
 static void encode_read3args(struct xdr_stream *xdr,
-			     const struct nfs_readargs *args)
+			     const struct nfs_pgio_args *args)
 {
 	__be32 *p;
 
@@ -966,7 +966,7 @@ static void encode_read3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_read3args(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfs_readargs *args)
+				   const struct nfs_pgio_args *args)
 {
 	encode_read3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
@@ -992,7 +992,7 @@ static void nfs3_xdr_enc_read3args(struct rpc_rqst *req,
  *	};
  */
 static void encode_write3args(struct xdr_stream *xdr,
-			      const struct nfs_writeargs *args)
+			      const struct nfs_pgio_args *args)
 {
 	__be32 *p;
 
@@ -1008,7 +1008,7 @@ static void encode_write3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_write3args(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs_writeargs *args)
+				    const struct nfs_pgio_args *args)
 {
 	encode_write3args(xdr, args);
 	xdr->buf->flags |= XDRBUF_WRITE;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 21cd1f2..4794ca6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4055,7 +4055,7 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
 }
 
 static bool nfs4_read_stateid_changed(struct rpc_task *task,
-		struct nfs_readargs *args)
+		struct nfs_pgio_args *args)
 {
 
 	if (!nfs4_error_stateid_expired(task->tk_status) ||
@@ -4121,7 +4121,7 @@ static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data
 }
 
 static bool nfs4_write_stateid_changed(struct rpc_task *task,
-		struct nfs_writeargs *args)
+		struct nfs_pgio_args *args)
 {
 
 	if (!nfs4_error_stateid_expired(task->tk_status) ||
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 73ce8d4..032159c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1556,7 +1556,8 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	encode_op_hdr(xdr, OP_PUTROOTFH, decode_putrootfh_maxsz, hdr);
 }
 
-static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args, struct compound_hdr *hdr)
+static void encode_read(struct xdr_stream *xdr, const struct nfs_pgio_args *args,
+			struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1701,7 +1702,8 @@ static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs4
 	encode_nfs4_verifier(xdr, &arg->confirm);
 }
 
-static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *args, struct compound_hdr *hdr)
+static void encode_write(struct xdr_stream *xdr, const struct nfs_pgio_args *args,
+			 struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -2451,7 +2453,7 @@ static void nfs4_xdr_enc_readdir(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a READ request
  */
 static void nfs4_xdr_enc_read(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      struct nfs_readargs *args)
+			      struct nfs_pgio_args *args)
 {
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
@@ -2513,7 +2515,7 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a WRITE request
  */
 static void nfs4_xdr_enc_write(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs_writeargs *args)
+			       struct nfs_pgio_args *args)
 {
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 7f87461..46d5552 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -470,7 +470,7 @@ int nfs_readpage_result(struct rpc_task *task, struct nfs_read_data *data)
 
 static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data)
 {
-	struct nfs_readargs *argp = &data->args;
+	struct nfs_pgio_args *argp = &data->args;
 	struct nfs_readres *resp = &data->res;
 
 	/* This is a short read! */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ee6d46f..25ba383 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1388,7 +1388,7 @@ static int nfs_should_remove_suid(const struct inode *inode)
  */
 void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 {
-	struct nfs_writeargs	*argp = &data->args;
+	struct nfs_pgio_args	*argp = &data->args;
 	struct nfs_writeres	*resp = &data->res;
 	struct inode		*inode = data->header->inode;
 	int status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3e8fc1f..9ce2a48 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -491,18 +491,6 @@ struct nfs4_delegreturnres {
 /*
  * Arguments to the read call.
  */
-struct nfs_readargs {
-	struct nfs4_sequence_args	seq_args;
-	struct nfs_fh *		fh;
-	struct nfs_open_context *context;
-	struct nfs_lock_context *lock_context;
-	nfs4_stateid		stateid;
-	__u64			offset;
-	__u32			count;
-	unsigned int		pgbase;
-	struct page **		pages;
-};
-
 struct nfs_readres {
 	struct nfs4_sequence_res	seq_res;
 	struct nfs_fattr *	fattr;
@@ -513,20 +501,6 @@ struct nfs_readres {
 /*
  * Arguments to the write call.
  */
-struct nfs_writeargs {
-	struct nfs4_sequence_args	seq_args;
-	struct nfs_fh *		fh;
-	struct nfs_open_context *context;
-	struct nfs_lock_context *lock_context;
-	nfs4_stateid		stateid;
-	__u64			offset;
-	__u32			count;
-	enum nfs3_stable_how	stable;
-	unsigned int		pgbase;
-	struct page **		pages;
-	const u32 *		bitmask;
-};
-
 struct nfs_write_verifier {
 	char			data[8];
 };
@@ -545,6 +519,23 @@ struct nfs_writeres {
 };
 
 /*
+ * Arguments shared by the read and write call.
+ */
+struct nfs_pgio_args {
+	struct nfs4_sequence_args	seq_args;
+	struct nfs_fh *		fh;
+	struct nfs_open_context *context;
+	struct nfs_lock_context *lock_context;
+	nfs4_stateid		stateid;
+	__u64			offset;
+	__u32			count;
+	enum nfs3_stable_how	stable;		/* used by write */
+	unsigned int		pgbase;
+	struct page **		pages;
+	const u32 *		bitmask;	/* used by write */
+};
+
+/*
  * Arguments to the commit call.
  */
 struct nfs_commitargs {
@@ -1269,7 +1260,7 @@ struct nfs_read_data {
 	struct list_head	list;
 	struct rpc_task		task;
 	struct nfs_fattr	fattr;	/* fattr storage */
-	struct nfs_readargs args;
+	struct nfs_pgio_args	args;
 	struct nfs_readres  res;
 	unsigned long		timestamp;	/* For lease renewal */
 	int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
@@ -1321,7 +1312,7 @@ struct nfs_write_data {
 	struct rpc_task		task;
 	struct nfs_fattr	fattr;
 	struct nfs_writeverf	verf;
-	struct nfs_writeargs	args;		/* argument struct */
+	struct nfs_pgio_args	args;		/* argument struct */
 	struct nfs_writeres	res;		/* result struct */
 	unsigned long		timestamp;	/* For lease renewal */
 	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
-- 
1.9.2

