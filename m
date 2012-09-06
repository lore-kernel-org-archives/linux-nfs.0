Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23903 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756667Ab2IFTye (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 15:54:34 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/2] NFSv4: Add ACCESS operation to OPEN compound
Date: Thu,  6 Sep 2012 15:54:28 -0400
Message-Id: <1346961268-15864-2-git-send-email-dros@netapp.com>
In-Reply-To: <1346961268-15864-1-git-send-email-dros@netapp.com>
References: <1346961268-15864-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The OPEN operation has no way to differentiate an open for read and an
open for execution - both look like read to the server. This allowed
users to read files that didn't have READ access but did have EXEC access,
which is obviously wrong.

This patch adds an ACCESS call to the OPEN compound to handle the
difference between OPENs for reading and execution.  Since we're going
through the trouble of calling ACCESS, we check all possible access bits
and cache the results hopefully avoiding an ACCESS call in the future.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/dir.c            |    3 ++-
 fs/nfs/nfs4proc.c       |   51 ++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c        |    8 ++++++++
 include/linux/nfs_fs.h  |    1 +
 include/linux/nfs_xdr.h |   18 +++++++++--------
 5 files changed, 71 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 627f108..92ae147 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2072,7 +2072,7 @@ found:
 	nfs_access_free_entry(entry);
 }
 
-static void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *set)
+void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *set)
 {
 	struct nfs_access_entry *cache = kmalloc(sizeof(*cache), GFP_KERNEL);
 	if (cache == NULL)
@@ -2098,6 +2098,7 @@ static void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *s
 		spin_unlock(&nfs_access_lru_lock);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_access_add_cache);
 
 static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6352741..ba362d8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -104,6 +104,8 @@ static int nfs4_map_errors(int err)
 		return -EACCES;
 	case -NFS4ERR_MINOR_VERS_MISMATCH:
 		return -EPROTONOSUPPORT;
+	case -NFS4ERR_ACCESS:
+		return -EACCES;
 	default:
 		dprintk("%s could not handle NFSv4 error %d\n",
 				__func__, -err);
@@ -860,6 +862,14 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.fh = NFS_FH(dir);
 	p->o_arg.open_flags = flags;
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
+	/* ask server to check for all possible rights as results are cached */
+	if (flags & O_DIRECTORY)
+		p->o_arg.access = NFS4_ACCESS_READ | NFS4_ACCESS_MODIFY |
+				  NFS4_ACCESS_EXTEND | NFS4_ACCESS_DELETE |
+				  NFS4_ACCESS_LOOKUP;
+	else
+		p->o_arg.access = NFS4_ACCESS_READ | NFS4_ACCESS_MODIFY |
+				  NFS4_ACCESS_EXTEND | NFS4_ACCESS_EXECUTE;
 	p->o_arg.clientid = server->nfs_client->cl_clientid;
 	p->o_arg.id.create_time = ktime_to_ns(sp->so_seqid.create_time);
 	p->o_arg.id.uniquifier = sp->so_seqid.owner_id;
@@ -1643,6 +1653,41 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
 	return status;
 }
 
+static int nfs4_opendata_access(struct rpc_cred *cred,
+				struct nfs4_opendata *opendata,
+				struct nfs4_state *state, fmode_t fmode)
+{
+	struct nfs_access_entry cache;
+	u32 mask = 0;
+	u32 a_res = opendata->o_res.access_res.access;
+
+	if (fmode & FMODE_READ)
+		mask |= MAY_READ;
+	if (fmode & FMODE_WRITE)
+		mask |= MAY_WRITE;
+	if (fmode & FMODE_EXEC)
+		mask |= MAY_EXEC;
+
+	cache.mask = 0;
+	cache.cred = cred;
+	cache.jiffies = jiffies;
+
+	if (a_res & NFS4_ACCESS_READ)
+		cache.mask |= MAY_READ;
+	if (a_res & (NFS4_ACCESS_MODIFY|NFS4_ACCESS_EXTEND|NFS4_ACCESS_DELETE))
+		cache.mask |= MAY_WRITE;
+	if (a_res & (NFS4_ACCESS_LOOKUP|NFS4_ACCESS_EXECUTE))
+		cache.mask |= MAY_EXEC;
+	nfs_access_add_cache(state->inode, &cache);
+
+	if ((mask & ~cache.mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) == 0)
+		return 0;
+
+	/* even though OPEN succeeded, access is denied. Close the file */
+	nfs4_close_state(state, fmode);
+	return -NFS4ERR_ACCESS;
+}
+
 /*
  * Note: On error, nfs4_proc_open will free the struct nfs4_opendata
  */
