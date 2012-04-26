Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12976 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754526Ab2DZVDp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 17:03:45 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/8] NFSv4: Simplify the NFSv4 CREATE compound
Date: Thu, 26 Apr 2012 17:03:34 -0400
Message-Id: <1335474215-29127-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335474215-29127-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1335474215-29127-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-4-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-5-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Get rid of the post-op GETATTR on the directory in order to reduce
the amount of processing done on the server.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       |    4 ----
 fs/nfs/nfs4xdr.c        |   19 +------------------
 include/linux/nfs_xdr.h |    1 -
 3 files changed, 1 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8219298..0239d52 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2975,7 +2975,6 @@ struct nfs4_createdata {
 	struct nfs4_create_res res;
 	struct nfs_fh fh;
 	struct nfs_fattr fattr;
-	struct nfs_fattr dir_fattr;
 };
 
 static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
@@ -2999,9 +2998,7 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 		data->res.server = server;
 		data->res.fh = &data->fh;
 		data->res.fattr = &data->fattr;
-		data->res.dir_fattr = &data->dir_fattr;
 		nfs_fattr_init(data->res.fattr);
-		nfs_fattr_init(data->res.dir_fattr);
 	}
 	return data;
 }
@@ -3012,7 +3009,6 @@ static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_
 				    &data->arg.seq_args, &data->res.seq_res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &data->res.dir_cinfo);
-		nfs_post_op_update_inode(dir, data->res.dir_fattr);
 		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
 	}
 	return status;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 782466d..e77097c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -647,20 +647,14 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_enc_create_sz	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
-				encode_savefh_maxsz + \
 				encode_create_maxsz + \
 				encode_getfh_maxsz + \
-				encode_getattr_maxsz + \
-				encode_restorefh_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_create_sz	(compound_decode_hdr_maxsz + \
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
-				decode_savefh_maxsz + \
 				decode_create_maxsz + \
 				decode_getfh_maxsz + \
-				decode_getattr_maxsz + \
-				decode_restorefh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_pathconf_sz	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
@@ -2118,12 +2112,9 @@ static void nfs4_xdr_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->dir_fh, &hdr);
-	encode_savefh(xdr, &hdr);
 	encode_create(xdr, args, &hdr);
 	encode_getfh(xdr, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
-	encode_restorefh(xdr, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -5911,21 +5902,13 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_savefh(xdr);
-	if (status)
-		goto out;
 	status = decode_create(xdr, &res->dir_cinfo);
 	if (status)
 		goto out;
 	status = decode_getfh(xdr, res->fh);
 	if (status)
 		goto out;
-	if (decode_getfattr(xdr, res->fattr, res->server))
-		goto out;
-	status = decode_restorefh(xdr);
-	if (status)
-		goto out;
-	decode_getfattr(xdr, res->dir_fattr, res->server);
+	decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 33b0d9e..8f4cd0d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -839,7 +839,6 @@ struct nfs4_create_res {
 	struct nfs_fh *			fh;
 	struct nfs_fattr *		fattr;
 	struct nfs4_change_info		dir_cinfo;
-	struct nfs_fattr *		dir_fattr;
 	struct nfs4_sequence_res	seq_res;
 };
 
-- 
1.7.7.6

