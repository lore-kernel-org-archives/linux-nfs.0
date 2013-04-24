Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39354 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757961Ab3DXUXM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 16:23:12 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 12/17] NFS: Add label lifecycle management
Date: Wed, 24 Apr 2013 16:17:58 -0400
Message-Id: <1366834683-29075-13-git-send-email-SteveD@redhat.com>
In-Reply-To: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

>From David Quigley <dpquigl@davequigley.com>

This patch adds the lifecycle management for the security label structure
introduced in an earlier patch. The label is not used yet but allocations and
freeing of the structure is handled.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
---
 fs/nfs/dir.c      | 23 ++++++++++++-
 fs/nfs/inode.c    | 15 +++++++--
 fs/nfs/nfs4proc.c | 98 +++++++++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 126 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e85753b..b911195 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -585,10 +585,16 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 	if (entry.fh == NULL || entry.fattr == NULL)
 		goto out;
 
+	entry.label = nfs4_label_alloc(NFS_SERVER(inode), GFP_NOWAIT);
+	if (IS_ERR(entry.label)) {
+		status = PTR_ERR(entry.label);
+		goto out;
+	}
+
 	array = nfs_readdir_get_array(page);
 	if (IS_ERR(array)) {
 		status = PTR_ERR(array);
-		goto out;
+		goto out_label_free;
 	}
 	memset(array, 0, sizeof(struct nfs_cache_array));
 	array->eof_index = -1;
@@ -614,6 +620,8 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 	nfs_readdir_free_large_page(pages_ptr, pages, array_size);
 out_release_array:
 	nfs_readdir_release_array(page);
+out_label_free:
+	nfs4_label_free(entry.label);
 out:
 	nfs_free_fattr(entry.fattr);
 	nfs_free_fhandle(entry.fh);
@@ -1083,6 +1091,10 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	if (fhandle == NULL || fattr == NULL)
 		goto out_error;
 
+	label = nfs4_label_alloc(NFS_SERVER(inode), GFP_NOWAIT);
+	if (IS_ERR(label))
+		goto out_error;
+
 	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, label);
 	if (error)
 		goto out_bad;
@@ -1093,6 +1105,8 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
+	nfs4_label_free(label);
+
 out_set_verifier:
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
  out_valid:
@@ -1109,6 +1123,7 @@ out_zap_parent:
  out_bad:
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
+	nfs4_label_free(label);
 	nfs_mark_for_revalidate(dir);
 	if (inode && S_ISDIR(inode->i_mode)) {
 		/* Purge readdir caches. */
@@ -1129,6 +1144,7 @@ out_zap_parent:
 out_error:
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
+	nfs4_label_free(label);
 	dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%s/%s) lookup returned error %d\n",
 			__func__, dentry->d_parent->d_name.name,
@@ -1284,6 +1300,10 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
 	if (fhandle == NULL || fattr == NULL)
 		goto out;
 
+	label = nfs4_label_alloc(NFS_SERVER(dir), GFP_NOWAIT);
+	if (IS_ERR(label))
+		goto out;
+
 	parent = dentry->d_parent;
 	/* Protect against concurrent sillydeletes */
 	nfs_block_sillyrename(parent);
@@ -1312,6 +1332,7 @@ no_entry:
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 out_unblock_sillyrename:
 	nfs_unblock_sillyrename(parent);
+	nfs4_label_free(label);
 out:
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5965c8b..4e92dfb 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -834,6 +834,13 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		goto out;
 
 	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
+
+	label = nfs4_label_alloc(NFS_SERVER(inode), GFP_KERNEL);
+	if (IS_ERR(label)) {
+		status = PTR_ERR(label);
+		goto out;
+	}
+
 	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), fattr, label);
 	if (status != 0) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) getattr failed, error=%d\n",
@@ -844,7 +851,7 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 			if (!S_ISDIR(inode->i_mode))
 				set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
 		}
-		goto out;
+		goto err_out;
 	}
 
 	status = nfs_refresh_inode(inode, fattr, label);
