Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37338 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754016Ab0HSP3H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Aug 2010 11:29:07 -0400
From: andros@netpp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/5] SQUASHME pnfs-submit rename layoutget 2
Date: Thu, 19 Aug 2010 11:27:55 -0400
Message-Id: <1282231677-4412-4-git-send-email-andros@netpp.com>
In-Reply-To: <1282231677-4412-3-git-send-email-andros@netpp.com>
References: <1282231677-4412-1-git-send-email-andros@netpp.com>
 <1282231677-4412-2-git-send-email-andros@netpp.com>
 <1282231677-4412-3-git-send-email-andros@netpp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit-layoutget

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c        |   32 ++++++++++++++++----------------
 fs/nfs/nfs4xdr.c         |   16 ++++++++--------
 fs/nfs/pnfs.c            |    4 ++--
 fs/nfs/pnfs.h            |    6 +++---
 include/linux/nfs4.h     |    2 +-
 include/linux/pnfs_xdr.h |   10 +++++-----
 6 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8c94e1e..7240900 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5441,9 +5441,9 @@ out:
 }
 
 static void
-nfs4_pnfs_layoutget_prepare(struct rpc_task *task, void *calldata)
+nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 {
-	struct nfs4_pnfs_layoutget *lgp = calldata;
+	struct nfs4_layoutget *lgp = calldata;
 	struct inode *ino = lgp->args.inode;
 	struct nfs_server *server = NFS_SERVER(ino);
 
@@ -5454,9 +5454,9 @@ nfs4_pnfs_layoutget_prepare(struct rpc_task *task, void *calldata)
 	rpc_call_start(task);
 }
 
-static void nfs4_pnfs_layoutget_done(struct rpc_task *task, void *calldata)
+static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 {
-	struct nfs4_pnfs_layoutget *lgp = calldata;
+	struct nfs4_layoutget *lgp = calldata;
 	struct inode *ino = lgp->args.inode;
 	struct nfs_server *server = NFS_SERVER(ino);
 
@@ -5477,9 +5477,9 @@ static void nfs4_pnfs_layoutget_done(struct rpc_task *task, void *calldata)
 	dprintk("<-- %s\n", __func__);
 }
 
-static void nfs4_pnfs_layoutget_release(void *calldata)
+static void nfs4_layoutget_release(void *calldata)
 {
-	struct nfs4_pnfs_layoutget *lgp = calldata;
+	struct nfs4_layoutget *lgp = calldata;
 
 	dprintk("--> %s\n", __func__);
 	pnfs_layout_release(NFS_I(lgp->args.inode)->layout, NULL);
@@ -5489,29 +5489,29 @@ static void nfs4_pnfs_layoutget_release(void *calldata)
 	dprintk("<-- %s\n", __func__);
 }
 
-static const struct rpc_call_ops nfs4_pnfs_layoutget_call_ops = {
-	.rpc_call_prepare = nfs4_pnfs_layoutget_prepare,
-	.rpc_call_done = nfs4_pnfs_layoutget_done,
-	.rpc_release = nfs4_pnfs_layoutget_release,
+static const struct rpc_call_ops nfs4_layoutget_call_ops = {
+	.rpc_call_prepare = nfs4_layoutget_prepare,
+	.rpc_call_done = nfs4_layoutget_done,
+	.rpc_release = nfs4_layoutget_release,
 };
 
 /* FIXME: We need to call nfs4_handle_exception
  * and deal with retries.
  * Currently we can't since we release lgp and its contents.
  */
-static int _pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
+static int _nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
 {
 	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
 	struct rpc_task *task;
 	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_LAYOUTGET],
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTGET],
 		.rpc_argp = &lgp->args,
 		.rpc_resp = &lgp->res,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = server->client,
 		.rpc_message = &msg,
-		.callback_ops = &nfs4_pnfs_layoutget_call_ops,
+		.callback_ops = &nfs4_layoutget_call_ops,
 		.callback_data = lgp,
 		.flags = RPC_TASK_ASYNC,
 	};
@@ -5521,7 +5521,7 @@ static int _pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
 
 	lgp->res.layout.buf = (void *)__get_free_page(GFP_NOFS);
 	if (lgp->res.layout.buf == NULL) {
-		nfs4_pnfs_layoutget_release(lgp);
+		nfs4_layoutget_release(lgp);
 		return -ENOMEM;
 	}
 
@@ -5542,13 +5542,13 @@ out:
 	return status;
 }
 
-int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp)
+int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
 {
 	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(server, _pnfs4_proc_layoutget(lgp),
+		err = nfs4_handle_exception(server, _nfs4_proc_layoutget(lgp),
 					    &exception);
 	} while (exception.retry);
 	return err;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 89f7139..7da6129 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -320,7 +320,7 @@ static int nfs4_stat_to_errno(int);
 				4 /* opaque devaddr4 length */ +\
 				4 /* notification bitmap length */ + \
 				4 /* notification bitmap */)
-#define encode_layoutget_sz	(op_encode_hdr_maxsz + 10 + \
+#define encode_layoutget_maxsz	(op_encode_hdr_maxsz + 10 + \
 				encode_stateid_maxsz)
 #define decode_layoutget_maxsz	(op_decode_hdr_maxsz + 8 + \
 				decode_stateid_maxsz + \