@@ -1896,6 +1941,10 @@ static int _nfs4_do_open(struct inode *dir,
 	if (server->caps & NFS_CAP_POSIX_LOCK)
 		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
 
+	status = nfs4_opendata_access(cred, opendata, state, fmode);
+	if (status != 0)
+		goto err_opendata_put;
+
 	if (opendata->o_arg.open_flags & O_EXCL) {
 		nfs4_exclusive_attrset(opendata, sattr);
 
@@ -1941,7 +1990,7 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 	struct nfs4_state *res;
 	int status;
 
-	fmode &= FMODE_READ|FMODE_WRITE;
+	fmode &= FMODE_READ|FMODE_WRITE|FMODE_EXEC;
 	do {
 		status = _nfs4_do_open(dir, dentry, fmode, flags, sattr, cred,
 				       &res, ctx_th);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f505726..6d31888 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2216,6 +2216,7 @@ static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_open(xdr, args, &hdr);
 	encode_getfh(xdr, &hdr);
+	encode_access(xdr, args->access, &hdr);
 	encode_getfattr_open(xdr, args->bitmask, args->open_bitmap, &hdr);
 	encode_nops(&hdr);
 }
@@ -2252,6 +2253,7 @@ static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_open(xdr, args, &hdr);
+	encode_access(xdr, args->access, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
@@ -6232,6 +6234,9 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_getfh(xdr, &res->fh);
 	if (status)
 		goto out;
+	status = decode_access(xdr, &res->access_res);
+	if (status)
+		goto out;
 	decode_getfattr(xdr, res->f_attr, res->server);
 out:
 	return status;
@@ -6280,6 +6285,9 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp,
 	status = decode_open(xdr, res);
 	if (status)
 		goto out;
+	status = decode_access(xdr, &res->access_res);
+	if (status)
+		goto out;
 	decode_getfattr(xdr, res->f_attr, res->server);
 out:
 	return status;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1f8fc7f..b944280 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -360,6 +360,7 @@ extern int nfs_refresh_inode(struct inode *, struct nfs_fattr *);
 extern int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr);
 extern int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fattr);
 extern int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+extern void nfs_access_add_cache(struct inode *, struct nfs_access_entry *);
 extern int nfs_permission(struct inode *, int);
 extern int nfs_open(struct inode *, struct file *);
 extern int nfs_release(struct inode *, struct file *);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ac7c8ae..c7435ae 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -335,6 +335,7 @@ struct nfs_openargs {
 	struct nfs_seqid *	seqid;
 	int			open_flags;
 	fmode_t			fmode;
+	u32			access;
 	__u64                   clientid;
 	struct stateowner_id	id;
 	union {
@@ -353,6 +354,14 @@ struct nfs_openargs {
 	struct nfs4_sequence_args	seq_args;
 };
 
+struct nfs4_accessres {
+	const struct nfs_server		*server;
+	struct nfs_fattr		*fattr;
+	u32				supported;
+	u32				access;
+	struct nfs4_sequence_res	seq_res;
+};
+
 struct nfs_openres {
 	nfs4_stateid            stateid;
 	struct nfs_fh           fh;
@@ -369,6 +378,7 @@ struct nfs_openres {
 	struct nfs4_string	*owner;
 	struct nfs4_string	*group_owner;
 	struct nfs4_sequence_res	seq_res;
+	struct nfs4_accessres	access_res;
 };
 
 /*
@@ -835,14 +845,6 @@ struct nfs4_accessargs {
 	struct nfs4_sequence_args	seq_args;
 };
 
-struct nfs4_accessres {
-	const struct nfs_server *	server;
-	struct nfs_fattr *		fattr;
-	u32				supported;
-	u32				access;
-	struct nfs4_sequence_res	seq_res;
-};
-
 struct nfs4_create_arg {
 	u32				ftype;
 	union {
-- 
1.7.9.6 (Apple Git-31.1)

