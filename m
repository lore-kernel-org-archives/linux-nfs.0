Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50260 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933028AbdELQSz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:18:55 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 29/33] nfsd4: properly type op_func callbacks
Date: Fri, 12 May 2017 18:16:57 +0200
Message-Id: <20170512161701.22468-30-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass union nfsd4_op_u to the op_func callbacks instead of using unsafe
function pointer casts.

It also adds two missing structures to struct nfsd4_op.u to facilitate
this.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4proc.c  | 234 ++++++++++++++++++++++++++++------------------------
 fs/nfsd/nfs4state.c |  82 +++++++++++-------
 fs/nfsd/xdr4.h      |  66 +++++++--------
 3 files changed, 209 insertions(+), 173 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0bd4b750262f..a947dcef5e4e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -344,8 +344,9 @@ copy_clientid(clientid_t *clid, struct nfsd4_session *session)
 
 static __be32
 nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	   struct nfsd4_open *open)
+	   union nfsd4_op_u *u)
 {
+	struct nfsd4_open *open = &u->open;
 	__be32 status;
 	struct svc_fh *resfh = NULL;
 	struct net *net = SVC_NET(rqstp);
@@ -467,14 +468,14 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
  */
 static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_op *op)
 {
-	struct nfsd4_open *open = (struct nfsd4_open *)&op->u;
+	struct nfsd4_open *open = &op->u.open;
 
 	if (!seqid_mutating_err(ntohl(op->status)))
 		return op->status;
 	if (nfsd4_has_session(cstate))
 		return op->status;
 	open->op_xdr_error = op->status;
-	return nfsd4_open(rqstp, cstate, open);
+	return nfsd4_open(rqstp, cstate, &op->u);
 }
 
 /*
@@ -482,19 +483,21 @@ static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_stat
  */
 static __be32
 nfsd4_getfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	    struct svc_fh **getfh)
+	    union nfsd4_op_u *u)
 {
 	if (!cstate->current_fh.fh_dentry)
 		return nfserr_nofilehandle;
 
-	*getfh = &cstate->current_fh;
+	u->getfh = &cstate->current_fh;
 	return nfs_ok;
 }
 
 static __be32
 nfsd4_putfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	    struct nfsd4_putfh *putfh)
+	    union nfsd4_op_u *u)
 {
+	struct nfsd4_putfh *putfh = &u->putfh;
+
 	fh_put(&cstate->current_fh);
 	cstate->current_fh.fh_handle.fh_size = putfh->pf_fhlen;
 	memcpy(&cstate->current_fh.fh_handle.fh_base, putfh->pf_fhval,
@@ -504,7 +507,7 @@ nfsd4_putfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_putrootfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		void *arg)
+		union nfsd4_op_u *u)
 {
 	__be32 status;
 
@@ -515,7 +518,7 @@ nfsd4_putrootfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		void *arg)
+		union nfsd4_op_u *u)
 {
 	if (!cstate->save_fh.fh_dentry)
 		return nfserr_restorefh;
@@ -530,7 +533,7 @@ nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_savefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	     void *arg)
+	     union nfsd4_op_u *u)
 {
 	if (!cstate->current_fh.fh_dentry)
 		return nfserr_nofilehandle;
@@ -548,8 +551,10 @@ nfsd4_savefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
  */
 static __be32
 nfsd4_access(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	     struct nfsd4_access *access)
+	     union nfsd4_op_u *u)
 {
+	struct nfsd4_access *access = &u->access;
+
 	if (access->ac_req_access & ~NFS3_ACCESS_FULL)
 		return nfserr_inval;
 
@@ -574,8 +579,10 @@ static void gen_boot_verifier(nfs4_verifier *verifier, struct net *net)
 
 static __be32
 nfsd4_commit(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	     struct nfsd4_commit *commit)
+	     union nfsd4_op_u *u)
 {
+	struct nfsd4_commit *commit = &u->commit;
+
 	gen_boot_verifier(&commit->co_verf, SVC_NET(rqstp));
 	return nfsd_commit(rqstp, &cstate->current_fh, commit->co_offset,
 			     commit->co_count);
@@ -583,8 +590,9 @@ nfsd4_commit(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	     struct nfsd4_create *create)
+	     union nfsd4_op_u *u)
 {
+	struct nfsd4_create *create = &u->create;
 	struct svc_fh resfh;
 	__be32 status;
 	dev_t rdev;
@@ -670,8 +678,9 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_getattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	      struct nfsd4_getattr *getattr)
+	      union nfsd4_op_u *u)
 {
+	struct nfsd4_getattr *getattr = &u->getattr;
 	__be32 status;
 
 	status = fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_NOP);
@@ -691,8 +700,9 @@ nfsd4_getattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_link(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	   struct nfsd4_link *link)
+	   union nfsd4_op_u *u)
 {
+	struct nfsd4_link *link = &u->link;
 	__be32 status = nfserr_nofilehandle;
 
 	if (!cstate->save_fh.fh_dentry)
@@ -723,24 +733,25 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 
 static __be32
 nfsd4_lookupp(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	      void *arg)
+	      union nfsd4_op_u *u)
 {
 	return nfsd4_do_lookupp(rqstp, &cstate->current_fh);
 }
 
 static __be32
 nfsd4_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	     struct nfsd4_lookup *lookup)
+	     union nfsd4_op_u *u)
 {
 	return nfsd_lookup(rqstp, &cstate->current_fh,
-			   lookup->lo_name, lookup->lo_len,
+			   u->lookup.lo_name, u->lookup.lo_len,
 			   &cstate->current_fh);
 }
 
 static __be32
 nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	   struct nfsd4_read *read)
