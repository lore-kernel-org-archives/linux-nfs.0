Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753025Ab2LQPnS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 10:43:18 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 10/13] NFS: Add label lifecycle management
Date: Mon, 17 Dec 2012 10:43:08 -0500
Message-Id: <1355758991-30049-11-git-send-email-steved@redhat.com>
In-Reply-To: <1355758991-30049-1-git-send-email-steved@redhat.com>
References: <1355758991-30049-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Dave Quigley <dpquigl@taiga.selinuxproject.org>

>From David Quigley <dpquigl@davequigley.com>

This patch adds the lifecycle management for the security label structure
introduced in an earlier patch. The label is not used yet but allocations and
freeing of the structure is handled.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
---
 fs/nfs/dir.c      |  30 +++++++++++++-
 fs/nfs/getroot.c  |   1 -
 fs/nfs/inode.c    |  13 ++++++
 fs/nfs/nfs4proc.c | 116 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 156 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 1339e44..561d2fb 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -581,7 +581,8 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 	entry.fh = nfs_alloc_fhandle();
 	entry.fattr = nfs_alloc_fattr();
 	entry.server = NFS_SERVER(inode);
-	if (entry.fh == NULL || entry.fattr == NULL)
+	entry.label = nfs4_label_alloc(GFP_NOWAIT);
+	if (entry.fh == NULL || entry.fattr == NULL || entry.label == NULL)
 		goto out;
 
 	array = nfs_readdir_get_array(page);
@@ -616,6 +617,7 @@ out_release_array:
 out:
 	nfs_free_fattr(entry.fattr);
 	nfs_free_fhandle(entry.fh);
+	nfs4_label_free(entry.label);
 	return status;
 }
 
@@ -1077,6 +1079,14 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	if (fhandle == NULL || fattr == NULL)
 		goto out_error;
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		label = nfs4_label_alloc(GFP_NOWAIT);
+		if (label == NULL)
+			goto out_error;
+	}
+#endif
+
 	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, label);
 	if (error)
 		goto out_bad;
@@ -1087,6 +1097,12 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL))
+		nfs4_label_free(label);
+#endif
+
 out_set_verifier:
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
  out_valid:
@@ -1123,6 +1139,7 @@ out_zap_parent:
 out_error:
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
+	nfs4_label_free(label);
 	dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%s/%s) lookup returned error %d\n",
 			__func__, dentry->d_parent->d_name.name,
@@ -1235,6 +1252,13 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
 	if (fhandle == NULL || fattr == NULL)
 		goto out;
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		label = nfs4_label_alloc(GFP_NOWAIT);
+		if (label == NULL)
+			goto out;
+	}
+#endif
 	parent = dentry->d_parent;
 	/* Protect against concurrent sillydeletes */
 	nfs_block_sillyrename(parent);
@@ -1264,6 +1288,10 @@ no_entry:
 out_unblock_sillyrename:
 	nfs_unblock_sillyrename(parent);
 out:
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL))
+		nfs4_label_free(label);
+#endif
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
 	return res;
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 3b68bb6..14bd667 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -75,7 +75,6 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh,
 	struct nfs_fsinfo fsinfo;
 	struct dentry *ret;
 	struct inode *inode;
-	struct nfs4_label *label = NULL;
 	void *name = kstrdup(devname, GFP_KERNEL);
 	int error;
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index daca08c..ab08d0d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -835,6 +835,15 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		goto out;
 
 	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL)) {
+		label = nfs4_label_alloc(GFP_KERNEL);
+		if (label == NULL) {
+			status = -ENOMEM;
+			goto out;
+		}
+	}
+#endif
 	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), fattr, label);
 	if (status != 0) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) getattr failed, error=%d\n",
@@ -864,6 +873,10 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		(long long)NFS_FILEID(inode));
 
  out:
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL))
+		nfs4_label_free(label);
+#endif
 	nfs_free_fattr(fattr);
 	return status;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8e0378c..4ab2738 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -865,9 +865,16 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p = kzalloc(sizeof(*p), gfp_mask);
 	if (p == NULL)
 		goto err;
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		p->f_label = nfs4_label_alloc(gfp_mask);
+		if (p->f_label == NULL)
+			goto err_free_p;
+	}
+#endif
 	p->o_arg.seqid = nfs_alloc_seqid(&sp->so_seqid, gfp_mask);
 	if (p->o_arg.seqid == NULL)
-		goto err_free;
+		goto err_free_label;
 	nfs_sb_active(dentry->d_sb);
 	p->dentry = dget(dentry);
 	p->dir = parent;
@@ -910,7 +917,13 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	nfs4_init_opendata_res(p);
 	kref_init(&p->kref);
 	return p;
-err_free:
+
+err_free_label:
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL)
+		nfs4_label_free(p->f_label);
+#endif
+err_free_p:
 	kfree(p);
 err:
 	dput(parent);
@@ -927,6 +940,10 @@ static void nfs4_opendata_free(struct kref *kref)
 	if (p->state != NULL)
 		nfs4_put_open_state(p->state);
 	nfs4_put_state_owner(p->owner);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (p->o_arg.server->caps & NFS_CAP_SECURITY_LABEL)
+		nfs4_label_free(p->f_label);
+#endif
 	dput(p->dir);
 	dput(p->dentry);
 	nfs_sb_deactive(sb);
