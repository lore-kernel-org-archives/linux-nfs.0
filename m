Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:54625 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078Ab3AVN6W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 08:58:22 -0500
From: Steve Dickson <steved@redhat.com>
To: David Quigley <selinux@davequigley.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 11/14] NFS: Client implementation of Labeled-NFS
Date: Tue, 22 Jan 2013 08:40:39 -0500
Message-Id: <1358862042-27520-12-git-send-email-steved@redhat.com>
In-Reply-To: <1358862042-27520-1-git-send-email-steved@redhat.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

This patch implements the client transport and handling support for labeled
NFS. The patch adds two functions to encode and decode the security label
recommended attribute which makes use of the LSM hooks added earlier. It also
adds code to grab the label from the file attribute structures and encode the
label to be sent back to the server.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
---
 fs/nfs/dir.c              |   4 -
 fs/nfs/inode.c            |  58 +++++++--
 fs/nfs/nfs4proc.c         | 296 ++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4xdr.c          | 178 +++++++++++++++++++++++-----
 fs/nfs/super.c            |  17 ++-
 include/linux/nfs_fs.h    |   3 +
 include/linux/nfs_fs_sb.h |   7 ++
 security/selinux/hooks.c  |   4 +
 8 files changed, 508 insertions(+), 59 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index d01fd1f..e7605fe 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1107,10 +1107,8 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
 
-#ifdef CONFIG_NFS_V4_SECURITY_LABEL
 	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL))
 		nfs4_label_free(label);
-#endif
 
 out_set_verifier:
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
@@ -1299,10 +1297,8 @@ no_entry:
 out_unblock_sillyrename:
 	nfs_unblock_sillyrename(parent);
 out:
-#ifdef CONFIG_NFS_V4_SECURITY_LABEL
 	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL))
 		nfs4_label_free(label);
-#endif
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
 	return res;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 30ce1e0..56cd542 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -162,11 +162,19 @@ static void nfs_zap_caches_locked(struct inode *inode)
 
 	memset(NFS_I(inode)->cookieverf, 0, sizeof(NFS_I(inode)->cookieverf));
 	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode)) {
-		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
 		nfs_fscache_invalidate(inode);
-	} else {
-		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
-	}
+		nfsi->cache_validity |= NFS_INO_INVALID_ATTR
+					| NFS_INO_INVALID_LABEL
+					| NFS_INO_INVALID_DATA
+					| NFS_INO_INVALID_ACCESS
+					| NFS_INO_INVALID_ACL
+					| NFS_INO_REVAL_PAGECACHE;
+	} else
+		nfsi->cache_validity |= NFS_INO_INVALID_ATTR
+					| NFS_INO_INVALID_LABEL
+					| NFS_INO_INVALID_ACCESS
+					| NFS_INO_INVALID_ACL
+					| NFS_INO_REVAL_PAGECACHE;
 }
 
 void nfs_zap_caches(struct inode *inode)
@@ -256,6 +264,24 @@ nfs_init_locked(struct inode *inode, void *opaque)
 }
 
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
+void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
+					struct nfs4_label *label)
+{
+	int error;
+
+	if ((fattr->valid & NFS_ATTR_FATTR_V4_SECURITY_LABEL) &&
+			label && inode->i_security) {
+		error = security_inode_notifysecctx(inode, label->label,
+				label->len);
+		if (error)
+			printk(KERN_ERR "%s() %s %d "
+					"security_inode_notifysecctx() %d\n",
+					__func__,
+					(char *)label->label,
+					label->len, error);
+	}
+}
+
 struct nfs4_label *nfs4_label_alloc(gfp_t flags)
 {
 	struct nfs4_label *label = NULL;
@@ -293,7 +319,14 @@ void nfs4_label_free(struct nfs4_label *label)
 	return;
 }
 EXPORT_SYMBOL_GPL(nfs4_label_free);
+
+#else
+void inline nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
+					struct nfs4_label *label)
+{
+}
 #endif
+EXPORT_SYMBOL_GPL(nfs_setsecurity);
 
 /*
  * This is our front-end to iget that looks up inodes by file handle
@@ -422,6 +455,9 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 			 */
 			inode->i_blocks = nfs_calc_block_size(fattr->du.nfs3.used);
 		}
+
+		nfs_setsecurity(inode, fattr, label);
+
 		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
 		nfsi->attrtimeo_timestamp = now;
 		nfsi->access_cache = RB_ROOT;
@@ -784,6 +820,7 @@ struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_c
 	spin_unlock(&inode->i_lock);
 	return ctx;
 }
+EXPORT_SYMBOL_GPL(nfs_find_open_context);
 
 static void nfs_file_clear_open_context(struct file *filp)
 {
@@ -885,10 +922,10 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		(long long)NFS_FILEID(inode));
 
  out:
-#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+
 	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL))
 		nfs4_label_free(label);
-#endif
+
 	nfs_free_fattr(fattr);
 	return status;
 }
