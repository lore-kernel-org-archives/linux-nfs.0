Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from messager.iut-bm.univ-fcomte.fr ([194.57.86.195]:39203 "EHLO
	messager.iut-bm.univ-fcomte.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755861Ab0GEN3C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jul 2010 09:29:02 -0400
From: Arnaud Giersch <arnaud.giersch@iut-bm.univ-fcomte.fr>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH/RFC 2.6.35-rc4] NFSv4: Don't do idmapper upcalls during XDR decode
References: <wwezkyas466.fsf@powwow.iut-bm.univ-fcomte.fr>
	<1278075804.3258.20.camel@heimdal.trondhjem.org>
Date: Mon, 05 Jul 2010 15:28:53 +0200
In-Reply-To: <1278075804.3258.20.camel@heimdal.trondhjem.org> (Trond
	Myklebust's message of "Fri, 02 Jul 2010 09:03:24 -0400")
Message-ID: <wwed3v2rrai.fsf_-_@powwow.iut-bm.univ-fcomte.fr>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Arnaud Giersch <arnaud.giersch@free.fr>

Move the name to id mapping out of the XDR decode functions.

Add two new fields to struct nfs_fattr: user_name and group_name, that
are defined iff a name to id mapping should be done.
A new function, nfs_fattr_name_to_id(), is defined to call the
idmapper if needed.

This also fixes the empty core dumps that may be produced since commit
80e52aced138bb41b045a8595a87510f27d8d8c5.

Signed-off-by: Arnaud Giersch <arnaud.giersch@free.fr>

---
Trond, did you think about something like this when you wrote "saving
the owner/group strings and doing the upcall after the XDR is done"?

I tagged the patch RFC mainly because I am not sure of the following:
* if the kmalloc() call if OK inside decode_attr_owner() and
  decode_attr_group();
* the calls to nfs_fattr_name_to_id() are done at the proper places.

Regards,
        Arnaud

 fs/nfs/inode.c          |   35 ++++++++++++
 fs/nfs/nfs4xdr.c        |  109 ++++++++++++++-----------------------
 include/linux/nfs_fs.h  |    2 +
 include/linux/nfs_xdr.h |    7 +++
 4 files changed, 86 insertions(+), 67 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 099b351..6df59ad 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -227,6 +227,35 @@ nfs_init_locked(struct inode *inode, void *opaque)
 	return 0;
 }
 
+static void
+nfs_fattr_name_to_id(struct nfs_client *clp, struct nfs_fattr *fattr)
+{
+	if (fattr->user_name) {
+		struct nfs_name *name = fattr->user_name;
+		if (nfs_map_name_to_uid(clp, name->buf, name->len,
+					&fattr->uid) == 0)
+			fattr->valid |= NFS_ATTR_FATTR_OWNER;
+		else
+			dprintk("%s: nfs_map_name_to_uid failed!\n",
+				__func__);
+		kfree(fattr->user_name);
+		fattr->user_name = NULL;
+		dprintk("%s: uid=%d\n", __func__, (int)fattr->uid);
+	}
+	if (fattr->group_name) {
+		struct nfs_name *name = fattr->group_name;
+		if (nfs_map_group_to_gid(clp, name->buf, name->len,
+					 &fattr->gid) == 0)
+			fattr->valid |= NFS_ATTR_FATTR_GROUP;
+		else
+			dprintk("%s: nfs_map_group_to_gid failed!\n",
+				__func__);
+		kfree(fattr->group_name);
+		fattr->group_name = NULL;
+		dprintk("%s: gid=%d\n", __func__, (int)fattr->gid);
+	}
+}
+
 /* Don't use READDIRPLUS on directories that we believe are too large */
 #define NFS_LIMIT_READDIRPLUS (8*PAGE_SIZE)
 
@@ -256,6 +285,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		inode = ERR_PTR(-ENOMEM);
 		goto out_no_inode;
 	}