+	   union nfsd4_op_u *u)
 {
+	struct nfsd4_read *read = &u->read;
 	__be32 status;
 
 	read->rd_filp = NULL;
@@ -775,8 +786,9 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_readdir(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	      struct nfsd4_readdir *readdir)
+	      union nfsd4_op_u *u)
 {
+	struct nfsd4_readdir *readdir = &u->readdir;
 	u64 cookie = readdir->rd_cookie;
 	static const nfs4_verifier zeroverf;
 
@@ -800,17 +812,18 @@ nfsd4_readdir(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_readlink(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	       struct nfsd4_readlink *readlink)
+	       union nfsd4_op_u *u)
 {
-	readlink->rl_rqstp = rqstp;
-	readlink->rl_fhp = &cstate->current_fh;
+	u->readlink.rl_rqstp = rqstp;
+	u->readlink.rl_fhp = &cstate->current_fh;
 	return nfs_ok;
 }
 
 static __be32
 nfsd4_remove(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	     struct nfsd4_remove *remove)
+	     union nfsd4_op_u *u)
 {
+	struct nfsd4_remove *remove = &u->remove;
 	__be32 status;
 
 	if (opens_in_grace(SVC_NET(rqstp)))
@@ -826,8 +839,9 @@ nfsd4_remove(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_rename(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	     struct nfsd4_rename *rename)
+	     union nfsd4_op_u *u)
 {
+	struct nfsd4_rename *rename = &u->rename;
 	__be32 status = nfserr_nofilehandle;
 
 	if (!cstate->save_fh.fh_dentry)
@@ -847,8 +861,9 @@ nfsd4_rename(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	      struct nfsd4_secinfo *secinfo)
+	      union nfsd4_op_u *u)
 {
+	struct nfsd4_secinfo *secinfo = &u->secinfo;
 	struct svc_export *exp;
 	struct dentry *dentry;
 	__be32 err;
@@ -876,11 +891,11 @@ nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_secinfo_no_name(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	      struct nfsd4_secinfo_no_name *sin)
+		union nfsd4_op_u *u)
 {
 	__be32 err;
 
-	switch (sin->sin_style) {
+	switch (u->secinfo_no_name.sin_style) {
 	case NFS4_SECINFO_STYLE4_CURRENT_FH:
 		break;
 	case NFS4_SECINFO_STYLE4_PARENT:
@@ -892,15 +907,16 @@ nfsd4_secinfo_no_name(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstat
 		return nfserr_inval;
 	}
 
-	sin->sin_exp = exp_get(cstate->current_fh.fh_export);
+	u->secinfo_no_name.sin_exp = exp_get(cstate->current_fh.fh_export);
 	fh_put(&cstate->current_fh);
 	return nfs_ok;
 }
 
 static __be32
 nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	      struct nfsd4_setattr *setattr)
+	      union nfsd4_op_u *u)
 {
+	struct nfsd4_setattr *setattr = &u->setattr;
 	__be32 status = nfs_ok;
 	int err;
 
@@ -960,8 +976,9 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 
 static __be32
 nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	    struct nfsd4_write *write)
+	    union nfsd4_op_u *u)
 {
+	struct nfsd4_write *write = &u->write;
 	stateid_t *stateid = &write->wr_stateid;
 	struct file *filp = NULL;
 	__be32 status = nfs_ok;
@@ -1034,8 +1051,9 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		struct nfsd4_clone *clone)
+		union nfsd4_op_u *u)
 {
+	struct nfsd4_clone *clone = &u->clone;
 	struct file *src, *dst;
 	__be32 status;
 
@@ -1055,8 +1073,9 @@ nfsd4_clone(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		struct nfsd4_copy *copy)
+		union nfsd4_op_u *u)
 {
+	struct nfsd4_copy *copy = &u->copy;
 	struct file *src, *dst;
 	__be32 status;
 	ssize_t bytes;
@@ -1111,23 +1130,24 @@ nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_allocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	       struct nfsd4_fallocate *fallocate)
+	       union nfsd4_op_u *u)
 {
-	return nfsd4_fallocate(rqstp, cstate, fallocate, 0);
+	return nfsd4_fallocate(rqstp, cstate, &u->allocate, 0);
 }
 
 static __be32
 nfsd4_deallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		 struct nfsd4_fallocate *fallocate)
+		 union nfsd4_op_u *u)
 {
-	return nfsd4_fallocate(rqstp, cstate, fallocate,
+	return nfsd4_fallocate(rqstp, cstate, &u->deallocate,
 			       FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE);
 }
 
 static __be32
 nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		struct nfsd4_seek *seek)
+	   union nfsd4_op_u *u)
 {
+	struct nfsd4_seek *seek = &u->seek;
 	int whence;
 	__be32 status;
 	struct file *file;
@@ -1232,21 +1252,21 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 static __be32
 nfsd4_nverify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	      struct nfsd4_verify *verify)
+	      union nfsd4_op_u *u)
 {
 	__be32 status;
 
-	status = _nfsd4_verify(rqstp, cstate, verify);
+	status = _nfsd4_verify(rqstp, cstate, &u->verify);
 	return status == nfserr_not_same ? nfs_ok : status;
 }
 
 static __be32
 nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	     struct nfsd4_verify *verify)
+	     union nfsd4_op_u *u)
 {
 	__be32 status;
 
-	status = _nfsd4_verify(rqstp, cstate, verify);
+	status = _nfsd4_verify(rqstp, cstate, &u->nverify);
 	return status == nfserr_same ? nfs_ok : status;
 }
 