@@ -1998,6 +2015,16 @@ static int _nfs4_do_open(struct inode *dir,
 	if (opendata == NULL)
 		goto err_put_state_owner;
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (label && nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
+		olabel = nfs4_label_alloc(GFP_KERNEL);
+		if (olabel == NULL) {
+			status = -ENOMEM;
+			goto err_opendata_put;
+		}
+	}
+#endif
+
 	if (ctx_th && server->attr_bitmask[2] & FATTR4_WORD2_MDSTHRESHOLD) {
 		opendata->f_attr.mdsthreshold = pnfs_mdsthreshold_alloc();
 		if (!opendata->f_attr.mdsthreshold)
@@ -2041,6 +2068,10 @@ static int _nfs4_do_open(struct inode *dir,
 		kfree(opendata->f_attr.mdsthreshold);
 	opendata->f_attr.mdsthreshold = NULL;
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL))
+		nfs4_label_free(olabel);
+#endif
 	nfs4_opendata_put(opendata);
 	nfs4_put_state_owner(sp);
 	*res = state;
@@ -2607,6 +2638,12 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *mntfh,
 		return error;
 	}
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	label = nfs4_label_alloc(GFP_KERNEL);
+	if (label == NULL)
+		return -ENOMEM;
+#endif
+
 	error = nfs4_proc_getattr(server, mntfh, fattr, label);
 	if (error < 0) {
 		dprintk("nfs4_get_root: getattr error = %d\n", -error);
@@ -2617,6 +2654,11 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *mntfh,
 	    !nfs_fsid_equal(&server->fsid, &fattr->fsid))
 		memcpy(&server->fsid, &fattr->fsid, sizeof(server->fsid));
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL)
+		nfs4_label_free(label);
+#endif
+
 	return error;
 }
 
@@ -2728,6 +2770,10 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	if (pnfs_ld_layoutret_on_setattr(inode))
 		pnfs_return_layout(inode);
 
+	olabel = nfs4_label_alloc(GFP_KERNEL);
+	if (olabel == NULL)
+		return -ENOMEM;
+
 	nfs_fattr_init(fattr);
 	
 	/* Deal with open(O_TRUNC) */
@@ -2905,12 +2951,27 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	res.fattr = nfs_alloc_fattr();
 	if (res.fattr == NULL)
 		return -ENOMEM;
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		res.label = nfs4_label_alloc(GFP_KERNEL);
+		if (res.label == NULL) {
+			status = -ENOMEM;
+			goto out;
+		}
+	}
+#endif
 
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (!status) {
 		nfs_access_set_mask(entry, res.access);
 		nfs_refresh_inode(inode, res.fattr, res.label);
 	}
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL)
+		nfs4_label_free(res.label);
+#endif
+out:
 	nfs_free_fattr(res.fattr);
 	return status;
 }
@@ -3034,6 +3095,7 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
 	if (status == 0)
 		update_changeattr(dir, &res.cinfo);
+
 	return status;
 }
 
@@ -3079,6 +3141,7 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
 	update_changeattr(dir, &res->cinfo);
+
 	return 1;
 }
 
@@ -3139,12 +3202,33 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		.rpc_resp = &res,
 	};
 	int status = -ENOMEM;
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		res.old_label = nfs4_label_alloc(GFP_NOWAIT);
+		if (res.old_label == NULL)
+			goto out;
+		res.new_label = nfs4_label_alloc(GFP_NOWAIT);
+		if (res.new_label == NULL) {
+			nfs4_label_free(res.old_label);
+			goto out;
+		}
+	}
+#endif
 	
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(old_dir, &res.old_cinfo);
 		update_changeattr(new_dir, &res.new_cinfo);
 	}
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		nfs4_label_free(res.old_label);
+		nfs4_label_free(res.new_label);
+	}
+#endif
+out:
 	return status;
 }
 
@@ -3186,11 +3270,25 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 	if (res.fattr == NULL)
 		goto out;
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		res.label = nfs4_label_alloc(GFP_KERNEL);
+		if (res.label == NULL)
+			goto out;
+	}
+#endif
+
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(inode, res.fattr, res.label);
 	}
+
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (server->caps & NFS_CAP_SECURITY_LABEL)
+		nfs4_label_free(res.label);
+#endif
+
 out:
 	nfs_free_fattr(res.fattr);
 	return status;
@@ -3226,6 +3324,13 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 	if (data != NULL) {
 		struct nfs_server *server = NFS_SERVER(dir);
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+		if (server->caps & NFS_CAP_SECURITY_LABEL) {
+			data->label = nfs4_label_alloc(GFP_KERNEL);
+			if (data->label == NULL)
+				goto out_free;
+		}
+#endif
 		data->msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CREATE];
 		data->msg.rpc_argp = &data->arg;
 		data->msg.rpc_resp = &data->res;
@@ -3242,6 +3347,9 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 		nfs_fattr_init(data->res.fattr);
 	}
 	return data;
+out_free:
+	kfree(data);
+	return NULL;
 }
 
 static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_createdata *data)
@@ -3257,6 +3365,10 @@ static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_
 
 static void nfs4_free_createdata(struct nfs4_createdata *data)
 {
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+	if (data->arg.server->caps & NFS_CAP_SECURITY_LABEL)
+		nfs4_label_free(data->label);
+#endif
 	kfree(data);
 }
 
-- 
1.7.11.7