@@ -852,7 +859,7 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) refresh failed, error=%d\n",
 			 inode->i_sb->s_id,
 			 (long long)NFS_FILEID(inode), status);
-		goto out;
+		goto err_out;
 	}
 
 	if (nfsi->cache_validity & NFS_INO_INVALID_ACL)
@@ -862,7 +869,9 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode));
 
- out:
+err_out:
+	nfs4_label_free(label);
+out:
 	nfs_free_fattr(fattr);
 	return status;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e711552..56f24c0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -788,9 +788,14 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p = kzalloc(sizeof(*p), gfp_mask);
 	if (p == NULL)
 		goto err;
+
+	p->f_label = nfs4_label_alloc(server, gfp_mask);
+	if (IS_ERR(p->f_label))
+		goto err_free_p;
+
 	p->o_arg.seqid = nfs_alloc_seqid(&sp->so_seqid, gfp_mask);
 	if (p->o_arg.seqid == NULL)
-		goto err_free;
+		goto err_free_label;
 	nfs_sb_active(dentry->d_sb);
 	p->dentry = dget(dentry);
 	p->dir = parent;
@@ -833,7 +838,10 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	nfs4_init_opendata_res(p);
 	kref_init(&p->kref);
 	return p;
-err_free:
+
+err_free_label:
+	nfs4_label_free(p->f_label);
+err_free_p:
 	kfree(p);
 err:
 	dput(parent);
@@ -850,6 +858,9 @@ static void nfs4_opendata_free(struct kref *kref)
 	if (p->state != NULL)
 		nfs4_put_open_state(p->state);
 	nfs4_put_state_owner(p->owner);
+
+	nfs4_label_free(p->f_label);
+
 	dput(p->dir);
 	dput(p->dentry);
 	nfs_sb_deactive(sb);
@@ -1931,10 +1942,18 @@ static int _nfs4_do_open(struct inode *dir,
 	if (opendata == NULL)
 		goto err_put_state_owner;
 
+	if (label) {
+		olabel = nfs4_label_alloc(server, GFP_KERNEL);
+		if (IS_ERR(olabel)) {
+			status = PTR_ERR(olabel);
+			goto err_opendata_put;
+		}
+	}
+
 	if (ctx_th && server->attr_bitmask[2] & FATTR4_WORD2_MDSTHRESHOLD) {
 		opendata->f_attr.mdsthreshold = pnfs_mdsthreshold_alloc();
 		if (!opendata->f_attr.mdsthreshold)
-			goto err_opendata_put;
+			goto err_free_label;
 		opendata->o_arg.open_bitmap = &nfs4_pnfs_open_bitmap[0];
 	}
 	if (dentry->d_inode != NULL)
@@ -1942,7 +1961,7 @@ static int _nfs4_do_open(struct inode *dir,
 
 	status = _nfs4_open_and_get_state(opendata, fmode, flags, &state);
 	if (status != 0)
-		goto err_opendata_put;
+		goto err_free_label;
 
 	if (opendata->o_arg.open_flags & O_EXCL) {
 		nfs4_exclusive_attrset(opendata, sattr);
@@ -1963,10 +1982,14 @@ static int _nfs4_do_open(struct inode *dir,
 		kfree(opendata->f_attr.mdsthreshold);
 	opendata->f_attr.mdsthreshold = NULL;
 
+	nfs4_label_free(olabel);
+
 	nfs4_opendata_put(opendata);
 	nfs4_put_state_owner(sp);
 	*res = state;
 	return 0;
+err_free_label:
+	nfs4_label_free(olabel);
 err_opendata_put:
 	kfree(opendata->f_attr.mdsthreshold);
 	nfs4_opendata_put(opendata);
@@ -2532,16 +2555,23 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *mntfh,
 		return error;
 	}
 
+	label = nfs4_label_alloc(server, GFP_KERNEL);
+	if (IS_ERR(label))
+		return PTR_ERR(label);
+
 	error = nfs4_proc_getattr(server, mntfh, fattr, label);
 	if (error < 0) {
 		dprintk("nfs4_get_root: getattr error = %d\n", -error);
-		return error;
+		goto err_free_label;
 	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_FSID &&
 	    !nfs_fsid_equal(&server->fsid, &fattr->fsid))
 		memcpy(&server->fsid, &fattr->fsid, sizeof(server->fsid));
 
+err_free_label:
+	nfs4_label_free(label);
+
 	return error;
 }
 
@@ -2647,6 +2677,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	struct inode *inode = dentry->d_inode;
 	struct rpc_cred *cred = NULL;
 	struct nfs4_state *state = NULL;
+	struct nfs4_label *label = NULL;
 	int status;
 
 	if (pnfs_ld_layoutret_on_setattr(inode))
@@ -2673,9 +2704,15 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		}
 	}
 