@@ -1271,9 +1291,9 @@ nfsd4_layout_verify(struct svc_export *exp, unsigned int layout_type)
 
 static __be32
 nfsd4_getdeviceinfo(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *cstate,
-		struct nfsd4_getdeviceinfo *gdp)
+		struct nfsd4_compound_state *cstate, union nfsd4_op_u *u)
 {
+	struct nfsd4_getdeviceinfo *gdp = &u->getdeviceinfo;
 	const struct nfsd4_layout_ops *ops;
 	struct nfsd4_deviceid_map *map;
 	struct svc_export *exp;
@@ -1317,9 +1337,9 @@ nfsd4_getdeviceinfo(struct svc_rqst *rqstp,
 
 static __be32
 nfsd4_layoutget(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *cstate,
-		struct nfsd4_layoutget *lgp)
+		struct nfsd4_compound_state *cstate, union nfsd4_op_u *u)
 {
+	struct nfsd4_layoutget *lgp = &u->layoutget;
 	struct svc_fh *current_fh = &cstate->current_fh;
 	const struct nfsd4_layout_ops *ops;
 	struct nfs4_layout_stateid *ls;
@@ -1397,9 +1417,9 @@ nfsd4_layoutget(struct svc_rqst *rqstp,
 
 static __be32
 nfsd4_layoutcommit(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *cstate,
-		struct nfsd4_layoutcommit *lcp)
+		struct nfsd4_compound_state *cstate, union nfsd4_op_u *u)
 {
+	struct nfsd4_layoutcommit *lcp = &u->layoutcommit;
 	const struct nfsd4_layout_seg *seg = &lcp->lc_seg;
 	struct svc_fh *current_fh = &cstate->current_fh;
 	const struct nfsd4_layout_ops *ops;
@@ -1461,9 +1481,9 @@ nfsd4_layoutcommit(struct svc_rqst *rqstp,
 
 static __be32
 nfsd4_layoutreturn(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *cstate,
-		struct nfsd4_layoutreturn *lrp)
+		struct nfsd4_compound_state *cstate, union nfsd4_op_u *u)
 {
+	struct nfsd4_layoutreturn *lrp = &u->layoutreturn;
 	struct svc_fh *current_fh = &cstate->current_fh;
 	__be32 nfserr;
 
@@ -1521,9 +1541,6 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 		nfsdstats.nfs4_opcount[opnum]++;
 }
 
-typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
-			      void *);
-
 enum nfsd4_op_flags {
 	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
 	ALLOWED_ON_ABSENT_FS = 1 << 1,	/* ops processed on absent fs */
@@ -1555,7 +1572,8 @@ enum nfsd4_op_flags {
 };
 
 struct nfsd4_operation {
-	nfsd4op_func op_func;
+	__be32 (*op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
+			union nfsd4_op_u *);
 	u32 op_flags;
 	char *op_name;
 	/* Try to get response size before operation */
@@ -2093,12 +2111,12 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 
 static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_ACCESS] = {
-		.op_func = (nfsd4op_func)nfsd4_access,
+		.op_func = nfsd4_access,
 		.op_name = "OP_ACCESS",
 		.op_rsize_bop = nfsd4_access_rsize,
 	},
 	[OP_CLOSE] = {
-		.op_func = (nfsd4op_func)nfsd4_close,
+		.op_func = nfsd4_close,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_CLOSE",
 		.op_rsize_bop = nfsd4_status_stateid_rsize,
@@ -2106,93 +2124,93 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_set_currentstateid = nfsd4_set_closestateid,
 	},
 	[OP_COMMIT] = {
-		.op_func = (nfsd4op_func)nfsd4_commit,
+		.op_func = nfsd4_commit,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_COMMIT",
 		.op_rsize_bop = nfsd4_commit_rsize,
 	},
 	[OP_CREATE] = {
-		.op_func = (nfsd4op_func)nfsd4_create,
+		.op_func = nfsd4_create,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME | OP_CLEAR_STATEID,
 		.op_name = "OP_CREATE",
 		.op_rsize_bop = nfsd4_create_rsize,
 	},
 	[OP_DELEGRETURN] = {
-		.op_func = (nfsd4op_func)nfsd4_delegreturn,
+		.op_func = nfsd4_delegreturn,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_DELEGRETURN",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 		.op_get_currentstateid = nfsd4_get_delegreturnstateid,
 	},
 	[OP_GETATTR] = {
-		.op_func = (nfsd4op_func)nfsd4_getattr,
+		.op_func = nfsd4_getattr,
 		.op_flags = ALLOWED_ON_ABSENT_FS,
 		.op_rsize_bop = nfsd4_getattr_rsize,
 		.op_name = "OP_GETATTR",
 	},
 	[OP_GETFH] = {
-		.op_func = (nfsd4op_func)nfsd4_getfh,
+		.op_func = nfsd4_getfh,
 		.op_name = "OP_GETFH",
 		.op_rsize_bop = nfsd4_getfh_rsize,
 	},
 	[OP_LINK] = {
-		.op_func = (nfsd4op_func)nfsd4_link,
+		.op_func = nfsd4_link,
 		.op_flags = ALLOWED_ON_ABSENT_FS | OP_MODIFIES_SOMETHING
 				| OP_CACHEME,
 		.op_name = "OP_LINK",
 		.op_rsize_bop = nfsd4_link_rsize,
 	},
 	[OP_LOCK] = {
-		.op_func = (nfsd4op_func)nfsd4_lock,
+		.op_func = nfsd4_lock,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LOCK",
 		.op_rsize_bop = nfsd4_lock_rsize,
 		.op_set_currentstateid = nfsd4_set_lockstateid,
 	},
 	[OP_LOCKT] = {
-		.op_func = (nfsd4op_func)nfsd4_lockt,
+		.op_func = nfsd4_lockt,
 		.op_name = "OP_LOCKT",
 		.op_rsize_bop = nfsd4_lock_rsize,
 	},
 	[OP_LOCKU] = {
-		.op_func = (nfsd4op_func)nfsd4_locku,
+		.op_func = nfsd4_locku,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LOCKU",
 		.op_rsize_bop = nfsd4_status_stateid_rsize,
 		.op_get_currentstateid = nfsd4_get_lockustateid,
 	},
 	[OP_LOOKUP] = {
-		.op_func = (nfsd4op_func)nfsd4_lookup,
+		.op_func = nfsd4_lookup,
 		.op_flags = OP_HANDLES_WRONGSEC | OP_CLEAR_STATEID,
 		.op_name = "OP_LOOKUP",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_LOOKUPP] = {
-		.op_func = (nfsd4op_func)nfsd4_lookupp,
+		.op_func = nfsd4_lookupp,
 		.op_flags = OP_HANDLES_WRONGSEC | OP_CLEAR_STATEID,
 		.op_name = "OP_LOOKUPP",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_NVERIFY] = {
-		.op_func = (nfsd4op_func)nfsd4_nverify,
+		.op_func = nfsd4_nverify,
 		.op_name = "OP_NVERIFY",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_OPEN] = {
-		.op_func = (nfsd4op_func)nfsd4_open,
+		.op_func = nfsd4_open,
 		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN",
 		.op_rsize_bop = nfsd4_open_rsize,
 		.op_set_currentstateid = nfsd4_set_openstateid,
 	},
 	[OP_OPEN_CONFIRM] = {
-		.op_func = (nfsd4op_func)nfsd4_open_confirm,
+		.op_func = nfsd4_open_confirm,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN_CONFIRM",
 		.op_rsize_bop = nfsd4_status_stateid_rsize,
 	},
 	[OP_OPEN_DOWNGRADE] = {
-		.op_func = (nfsd4op_func)nfsd4_open_downgrade,
+		.op_func = nfsd4_open_downgrade,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN_DOWNGRADE",
 		.op_rsize_bop = nfsd4_status_stateid_rsize,
@@ -2200,56 +2218,56 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_set_currentstateid = nfsd4_set_opendowngradestateid,
 	},
 	[OP_PUTFH] = {
-		.op_func = (nfsd4op_func)nfsd4_putfh,
+		.op_func = nfsd4_putfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
 		.op_name = "OP_PUTFH",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_PUTPUBFH] = {
-		.op_func = (nfsd4op_func)nfsd4_putrootfh,
+		.op_func = nfsd4_putrootfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
 		.op_name = "OP_PUTPUBFH",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_PUTROOTFH] = {
-		.op_func = (nfsd4op_func)nfsd4_putrootfh,
+		.op_func = nfsd4_putrootfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
 		.op_name = "OP_PUTROOTFH",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_READ] = {
-		.op_func = (nfsd4op_func)nfsd4_read,
+		.op_func = nfsd4_read,
 		.op_name = "OP_READ",
 		.op_rsize_bop = nfsd4_read_rsize,
 		.op_get_currentstateid = nfsd4_get_readstateid,
 	},
 	[OP_READDIR] = {
-		.op_func = (nfsd4op_func)nfsd4_readdir,
+		.op_func = nfsd4_readdir,
 		.op_name = "OP_READDIR",
 		.op_rsize_bop = nfsd4_readdir_rsize,
 	},
 	[OP_READLINK] = {
-		.op_func = (nfsd4op_func)nfsd4_readlink,
+		.op_func = nfsd4_readlink,
 		.op_name = "OP_READLINK",
 		.op_rsize_bop = nfsd4_readlink_rsize,
 	},
 	[OP_REMOVE] = {
-		.op_func = (nfsd4op_func)nfsd4_remove,
+		.op_func = nfsd4_remove,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_REMOVE",
 		.op_rsize_bop = nfsd4_remove_rsize,
 	},
 	[OP_RENAME] = {
-		.op_func = (nfsd4op_func)nfsd4_rename,
+		.op_func = nfsd4_rename,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_RENAME",
 		.op_rsize_bop = nfsd4_rename_rsize,
 	},
 	[OP_RENEW] = {
-		.op_func = (nfsd4op_func)nfsd4_renew,
+		.op_func = nfsd4_renew,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_RENEW",
@@ -2257,59 +2275,59 @@ static struct nfsd4_operation nfsd4_ops[] = {
 
 	},
 	[OP_RESTOREFH] = {
-		.op_func = (nfsd4op_func)nfsd4_restorefh,
+		.op_func = nfsd4_restorefh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_RESTOREFH",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_SAVEFH] = {
-		.op_func = (nfsd4op_func)nfsd4_savefh,
+		.op_func = nfsd4_savefh,
 		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_SAVEFH",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_SECINFO] = {
-		.op_func = (nfsd4op_func)nfsd4_secinfo,
+		.op_func = nfsd4_secinfo,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO",
 		.op_rsize_bop = nfsd4_secinfo_rsize,
 	},
 	[OP_SETATTR] = {
-		.op_func = (nfsd4op_func)nfsd4_setattr,
+		.op_func = nfsd4_setattr,
 		.op_name = "OP_SETATTR",
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_rsize_bop = nfsd4_setattr_rsize,
 		.op_get_currentstateid = nfsd4_get_setattrstateid,
 	},
 	[OP_SETCLIENTID] = {
-		.op_func = (nfsd4op_func)nfsd4_setclientid,
+		.op_func = nfsd4_setclientid,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_SETCLIENTID",
 		.op_rsize_bop = nfsd4_setclientid_rsize,
 	},
 	[OP_SETCLIENTID_CONFIRM] = {
-		.op_func = (nfsd4op_func)nfsd4_setclientid_confirm,
+		.op_func = nfsd4_setclientid_confirm,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_SETCLIENTID_CONFIRM",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_VERIFY] = {
-		.op_func = (nfsd4op_func)nfsd4_verify,
+		.op_func = nfsd4_verify,
 		.op_name = "OP_VERIFY",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_WRITE] = {
-		.op_func = (nfsd4op_func)nfsd4_write,
+		.op_func = nfsd4_write,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_WRITE",
 		.op_rsize_bop = nfsd4_write_rsize,
 		.op_get_currentstateid = nfsd4_get_writestateid,
 	},
 	[OP_RELEASE_LOCKOWNER] = {
-		.op_func = (nfsd4op_func)nfsd4_release_lockowner,
+		.op_func = nfsd4_release_lockowner,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_RELEASE_LOCKOWNER",
@@ -2318,72 +2336,72 @@ static struct nfsd4_operation nfsd4_ops[] = {
 
 	/* NFSv4.1 operations */
 	[OP_EXCHANGE_ID] = {
-		.op_func = (nfsd4op_func)nfsd4_exchange_id,
+		.op_func = nfsd4_exchange_id,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_EXCHANGE_ID",
 		.op_rsize_bop = nfsd4_exchange_id_rsize,
 	},
 	[OP_BACKCHANNEL_CTL] = {
-		.op_func = (nfsd4op_func)nfsd4_backchannel_ctl,
+		.op_func = nfsd4_backchannel_ctl,
 		.op_flags = ALLOWED_WITHOUT_FH | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_BACKCHANNEL_CTL",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_BIND_CONN_TO_SESSION] = {
-		.op_func = (nfsd4op_func)nfsd4_bind_conn_to_session,
+		.op_func = nfsd4_bind_conn_to_session,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_BIND_CONN_TO_SESSION",
 		.op_rsize_bop = nfsd4_bind_conn_to_session_rsize,
 	},
 	[OP_CREATE_SESSION] = {
-		.op_func = (nfsd4op_func)nfsd4_create_session,
+		.op_func = nfsd4_create_session,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_CREATE_SESSION",
 		.op_rsize_bop = nfsd4_create_session_rsize,
 	},
 	[OP_DESTROY_SESSION] = {
-		.op_func = (nfsd4op_func)nfsd4_destroy_session,
+		.op_func = nfsd4_destroy_session,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_DESTROY_SESSION",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_SEQUENCE] = {
-		.op_func = (nfsd4op_func)nfsd4_sequence,
+		.op_func = nfsd4_sequence,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_SEQUENCE",
 		.op_rsize_bop = nfsd4_sequence_rsize,
 	},
 	[OP_DESTROY_CLIENTID] = {
-		.op_func = (nfsd4op_func)nfsd4_destroy_clientid,
+		.op_func = nfsd4_destroy_clientid,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
 				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_DESTROY_CLIENTID",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_RECLAIM_COMPLETE] = {
-		.op_func = (nfsd4op_func)nfsd4_reclaim_complete,
+		.op_func = nfsd4_reclaim_complete,
 		.op_flags = ALLOWED_WITHOUT_FH | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_RECLAIM_COMPLETE",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_SECINFO_NO_NAME] = {
-		.op_func = (nfsd4op_func)nfsd4_secinfo_no_name,
+		.op_func = nfsd4_secinfo_no_name,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO_NO_NAME",
 		.op_rsize_bop = nfsd4_secinfo_rsize,
 	},
 	[OP_TEST_STATEID] = {
-		.op_func = (nfsd4op_func)nfsd4_test_stateid,
+		.op_func = nfsd4_test_stateid,
 		.op_flags = ALLOWED_WITHOUT_FH,
 		.op_name = "OP_TEST_STATEID",
 		.op_rsize_bop = nfsd4_test_stateid_rsize,
 	},
 	[OP_FREE_STATEID] = {
-		.op_func = (nfsd4op_func)nfsd4_free_stateid,
+		.op_func = nfsd4_free_stateid,
 		.op_flags = ALLOWED_WITHOUT_FH | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_FREE_STATEID",
 		.op_get_currentstateid = nfsd4_get_freestateid,
@@ -2391,25 +2409,25 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 #ifdef CONFIG_NFSD_PNFS
 	[OP_GETDEVICEINFO] = {
-		.op_func = (nfsd4op_func)nfsd4_getdeviceinfo,
+		.op_func = nfsd4_getdeviceinfo,
 		.op_flags = ALLOWED_WITHOUT_FH,
 		.op_name = "OP_GETDEVICEINFO",
 		.op_rsize_bop = nfsd4_getdeviceinfo_rsize,
 	},
 	[OP_LAYOUTGET] = {
-		.op_func = (nfsd4op_func)nfsd4_layoutget,
+		.op_func = nfsd4_layoutget,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LAYOUTGET",
 		.op_rsize_bop = nfsd4_layoutget_rsize,
 	},
 	[OP_LAYOUTCOMMIT] = {
-		.op_func = (nfsd4op_func)nfsd4_layoutcommit,
+		.op_func = nfsd4_layoutcommit,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LAYOUTCOMMIT",
 		.op_rsize_bop = nfsd4_layoutcommit_rsize,
 	},
 	[OP_LAYOUTRETURN] = {
-		.op_func = (nfsd4op_func)nfsd4_layoutreturn,
+		.op_func = nfsd4_layoutreturn,
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LAYOUTRETURN",
 		.op_rsize_bop = nfsd4_layoutreturn_rsize,
@@ -2418,31 +2436,31 @@ static struct nfsd4_operation nfsd4_ops[] = {
 
 	/* NFSv4.2 operations */
 	[OP_ALLOCATE] = {
-		.op_func = (nfsd4op_func)nfsd4_allocate,
+		.op_func = nfsd4_allocate,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_ALLOCATE",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_DEALLOCATE] = {
-		.op_func = (nfsd4op_func)nfsd4_deallocate,
+		.op_func = nfsd4_deallocate,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_DEALLOCATE",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_CLONE] = {
-		.op_func = (nfsd4op_func)nfsd4_clone,
+		.op_func = nfsd4_clone,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_CLONE",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_COPY] = {
-		.op_func = (nfsd4op_func)nfsd4_copy,
+		.op_func = nfsd4_copy,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_COPY",
 		.op_rsize_bop = nfsd4_copy_rsize,
 	},
 	[OP_SEEK] = {
-		.op_func = (nfsd4op_func)nfsd4_seek,
+		.op_func = nfsd4_seek,
 		.op_name = "OP_SEEK",
 		.op_rsize_bop = nfsd4_seek_rsize,
 	},
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 01ab21f8d34d..0c04f81aa63b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2402,10 +2402,10 @@ static bool client_has_state(struct nfs4_client *clp)
 }
 
 __be32
-nfsd4_exchange_id(struct svc_rqst *rqstp,
-		  struct nfsd4_compound_state *cstate,
-		  struct nfsd4_exchange_id *exid)
+nfsd4_exchange_id(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
+	struct nfsd4_exchange_id *exid = &u->exchange_id;
 	struct nfs4_client *conf, *new;
 	struct nfs4_client *unconf = NULL;
 	__be32 status;
@@ -2698,9 +2698,9 @@ static __be32 nfsd4_check_cb_sec(struct nfsd4_cb_sec *cbs)
 
 __be32
 nfsd4_create_session(struct svc_rqst *rqstp,
-		     struct nfsd4_compound_state *cstate,
-		     struct nfsd4_create_session *cr_ses)
+		struct nfsd4_compound_state *cstate, union nfsd4_op_u *u)
 {
+	struct nfsd4_create_session *cr_ses = &u->create_session;
 	struct sockaddr *sa = svc_addr(rqstp);
 	struct nfs4_client *conf, *unconf;
 	struct nfs4_client *old = NULL;
@@ -2824,8 +2824,11 @@ static __be32 nfsd4_map_bcts_dir(u32 *dir)
 	return nfserr_inval;
 }
 
-__be32 nfsd4_backchannel_ctl(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_backchannel_ctl *bc)
+__be32 nfsd4_backchannel_ctl(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
+	struct nfsd4_backchannel_ctl *bc = &u->backchannel_ctl;
 	struct nfsd4_session *session = cstate->session;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 	__be32 status;
@@ -2845,8 +2848,9 @@ __be32 nfsd4_backchannel_ctl(struct svc_rqst *rqstp, struct nfsd4_compound_state
 
 __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
-		     struct nfsd4_bind_conn_to_session *bcts)
+		     union nfsd4_op_u *u)
 {
+	struct nfsd4_bind_conn_to_session *bcts = &u->bind_conn_to_session;
 	__be32 status;
 	struct nfsd4_conn *conn;
 	struct nfsd4_session *session;
@@ -2886,10 +2890,10 @@ static bool nfsd4_compound_in_session(struct nfsd4_session *session, struct nfs4
 }
 
 __be32
-nfsd4_destroy_session(struct svc_rqst *r,
-		      struct nfsd4_compound_state *cstate,
-		      struct nfsd4_destroy_session *sessionid)
+nfsd4_destroy_session(struct svc_rqst *r, struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
+	struct nfsd4_destroy_session *sessionid = &u->destroy_session;
 	struct nfsd4_session *ses;
 	__be32 status;
 	int ref_held_by_me = 0;
@@ -2983,10 +2987,10 @@ static bool nfsd4_request_too_big(struct svc_rqst *rqstp,
 }
 
 __be32
-nfsd4_sequence(struct svc_rqst *rqstp,
-	       struct nfsd4_compound_state *cstate,
-	       struct nfsd4_sequence *seq)
+nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
+	struct nfsd4_sequence *seq = &u->sequence;
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct xdr_stream *xdr = &resp->xdr;
 	struct nfsd4_session *session;
@@ -3120,8 +3124,11 @@ nfsd4_sequence_done(struct nfsd4_compoundres *resp)
 }
 
 __be32
-nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_destroy_clientid *dc)
+nfsd4_destroy_clientid(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
+	struct nfsd4_destroy_clientid *dc = &u->destroy_clientid;
 	struct nfs4_client *conf, *unconf;
 	struct nfs4_client *clp = NULL;
 	__be32 status = 0;
@@ -3161,8 +3168,10 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 }
 
 __be32
-nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_reclaim_complete *rc)
+nfsd4_reclaim_complete(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *cstate, union nfsd4_op_u *u)
 {
+	struct nfsd4_reclaim_complete *rc = &u->reclaim_complete;
 	__be32 status = 0;
 
 	if (rc->rca_one_fs) {
@@ -3199,8 +3208,9 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 
 __be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		  struct nfsd4_setclientid *setclid)
+		  union nfsd4_op_u *u)
 {
+	struct nfsd4_setclientid *setclid = &u->setclientid;
 	struct xdr_netobj 	clname = setclid->se_name;
 	nfs4_verifier		clverifier = setclid->se_verf;
 	struct nfs4_client	*conf, *new;
@@ -3257,9 +3267,11 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 __be32
 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
-			 struct nfsd4_compound_state *cstate,
-			 struct nfsd4_setclientid_confirm *setclientid_confirm)
+			struct nfsd4_compound_state *cstate,
+			union nfsd4_op_u *u)
 {
+	struct nfsd4_setclientid_confirm *setclientid_confirm =
+			&u->setclientid_confirm;
 	struct nfs4_client *conf, *unconf;
 	struct nfs4_client *old = NULL;
 	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
@@ -4506,8 +4518,9 @@ void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
 
 __be32
 nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	    clientid_t *clid)
+	    union nfsd4_op_u *u)
 {
+	clientid_t *clid = &u->renew;
 	struct nfs4_client *clp;
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
@@ -4993,8 +5006,9 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
  */
 __be32
 nfsd4_test_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		   struct nfsd4_test_stateid *test_stateid)
+		   union nfsd4_op_u *u)
 {
+	struct nfsd4_test_stateid *test_stateid = &u->test_stateid;
 	struct nfsd4_test_stateid_id *stateid;
 	struct nfs4_client *cl = cstate->session->se_client;
 
@@ -5033,8 +5047,9 @@ nfsd4_free_lock_stateid(stateid_t *stateid, struct nfs4_stid *s)
 
 __be32
 nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		   struct nfsd4_free_stateid *free_stateid)
+		   union nfsd4_op_u *u)
 {
+	struct nfsd4_free_stateid *free_stateid = &u->free_stateid;
 	stateid_t *stateid = &free_stateid->fr_stateid;
 	struct nfs4_stid *s;
 	struct nfs4_delegation *dp;
@@ -5162,8 +5177,9 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
 
 __be32
 nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		   struct nfsd4_open_confirm *oc)
+		   union nfsd4_op_u *u)
 {
+	struct nfsd4_open_confirm *oc = &u->open_confirm;
 	__be32 status;
 	struct nfs4_openowner *oo;
 	struct nfs4_ol_stateid *stp;
@@ -5230,9 +5246,9 @@ static inline void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_ac
 
 __be32
 nfsd4_open_downgrade(struct svc_rqst *rqstp,
-		     struct nfsd4_compound_state *cstate,
-		     struct nfsd4_open_downgrade *od)
+		     struct nfsd4_compound_state *cstate, union nfsd4_op_u *u)
 {
+	struct nfsd4_open_downgrade *od = &u->open_downgrade;
 	__be32 status;
 	struct nfs4_ol_stateid *stp;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
@@ -5300,8 +5316,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
  */
 __be32
 nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	    struct nfsd4_close *close)
+		union nfsd4_op_u *u)
 {
+	struct nfsd4_close *close = &u->close;
 	__be32 status;
 	struct nfs4_ol_stateid *stp;
 	struct net *net = SVC_NET(rqstp);
@@ -5330,8 +5347,9 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 __be32
 nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		  struct nfsd4_delegreturn *dr)
+		  union nfsd4_op_u *u)
 {
+	struct nfsd4_delegreturn *dr = &u->delegreturn;
 	struct nfs4_delegation *dp;
 	stateid_t *stateid = &dr->dr_stateid;
 	struct nfs4_stid *s;
@@ -5706,8 +5724,9 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
  */
 __be32
 nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	   struct nfsd4_lock *lock)
