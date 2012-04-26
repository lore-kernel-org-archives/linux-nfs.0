Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12976 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754596Ab2DZVDo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 17:03:44 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/8] NFSv4: Simplify the NFSv4 OPEN compound
Date: Thu, 26 Apr 2012 17:03:33 -0400
Message-Id: <1335474215-29127-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335474215-29127-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1335474215-29127-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-4-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Get rid of the post-op GETATTR on the directory in order to reduce
the amount of processing done on the server.

The cost is that if we later need to stat() the directory, then we
know that the ctime and mtime are likely to be invalid.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       |   11 +----------
 fs/nfs/nfs4xdr.c        |   18 +-----------------
 include/linux/nfs_xdr.h |    2 --
 3 files changed, 2 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a3930fe..8219298 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -788,7 +788,6 @@ struct nfs4_opendata {
 	struct nfs4_string owner_name;
 	struct nfs4_string group_name;
 	struct nfs_fattr f_attr;
-	struct nfs_fattr dir_attr;
 	struct dentry *dir;
 	struct dentry *dentry;
 	struct nfs4_state_owner *owner;
@@ -804,12 +803,10 @@ struct nfs4_opendata {
 static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 {
 	p->o_res.f_attr = &p->f_attr;
-	p->o_res.dir_attr = &p->dir_attr;
 	p->o_res.seqid = p->o_arg.seqid;
 	p->c_res.seqid = p->c_arg.seqid;
 	p->o_res.server = p->o_arg.server;
 	nfs_fattr_init(&p->f_attr);
-	nfs_fattr_init(&p->dir_attr);
 	nfs_fattr_init_names(&p->f_attr, &p->owner_name, &p->group_name);
 }
 
@@ -844,7 +841,6 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.name = &dentry->d_name;
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
-	p->o_arg.dir_bitmask = server->cache_consistency_bitmask;
 	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
 	p->o_arg.opentype = NFS4_OPEN_NOCREATE;
 	p->o_arg.createmode = NFS4_CREATE_UNCHECKED;
@@ -1629,8 +1625,6 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
 
 	nfs_fattr_map_and_free_names(NFS_SERVER(dir), &data->f_attr);
 
-	nfs_refresh_inode(dir, o_res->dir_attr);
-
 	if (o_res->rflags & NFS4_OPEN_RESULT_CONFIRM) {
 		status = _nfs4_proc_open_confirm(data);
 		if (status != 0)
@@ -1663,11 +1657,8 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 
 	nfs_fattr_map_and_free_names(server, &data->f_attr);
 
-	if (o_arg->open_flags & O_CREAT) {
+	if (o_arg->open_flags & O_CREAT)
 		update_changeattr(dir, &o_res->cinfo);
-		nfs_post_op_update_inode(dir, o_res->dir_attr);
-	} else
-		nfs_refresh_inode(dir, o_res->dir_attr);
 	if ((o_res->rflags & NFS4_OPEN_RESULT_LOCKTYPE_POSIX) == 0)
 		server->caps &= ~NFS_CAP_POSIX_LOCK;
 	if(o_res->rflags & NFS4_OPEN_RESULT_CONFIRM) {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5edf936..782466d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -431,20 +431,14 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_enc_open_sz        (compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
-				encode_savefh_maxsz + \
 				encode_open_maxsz + \
 				encode_getfh_maxsz + \
-				encode_getattr_maxsz + \
-				encode_restorefh_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_open_sz        (compound_decode_hdr_maxsz + \
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
-				decode_savefh_maxsz + \
 				decode_open_maxsz + \
 				decode_getfh_maxsz + \
-				decode_getattr_maxsz + \
-				decode_restorefh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_open_confirm_sz \
 				(compound_encode_hdr_maxsz + \
@@ -2190,12 +2184,9 @@ static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
-	encode_savefh(xdr, &hdr);
 	encode_open(xdr, args, &hdr);
 	encode_getfh(xdr, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
-	encode_restorefh(xdr, &hdr);
-	encode_getfattr(xdr, args->dir_bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -6091,19 +6082,12 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_savefh(xdr);
-	if (status)
-		goto out;
 	status = decode_open(xdr, res);
 	if (status)
 		goto out;
 	if (decode_getfh(xdr, &res->fh) != 0)
 		goto out;
-	if (decode_getfattr(xdr, res->f_attr, res->server) != 0)
-		goto out;
-	if (decode_restorefh(xdr) != 0)
-		goto out;
-	decode_getfattr(xdr, res->dir_attr, res->server);
+	decode_getfattr(xdr, res->f_attr, res->server);
 out:
 	return status;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1def5fe..33b0d9e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -338,7 +338,6 @@ struct nfs_openargs {
 	const struct qstr *	name;
 	const struct nfs_server *server;	 /* Needed for ID mapping */
 	const u32 *		bitmask;
-	const u32 *		dir_bitmask;
 	__u32			claim;
 	__u32			opentype;
 	__u32			createmode;
@@ -351,7 +350,6 @@ struct nfs_openres {
 	struct nfs4_change_info	cinfo;
 	__u32                   rflags;
 	struct nfs_fattr *      f_attr;
-	struct nfs_fattr *      dir_attr;
 	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
 	fmode_t			delegation_type;
-- 
1.7.7.6

