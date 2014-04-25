Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:10689 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754582AbaDYU4I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 16:56:08 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [PATCH v2 02/17] NFS: Create a common results structure for reads and writes
Date: Fri, 25 Apr 2014 16:55:45 -0400
Message-ID: <1398459360-2093-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

Reads and writes have very similar results.  This patch combines the two
structs together with comments to show where the differing fields are
used.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

v2:
- Move the write-only variables to the end of the struct

TODO:
- Consider making a union for read and write variables
---
 fs/nfs/nfs2xdr.c        |  6 +++---
 fs/nfs/nfs3xdr.c        |  8 ++++----
 fs/nfs/nfs4xdr.c        |  9 +++++----
 fs/nfs/read.c           |  2 +-
 fs/nfs/write.c          |  2 +-
 include/linux/nfs_xdr.h | 32 ++++++++++++--------------------
 6 files changed, 26 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 461cd8b..5f61b83 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -103,7 +103,7 @@ static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 /*
  *	typedef opaque	nfsdata<>;
  */
-static int decode_nfsdata(struct xdr_stream *xdr, struct nfs_readres *result)
+static int decode_nfsdata(struct xdr_stream *xdr, struct nfs_pgio_res *result)
 {
 	u32 recvd, count;
 	__be32 *p;
@@ -857,7 +857,7 @@ out_default:
  *	};
  */
 static int nfs2_xdr_dec_readres(struct rpc_rqst *req, struct xdr_stream *xdr,
-				struct nfs_readres *result)
+				struct nfs_pgio_res *result)
 {
 	enum nfs_stat status;
 	int error;
@@ -878,7 +878,7 @@ out_default:
 }
 
 static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs_writeres *result)
+				 struct nfs_pgio_res *result)
 {
 	/* All NFSv2 writes are "file sync" writes */
 	result->verf->committed = NFS_FILE_SYNC;
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 02f16c2..8f4cbe7 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1589,7 +1589,7 @@ out_default:
  *	};
  */
 static int decode_read3resok(struct xdr_stream *xdr,
-			     struct nfs_readres *result)
+			     struct nfs_pgio_res *result)
 {
 	u32 eof, count, ocount, recvd;
 	__be32 *p;
@@ -1625,7 +1625,7 @@ out_overflow:
 }
 
 static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs_readres *result)
+				 struct nfs_pgio_res *result)
 {
 	enum nfs_stat status;
 	int error;
@@ -1673,7 +1673,7 @@ out_status:
  *	};
  */
 static int decode_write3resok(struct xdr_stream *xdr,
-			      struct nfs_writeres *result)
+			      struct nfs_pgio_res *result)
 {
 	__be32 *p;
 
@@ -1697,7 +1697,7 @@ out_eio:
 }
 
 static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  struct nfs_writeres *result)
+				  struct nfs_pgio_res *result)
 {
 	enum nfs_stat status;
 	int error;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 032159c..939ae60 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5087,7 +5087,8 @@ static int decode_putrootfh(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_PUTROOTFH);
 }
 
-static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_readres *res)
+static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req,
+		       struct nfs_pgio_res *res)
 {
 	__be32 *p;
 	uint32_t count, eof, recvd;
@@ -5341,7 +5342,7 @@ static int decode_setclientid_confirm(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_SETCLIENTID_CONFIRM);
 }
 
-static int decode_write(struct xdr_stream *xdr, struct nfs_writeres *res)
+static int decode_write(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 {
 	__be32 *p;
 	int status;
@@ -6638,7 +6639,7 @@ out:
  * Decode Read response
  */
 static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			     struct nfs_readres *res)
+			     struct nfs_pgio_res *res)
 {
 	struct compound_hdr hdr;
 	int status;
@@ -6663,7 +6664,7 @@ out:
  * Decode WRITE response
  */
 static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			      struct nfs_writeres *res)
+			      struct nfs_pgio_res *res)
 {
 	struct compound_hdr hdr;
 	int status;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 46d5552..473bba3 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -471,7 +471,7 @@ int nfs_readpage_result(struct rpc_task *task, struct nfs_read_data *data)
 static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_pgio_args *argp = &data->args;
-	struct nfs_readres *resp = &data->res;
+	struct nfs_pgio_res  *resp = &data->res;
 
 	/* This is a short read! */
 	nfs_inc_stats(data->header->inode, NFSIOS_SHORTREAD);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 25ba383..d392a70 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1389,7 +1389,7 @@ static int nfs_should_remove_suid(const struct inode *inode)
 void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct nfs_pgio_args	*argp = &data->args;
-	struct nfs_writeres	*resp = &data->res;
+	struct nfs_pgio_res	*resp = &data->res;
 	struct inode		*inode = data->header->inode;
 	int status;
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 5875001..381f832 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -489,16 +489,6 @@ struct nfs4_delegreturnres {
 };
 
 /*
- * Arguments to the read call.
- */
-struct nfs_readres {
-	struct nfs4_sequence_res	seq_res;
-	struct nfs_fattr *	fattr;
-	__u32			count;
-	int                     eof;
-};
-
-/*
  * Arguments to the write call.
  */
 struct nfs_write_verifier {
@@ -510,14 +500,6 @@ struct nfs_writeverf {
 	enum nfs3_stable_how	committed;
 };
 
-struct nfs_writeres {
-	struct nfs4_sequence_res	seq_res;
-	struct nfs_fattr *	fattr;
-	struct nfs_writeverf *	verf;
-	__u32			count;
-	const struct nfs_server *server;
-};
-
 /*
  * Arguments shared by the read and write call.
  */
@@ -535,6 +517,16 @@ struct nfs_pgio_args {
 	enum nfs3_stable_how	stable;		/* used by write */
 };
 
+struct nfs_pgio_res {
+	struct nfs4_sequence_res	seq_res;
+	struct nfs_fattr *	fattr;
+	__u32			count;
+	int			eof;		/* used by read */
+	struct nfs_writeverf *	verf;		/* used by write */
+	const struct nfs_server *server;	/* used by write */
+
+};
+
 /*
  * Arguments to the commit call.
  */
@@ -1261,7 +1253,7 @@ struct nfs_read_data {
 	struct rpc_task		task;
 	struct nfs_fattr	fattr;	/* fattr storage */
 	struct nfs_pgio_args	args;
-	struct nfs_readres  res;
+	struct nfs_pgio_res	res;
 	unsigned long		timestamp;	/* For lease renewal */
 	int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
 	__u64			mds_offset;
@@ -1313,7 +1305,7 @@ struct nfs_write_data {
 	struct nfs_fattr	fattr;
 	struct nfs_writeverf	verf;
 	struct nfs_pgio_args	args;		/* argument struct */
-	struct nfs_writeres	res;		/* result struct */
+	struct nfs_pgio_res	res;		/* result struct */
 	unsigned long		timestamp;	/* For lease renewal */
 	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
 	__u64			mds_offset;	/* Filelayout dense stripe */
-- 
1.9.2