+	   union nfsd4_op_u *u)
 {
+	struct nfsd4_lock *lock = &u->lock;
 	struct nfs4_openowner *open_sop = NULL;
 	struct nfs4_lockowner *lock_sop = NULL;
 	struct nfs4_ol_stateid *lock_stp = NULL;
@@ -5939,8 +5958,9 @@ static __be32 nfsd_test_lock(struct svc_rqst *rqstp, struct svc_fh *fhp, struct
  */
 __be32
 nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	    struct nfsd4_lockt *lockt)
+	    union nfsd4_op_u *u)
 {
+	struct nfsd4_lockt *lockt = &u->lockt;
 	struct file_lock *file_lock = NULL;
 	struct nfs4_lockowner *lo = NULL;
 	__be32 status;
@@ -6012,8 +6032,9 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 __be32
 nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	    struct nfsd4_locku *locku)
+	    union nfsd4_op_u *u)
 {
+	struct nfsd4_locku *locku = &u->locku;
 	struct nfs4_ol_stateid *stp;
 	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
@@ -6119,8 +6140,9 @@ check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner)
 __be32
 nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			struct nfsd4_compound_state *cstate,
-			struct nfsd4_release_lockowner *rlockowner)
+			union nfsd4_op_u *u)
 {
+	struct nfsd4_release_lockowner *rlockowner = &u->release_lockowner;
 	clientid_t *clid = &rlockowner->rl_clientid;
 	struct nfs4_stateowner *sop;
 	struct nfs4_lockowner *lo = NULL;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index b625f4aa1061..72c6ad136107 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -577,6 +577,7 @@ struct nfsd4_op {
 		struct nfsd4_bind_conn_to_session bind_conn_to_session;
 		struct nfsd4_create_session	create_session;
 		struct nfsd4_destroy_session	destroy_session;
+		struct nfsd4_destroy_clientid	destroy_clientid;
 		struct nfsd4_sequence		sequence;
 		struct nfsd4_reclaim_complete	reclaim_complete;
 		struct nfsd4_test_stateid	test_stateid;
@@ -585,6 +586,7 @@ struct nfsd4_op {
 		struct nfsd4_layoutget		layoutget;
 		struct nfsd4_layoutcommit	layoutcommit;
 		struct nfsd4_layoutreturn	layoutreturn;
+		struct nfsd4_secinfo_no_name	secinfo_no_name;
 
 		/* NFSv4.2 */
 		struct nfsd4_fallocate		allocate;
@@ -693,27 +695,26 @@ __be32 nfsd4_encode_fattr_to_buf(__be32 **p, int words,
 		struct dentry *dentry,
 		u32 *bmval, struct svc_rqst *, int ignore_crossmnt);
 extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *,
-		struct nfsd4_setclientid *setclid);
+		struct nfsd4_compound_state *, union nfsd4_op_u *u);
 extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *,
-		struct nfsd4_setclientid_confirm *setclientid_confirm);
+		struct nfsd4_compound_state *, union nfsd4_op_u *u);
 extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *, struct nfsd4_exchange_id *);
