Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57089 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181Ab2AGRIm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Jan 2012 12:08:42 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Save the owner/group name string when doing open
Date: Sat,  7 Jan 2012 12:08:35 -0500
Message-Id: <1325956115-21767-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...so that we can do the uid/gid mapping outside the asynchronous RPC
context.
This fixes a bug in the current NFSv4 atomic open code where the client
isn't able to determine what the true uid/gid fields of the file are,
(because the asynchronous nature of the OPEN call denies it the ability
to do an upcall) and so fills them with default values, marking the
inode as needing revalidation.
Unfortunately, in some cases, the VFS will do some additional sanity
checks on the file, and may override the server's decision to allow
the open because it sees the wrong owner/group fields.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c          |    2 +
 fs/nfs/nfs4proc.c       |   63 ++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c        |  106 +++++++++++++++++++++--------------------------
 include/linux/nfs_xdr.h |   17 +++++--
 4 files changed, 124 insertions(+), 64 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 50a15fa..8bbcaf7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1019,6 +1019,8 @@ void nfs_fattr_init(struct nfs_fattr *fattr)
 	fattr->valid = 0;
 	fattr->time_start = jiffies;
 	fattr->gencount = nfs_inc_attr_generation_counter();
+	fattr->owner = NULL;
+	fattr->group_owner = NULL;
 }
 
 struct nfs_fattr *nfs_alloc_fattr(void)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3b10801..6e65fef 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -52,6 +52,7 @@
 #include <linux/namei.h>
 #include <linux/mount.h>
 #include <linux/module.h>
+#include <linux/nfs_idmap.h>
 #include <linux/sunrpc/bc_xprt.h>
 #include <linux/xattr.h>
 #include <linux/utsname.h>
@@ -754,12 +755,66 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 	spin_unlock(&dir->i_lock);
 }
 
+static void nfs4_fattr_free_owner(struct nfs_fattr *fattr)
+{
+	if (fattr->valid & NFS_ATTR_FATTR_OWNER_STRING) {
+		fattr->valid &= ~NFS_ATTR_FATTR_OWNER_STRING;
+		kfree(fattr->owner->data);
+	}
+}
+
+static void nfs4_fattr_free_group_owner(struct nfs_fattr *fattr)
+{
+	if (fattr->valid & NFS_ATTR_FATTR_GROUP_STRING) {
+		fattr->valid &= ~NFS_ATTR_FATTR_GROUP_STRING;
+		kfree(fattr->group_owner->data);
+	}
+}
+
+static void nfs4_fattr_map_owner(struct nfs_server *server, struct nfs_fattr *fattr)
+{
+	struct nfs4_string *owner = fattr->owner;
+	__u32 uid;
+
+	if (!(fattr->valid & NFS_ATTR_FATTR_OWNER_STRING))
+		return;
+	if (nfs_map_name_to_uid(server, owner->data, owner->len, &uid) == 0) {
+		fattr->uid = uid;
+		fattr->valid |= NFS_ATTR_FATTR_OWNER;
+	}
+	fattr->valid &= ~NFS_ATTR_FATTR_OWNER_STRING;
+	kfree(fattr->owner->data);
+}
+
+static void nfs4_fattr_map_group_owner(struct nfs_server *server, struct nfs_fattr *fattr)
+{
+	struct nfs4_string *group = fattr->group_owner;
+	__u32 gid;
+
+	if (!(fattr->valid & NFS_ATTR_FATTR_GROUP_STRING))
+		return;
+	if (nfs_map_group_to_gid(server, group->data, group->len, &gid) == 0) {
+		fattr->gid = gid;
+		fattr->valid |= NFS_ATTR_FATTR_GROUP;
+	}
+	fattr->valid &= ~NFS_ATTR_FATTR_GROUP_STRING;
+	kfree(fattr->group_owner->data);
+}
+
+static void nfs4_fattr_map_strings(struct nfs_server *server, struct nfs_fattr *fattr)
+{
+	nfs4_fattr_map_owner(server, fattr);
+	nfs4_fattr_map_group_owner(server, fattr);
+}
+
 struct nfs4_opendata {
 	struct kref kref;
 	struct nfs_openargs o_arg;
 	struct nfs_openres o_res;
 	struct nfs_open_confirmargs c_arg;
 	struct nfs_open_confirmres c_res;
+	struct nfs4_string owner_name;
+	struct nfs4_string group_name;
 	struct nfs_fattr f_attr;
 	struct nfs_fattr dir_attr;
 	struct dentry *dir;
@@ -783,6 +838,8 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
 	p->o_res.server = p->o_arg.server;
 	nfs_fattr_init(&p->f_attr);
 	nfs_fattr_init(&p->dir_attr);
+	p->f_attr.owner = &p->owner_name;
+	p->f_attr.group_owner = &p->group_name;
 }
 
 static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