@@ -916,7 +953,8 @@ static int nfs_attribute_cache_expired(struct inode *inode)
  */
 int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 {
-	if (!(NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATTR)
+	if (!(NFS_I(inode)->cache_validity &
+			(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL))
 			&& !nfs_attribute_cache_expired(inode))
 		return NFS_STALE(inode) ? -ESTALE : 0;
 	return __nfs_revalidate_inode(server, inode);
@@ -1515,6 +1553,9 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr, struct
 				| NFS_INO_INVALID_ACL
 				| NFS_INO_REVAL_FORCED);
 
+	if (label && (server->caps & NFS_CAP_SECURITY_LABEL))
+		nfs_setsecurity(inode, fattr, label);
+
 	if (fattr->valid & NFS_ATTR_FATTR_NLINK) {
 		if (inode->i_nlink != fattr->nlink) {
 			invalid |= NFS_INO_INVALID_ATTR;
@@ -1536,7 +1577,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr, struct
 		inode->i_blocks = fattr->du.nfs2.blocks;
 
 	/* Update attrtimeo value if we're out of the unstable period */
-	if (invalid & NFS_INO_INVALID_ATTR) {
+	if (invalid & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL)) {
 		nfs_inc_stats(inode, NFSIOS_ATTRINVALIDATE);
 		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
 		nfsi->attrtimeo_timestamp = now;
@@ -1549,6 +1590,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr, struct
 		}
 	}
 	invalid &= ~NFS_INO_INVALID_ATTR;
+	invalid &= ~NFS_INO_INVALID_LABEL;
 	/* Don't invalidate the data if we were to blame */
 	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
 				|| S_ISLNK(inode->i_mode)))
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d08f033..ba4f268 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -132,7 +132,7 @@ const u32 nfs4_fattr_bitmap[3] = {
 	| FATTR4_WORD1_TIME_ACCESS
 	| FATTR4_WORD1_TIME_METADATA
 	| FATTR4_WORD1_TIME_MODIFY,
-	0
+	FATTR4_WORD2_SECURITY_LABEL
 };
 
 static const u32 nfs4_pnfs_open_bitmap[3] = {
@@ -1947,6 +1947,7 @@ static int _nfs4_do_open(struct inode *dir,
 		if (status == 0) {
 			nfs_setattr_update_inode(state->inode, sattr);
 			nfs_post_op_update_inode(state->inode, opendata->o_res.f_attr, olabel);
+			nfs_setsecurity(state->inode, opendata->o_res.f_attr, olabel);
 		}
 	}
 
@@ -2059,6 +2060,9 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	unsigned long timestamp = jiffies;
 	int status;
 
+	if (ilabel == NULL || olabel == NULL)
+		arg.bitmask = server->attr_bitmask_nl;
+
 	nfs_fattr_init(fattr);
 
 	if (state != NULL) {
@@ -2286,7 +2290,7 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	if (calldata->arg.seqid == NULL)
 		goto out_free_calldata;
 	calldata->arg.fmode = 0;
-	calldata->arg.bitmask = server->cache_consistency_bitmask;
+	calldata->arg.bitmask = server->cache_consistency_bitmask_nl;
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
@@ -2316,11 +2320,24 @@ static struct inode *
 nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags, struct iattr *attr)
 {
 	struct nfs4_state *state;
-	struct nfs4_label *label = NULL;
+	struct nfs4_label l, *label = NULL;
+
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		struct dentry *dentry = ctx->dentry;
+		int error;
+		error = security_dentry_init_security(dentry, attr->ia_mode,
+				&dentry->d_name, &l.label, &l.len);
+		if (error == 0)
+			label = &l;
+	}
 
 	/* Protect against concurrent sillydeletes */
 	state = nfs4_do_open(dir, ctx->dentry, ctx->mode, open_flags, attr, label,
 			     ctx->cred, &ctx->mdsthreshold);
+
+	if (label)
+		security_release_secctx(l.label, l.len);
+
 	if (IS_ERR(state))
 		return ERR_CAST(state);
 	ctx->state = state;
@@ -2380,10 +2397,27 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 			server->caps |= NFS_CAP_CTIME;
 		if (res.attr_bitmask[1] & FATTR4_WORD1_TIME_MODIFY)
 			server->caps |= NFS_CAP_MTIME;
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+		if (res.attr_bitmask[2] & FATTR4_WORD2_SECURITY_LABEL) {
+			server->caps |= NFS_CAP_SECURITY_LABEL;
+		} else
+#endif
+		server->attr_bitmask[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
+
+		if (server->caps & NFS_CAP_SECURITY_LABEL) {
+			memcpy(server->attr_bitmask_nl, res.attr_bitmask, 
+				sizeof(server->attr_bitmask));
+			server->attr_bitmask_nl[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
+		}
 
 		memcpy(server->cache_consistency_bitmask, res.attr_bitmask, sizeof(server->cache_consistency_bitmask));
 		server->cache_consistency_bitmask[0] &= FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
-		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
+		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA |
+							FATTR4_WORD1_TIME_MODIFY;
+		server->cache_consistency_bitmask[2] &= FATTR4_WORD2_SECURITY_LABEL;
+		memcpy(server->cache_consistency_bitmask_nl, server->cache_consistency_bitmask,
+							sizeof(server->cache_consistency_bitmask_nl));
+		server->cache_consistency_bitmask_nl[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
 		server->acl_bitmask = res.acl_bitmask;
 		server->fh_expire_type = res.fh_expire_type;
 	}
@@ -2406,8 +2440,9 @@ int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		struct nfs_fsinfo *info)
 {
+	u32 bitmask[3];
 	struct nfs4_lookup_root_arg args = {
-		.bitmask = nfs4_fattr_bitmap,
+		.bitmask = bitmask,
 	};
 	struct nfs4_lookup_res res = {
 		.server = server,
@@ -2420,6 +2455,10 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_resp = &res,
 	};
 
+	bitmask[0] = nfs4_fattr_bitmap[0];
+	bitmask[1] = nfs4_fattr_bitmap[1];
+	bitmask[2] = nfs4_fattr_bitmap[2] & ~FATTR4_WORD2_SECURITY_LABEL;
+
 	nfs_fattr_init(info->fattr);
 	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
@@ -2607,7 +2646,10 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	
+
+	if (!label)
+		args.bitmask = server->attr_bitmask_nl;
+
 	nfs_fattr_init(fattr);
 	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 }
@@ -2703,6 +2745,7 @@ static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 	struct nfs4_lookup_res res = {
 		.server = server,
 		.fattr = fattr,
+		.label = label,
 		.fh = fhandle,
 	};
 	struct rpc_message msg = {
@@ -2711,6 +2754,9 @@ static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 		.rpc_resp = &res,
 	};
 
+	if (label == NULL)
+		args.bitmask = server->attr_bitmask_nl;
+
 	nfs_fattr_init(fattr);
 
 	dprintk("NFS call  lookup %s\n", name->name);
@@ -2817,7 +2863,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 		.rpc_cred = entry->cred,
 	};
 	int mode = entry->mask;
-	int status;
+	int status = 0;
 
 	/*
 	 * Determine which access bits we want to ask for...
@@ -2935,7 +2981,7 @@ static int
 nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		 int flags)
 {
-	struct nfs4_label *ilabel = NULL;
+	struct nfs4_label l, *ilabel = NULL;
 	struct nfs_open_context *ctx;
 	struct nfs4_state *state;
 	int status = 0;
@@ -2944,6 +2990,13 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		status = security_dentry_init_security(dentry, sattr->ia_mode,
+						&dentry->d_name, &l.label, &l.len);
+		if (status == 0)
+			ilabel = &l;
+	}
+
 	sattr->ia_mode &= ~current_umask();
 	state = nfs4_do_open(dir, dentry, ctx->mode,
 			flags, sattr, ilabel, ctx->cred,
@@ -2957,6 +3010,8 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	ctx->state = state;
 out:
+	if (ilabel)
+		security_release_secctx(ilabel->label, ilabel->len);
 	put_nfs_open_context(ctx);
 	return status;
 }
@@ -3006,6 +3061,8 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 	res->server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
 	nfs41_init_sequence(&args->seq_args, &res->seq_res, 1);
+
+	nfs_fattr_init(res->dir_attr);
 }
 
 static void nfs4_proc_unlink_rpc_prepare(struct rpc_task *task, struct nfs_unlinkdata *data)
@@ -3278,14 +3335,25 @@ static int nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 		struct page *page, unsigned int len, struct iattr *sattr)
 {
 	struct nfs4_exception exception = { };
-	struct nfs4_label *label = NULL;
+	struct nfs4_label l, *label = NULL;
 	int err;
+
+
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		err = security_dentry_init_security(dentry, sattr->ia_mode,
+					&dentry->d_name, &l.label, &l.len);
+		if (err == 0)
+			label = &l;
+	}
+
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
 				_nfs4_proc_symlink(dir, dentry, page,
 							len, sattr, label),
 				&exception);
 	} while (exception.retry);
+	if (label)
+		security_release_secctx(l.label, l.len);
 	return err;
 }
 
@@ -3311,15 +3379,24 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr)
 {
 	struct nfs4_exception exception = { };
-	struct nfs4_label *label = NULL;
+	struct nfs4_label l, *label = NULL;
 	int err;
 
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		err = security_dentry_init_security(dentry, sattr->ia_mode,
+					&dentry->d_name, &l.label, &l.len);
+		if (err == 0)
+			label = &l;
+	}
+
 	sattr->ia_mode &= ~current_umask();
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
 				_nfs4_proc_mkdir(dir, dentry, sattr, label),
 				&exception);
 	} while (exception.retry);
+	if (label)
+		security_release_secctx(l.label, l.len);
 	return err;
 }
 
@@ -3335,7 +3412,9 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		.bitmask = NFS_SERVER(dentry->d_inode)->attr_bitmask,
 		.plus = plus,
 	};
-	struct nfs4_readdir_res res;
+	struct nfs4_readdir_res res = {
+		.pgbase = 0,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READDIR],
 		.rpc_argp = &args,
@@ -3415,15 +3494,26 @@ static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr, dev_t rdev)
 {
 	struct nfs4_exception exception = { };
-	struct nfs4_label *label = NULL;
+	struct nfs4_label l, *label = NULL;
 	int err;
 
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		err = security_dentry_init_security(dentry, sattr->ia_mode,
+					&dentry->d_name, &l.label, &l.len);
+		if (err == 0)
+			label = &l;
+	}
+
 	sattr->ia_mode &= ~current_umask();
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
 				_nfs4_proc_mknod(dir, dentry, sattr, label, rdev),
 				&exception);
 	} while (exception.retry);
+
+	if (label)
+		security_release_secctx(l.label, l.len);
+
 	return err;
 }
 
@@ -3639,7 +3729,11 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 		data->args.bitmask = NULL;
 		data->res.fattr = NULL;
 	} else
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+		data->args.bitmask = server->cache_consistency_bitmask_nl;
+#else
 		data->args.bitmask = server->cache_consistency_bitmask;
+#endif
 
 	if (!data->write_done_cb)
 		data->write_done_cb = nfs4_write_done_cb;
@@ -4064,6 +4158,182 @@ static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen
 	return err;
 }
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+static int _nfs4_get_security_label(struct inode *inode, void *buf,
+					size_t buflen)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs_fattr fattr;
+	struct nfs4_label label;
+	u32 bitmask[3] = { 0, 0, FATTR4_WORD2_SECURITY_LABEL };
+	struct nfs4_getattr_arg args = {
+		.fh		= NFS_FH(inode),
+		.bitmask	= bitmask,
+	};
+	struct nfs4_getattr_res res = {
+		.fattr		= &fattr,
+		.label		= &label,
+		.server		= server,
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_GETATTR],
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+	};
+	int ret;
+
+	label.label = buf;
+	label.len = buflen;
+	nfs_fattr_init(&fattr);
+
+	ret = rpc_call_sync(server->client, &msg, 0);
+	if (ret)
+		return ret;
+	if (!(fattr.valid & NFS_ATTR_FATTR_V4_SECURITY_LABEL))
+		return -ENOENT;
+	if (buflen < label.len)
+		return -ERANGE;
+	return 0;
+}
+
+static int nfs4_get_security_label(struct inode *inode, void *buf,
+					size_t buflen)
+{
+	struct nfs4_exception exception = { };
+	int err;
+
+	if (!nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL))
+		return -EOPNOTSUPP;
+
+	do {
+		err = nfs4_handle_exception(NFS_SERVER(inode),
+				_nfs4_get_security_label(inode, buf, buflen),
+				&exception);
+	} while (exception.retry);
+	return err;
+}
+
+static int _nfs4_do_set_security_label(struct inode *inode,
+		struct nfs4_label *ilabel,
+		struct nfs_fattr *fattr,
+		struct nfs4_label *olabel,
+		struct nfs4_state *state)
+{
+
+	struct iattr sattr;
+	struct nfs_server *server = NFS_SERVER(inode);
+	const u32 bitmask[3] = { 0, 0, FATTR4_WORD2_SECURITY_LABEL };
+	struct nfs_setattrargs args = {
+		.fh             = NFS_FH(inode),
+		.iap            = &sattr,
+		.server		= server,
+		.bitmask	= bitmask,
+		.label		= ilabel,
+	};
+	struct nfs_setattrres res = {
+		.fattr		= fattr,
+		.label		= olabel,
+		.server		= server,
+	};
+	struct rpc_message msg = {
+		.rpc_proc       = &nfs4_procedures[NFSPROC4_CLNT_SETATTR],
+		.rpc_argp       = &args,
+		.rpc_resp       = &res,
+	};
+	unsigned long timestamp = jiffies;
+	int status;
+
+	memset(&sattr, 0, sizeof(struct iattr));
+
+	if (state != NULL) {
+		struct nfs_lockowner lockowner = {
+			.l_owner = current->files,
+			.l_pid = current->tgid,
+		};
+
+		msg.rpc_cred = state->owner->so_cred;
+		nfs4_select_rw_stateid(&args.stateid, state, FMODE_WRITE,
+				&lockowner);
+	} else if (nfs4_copy_delegation_stateid(&args.stateid, inode,
+				FMODE_WRITE)) {
+		/* Use that stateid */
+	} else
+		nfs4_stateid_copy(&args.stateid, &zero_stateid);
+
+	status = rpc_call_sync(server->client, &msg, 0);
+	if (status == 0 && state != NULL)
+		renew_lease(server, timestamp);
+	return status;
+}
+
+static int nfs4_do_set_security_label(struct inode *inode,
+		struct nfs4_label *ilabel,
+		struct nfs_fattr *fattr,
+		struct nfs4_label *olabel,
+		struct nfs4_state *state)
+{
+	struct nfs4_exception exception = { };
+	int err;
+
+	do {
+		err = nfs4_handle_exception(NFS_SERVER(inode),
+				_nfs4_do_set_security_label(inode, ilabel,
+				fattr, olabel, state),
+				&exception);
+	} while (exception.retry);
+	return err;
+}
+
+static int
+nfs4_set_security_label(struct dentry *dentry, const void *buf, size_t buflen)
+{
+	struct nfs4_label ilabel, *olabel = NULL;
+	struct nfs_fattr fattr;
+	struct rpc_cred *cred;
+	struct nfs_open_context *ctx;
+	struct nfs4_state *state = NULL;
+	struct inode *inode = dentry->d_inode;
+	int status;
+
+	if (!nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL))
+		return -EOPNOTSUPP;
+
+	nfs_fattr_init(&fattr);
+
+	ilabel.pi = 0;
+	ilabel.lfs = 0;
+	ilabel.label = (char *)buf;
+	ilabel.len = buflen;
+
+	cred = rpc_lookup_cred();
+	if (IS_ERR(cred))
+		return PTR_ERR(cred);
+
+	olabel = nfs4_label_alloc(GFP_KERNEL);
+	if (olabel == NULL) {
+		status = -ENOMEM;
+		goto out;
+	}
+
+	/* Search for an existing open(O_WRITE) file */
+	ctx = nfs_find_open_context(inode, cred, FMODE_WRITE);
+	if (ctx != NULL)
+		state = ctx->state;
+
+	status = nfs4_do_set_security_label(inode, &ilabel, &fattr, olabel,
+						state);
+	if (status == 0)
+		nfs_setsecurity(inode, &fattr, olabel);
+	if (ctx != NULL)
+		put_nfs_open_context(ctx);
+	nfs4_label_free(olabel);
+out:
+	put_rpccred(cred);
+	return status;
+}
+#endif	/* CONFIG_NFS_V4_SECURITY_LABEL */
+
+
 static int
 nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state)
 {
@@ -4352,7 +4622,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 	data->args.fhandle = &data->fh;
 	data->args.stateid = &data->stateid;
-	data->args.bitmask = server->cache_consistency_bitmask;
+	data->args.bitmask = server->cache_consistency_bitmask_nl;
 	nfs_copy_fh(&data->fh, NFS_FH(inode));
 	nfs4_stateid_copy(&data->stateid, stateid);
 	data->res.fattr = &data->fattr;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a9353d1..49f6d1a 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -102,12 +102,19 @@ static int nfs4_stat_to_errno(int);
 #define nfs4_path_maxsz		(1 + ((3 + NFS4_MAXPATHLEN) >> 2))
 #define nfs4_owner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
 #define nfs4_group_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+/* PI(4 bytes) + LFS(4 bytes) + 1(for null terminator?) + MAXLABELLEN */
+#define	nfs4_label_maxsz	(4 + 4 + 1 + XDR_QUADLEN(NFS4_MAXLABELLEN))
+#else
+#define	nfs4_label_maxsz	0
+#endif
 /* We support only one layout type per file system */
 #define decode_mdsthreshold_maxsz (1 + 1 + nfs4_fattr_bitmap_maxsz + 1 + 8)
 /* This is based on getfattr, which uses the most attributes: */
 #define nfs4_fattr_value_maxsz	(1 + (1 + 2 + 2 + 4 + 2 + 1 + 1 + 2 + 2 + \
 				3 + 3 + 3 + nfs4_owner_maxsz + \
-				nfs4_group_maxsz + decode_mdsthreshold_maxsz))
+				nfs4_group_maxsz + nfs4_label_maxsz + \
+				 decode_mdsthreshold_maxsz))
 #define nfs4_fattr_maxsz	(nfs4_fattr_bitmap_maxsz + \
 				nfs4_fattr_value_maxsz)
 #define decode_getattr_maxsz    (op_decode_hdr_maxsz + nfs4_fattr_maxsz)
