Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21774 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757252Ab2IJSAu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Sep 2012 14:00:50 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFSv4: Add ACCESS operation to OPEN compound
Date: Mon, 10 Sep 2012 14:00:46 -0400
Message-Id: <1347300046-3220-1-git-send-email-dros@netapp.com>
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
Acted on Trond's comments.

Great catch on decode_access failing - don't know how I missed that!

The only thing I can see that you may not like is using
access_supported == 0 to skip the access checks instead of storing the 
status from the access call in opendata->o_res.  It makes sense to me since
only a broken server wouldn't support any access bits.

 fs/nfs/dir.c            |   16 ++++++++++++++-
 fs/nfs/nfs4proc.c       |   52 +++++++++++++++++++++++++++++++++++++++--------
 fs/nfs/nfs4xdr.c        |   16 +++++++++++----
 include/linux/nfs_fs.h  |    2 ++
 include/linux/nfs_xdr.h |    3 +++
 5 files changed, 76 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 627f108..ce8cb92 100644
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
@@ -2098,6 +2098,20 @@ static void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *s
 		spin_unlock(&nfs_access_lru_lock);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_access_add_cache);
+
+void nfs_access_set_mask(struct nfs_access_entry *entry, u32 access_result)
+{
+	entry->mask = 0;
+	if (access_result & NFS4_ACCESS_READ)
+		entry->mask |= MAY_READ;
+	if (access_result &
+	    (NFS4_ACCESS_MODIFY | NFS4_ACCESS_EXTEND | NFS4_ACCESS_DELETE))
+		entry->mask |= MAY_WRITE;
+	if (access_result & (NFS4_ACCESS_LOOKUP|NFS4_ACCESS_EXECUTE))
+		entry->mask |= MAY_EXEC;
+}
+EXPORT_SYMBOL_GPL(nfs_access_set_mask);
 
 static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1e50326..3fb7270 100644
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
@@ -860,6 +862,9 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.fh = NFS_FH(dir);
 	p->o_arg.open_flags = flags;
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
+	/* ask server to check for all possible rights as results are cached */
+	p->o_arg.access = NFS4_ACCESS_READ | NFS4_ACCESS_MODIFY |
+			  NFS4_ACCESS_EXTEND | NFS4_ACCESS_EXECUTE;
 	p->o_arg.clientid = server->nfs_client->cl_clientid;
 	p->o_arg.id.create_time = ktime_to_ns(sp->so_seqid.create_time);
 	p->o_arg.id.uniquifier = sp->so_seqid.owner_id;
@@ -1643,6 +1648,39 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
 	return status;
 }
 