+	nfs_fattr_name_to_id(NFS_SERVER(inode)->nfs_client, fattr);
 
 	if (inode->i_state & I_NEW) {
 		struct nfs_inode *nfsi = NFS_I(inode);
@@ -930,6 +960,8 @@ unsigned long nfs_inc_attr_generation_counter(void)
 void nfs_fattr_init(struct nfs_fattr *fattr)
 {
 	fattr->valid = 0;
+	fattr->user_name = NULL;
+	fattr->group_name = NULL;
 	fattr->time_start = jiffies;
 	fattr->gencount = nfs_inc_attr_generation_counter();
 }
@@ -1004,6 +1036,7 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
 	int status;
 
+	nfs_fattr_name_to_id(NFS_SERVER(inode)->nfs_client, fattr);
 	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
 		return 0;
 	spin_lock(&inode->i_lock);
@@ -1043,6 +1076,7 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
 	int status;
 
+	nfs_fattr_name_to_id(NFS_SERVER(inode)->nfs_client, fattr);
 	spin_lock(&inode->i_lock);
 	status = nfs_post_op_update_inode_locked(inode, fattr);
 	spin_unlock(&inode->i_lock);
@@ -1064,6 +1098,7 @@ int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fa
 {
 	int status;
 
+	nfs_fattr_name_to_id(NFS_SERVER(inode)->nfs_client, fattr);
 	spin_lock(&inode->i_lock);
 	/* Don't do a WCC update if these attributes are already stale */
 	if ((fattr->valid & NFS_ATTR_FATTR) == 0 ||
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 65c8dae..b4c2735 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3227,13 +3227,13 @@ out_overflow:
 }
 
 static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
-		struct nfs_client *clp, uint32_t *uid, int may_sleep)
+			     struct nfs_client *clp, struct nfs_name **owner)
 {
 	uint32_t len;
 	__be32 *p;
 	int ret = 0;
 
-	*uid = -2;
+	BUG_ON(*owner);
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER)) {
@@ -3244,20 +3244,18 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
 			goto out_overflow;
-		if (!may_sleep) {
-			/* do nothing */
-		} else if (len < XDR_MAX_NETOBJ) {
-			if (nfs_map_name_to_uid(clp, (char *)p, len, uid) == 0)
-				ret = NFS_ATTR_FATTR_OWNER;
-			else
-				dprintk("%s: nfs_map_name_to_uid failed!\n",
-						__func__);
+		if (len < XDR_MAX_NETOBJ) {
+			*owner = kmalloc((sizeof **owner) + len, GFP_NOFS);
+			if (*owner) {
+				(*owner)->len = len;
+				memcpy((*owner)->buf, p, len);
+			} else
+				dprintk("%s: kmalloc failed!\n", __func__);
 		} else
 			dprintk("%s: name too long (%u)!\n",
 					__func__, len);
 		bitmap[1] &= ~FATTR4_WORD1_OWNER;
 	}
-	dprintk("%s: uid=%d\n", __func__, (int)*uid);
 	return ret;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -3265,13 +3263,13 @@ out_overflow:
 }
 
 static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
-		struct nfs_client *clp, uint32_t *gid, int may_sleep)
+			     struct nfs_client *clp, struct nfs_name **group)
 {
 	uint32_t len;
 	__be32 *p;
 	int ret = 0;
 
-	*gid = -2;
+	BUG_ON(*group);
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER_GROUP - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER_GROUP)) {
@@ -3282,20 +3280,18 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
 			goto out_overflow;
-		if (!may_sleep) {
-			/* do nothing */
-		} else if (len < XDR_MAX_NETOBJ) {
-			if (nfs_map_group_to_gid(clp, (char *)p, len, gid) == 0)
-				ret = NFS_ATTR_FATTR_GROUP;
-			else
-				dprintk("%s: nfs_map_group_to_gid failed!\n",
-						__func__);
+		if (len < XDR_MAX_NETOBJ) {
+			*group = kmalloc((sizeof **group) + len, GFP_NOFS);
+			if (*group) {
+				(*group)->len = len;
+				memcpy((*group)->buf, p, len);
+			} else
+				dprintk("%s: kmalloc failed!\n", __func__);
 		} else
 			dprintk("%s: name too long (%u)!\n",
 					__func__, len);
 		bitmap[1] &= ~FATTR4_WORD1_OWNER_GROUP;
 	}
-	dprintk("%s: gid=%d\n", __func__, (int)*gid);
 	return ret;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -3701,7 +3697,7 @@ xdr_error:
 }
 
 static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
-		const struct nfs_server *server, int may_sleep)
+			   const struct nfs_server *server)
 {
 	__be32 *savep;
 	uint32_t attrlen,
@@ -3774,13 +3770,13 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
 	fattr->valid |= status;
 
 	status = decode_attr_owner(xdr, bitmap, server->nfs_client,
-			&fattr->uid, may_sleep);
+				   &fattr->user_name);
 	if (status < 0)
 		goto xdr_error;
 	fattr->valid |= status;
 
 	status = decode_attr_group(xdr, bitmap, server->nfs_client,
-			&fattr->gid, may_sleep);
+				   &fattr->group_name);
 	if (status < 0)
 		goto xdr_error;
 	fattr->valid |= status;