@@ -115,6 +122,7 @@ static int nfs4_stat_to_errno(int);
 				 1 + 2 + 1 + \
 				nfs4_owner_maxsz + \
 				nfs4_group_maxsz + \
+				nfs4_label_maxsz + \
 				4 + 4)
 #define encode_savefh_maxsz     (op_encode_hdr_maxsz)
 #define decode_savefh_maxsz     (op_decode_hdr_maxsz)
@@ -192,9 +200,11 @@ static int nfs4_stat_to_errno(int);
 				 encode_stateid_maxsz + 3)
 #define decode_read_maxsz	(op_decode_hdr_maxsz + 2)
 #define encode_readdir_maxsz	(op_encode_hdr_maxsz + \
-				 2 + encode_verifier_maxsz + 5)
+				 2 + encode_verifier_maxsz + 5 + \
+				nfs4_label_maxsz)
 #define decode_readdir_maxsz	(op_decode_hdr_maxsz + \
-				 decode_verifier_maxsz)
+				 decode_verifier_maxsz + \
+				nfs4_label_maxsz + nfs4_fattr_maxsz)
 #define encode_readlink_maxsz	(op_encode_hdr_maxsz)
 #define decode_readlink_maxsz	(op_decode_hdr_maxsz + 1)
 #define encode_write_maxsz	(op_encode_hdr_maxsz + \