+static int nfs4_opendata_access(struct rpc_cred *cred,
+				struct nfs4_opendata *opendata,
+				struct nfs4_state *state, fmode_t fmode)
+{
+	struct nfs_access_entry cache;
+	u32 mask;
+
+	/* access call failed or for some reason the server doesn't
+	 * support any access modes -- defer access call until later */
+	if (opendata->o_res.access_supported == 0)
+		return 0;
+
+	mask = 0;
+	if (fmode & FMODE_READ)
+		mask |= MAY_READ;
+	if (fmode & FMODE_WRITE)
+		mask |= MAY_WRITE;
+	if (fmode & FMODE_EXEC)
+		mask |= MAY_EXEC;
+
+	cache.cred = cred;
+	cache.jiffies = jiffies;
+	nfs_access_set_mask(&cache, opendata->o_res.access_result);
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
@@ -1896,6 +1934,10 @@ static int _nfs4_do_open(struct inode *dir,
 	if (server->caps & NFS_CAP_POSIX_LOCK)
 		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
 
+	status = nfs4_opendata_access(cred, opendata, state, fmode);
+	if (status != 0)
+		goto err_opendata_put;
+
 	if (opendata->o_arg.open_flags & O_EXCL) {
 		nfs4_exclusive_attrset(opendata, sattr);
 
@@ -1941,7 +1983,7 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 	struct nfs4_state *res;
 	int status;
 
-	fmode &= FMODE_READ|FMODE_WRITE;
+	fmode &= FMODE_READ|FMODE_WRITE|FMODE_EXEC;
 	do {
 		status = _nfs4_do_open(dir, dentry, fmode, flags, sattr, cred,
 				       &res, ctx_th);
@@ -2767,13 +2809,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (!status) {
-		entry->mask = 0;
-		if (res.access & NFS4_ACCESS_READ)
-			entry->mask |= MAY_READ;
-		if (res.access & (NFS4_ACCESS_MODIFY | NFS4_ACCESS_EXTEND | NFS4_ACCESS_DELETE))
-			entry->mask |= MAY_WRITE;
-		if (res.access & (NFS4_ACCESS_LOOKUP|NFS4_ACCESS_EXECUTE))
-			entry->mask |= MAY_EXEC;
+		nfs_access_set_mask(entry, res.access);
 		nfs_refresh_inode(inode, res.fattr);
 	}
 	nfs_free_fattr(res.fattr);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 8dba6bd..8a9f1b8 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -447,12 +447,14 @@ static int nfs4_stat_to_errno(int);
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_open_maxsz + \
+				encode_access_maxsz + \
 				encode_getfh_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_open_sz        (compound_decode_hdr_maxsz + \
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_open_maxsz + \
+				decode_access_maxsz + \
 				decode_getfh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_open_confirm_sz \
@@ -467,11 +469,13 @@ static int nfs4_stat_to_errno(int);
 					encode_sequence_maxsz + \
 					encode_putfh_maxsz + \
 					encode_open_maxsz + \
+					encode_access_maxsz + \
 					encode_getattr_maxsz)
 #define NFS4_dec_open_noattr_sz	(compound_decode_hdr_maxsz + \
 					decode_sequence_maxsz + \
 					decode_putfh_maxsz + \
 					decode_open_maxsz + \
+					decode_access_maxsz + \
 					decode_getattr_maxsz)
 #define NFS4_enc_open_downgrade_sz \
 				(compound_encode_hdr_maxsz + \
@@ -2216,6 +2220,7 @@ static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_open(xdr, args, &hdr);
 	encode_getfh(xdr, &hdr);
+	encode_access(xdr, args->access, &hdr);
 	encode_getfattr_open(xdr, args->bitmask, args->open_bitmap, &hdr);
 	encode_nops(&hdr);
 }
@@ -2252,6 +2257,7 @@ static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_open(xdr, args, &hdr);
+	encode_access(xdr, args->access, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
@@ -4095,7 +4101,7 @@ out_overflow:
 	return -EIO;
 }
 
-static int decode_access(struct xdr_stream *xdr, struct nfs4_accessres *access)
+static int decode_access(struct xdr_stream *xdr, u32 *supported, u32 *access)
 {
 	__be32 *p;
 	uint32_t supp, acc;
@@ -4109,8 +4115,8 @@ static int decode_access(struct xdr_stream *xdr, struct nfs4_accessres *access)
 		goto out_overflow;
 	supp = be32_to_cpup(p++);
 	acc = be32_to_cpup(p);
-	access->supported = supp;
-	access->access = acc;
+	*supported = supp;
+	*access = acc;
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -5887,7 +5893,7 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_putfh(xdr);
 	if (status != 0)
 		goto out;
-	status = decode_access(xdr, res);
+	status = decode_access(xdr, &res->supported, &res->access);
 	if (status != 0)
 		goto out;
 	decode_getfattr(xdr, res->fattr, res->server);
@@ -6228,6 +6234,7 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_getfh(xdr, &res->fh);
 	if (status)
 		goto out;
+	decode_access(xdr, &res->access_supported, &res->access_result);
 	decode_getfattr(xdr, res->f_attr, res->server);
 out:
 	return status;
@@ -6276,6 +6283,7 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp,
 	status = decode_open(xdr, res);
 	if (status)
 		goto out;
+	decode_access(xdr, &res->access_supported, &res->access_result);
 	decode_getfattr(xdr, res->f_attr, res->server);
 out:
 	return status;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 4b03f56..3704094 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -355,6 +355,8 @@ extern int nfs_refresh_inode(struct inode *, struct nfs_fattr *);
 extern int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr);
 extern int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fattr);
 extern int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+extern void nfs_access_add_cache(struct inode *, struct nfs_access_entry *);
+extern void nfs_access_set_mask(struct nfs_access_entry *, u32);
 extern int nfs_permission(struct inode *, int);
 extern int nfs_open(struct inode *, struct file *);
 extern int nfs_release(struct inode *, struct file *);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index be9cf3c..70371aa 100644
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
@@ -369,6 +370,8 @@ struct nfs_openres {
 	struct nfs4_string	*owner;
 	struct nfs4_string	*group_owner;
 	struct nfs4_sequence_res	seq_res;
+	__u32			access_supported;
+	__u32			access_result;
 };
 
 /*
-- 
1.7.9.6 (Apple Git-31.1)

