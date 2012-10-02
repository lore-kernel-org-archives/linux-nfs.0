Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51119 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932392Ab2JBVt5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 17:49:57 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/2] NFSv4: don't put ACCESS in OPEN compound if O_EXCL
Date: Tue,  2 Oct 2012 14:49:52 -0700
Message-Id: <1349214592-11717-3-git-send-email-dros@netapp.com>
In-Reply-To: <1349214592-11717-1-git-send-email-dros@netapp.com>
References: <1349214592-11717-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't put an ACCESS op in OPEN compound if O_EXCL, because ACCESS
will return permission denied for all bits until close.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c       |   12 +++++++++---
 fs/nfs/nfs4xdr.c        |   12 ++++++++----
 include/linux/nfs_xdr.h |    1 +
 3 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ccada68..21cfac7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -862,9 +862,15 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.fh = NFS_FH(dir);
 	p->o_arg.open_flags = flags;
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
-	/* ask server to check for all possible rights as results are cached */
-	p->o_arg.access = NFS4_ACCESS_READ | NFS4_ACCESS_MODIFY |
-			  NFS4_ACCESS_EXTEND | NFS4_ACCESS_EXECUTE;
+	/* don't put an ACCESS op in OPEN compound if O_EXCL, because ACCESS
+	 * will return permission denied for all bits until close */
+	if (!(flags & O_EXCL)) {
+		/* ask server to check for all possible rights as results
+		 * are cached */
+		p->o_arg.access = NFS4_ACCESS_READ | NFS4_ACCESS_MODIFY |
+				  NFS4_ACCESS_EXTEND | NFS4_ACCESS_EXECUTE;
+		p->o_res.access_request = p->o_arg.access;
+	}
 	p->o_arg.clientid = server->nfs_client->cl_clientid;
 	p->o_arg.id.create_time = ktime_to_ns(sp->so_seqid.create_time);
 	p->o_arg.id.uniquifier = sp->so_seqid.owner_id;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 657483c..0d60305 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2224,7 +2224,8 @@ static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_open(xdr, args, &hdr);
 	encode_getfh(xdr, &hdr);
-	encode_access(xdr, args->access, &hdr);
+	if (args->access)
+		encode_access(xdr, args->access, &hdr);
 	encode_getfattr_open(xdr, args->bitmask, args->open_bitmap, &hdr);
 	encode_nops(&hdr);
 }
@@ -2261,7 +2262,8 @@ static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_open(xdr, args, &hdr);
-	encode_access(xdr, args->access, &hdr);
+	if (args->access)
+		encode_access(xdr, args->access, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
@@ -6239,7 +6241,8 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_getfh(xdr, &res->fh);
 	if (status)
 		goto out;
-	decode_access(xdr, &res->access_supported, &res->access_result);
+	if (res->access_request)
+		decode_access(xdr, &res->access_supported, &res->access_result);
 	decode_getfattr(xdr, res->f_attr, res->server);
 out:
 	return status;
@@ -6288,7 +6291,8 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp,
 	status = decode_open(xdr, res);
 	if (status)
 		goto out;
-	decode_access(xdr, &res->access_supported, &res->access_result);
+	if (res->access_request)
+		decode_access(xdr, &res->access_supported, &res->access_result);
 	decode_getfattr(xdr, res->f_attr, res->server);
 out:
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 655490d..a73ea89 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -369,6 +369,7 @@ struct nfs_openres {
 	struct nfs4_string	*owner;
 	struct nfs4_string	*group_owner;
 	struct nfs4_sequence_res	seq_res;
+	__u32			access_request;
 	__u32			access_supported;
 	__u32			access_result;
 };
-- 
1.7.9.6 (Apple Git-31.1)