@@ -972,7 +982,9 @@ static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *ve
 	encode_opaque_fixed(xdr, verf->data, NFS4_VERIFIER_SIZE);
 }
 
-static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const struct nfs_server *server)
+static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
+				const struct nfs4_label *label,
+				const struct nfs_server *server)
 {
 	char owner_name[IDMAP_NAMESZ];
 	char owner_group[IDMAP_NAMESZ];
@@ -1022,6 +1034,8 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 		}
 		len += 4 + (XDR_QUADLEN(owner_grouplen) << 2);
 	}
+	if (label && (server->caps & NFS_CAP_SECURITY_LABEL))
+		len += 4 + 4 + 4 + (XDR_QUADLEN(label->len) << 2);
 	if (iap->ia_valid & ATTR_ATIME_SET)
 		len += 16;
 	else if (iap->ia_valid & ATTR_ATIME)
@@ -1078,6 +1092,13 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 		bmval1 |= FATTR4_WORD1_TIME_MODIFY_SET;
 		*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
 	}
+	if (label && (server->caps & NFS_CAP_SECURITY_LABEL)) {
+		bmval2 |= FATTR4_WORD2_SECURITY_LABEL;
+		*p++ = cpu_to_be32(label->lfs);
+		*p++ = cpu_to_be32(label->pi);
+		*p++ = cpu_to_be32(label->len);
+		p = xdr_encode_opaque_fixed(p, label->label, label->len);
+	}
 
 	/*
 	 * Now we backfill the bitmap and the attribute buffer length.
@@ -1144,7 +1165,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 	}
 
 	encode_string(xdr, create->name->len, create->name->name);
-	encode_attrs(xdr, create->attrs, create->server);
+	encode_attrs(xdr, create->attrs, create->label, create->server);
 }
 
 static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct compound_hdr *hdr)
@@ -1377,21 +1398,23 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 	switch(arg->open_flags & O_EXCL) {
 	case 0:
 		*p = cpu_to_be32(NFS4_CREATE_UNCHECKED);
-		encode_attrs(xdr, arg->u.attrs, arg->server);
+		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server);
 		break;
 	default:
 		clp = arg->server->nfs_client;
 		if (clp->cl_mvops->minor_version > 0) {
 			if (nfs4_has_persistent_session(clp)) {
 				*p = cpu_to_be32(NFS4_CREATE_GUARDED);
-				encode_attrs(xdr, arg->u.attrs, arg->server);
+				encode_attrs(xdr, arg->u.attrs, arg->label,
+						arg->server);
 			} else {
 				struct iattr dummy;
 
 				*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE4_1);
 				encode_nfs4_verifier(xdr, &arg->u.verifier);
 				dummy.ia_valid = 0;
-				encode_attrs(xdr, &dummy, arg->server);
+				encode_attrs(xdr, &dummy, arg->label,
+						arg->server);
 			}
 		} else {
 			*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
@@ -1570,20 +1593,43 @@ static void encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 	encode_op_hdr(xdr, OP_READDIR, decode_readdir_maxsz, hdr);
 	encode_uint64(xdr, readdir->cookie);
 	encode_nfs4_verifier(xdr, &readdir->verifier);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	p = reserve_space(xdr, 24);
+#else
 	p = reserve_space(xdr, 20);
+#endif
 	*p++ = cpu_to_be32(dircount);
 	*p++ = cpu_to_be32(readdir->count);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	*p++ = cpu_to_be32(3);
+#else
 	*p++ = cpu_to_be32(2);
-
+#endif
 	*p++ = cpu_to_be32(attrs[0] & readdir->bitmask[0]);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	*p++ = cpu_to_be32(attrs[1] & readdir->bitmask[1]);
+	*p = cpu_to_be32(readdir->bitmask[2]);
+#else
 	*p = cpu_to_be32(attrs[1] & readdir->bitmask[1]);
+#endif
 	memcpy(verf, readdir->verifier.data, sizeof(verf));
-	dprintk("%s: cookie = %Lu, verifier = %08x:%08x, bitmap = %08x:%08x\n",
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	dprintk("%s: cookie = %llu, verifier = %08x:%08x, bitmap = %08x:%08x:%08x\n",
+			__func__,
+			(unsigned long long)readdir->cookie,
+			verf[0], verf[1],
+			attrs[0] & readdir->bitmask[0],
+			attrs[1] & readdir->bitmask[1],
+			readdir->bitmask[2]);
+#else
+	dprintk("%s: cookie = %llu, verifier = %08x:%08x, bitmap = %08x:%08x\n",
 			__func__,
 			(unsigned long long)readdir->cookie,
 			verf[0], verf[1],
 			attrs[0] & readdir->bitmask[0],
 			attrs[1] & readdir->bitmask[1]);
+#endif
+
 }
 
 static void encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *readlink, struct rpc_rqst *req, struct compound_hdr *hdr)
@@ -1642,7 +1688,7 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 {
 	encode_op_hdr(xdr, OP_SETATTR, decode_setattr_maxsz, hdr);
 	encode_nfs4_stateid(xdr, &arg->stateid);
-	encode_attrs(xdr, arg->iap, server);
+	encode_attrs(xdr, arg->iap, arg->label, server);
 }
 
 static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclientid *setclientid, struct compound_hdr *hdr)
@@ -4060,6 +4106,67 @@ static int decode_attr_time_delta(struct xdr_stream *xdr, uint32_t *bitmap,
 	return status;
 }
 
+static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap,
+					struct nfs4_label *label)
+{
+	uint32_t pi = 0;
+	uint32_t lfs = 0;
+	__u32 len;
+	__be32 *p;
+	int status = 0;
+
+	if (unlikely(bitmap[2] & (FATTR4_WORD2_SECURITY_LABEL - 1U)))
+		return -EIO;
+	if (likely(bitmap[2] & FATTR4_WORD2_SECURITY_LABEL)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		lfs = be32_to_cpup(p++);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		pi = be32_to_cpup(p++);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		len = be32_to_cpup(p++);
+		p = xdr_inline_decode(xdr, len);
+		if (unlikely(!p))
+			goto out_overflow;
+		if (len < XDR_MAX_NETOBJ) {
+			if (label) {
+				nfs4_label_init(label);
+				if (label->len < len) {
+					printk(KERN_ERR
+						"%s(): label->len %d < len %d\n",
+						__func__, label->len, len);
+				} else {
+					memcpy(label->label, p, len);
+					label->len = len;
+					label->pi = pi;
+					label->lfs = lfs;
+					status = NFS_ATTR_FATTR_V4_SECURITY_LABEL;
+				}
+			} else {
+				printk("%s(): NULL label.\n", __func__);
+				dump_stack();
+				goto out_overflow;
+			}
+			bitmap[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
+		} else
+			printk(KERN_WARNING "%s: label too long (%u)!\n",
+					__func__, len);
+	}
+	if (label && label->label)
+		dprintk("%s: label=%s, len=%d, PI=%d, LFS=%d\n", __func__,
+			(char *)label->label, label->len, label->pi, label->lfs);
+	return status;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_attr_time_modify(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
 {
 	int status = 0;
@@ -4402,7 +4509,7 @@ out_overflow:
 
 static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		struct nfs_fattr *fattr, struct nfs_fh *fh,
-		struct nfs4_fs_locations *fs_loc,
+		struct nfs4_fs_locations *fs_loc, struct nfs4_label *label,
 		const struct nfs_server *server)
 {
 	int status;
@@ -4510,6 +4617,11 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 	if (status < 0)
 		goto xdr_error;
 
+	status = decode_attr_security_label(xdr, bitmap, label);
+	if (status < 0)
+		goto xdr_error;
+	fattr->valid |= status;
+
 xdr_error:
 	dprintk("%s: xdr returned %d\n", __func__, -status);
 	return status;
@@ -4517,7 +4629,7 @@ xdr_error:
 
 static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fattr,
 		struct nfs_fh *fh, struct nfs4_fs_locations *fs_loc,
-		const struct nfs_server *server)
+		struct nfs4_label *label, const struct nfs_server *server)
 {
 	unsigned int savep;
 	uint32_t attrlen,
@@ -4536,7 +4648,8 @@ static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fat
 	if (status < 0)
 		goto xdr_error;
 
-	status = decode_getfattr_attrs(xdr, bitmap, fattr, fh, fs_loc, server);
+	status = decode_getfattr_attrs(xdr, bitmap, fattr, fh, fs_loc,
+					label, server);
 	if (status < 0)
 		goto xdr_error;
 
@@ -4547,9 +4660,9 @@ xdr_error:
 }
 
 static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
-		const struct nfs_server *server)
+		struct nfs4_label *label, const struct nfs_server *server)
 {
-	return decode_getfattr_generic(xdr, fattr, NULL, NULL, server);
+	return decode_getfattr_generic(xdr, fattr, NULL, NULL, label, server);
 }
 
 /*
@@ -5883,7 +5996,7 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp,
 	status = decode_open_downgrade(xdr, res);
 	if (status != 0)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server);
+	decode_getfattr(xdr, res->fattr, res->label, res->server);
 out:
 	return status;
 }
@@ -5909,7 +6022,7 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_access(xdr, &res->supported, &res->access);
 	if (status != 0)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server);
+	decode_getfattr(xdr, res->fattr, res->label, res->server);
 out:
 	return status;
 }
@@ -5938,7 +6051,7 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_getfh(xdr, res->fh);
 	if (status)
 		goto out;
-	status = decode_getfattr(xdr, res->fattr, res->server);
+	status = decode_getfattr(xdr, res->fattr, res->label, res->server);
 out:
 	return status;
 }
@@ -5964,7 +6077,8 @@ static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp,
 		goto out;
 	status = decode_getfh(xdr, res->fh);
 	if (status == 0)
-		status = decode_getfattr(xdr, res->fattr, res->server);
+		status = decode_getfattr(xdr, res->fattr,
+						res->label, res->server);
 out:
 	return status;
 }
@@ -6055,7 +6169,7 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_restorefh(xdr);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server);
+	decode_getfattr(xdr, res->fattr, res->label, res->server);
 out:
 	return status;
 }
@@ -6084,7 +6198,7 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_getfh(xdr, res->fh);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server);
+	decode_getfattr(xdr, res->fattr, res->label, res->server);
 out:
 	return status;
 }
@@ -6116,7 +6230,7 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_getfattr(xdr, res->fattr, res->server);
+	status = decode_getfattr(xdr, res->fattr, res->label, res->server);
 out:
 	return status;
 }
@@ -6218,7 +6332,7 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	 * 	an ESTALE error. Shouldn't be a problem,
 	 * 	though, since fattr->valid will remain unset.
 	 */
