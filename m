From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/32] NFSv4: Don't do idmapper upcalls for asynchronous
 RPC calls
Date: Wed, 19 Aug 2009 19:38:27 -0400
Message-ID: <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51423 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754107AbZHSXkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:55 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNehbr001920
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:43 -0700 (PDT)
In-Reply-To: <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't want to cause rpciod to hang...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |   86 ++++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 58 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 617273e..e65cc2e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3075,7 +3075,8 @@ static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t
 	return ret;
 }
 
-static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs_client *clp, uint32_t *uid)
+static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
+		struct nfs_client *clp, uint32_t *uid, int may_sleep)
 {
 	uint32_t len;
 	__be32 *p;
@@ -3088,7 +3089,9 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		READ_BUF(4);
 		READ32(len);
 		READ_BUF(len);
-		if (len < XDR_MAX_NETOBJ) {
+		if (!may_sleep) {
+			/* do nothing */
+		} else if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_name_to_uid(clp, (char *)p, len, uid) == 0)
 				ret = NFS_ATTR_FATTR_OWNER;
 			else
@@ -3103,7 +3106,8 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 	return ret;
 }
 
-static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs_client *clp, uint32_t *gid)
+static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
+		struct nfs_client *clp, uint32_t *gid, int may_sleep)
 {
 	uint32_t len;
 	__be32 *p;
@@ -3116,7 +3120,9 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		READ_BUF(4);
 		READ32(len);
 		READ_BUF(len);
-		if (len < XDR_MAX_NETOBJ) {
+		if (!may_sleep) {
+			/* do nothing */
+		} else if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_group_to_gid(clp, (char *)p, len, gid) == 0)
 				ret = NFS_ATTR_FATTR_GROUP;
 			else
@@ -3466,7 +3472,8 @@ xdr_error:
 	return status;
 }
 
-static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr, const struct nfs_server *server)
+static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
+		const struct nfs_server *server, int may_sleep)
 {
 	__be32 *savep;
 	uint32_t attrlen,
@@ -3538,12 +3545,14 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr, cons
 		goto xdr_error;
 	fattr->valid |= status;
 
-	status = decode_attr_owner(xdr, bitmap, server->nfs_client, &fattr->uid);
+	status = decode_attr_owner(xdr, bitmap, server->nfs_client,
+			&fattr->uid, may_sleep);
 	if (status < 0)
 		goto xdr_error;
 	fattr->valid |= status;
 
-	status = decode_attr_group(xdr, bitmap, server->nfs_client, &fattr->gid);
+	status = decode_attr_group(xdr, bitmap, server->nfs_client,
+			&fattr->gid, may_sleep);
 	if (status < 0)
 		goto xdr_error;
 	fattr->valid |= status;
@@ -4370,7 +4379,8 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct
 	status = decode_open_downgrade(&xdr, res);
 	if (status != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server);
+	decode_getfattr(&xdr, res->fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -4397,7 +4407,8 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_ac
 	status = decode_access(&xdr, res);
 	if (status != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server);
+	decode_getfattr(&xdr, res->fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -4424,7 +4435,8 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lo
 		goto out;
 	if ((status = decode_getfh(&xdr, res->fh)) != 0)
 		goto out;
-	status = decode_getfattr(&xdr, res->fattr, res->server);
+	status = decode_getfattr(&xdr, res->fattr, res->server
+			,!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -4448,7 +4460,8 @@ static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	if ((status = decode_putrootfh(&xdr)) != 0)
 		goto out;
 	if ((status = decode_getfh(&xdr, res->fh)) == 0)
-		status = decode_getfattr(&xdr, res->fattr, res->server);
+		status = decode_getfattr(&xdr, res->fattr, res->server,
+				!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -4473,7 +4486,8 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_rem
 		goto out;
 	if ((status = decode_remove(&xdr, &res->cinfo)) != 0)
 		goto out;
-	decode_getfattr(&xdr, &res->dir_attr, res->server);
+	decode_getfattr(&xdr, &res->dir_attr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -4503,11 +4517,13 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_re
 	if ((status = decode_rename(&xdr, &res->old_cinfo, &res->new_cinfo)) != 0)
 		goto out;
 	/* Current FH is target directory */
-	if (decode_getfattr(&xdr, res->new_fattr, res->server) != 0)
+	if (decode_getfattr(&xdr, res->new_fattr, res->server,
+				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
 		goto out;
 	if ((status = decode_restorefh(&xdr)) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->old_fattr, res->server);
+	decode_getfattr(&xdr, res->old_fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -4540,11 +4556,13 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_link
 	 * Note order: OP_LINK leaves the directory as the current
 	 *             filehandle.
 	 */
-	if (decode_getfattr(&xdr, res->dir_attr, res->server) != 0)
+	if (decode_getfattr(&xdr, res->dir_attr, res->server,
+				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
 		goto out;
 	if ((status = decode_restorefh(&xdr)) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server);
+	decode_getfattr(&xdr, res->fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -4573,11 +4591,13 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_cr
 		goto out;
 	if ((status = decode_getfh(&xdr, res->fh)) != 0)
 		goto out;
-	if (decode_getfattr(&xdr, res->fattr, res->server) != 0)
+	if (decode_getfattr(&xdr, res->fattr, res->server,
+				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
 		goto out;
 	if ((status = decode_restorefh(&xdr)) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->dir_fattr, res->server);
+	decode_getfattr(&xdr, res->dir_fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -4609,7 +4629,8 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_g
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	status = decode_getfattr(&xdr, res->fattr, res->server);
+	status = decode_getfattr(&xdr, res->fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -4716,7 +4737,8 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	 * 	an ESTALE error. Shouldn't be a problem,
 	 * 	though, since fattr->valid will remain unset.
 	 */
-	decode_getfattr(&xdr, res->fattr, res->server);
+	decode_getfattr(&xdr, res->fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -4748,11 +4770,13 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openr
 		goto out;
 	if (decode_getfh(&xdr, &res->fh) != 0)
 		goto out;
-	if (decode_getfattr(&xdr, res->f_attr, res->server) != 0)
+	if (decode_getfattr(&xdr, res->f_attr, res->server,
+				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
 		goto out;
 	if (decode_restorefh(&xdr) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->dir_attr, res->server);
+	decode_getfattr(&xdr, res->dir_attr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -4800,7 +4824,8 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	status = decode_open(&xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->f_attr, res->server);
+	decode_getfattr(&xdr, res->f_attr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -4827,7 +4852,8 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_se
 	status = decode_setattr(&xdr);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server);
+	decode_getfattr(&xdr, res->fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -5001,7 +5027,8 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writ
 	status = decode_write(&xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server);
+	decode_getfattr(&xdr, res->fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 	if (!status)
 		status = res->count;
 out:
@@ -5030,7 +5057,8 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, __be32 *p, struct nfs_wri
 	status = decode_commit(&xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server);
+	decode_getfattr(&xdr, res->fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -5194,7 +5222,8 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	if (status != 0)
 		goto out;
 	status = decode_delegreturn(&xdr);
-	decode_getfattr(&xdr, res->fattr, res->server);
+	decode_getfattr(&xdr, res->fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
 	return status;
 }
@@ -5222,7 +5251,8 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p,
 		goto out;
 	xdr_enter_page(&xdr, PAGE_SIZE);
 	status = decode_getfattr(&xdr, &res->fs_locations->fattr,
-				 res->fs_locations->server);
+				 res->fs_locations->server,
+				 !RPC_IS_ASYNC(req->rq_task));
 out:
 	return status;
 }
-- 
1.6.0.4