-extern __be32 nfsd4_backchannel_ctl(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_backchannel_ctl *);
-extern __be32 nfsd4_bind_conn_to_session(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_bind_conn_to_session *);
+		struct nfsd4_compound_state *, union nfsd4_op_u *u);
+extern __be32 nfsd4_backchannel_ctl(struct svc_rqst *,
+		struct nfsd4_compound_state *, union nfsd4_op_u *u);
+extern __be32 nfsd4_bind_conn_to_session(struct svc_rqst *,
+		struct nfsd4_compound_state *, union nfsd4_op_u *u);
 extern __be32 nfsd4_create_session(struct svc_rqst *,
-		struct nfsd4_compound_state *,
-		struct nfsd4_create_session *);
+		struct nfsd4_compound_state *, union nfsd4_op_u *u);
 extern __be32 nfsd4_sequence(struct svc_rqst *,
-		struct nfsd4_compound_state *,
-		struct nfsd4_sequence *);
+		struct nfsd4_compound_state *, union nfsd4_op_u *u);
 extern void nfsd4_sequence_done(struct nfsd4_compoundres *resp);
 extern __be32 nfsd4_destroy_session(struct svc_rqst *,
-		struct nfsd4_compound_state *,
-		struct nfsd4_destroy_session *);
-extern __be32 nfsd4_destroy_clientid(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_destroy_clientid *);
-__be32 nfsd4_reclaim_complete(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_reclaim_complete *);
+		struct nfsd4_compound_state *, union nfsd4_op_u *u);
+extern __be32 nfsd4_destroy_clientid(struct svc_rqst *, struct nfsd4_compound_state *,
+		union nfsd4_op_u *u);
+__be32 nfsd4_reclaim_complete(struct svc_rqst *, struct nfsd4_compound_state *,
+		union nfsd4_op_u *u);
 extern __be32 nfsd4_process_open1(struct nfsd4_compound_state *,
 		struct nfsd4_open *open, struct nfsd_net *nn);
 extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