-	status = nfs4_do_setattr(inode, cred, fattr, sattr, state, NULL, NULL);
+	label = nfs4_label_alloc(NFS_SERVER(inode), GFP_KERNEL);
+	if (IS_ERR(label))
+		return PTR_ERR(label);
+
+	status = nfs4_do_setattr(inode, cred, fattr, sattr, state, NULL, label);
 	if (status == 0)
 		nfs_setattr_update_inode(inode, sattr);
+
+	nfs4_label_free(label);
 	return status;
 }
 
@@ -2830,11 +2867,21 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	if (res.fattr == NULL)
 		return -ENOMEM;
 
+	res.label = nfs4_label_alloc(server, GFP_KERNEL);
+	if (IS_ERR(res.label)) {
+		status = PTR_ERR(res.label);
+		goto out;
+	}
+
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (!status) {
 		nfs_access_set_mask(entry, res.access);
 		nfs_refresh_inode(inode, res.fattr, res.label);
 	}
+
+	nfs4_label_free(res.label);
+
+out:
 	nfs_free_fattr(res.fattr);
 	return status;
 }
@@ -3059,12 +3106,33 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		.rpc_resp = &res,
 	};
 	int status = -ENOMEM;
+
+
+	if (server->caps & NFS_CAP_SECURITY_LABEL) {
+		res.old_label = nfs4_label_alloc(server, GFP_NOWAIT);
+		if (IS_ERR(res.old_label)) {
+			status = PTR_ERR(res.old_label);
+			goto out;
+		}
+		res.new_label = nfs4_label_alloc(server, GFP_NOWAIT);
+		if (IS_ERR(res.new_label)) {
+			status = PTR_ERR(res.new_label);
+			nfs4_label_free(res.old_label);
+			goto out;
+		}
+	}
+
 	
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(old_dir, &res.old_cinfo);
 		update_changeattr(new_dir, &res.new_cinfo);
 	}
+
+	nfs4_label_free(res.old_label);
+	nfs4_label_free(res.new_label);
+
+out:
 	return status;
 }
 
@@ -3106,11 +3174,21 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 	if (res.fattr == NULL)
 		goto out;
 
+	res.label = nfs4_label_alloc(server, GFP_KERNEL);
+	if (IS_ERR(res.label)) {
+		status = PTR_ERR(res.label);
+		goto out;
+	}
+
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(inode, res.fattr, res.label);
 	}
+
+
+	nfs4_label_free(res.label);
+
 out:
 	nfs_free_fattr(res.fattr);
 	return status;
@@ -3146,6 +3224,10 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 	if (data != NULL) {
 		struct nfs_server *server = NFS_SERVER(dir);
 
+		data->label = nfs4_label_alloc(server, GFP_KERNEL);
+		if (IS_ERR(data->label))
+			goto out_free;
+
 		data->msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CREATE];
 		data->msg.rpc_argp = &data->arg;
 		data->msg.rpc_resp = &data->res;
@@ -3162,6 +3244,9 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 		nfs_fattr_init(data->res.fattr);
 	}
 	return data;
+out_free:
+	kfree(data);
+	return NULL;
 }
 
 static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_createdata *data)
@@ -3177,6 +3262,7 @@ static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_
 
 static void nfs4_free_createdata(struct nfs4_createdata *data)
 {
+	nfs4_label_free(data->label);
 	kfree(data);
 }
 
-- 
1.8.1.4

