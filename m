Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55610 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754218Ab2D2Uud (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Apr 2012 16:50:33 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 12/15] NFSv4: Simplify the NFSv4 CREATE compound
Date: Sun, 29 Apr 2012 16:50:17 -0400
Message-Id: <1335732620-10445-13-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335732620-10445-12-git-send-email-Trond.Myklebust@netapp.com>
References: <1335732620-10445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-4-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-5-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-6-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-7-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-8-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-9-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-10-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-11-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-12-git-send-email-Trond.Myklebust@netapp.com>
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
index f01c3d1..619bc1e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2994,7 +2994,6 @@ struct nfs4_createdata {
 	struct nfs4_create_res res;
 	struct nfs_fh fh;
 	struct nfs_fattr fattr;
-	struct nfs_fattr dir_fattr;
 };
 
 static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
@@ -3018,9 +3017,7 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 		data->res.server = server;
 		data->res.fh = &data->fh;
 		data->res.fattr = &data->fattr;
-		data->res.dir_fattr = &data->dir_fattr;
 		nfs_fattr_init(data->res.fattr);
-		nfs_fattr_init(data->res.dir_fattr);
 	}
 	return data;
 }
@@ -3031,7 +3028,6 @@ static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_
 				    &data->arg.seq_args, &data->res.seq_res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &data->res.dir_cinfo);
-		nfs_post_op_update_inode(dir, data->res.dir_fattr);
 		status = nfs_instantiate(dentry, data->res.fh, data->res.fattr);
 	}
 	return status;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6e878dc..1a70097 100644
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
@@ -2119,12 +2113,9 @@ static void nfs4_xdr_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
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
 
@@ -5895,21 +5886,13 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
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
index fb25080..5a05739 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -855,7 +855,6 @@ struct nfs4_create_res {
 	struct nfs_fh *			fh;
 	struct nfs_fattr *		fattr;
 	struct nfs4_change_info		dir_cinfo;
-	struct nfs_fattr *		dir_fattr;
 	struct nfs4_sequence_res	seq_res;
 };
 
-- 
1.7.7.6