-	decode_getfattr(xdr, res->fattr, res->server);
+	decode_getfattr(xdr, res->fattr, res->label, res->server);
 out:
 	return status;
 }
@@ -6249,7 +6363,7 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 		goto out;
 	if (res->access_request)
 		decode_access(xdr, &res->access_supported, &res->access_result);
-	decode_getfattr(xdr, res->f_attr, res->server);
+	decode_getfattr(xdr, res->f_attr, res->f_label, res->server);
 out:
 	return status;
 }
@@ -6299,7 +6413,7 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp,
 		goto out;
 	if (res->access_request)
 		decode_access(xdr, &res->access_supported, &res->access_result);
-	decode_getfattr(xdr, res->f_attr, res->server);
+	decode_getfattr(xdr, res->f_attr, NULL, res->server);
 out:
 	return status;
 }
@@ -6326,7 +6440,7 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp,
 	status = decode_setattr(xdr);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server);
+	decode_getfattr(xdr, res->fattr, res->label, res->server);
 out:
 	return status;
 }
@@ -6506,7 +6620,7 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	if (status)
 		goto out;
 	if (res->fattr)
-		decode_getfattr(xdr, res->fattr, res->server);
+		decode_getfattr(xdr, res->fattr, NULL, res->server);
 	if (!status)
 		status = res->count;
 out:
@@ -6687,7 +6801,7 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp,
 	status = decode_putfh(xdr);
 	if (status != 0)
 		goto out;
-	status = decode_getfattr(xdr, res->fattr, res->server);
+	status = decode_getfattr(xdr, res->fattr, res->label, res->server);
 	if (status != 0)
 		goto out;
 	status = decode_delegreturn(xdr);
@@ -6720,7 +6834,7 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req,
 	xdr_enter_page(xdr, PAGE_SIZE);
 	status = decode_getfattr_generic(xdr, &res->fs_locations->fattr,
 					 NULL, res->fs_locations,
-					 res->fs_locations->server);
+					 NULL, res->fs_locations->server);
 out:
 	return status;
 }
@@ -7001,7 +7115,7 @@ static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp,
 	status = decode_layoutcommit(xdr, rqstp, res);
 	if (status)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server);
+	decode_getfattr(xdr, res->fattr, NULL, res->server);
 out:
 	return status;
 }
@@ -7133,7 +7247,7 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		goto out_overflow;
 
 	if (decode_getfattr_attrs(xdr, bitmap, entry->fattr, entry->fh,
-				  NULL, entry->server) < 0)
+			NULL, entry->label, entry->server) < 0)
 		goto out_overflow;
 	if (entry->fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID)
 		entry->ino = entry->fattr->mounted_on_fileid;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 86442f4..5cf7ee5 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2419,8 +2419,21 @@ static int nfs_bdi_register(struct nfs_server *server)
 int nfs_set_sb_security(struct super_block *s, struct dentry *mntroot,
 			struct nfs_mount_info *mount_info)
 {
-	return security_sb_set_mnt_opts(s, &mount_info->parsed->lsm_opts,
-								0, NULL);
+	int error;
+	unsigned long kflags = 0, kflags_out = 0;
+	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL)
+		kflags |= SECURITY_LSM_NATIVE_LABELS;
+
+	error = security_sb_set_mnt_opts(s, &mount_info->parsed->lsm_opts,
+						kflags, &kflags_out);
+	if (error)
+		goto err;
+
+	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL &&
+		!(kflags_out & SECURITY_LSM_NATIVE_LABELS))
+		NFS_SB(s)->caps &= ~NFS_CAP_SECURITY_LABEL;
+err:
+	return error;
 }
 EXPORT_SYMBOL_GPL(nfs_set_sb_security);
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 9082979..822ca73 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -199,6 +199,7 @@ struct nfs_inode {
 #define NFS_INO_INVALID_ACL	0x0010		/* cached acls are invalid */
 #define NFS_INO_REVAL_PAGECACHE	0x0020		/* must revalidate pagecache */
 #define NFS_INO_REVAL_FORCED	0x0040		/* force revalidation ignoring a delegation */
+#define NFS_INO_INVALID_LABEL	0x0080		/* cached label is invalid */
 
 /*
  * Bit offsets in flags field
@@ -344,6 +345,8 @@ extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
 extern int nfs_setattr(struct dentry *, struct iattr *);
 extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr);
+extern void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
+				struct nfs4_label *label);
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, fmode_t mode);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index e6ed3c2..2a4f1d4 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -145,11 +145,18 @@ struct nfs_server {
 	u32			attr_bitmask[3];/* V4 bitmask representing the set
 						   of attributes supported on this
 						   filesystem */
+	u32			attr_bitmask_nl[3];
+						/* V4 bitmask representing the
+						   set of attributes supported
+						   on this filesystem excluding
+						   the label support bit. */
 	u32			cache_consistency_bitmask[3];
 						/* V4 bitmask representing the subset
 						   of change attribute, size, ctime
 						   and mtime attributes supported by
 						   the server */
+	u32			cache_consistency_bitmask_nl[3];
+						/* As above, excluding label. */
 	u32			acl_bitmask;	/* V4 bitmask representing the ACEs
 						   that are supported on this
 						   filesystem */
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 8f233ff..3e1b84d 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2876,7 +2876,10 @@ static void selinux_inode_post_setxattr(struct dentry *dentry, const char *name,
 		return;
 	}
 
+	isec->sclass = inode_mode_to_security_class(inode->i_mode);
 	isec->sid = newsid;
+	isec->initialized = 1;
+
 	return;
 }
 
@@ -2964,6 +2967,7 @@ static int selinux_inode_setsecurity(struct inode *inode, const char *name,
 	if (rc)
 		return rc;
 
+	isec->sclass = inode_mode_to_security_class(inode->i_mode);
 	isec->sid = newsid;
 	isec->initialized = 1;
 	return 0;
-- 
1.8.1