@@ -814,6 +871,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.name = &dentry->d_name;
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
+	p->o_arg.dir_bitmask = server->cache_consistency_bitmask;
 	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
 	if (flags & O_CREAT) {
 		u32 *s;
@@ -850,6 +908,8 @@ static void nfs4_opendata_free(struct kref *kref)
 	dput(p->dir);
 	dput(p->dentry);
 	nfs_sb_deactive(sb);
+	nfs4_fattr_free_owner(&p->f_attr);
+	nfs4_fattr_free_group_owner(&p->f_attr);
 	kfree(p);
 }
 
@@ -1574,6 +1634,7 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
 	if (status != 0 || !data->rpc_done)
 		return status;
 
+	nfs4_fattr_map_strings(NFS_SERVER(dir), &data->f_attr);
 	nfs_refresh_inode(dir, o_res->dir_attr);
 
 	if (o_res->rflags & NFS4_OPEN_RESULT_CONFIRM) {
@@ -1606,6 +1667,8 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 		return status;
 	}
 
+	nfs4_fattr_map_strings(server, &data->f_attr);
+
 	if (o_arg->open_flags & O_CREAT) {
 		update_changeattr(dir, &o_res->cinfo);
 		nfs_post_op_update_inode(dir, o_res->dir_attr);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index dcaf693..31201db 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2298,7 +2298,7 @@ static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_getfh(xdr, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_restorefh(xdr, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
+	encode_getfattr(xdr, args->dir_bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -3792,7 +3792,8 @@ out_overflow:
 }
 
 static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
-		const struct nfs_server *server, uint32_t *uid, int may_sleep)
+		const struct nfs_server *server, uint32_t *uid,
+		struct nfs4_string *owner)
 {
 	uint32_t len;
 	__be32 *p;
@@ -3809,8 +3810,12 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap,
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
 			goto out_overflow;
-		if (!may_sleep) {
-			/* do nothing */
+		if (owner != NULL) {
+			owner->data = kmemdup(p, len, GFP_NOWAIT);
+			if (owner->data != NULL) {
+				owner->len = len;
+				ret = NFS_ATTR_FATTR_OWNER_STRING;
+			}
 		} else if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_name_to_uid(server, (char *)p, len, uid) == 0)
 				ret = NFS_ATTR_FATTR_OWNER;
@@ -3830,7 +3835,8 @@ out_overflow:
 }
 
 static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
-		const struct nfs_server *server, uint32_t *gid, int may_sleep)
+		const struct nfs_server *server, uint32_t *gid,
+		struct nfs4_string *group)
 {
 	uint32_t len;
 	__be32 *p;
@@ -3847,8 +3853,12 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap,
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
 			goto out_overflow;
-		if (!may_sleep) {
-			/* do nothing */
+		if (group != NULL) {
+			group->data = kmemdup(p, len, GFP_NOWAIT);
+			if (group->data != NULL) {
+				group->len = len;
+				ret = NFS_ATTR_FATTR_GROUP_STRING;
+			}
 		} else if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_group_to_gid(server, (char *)p, len, gid) == 0)
 				ret = NFS_ATTR_FATTR_GROUP;
@@ -4285,7 +4295,7 @@ xdr_error:
 
 static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		struct nfs_fattr *fattr, struct nfs_fh *fh,
-		const struct nfs_server *server, int may_sleep)
+		const struct nfs_server *server)
 {
 	int status;
 	umode_t fmode = 0;
@@ -4352,12 +4362,12 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		goto xdr_error;
 	fattr->valid |= status;
 
-	status = decode_attr_owner(xdr, bitmap, server, &fattr->uid, may_sleep);
+	status = decode_attr_owner(xdr, bitmap, server, &fattr->uid, fattr->owner);
 	if (status < 0)
 		goto xdr_error;
 	fattr->valid |= status;
 
-	status = decode_attr_group(xdr, bitmap, server, &fattr->gid, may_sleep);
+	status = decode_attr_group(xdr, bitmap, server, &fattr->gid, fattr->group_owner);
 	if (status < 0)
 		goto xdr_error;
 	fattr->valid |= status;
@@ -4398,7 +4408,7 @@ xdr_error:
 }
 
 static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fattr,
