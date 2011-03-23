Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64002 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753174Ab1CWMaj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 08:30:39 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/11] NFSv4.1: remove GETATTR from ds commits
Date: Wed, 23 Mar 2011 08:30:10 -0400
Message-Id: <1300883412-32296-10-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300883412-32296-1-git-send-email-iisaman@netapp.com>
References: <1300883412-32296-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Any COMMIT compound directed to a data server needs to have the
GETATTR calls suppressed.  We here, make sure the field we are testing
(data->lseg) is set and refcounted correctly.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |    8 ++++++--
 fs/nfs/nfs4xdr.c  |    8 +++++---
 fs/nfs/write.c    |    7 +++++--
 3 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bcc29bd..5d61ccc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3217,8 +3217,12 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
-	
-	data->args.bitmask = server->cache_consistency_bitmask;
+
+	if (data->lseg) {
+		data->args.bitmask = NULL;
+		data->res.fattr = NULL;
+	} else
+		data->args.bitmask = server->cache_consistency_bitmask;
 	if (!data->write_done_cb)
 		data->write_done_cb = nfs4_commit_done_cb;
 	data->res.server = server;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0cf560f..07cdf92 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2294,7 +2294,8 @@ static void nfs4_xdr_enc_commit(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_commit(xdr, args, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
+	if (args->bitmask)
+		encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -5723,8 +5724,9 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_commit(xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	if (res->fattr)
+		decode_getfattr(xdr, res->fattr, res->server,
+				!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 6927a18..cae5d16 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1295,6 +1295,7 @@ static void nfs_commitdata_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
 
+	put_lseg(wdata->lseg);
 	put_nfs_open_context(wdata->args.context);
 	nfs_commit_free(wdata);
 }
@@ -1338,7 +1339,8 @@ static int nfs_initiate_commit(struct nfs_write_data *data, struct rpc_clnt *cln
  * Set up the argument/result storage required for the RPC call.
  */
 static void nfs_init_commit(struct nfs_write_data *data,
-			    struct list_head *head)
+			    struct list_head *head,
+			    struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page *first = nfs_list_entry(head->next);
 	struct inode *inode = first->wb_context->path.dentry->d_inode;
@@ -1350,6 +1352,7 @@ static void nfs_init_commit(struct nfs_write_data *data,
 
 	data->inode	  = inode;
 	data->cred	  = first->wb_context->cred;
+	data->lseg	  = lseg; /* reference transferred */
 	data->mds_ops     = &nfs_commit_ops;
 
 	data->args.fh     = NFS_FH(data->inode);
@@ -1393,7 +1396,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 		goto out_bad;
 
 	/* Set up the argument struct */
-	nfs_init_commit(data, head);
+	nfs_init_commit(data, head, NULL);
 	return nfs_initiate_commit(data, NFS_CLIENT(inode), data->mds_ops, how);
  out_bad:
 	nfs_retry_commit(head, NULL);
-- 
1.7.2.1