@@ -722,34 +723,29 @@ extern void nfsd4_cstate_clear_replay(struct nfsd4_compound_state *cstate);
 extern void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
 		struct nfsd4_open *open);
 extern __be32 nfsd4_open_confirm(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *, struct nfsd4_open_confirm *oc);
-extern __be32 nfsd4_close(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *,
-		struct nfsd4_close *close);
+		struct nfsd4_compound_state *, union nfsd4_op_u *u);
+extern __be32 nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *,
+		union nfsd4_op_u *u);
 extern __be32 nfsd4_open_downgrade(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *,
-		struct nfsd4_open_downgrade *od);
+		struct nfsd4_compound_state *, union nfsd4_op_u *u);
 extern __be32 nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *,
-		struct nfsd4_lock *lock);
-extern __be32 nfsd4_lockt(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *,
-		struct nfsd4_lockt *lockt);
-extern __be32 nfsd4_locku(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *,
-		struct nfsd4_locku *locku);
+		union nfsd4_op_u *u);
+extern __be32 nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *,
+		union nfsd4_op_u *u);
+extern __be32 nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *,
+		union nfsd4_op_u *u);
 extern __be32
 nfsd4_release_lockowner(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *,
-		struct nfsd4_release_lockowner *rlockowner);
+		struct nfsd4_compound_state *, union nfsd4_op_u *u);
 extern void nfsd4_release_compoundargs(struct svc_rqst *rqstp);
 extern __be32 nfsd4_delegreturn(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *, struct nfsd4_delegreturn *dr);
-extern __be32 nfsd4_renew(struct svc_rqst *rqstp,
-			  struct nfsd4_compound_state *, clientid_t *clid);
+		struct nfsd4_compound_state *, union nfsd4_op_u *u);
+extern __be32 nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *,
+		union nfsd4_op_u *u);
 extern __be32 nfsd4_test_stateid(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *, struct nfsd4_test_stateid *test_stateid);
+		struct nfsd4_compound_state *, union nfsd4_op_u *);
 extern __be32 nfsd4_free_stateid(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *, struct nfsd4_free_stateid *free_stateid);
+		struct nfsd4_compound_state *, union nfsd4_op_u *);
 extern void nfsd4_bump_seqid(struct nfsd4_compound_state *, __be32 nfserr);
 
 #endif
-- 
2.11.0