-		struct nfs_fh *fh, const struct nfs_server *server, int may_sleep)
+		struct nfs_fh *fh, const struct nfs_server *server)
 {
 	__be32 *savep;
 	uint32_t attrlen,
@@ -4417,7 +4427,7 @@ static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fat
 	if (status < 0)
 		goto xdr_error;
 
-	status = decode_getfattr_attrs(xdr, bitmap, fattr, fh, server, may_sleep);
+	status = decode_getfattr_attrs(xdr, bitmap, fattr, fh, server);
 	if (status < 0)
 		goto xdr_error;
 
@@ -4428,9 +4438,9 @@ xdr_error:
 }
 
 static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
-		const struct nfs_server *server, int may_sleep)
+		const struct nfs_server *server)
 {
-	return decode_getfattr_generic(xdr, fattr, NULL, server, may_sleep);
+	return decode_getfattr_generic(xdr, fattr, NULL, server);
 }
 
 /*
@@ -5711,8 +5721,7 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp,
 	status = decode_open_downgrade(xdr, res);
 	if (status != 0)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -5738,8 +5747,7 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_access(xdr, res);
 	if (status != 0)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -5768,8 +5776,7 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_getfh(xdr, res->fh);
 	if (status)
 		goto out;
-	status = decode_getfattr(xdr, res->fattr, res->server
-			,!RPC_IS_ASYNC(rqstp->rq_task));
+	status = decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -5795,8 +5802,7 @@ static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp,
 		goto out;
 	status = decode_getfh(xdr, res->fh);
 	if (status == 0)
-		status = decode_getfattr(xdr, res->fattr, res->server,
-				!RPC_IS_ASYNC(rqstp->rq_task));
+		status = decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -5822,8 +5828,7 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_remove(xdr, &res->cinfo);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->dir_attr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(xdr, res->dir_attr, res->server);
 out:
 	return status;
 }
@@ -5856,14 +5861,12 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	if (status)
 		goto out;
 	/* Current FH is target directory */