@@ -4708,8 +4704,7 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct
 	status = decode_open_downgrade(&xdr, res);
 	if (status != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -4736,8 +4731,7 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_ac
 	status = decode_access(&xdr, res);
 	if (status != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -4764,8 +4758,7 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lo
 		goto out;
 	if ((status = decode_getfh(&xdr, res->fh)) != 0)
 		goto out;
-	status = decode_getfattr(&xdr, res->fattr, res->server
-			,!RPC_IS_ASYNC(rqstp->rq_task));
+	status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -4789,8 +4782,7 @@ static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	if ((status = decode_putrootfh(&xdr)) != 0)
 		goto out;
 	if ((status = decode_getfh(&xdr, res->fh)) == 0)
-		status = decode_getfattr(&xdr, res->fattr, res->server,
-				!RPC_IS_ASYNC(rqstp->rq_task));
+		status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -4815,8 +4807,7 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_rem
 		goto out;
 	if ((status = decode_remove(&xdr, &res->cinfo)) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->dir_attr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->dir_attr, res->server);
 out:
 	return status;
 }
@@ -4846,13 +4837,11 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_re
 	if ((status = decode_rename(&xdr, &res->old_cinfo, &res->new_cinfo)) != 0)
 		goto out;
 	/* Current FH is target directory */
-	if (decode_getfattr(&xdr, res->new_fattr, res->server,
-				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
+	if (decode_getfattr(&xdr, res->new_fattr, res->server) != 0)
 		goto out;
 	if ((status = decode_restorefh(&xdr)) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->old_fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->old_fattr, res->server);
 out:
 	return status;
 }
@@ -4885,13 +4874,11 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_link
 	 * Note order: OP_LINK leaves the directory as the current
 	 *             filehandle.
 	 */
-	if (decode_getfattr(&xdr, res->dir_attr, res->server,
-				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
+	if (decode_getfattr(&xdr, res->dir_attr, res->server) != 0)
 		goto out;
 	if ((status = decode_restorefh(&xdr)) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -4920,13 +4907,11 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_cr
 		goto out;
 	if ((status = decode_getfh(&xdr, res->fh)) != 0)
 		goto out;
-	if (decode_getfattr(&xdr, res->fattr, res->server,
-				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
+	if (decode_getfattr(&xdr, res->fattr, res->server) != 0)
 		goto out;
 	if ((status = decode_restorefh(&xdr)) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->dir_fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->dir_fattr, res->server);
 out:
 	return status;
 }
@@ -4958,8 +4943,7 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_g
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	status = decode_getfattr(&xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -5066,8 +5050,7 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	 * 	an ESTALE error. Shouldn't be a problem,
 	 * 	though, since fattr->valid will remain unset.
 	 */
-	decode_getfattr(&xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -5099,13 +5082,11 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openr
 		goto out;
 	if (decode_getfh(&xdr, &res->fh) != 0)
 		goto out;
-	if (decode_getfattr(&xdr, res->f_attr, res->server,
-				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
+	if (decode_getfattr(&xdr, res->f_attr, res->server) != 0)
 		goto out;
 	if (decode_restorefh(&xdr) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->dir_attr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->dir_attr, res->server);
 out:
 	return status;
 }
@@ -5153,8 +5134,7 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	status = decode_open(&xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->f_attr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->f_attr, res->server);
 out:
 	return status;
 }
@@ -5181,8 +5161,7 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_se
 	status = decode_setattr(&xdr);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -5356,8 +5335,7 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writ
 	status = decode_write(&xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->fattr, res->server);
 	if (!status)
 		status = res->count;
 out:
@@ -5386,8 +5364,7 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, __be32 *p, struct nfs_wri
 	status = decode_commit(&xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -5553,8 +5530,7 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	status = decode_delegreturn(&xdr);
 	if (status != 0)
 		goto out;
-	decode_getfattr(&xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -5582,8 +5558,7 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p,
 		goto out;
 	xdr_enter_page(&xdr, PAGE_SIZE);
 	status = decode_getfattr(&xdr, &res->fs_locations->fattr,
-				 res->fs_locations->server,
-				 !RPC_IS_ASYNC(req->rq_task));
+				 res->fs_locations->server);
 out:
 	return status;
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 77c2ae5..fd4cea0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -360,6 +360,8 @@ extern struct nfs_fattr *nfs_alloc_fattr(void);
 
 static inline void nfs_free_fattr(const struct nfs_fattr *fattr)
 {
+	kfree(fattr->user_name);
+	kfree(fattr->group_name);
 	kfree(fattr);
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 51914d7..074c3db 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -27,10 +27,17 @@ static inline int nfs_fsid_equal(const struct nfs_fsid *a, const struct nfs_fsid
 	return a->major == b->major && a->minor == b->minor;
 }
 
+struct nfs_name {
+	size_t len;
+	char buf[];
+};
+
 struct nfs_fattr {
 	unsigned int		valid;		/* which fields are valid */
 	umode_t			mode;
 	__u32			nlink;
+	struct nfs_name *	user_name;
+	struct nfs_name *	group_name;
 	__u32			uid;
 	__u32			gid;
 	dev_t			rdev;