@@ -734,7 +734,7 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_enc_layoutget_sz	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz +        \
-				encode_layoutget_sz)
+				encode_layoutget_maxsz)
 #define NFS4_dec_layoutget_sz	(compound_decode_hdr_maxsz + \
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz +        \
@@ -1824,7 +1824,7 @@ encode_getdeviceinfo(struct xdr_stream *xdr,
 
 static void
 encode_layoutget(struct xdr_stream *xdr,
-		      const struct nfs4_pnfs_layoutget_arg *args,
+		      const struct nfs4_layoutget_args *args,
 		      struct compound_hdr *hdr)
 {
 	nfs4_stateid stateid;
@@ -2773,7 +2773,7 @@ static int nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req, uint32_t *p,
  *  Encode LAYOUTGET request
  */
 static int nfs4_xdr_enc_layoutget(struct rpc_rqst *req, uint32_t *p,
-				  struct nfs4_pnfs_layoutget_arg *args)
+				  struct nfs4_layoutget_args *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
@@ -5175,7 +5175,7 @@ out_overflow:
 }
 
 static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
-			    struct nfs4_pnfs_layoutget_res *res)
+			    struct nfs4_layoutget_res *res)
 {
 	__be32 *p;
 	int status;
@@ -5216,7 +5216,7 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 		res->type,
 		res->layout.len);
 
-	/* presuambly, pnfs4_proc_layoutget allocated a single page */
+	/* presuambly, nfs4_proc_layoutget allocated a single page */
 	if (res->layout.len > PAGE_SIZE)
 		return -ENOMEM;
 	memcpy(res->layout.buf, p, res->layout.len);
@@ -6347,7 +6347,7 @@ out:
  * Decode LAYOUTGET response
  */
 static int nfs4_xdr_dec_layoutget(struct rpc_rqst *rqstp, uint32_t *p,
-				  struct nfs4_pnfs_layoutget_res *res)
+				  struct nfs4_layoutget_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -6652,7 +6652,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
   PROC(RECLAIM_COMPLETE, enc_reclaim_complete,  dec_reclaim_complete),
   PROC(GETDEVICEINFO, enc_getdeviceinfo, dec_getdeviceinfo),
-  PROC(PNFS_LAYOUTGET,  enc_layoutget,     dec_layoutget),
+  PROC(LAYOUTGET,  enc_layoutget,     dec_layoutget),
   PROC(PNFS_LAYOUTCOMMIT, enc_layoutcommit,  dec_layoutcommit),
   PROC(PNFS_LAYOUTRETURN, enc_layoutreturn,  dec_layoutreturn),
   PROC(PNFS_WRITE, enc_dswrite,  dec_dswrite),
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7bf812f..f838f2d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1014,7 +1014,7 @@ out_unlock:
 }
 
 void
-pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
+pnfs_get_layout_done(struct nfs4_layoutget *lgp, int rpc_status)
 {
 	struct pnfs_layout_segment *lseg = NULL;
 	struct nfs_inode *nfsi = NFS_I(lgp->args.inode);
@@ -1118,7 +1118,7 @@ out:
 }
 
 int
-pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
+pnfs_layout_process(struct nfs4_layoutget *lgp)
 {
 	struct pnfs_layout_hdr *lo = NFS_I(lgp->args.inode)->layout;
 	struct nfs4_pnfs_layoutget_res *res = &lgp->res;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d6ed419..999d122 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -24,7 +24,7 @@
 /* nfs4proc.c */
 extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
-extern int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp);
+extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
 extern int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data,
 				   int issync);
 extern int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool wait);
@@ -56,8 +56,8 @@ enum pnfs_try_status pnfs_try_to_commit(struct nfs_write_data *,
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   struct nfs_open_context *, struct list_head *);
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
-void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
-int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
+void pnfs_get_layout_done(struct nfs4_layoutget *, int rpc_status);
+int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_layout_release(struct pnfs_layout_hdr *, struct nfs4_pnfs_layout_segment *range);
 void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			     const nfs4_stateid *stateid);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 7c54b00..1fa7f4a 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -553,7 +553,7 @@ enum {
 	NFSPROC4_CLNT_SEQUENCE,
 	NFSPROC4_CLNT_GET_LEASE_TIME,
 	NFSPROC4_CLNT_RECLAIM_COMPLETE,
-	NFSPROC4_CLNT_PNFS_LAYOUTGET,
+	NFSPROC4_CLNT_LAYOUTGET,
 	NFSPROC4_CLNT_PNFS_LAYOUTCOMMIT,
 	NFSPROC4_CLNT_PNFS_LAYOUTRETURN,
 	NFSPROC4_CLNT_GETDEVICEINFO,
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index 4371c84..bc02f36 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -30,7 +30,7 @@ struct nfs4_pnfs_layout_segment {
 	u64 length;
 };
 
-struct nfs4_pnfs_layoutget_arg {
+struct nfs4_layoutget_args {
 	__u32 type;
 	struct nfs4_pnfs_layout_segment lseg;
 	__u64 minlength;
@@ -39,7 +39,7 @@ struct nfs4_pnfs_layoutget_arg {
 	struct nfs4_sequence_args seq_args;
 };
 
-struct nfs4_pnfs_layoutget_res {
+struct nfs4_layoutget_res {
 	__u32 return_on_close;
 	struct nfs4_pnfs_layout_segment lseg;
 	__u32 type;
@@ -48,9 +48,9 @@ struct nfs4_pnfs_layoutget_res {
 	struct nfs4_sequence_res seq_res;
 };
 
-struct nfs4_pnfs_layoutget {
-	struct nfs4_pnfs_layoutget_arg args;
-	struct nfs4_pnfs_layoutget_res res;
+struct nfs4_layoutget {
+	struct nfs4_layoutget_args args;
+	struct nfs4_layoutget_res res;
 	struct pnfs_layout_segment **lsegpp;
 	int status;
 };
-- 
1.6.2.5