-	if (decode_getfattr(xdr, res->new_fattr, res->server,
-				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
+	if (decode_getfattr(xdr, res->new_fattr, res->server))
 		goto out;
 	status = decode_restorefh(xdr);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->old_fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(xdr, res->old_fattr, res->server);
 out:
 	return status;
 }
@@ -5899,14 +5902,12 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	 * Note order: OP_LINK leaves the directory as the current
 	 *             filehandle.
 	 */
-	if (decode_getfattr(xdr, res->dir_attr, res->server,
-				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
+	if (decode_getfattr(xdr, res->dir_attr, res->server))
 		goto out;
 	status = decode_restorefh(xdr);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -5938,14 +5939,12 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_getfh(xdr, res->fh);
 	if (status)
 		goto out;
-	if (decode_getfattr(xdr, res->fattr, res->server,
-				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
+	if (decode_getfattr(xdr, res->fattr, res->server))
 		goto out;
 	status = decode_restorefh(xdr);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->dir_fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(xdr, res->dir_fattr, res->server);
 out:
 	return status;
 }
@@ -5977,8 +5976,7 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_getfattr(xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	status = decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -6076,8 +6074,7 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	 * 	an ESTALE error. Shouldn't be a problem,
 	 * 	though, since fattr->valid will remain unset.
 	 */
-	decode_getfattr(xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -6108,13 +6105,11 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 		goto out;
 	if (decode_getfh(xdr, &res->fh) != 0)
 		goto out;
-	if (decode_getfattr(xdr, res->f_attr, res->server,
-				!RPC_IS_ASYNC(rqstp->rq_task)) != 0)
+	if (decode_getfattr(xdr, res->f_attr, res->server) != 0)
 		goto out;
 	if (decode_restorefh(xdr) != 0)
 		goto out;
-	decode_getfattr(xdr, res->dir_attr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(xdr, res->dir_attr, res->server);
 out:
 	return status;
 }
@@ -6162,8 +6157,7 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp,
 	status = decode_open(xdr, res);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->f_attr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(xdr, res->f_attr, res->server);
 out:
 	return status;
 }
@@ -6190,8 +6184,7 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp,
 	status = decode_setattr(xdr);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -6371,8 +6364,7 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	if (status)
 		goto out;
 	if (res->fattr)
-		decode_getfattr(xdr, res->fattr, res->server,
-				!RPC_IS_ASYNC(rqstp->rq_task));
+		decode_getfattr(xdr, res->fattr, res->server);
 	if (!status)
 		status = res->count;
 out:
@@ -6401,8 +6393,7 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	if (status)
 		goto out;
 	if (res->fattr)
-		decode_getfattr(xdr, res->fattr, res->server,
-				!RPC_IS_ASYNC(rqstp->rq_task));
+		decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -6561,8 +6552,7 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp,
 	status = decode_delegreturn(xdr);
 	if (status != 0)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -6591,8 +6581,7 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req,
 		goto out;
 	xdr_enter_page(xdr, PAGE_SIZE);
 	status = decode_getfattr(xdr, &res->fs_locations->fattr,
-				 res->fs_locations->server,
-				 !RPC_IS_ASYNC(req->rq_task));
+				 res->fs_locations->server);
 out:
 	return status;
 }
@@ -6841,8 +6830,7 @@ static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp,
 	status = decode_layoutcommit(xdr, rqstp, res);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server,
-			!RPC_IS_ASYNC(rqstp->rq_task));
+	decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
@@ -6973,7 +6961,7 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		goto out_overflow;
 
 	if (decode_getfattr_attrs(xdr, bitmap, entry->fattr, entry->fh,
-					entry->server, 1) < 0)
+					entry->server) < 0)
 		goto out_overflow;
 	if (entry->fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID)
 		entry->ino = entry->fattr->mounted_on_fileid;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6c898af..8bd5858 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -18,6 +18,11 @@
 /* Forward declaration for NFS v3 */
 struct nfs4_secinfo_flavors;
 
+struct nfs4_string {
+	unsigned int len;
+	char *data;
+};
+
 struct nfs_fsid {
 	uint64_t		major;
 	uint64_t		minor;
@@ -61,6 +66,8 @@ struct nfs_fattr {
 	struct timespec		pre_ctime;	/* pre_op_attr.ctime	  */
 	unsigned long		time_start;
 	unsigned long		gencount;
+	struct nfs4_string	*owner;
+	struct nfs4_string	*group_owner;
 };
 
 #define NFS_ATTR_FATTR_TYPE		(1U << 0)
@@ -85,6 +92,8 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_V4_REFERRAL	(1U << 19)	/* NFSv4 referral */
 #define NFS_ATTR_FATTR_MOUNTPOINT	(1U << 20)	/* Treat as mountpoint */
 #define NFS_ATTR_FATTR_MOUNTED_ON_FILEID		(1U << 21)
+#define NFS_ATTR_FATTR_OWNER_STRING	(1U << 22)
+#define NFS_ATTR_FATTR_GROUP_STRING	(1U << 23)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \
@@ -324,6 +333,7 @@ struct nfs_openargs {
 	const struct qstr *	name;
 	const struct nfs_server *server;	 /* Needed for ID mapping */
 	const u32 *		bitmask;
+	const u32 *		dir_bitmask;
 	__u32			claim;
 	struct nfs4_sequence_args	seq_args;
 };
@@ -342,6 +352,8 @@ struct nfs_openres {
 	__u32			do_recall;
 	__u64			maxsize;
 	__u32			attrset[NFS4_BITMAP_SIZE];
+	struct nfs4_string	*owner;
+	struct nfs4_string	*group_owner;
 	struct nfs4_sequence_res	seq_res;
 };
 
@@ -778,11 +790,6 @@ struct nfs3_getaclres {
 	struct posix_acl *	acl_default;
 };
 
-struct nfs4_string {
-	unsigned int len;
-	char *data;
-};
-
 #ifdef CONFIG_NFS_V4
 
 typedef u64 clientid4;
-- 
1.7.7.5

