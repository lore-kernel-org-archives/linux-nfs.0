Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11425 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751687Ab3AWTbv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 14:31:51 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
CC: David Quigley <selinux@davequigley.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/14] NFS: Add label lifecycle management
Date: Wed, 23 Jan 2013 19:31:49 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA918333623@sacexcmbx05-prd.hq.netapp.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
	 <1358862042-27520-11-git-send-email-steved@redhat.com>
In-Reply-To: <1358862042-27520-11-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
> From: Dave Quigley <dpquigl@taiga.selinuxproject.org>
> 
> >From David Quigley <dpquigl@davequigley.com>
> 
> This patch adds the lifecycle management for the security label structure
> introduced in an earlier patch. The label is not used yet but allocations and
> freeing of the structure is handled.
> 
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> ---
>  fs/nfs/dir.c           |  30 ++++++++++++++
>  fs/nfs/getroot.c       |   3 +-
>  fs/nfs/inode.c         |  15 ++++++-
>  fs/nfs/nfs4proc.c      | 105 +++++++++++++++++++++++++++++++++++++++++++++++--
>  include/linux/nfs_fs.h |   4 +-
>  5 files changed, 150 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 7003931..d01fd1f 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -585,6 +585,12 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
>  	if (entry.fh == NULL || entry.fattr == NULL)
>  		goto out;
>  
> +	entry.label = nfs4_label_alloc(GFP_NOWAIT);

Needs a check for NFS_CAP_SECURITY_LABEL. See comment below.

> +	if (NFS4_LABEL_ERR(entry.label)) {
> +		status = PTR_ERR(entry.label);
> +		goto out;
> +	}
> +
>  	array = nfs_readdir_get_array(page);
>  	if (IS_ERR(array)) {
>  		status = PTR_ERR(array);
> @@ -617,6 +623,7 @@ out_release_array:
>  out:
>  	nfs_free_fattr(entry.fattr);
>  	nfs_free_fhandle(entry.fh);
> +	nfs4_label_free(entry.label);
>  	return status;
>  }
>  
> @@ -1083,6 +1090,12 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
>  	if (fhandle == NULL || fattr == NULL)
>  		goto out_error;
>  
> +	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {

Why not add this to nfs4_label_alloc()? ...or at least add it as a
wrapper so that we don't do allocations in the non-labeled NFS case.

> +		label = nfs4_label_alloc(GFP_NOWAIT);
> +		if (NFS4_LABEL_ERR(label))

Why the special error checking macro? Just have nfs4_label_alloc()
return a standard ERR_PTR()...

> +			goto out_error;
> +	}
> +
>  	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, label);
>  	if (error)
>  		goto out_bad;
> @@ -1093,6 +1106,12 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
>  
>  	nfs_free_fattr(fattr);
>  	nfs_free_fhandle(fhandle);
> +
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL

Please eliminate the inlined #ifdef

> +	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL))
> +		nfs4_label_free(label);

Also note that it would be better to just have nfs4_label_free() check
if label != NULL instead of using the capability check.

> +#endif
> +
>  out_set_verifier:
>  	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
>   out_valid:
> @@ -1129,6 +1148,7 @@ out_zap_parent:
>  out_error:
>  	nfs_free_fattr(fattr);
>  	nfs_free_fhandle(fhandle);
> +	nfs4_label_free(label);
>  	dput(parent);
>  	dfprintk(LOOKUPCACHE, "NFS: %s(%s/%s) lookup returned error %d\n",
>  			__func__, dentry->d_parent->d_name.name,
> @@ -1244,6 +1264,12 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
>  	if (fhandle == NULL || fattr == NULL)
>  		goto out;
>  
> +	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {

See comment above...

> +		label = nfs4_label_alloc(GFP_NOWAIT);
> +		if (NFS4_LABEL_ERR(label))
> +			goto out;
> +	}
> +
>  	parent = dentry->d_parent;
>  	/* Protect against concurrent sillydeletes */
>  	nfs_block_sillyrename(parent);
> @@ -1273,6 +1299,10 @@ no_entry:
>  out_unblock_sillyrename:
>  	nfs_unblock_sillyrename(parent);
>  out:
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL))
> +		nfs4_label_free(label);
> +#endif

See comments above...

>  	nfs_free_fattr(fattr);
>  	nfs_free_fhandle(fhandle);
>  	return res;
> diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
> index 08e14d3..14bd667 100644
> --- a/fs/nfs/getroot.c
> +++ b/fs/nfs/getroot.c
> @@ -75,7 +75,6 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh,
>  	struct nfs_fsinfo fsinfo;
>  	struct dentry *ret;
>  	struct inode *inode;
> -	struct nfs4_label *label = NULL;

Ummm.... Couldn't this simply be squashed into 9/14?

>  	void *name = kstrdup(devname, GFP_KERNEL);
>  	int error;
>  
> @@ -96,7 +95,7 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh,
>  		goto out;
>  	}
>  
> -	inode = nfs_fhget(sb, mntfh, fsinfo.fattr, label);
> +	inode = nfs_fhget(sb, mntfh, fsinfo.fattr, NULL);
>  	if (IS_ERR(inode)) {
>  		dprintk("nfs_get_root: get root inode failed\n");
>  		ret = ERR_CAST(inode);
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 269ba8f..30ce1e0 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -262,7 +262,7 @@ struct nfs4_label *nfs4_label_alloc(gfp_t flags)
>  
>  	label = kzalloc(sizeof(struct nfs4_label) + NFS4_MAXLABELLEN, flags);
>  	if (label == NULL)
> -		return NULL;
> +		return ERR_PTR(-ENOMEM);
>  
>  	label->label = (void *)(label + 1);
>  	label->len = NFS4_MAXLABELLEN;
> @@ -847,6 +847,15 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
>  		goto out;
>  
>  	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
> +
> +	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL)) {

See above

> +		label = nfs4_label_alloc(GFP_KERNEL);
> +		if (NFS4_LABEL_ERR(label)) {
> +			status = -ENOMEM;
> +			goto out;
> +		}
> +	}
> +
>  	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), fattr, label);
>  	if (status != 0) {
>  		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) getattr failed, error=%d\n",
> @@ -876,6 +885,10 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
>  		(long long)NFS_FILEID(inode));
>  
>   out:
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL))
> +		nfs4_label_free(label);
> +#endif

See above...

>  	nfs_free_fattr(fattr);
>  	return status;
>  }
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 4aeb71e..d08f033 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -790,9 +790,16 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
>  	p = kzalloc(sizeof(*p), gfp_mask);
>  	if (p == NULL)
>  		goto err;
> +
> +	if (server->caps & NFS_CAP_SECURITY_LABEL) {

See above...
> +		p->f_label = nfs4_label_alloc(gfp_mask);
> +		if (NFS4_LABEL_ERR(p->f_label))
> +			goto err_free_p;
> +	}
> +
>  	p->o_arg.seqid = nfs_alloc_seqid(&sp->so_seqid, gfp_mask);
>  	if (p->o_arg.seqid == NULL)
> -		goto err_free;
> +		goto err_free_label;
>  	nfs_sb_active(dentry->d_sb);
>  	p->dentry = dget(dentry);
>  	p->dir = parent;
> @@ -835,7 +842,11 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
>  	nfs4_init_opendata_res(p);
>  	kref_init(&p->kref);
>  	return p;
> -err_free:
> +
> +err_free_label:
> +	if (server->caps & NFS_CAP_SECURITY_LABEL)
> +		nfs4_label_free(p->f_label);

See above

> +err_free_p:
>  	kfree(p);
>  err:
>  	dput(parent);
> @@ -852,6 +863,10 @@ static void nfs4_opendata_free(struct kref *kref)
>  	if (p->state != NULL)
>  		nfs4_put_open_state(p->state);
>  	nfs4_put_state_owner(p->owner);
> +
> +	if (p->o_arg.server->caps & NFS_CAP_SECURITY_LABEL)
> +		nfs4_label_free(p->f_label);

See above...

> +
>  	dput(p->dir);
>  	dput(p->dentry);
>  	nfs_sb_deactive(sb);
> @@ -1890,6 +1905,14 @@ static int _nfs4_do_open(struct inode *dir,
>  	if (opendata == NULL)
>  		goto err_put_state_owner;
>  
> +	if (label && nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {

See above...
> +		olabel = nfs4_label_alloc(GFP_KERNEL);
> +		if (NFS4_LABEL_ERR(olabel)) {
> +			status = -ENOMEM;
> +			goto err_opendata_put;
> +		}
> +	}
> +
>  	if (ctx_th && server->attr_bitmask[2] & FATTR4_WORD2_MDSTHRESHOLD) {
>  		opendata->f_attr.mdsthreshold = pnfs_mdsthreshold_alloc();
>  		if (!opendata->f_attr.mdsthreshold)
> @@ -1933,6 +1956,9 @@ static int _nfs4_do_open(struct inode *dir,
>  		kfree(opendata->f_attr.mdsthreshold);
>  	opendata->f_attr.mdsthreshold = NULL;
>  
> +	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL))
> +		nfs4_label_free(olabel);
> +
See above...

>  	nfs4_opendata_put(opendata);
>  	nfs4_put_state_owner(sp);
>  	*res = state;
> @@ -2500,6 +2526,11 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *mntfh,
>  		return error;
>  	}
>  
> +	if (server->caps & NFS_CAP_SECURITY_LABEL) {

....

> +		label = nfs4_label_alloc(GFP_KERNEL);
> +		if (NFS4_LABEL_ERR(label))
> +			return -ENOMEM;
> +	}
>  	error = nfs4_proc_getattr(server, mntfh, fattr, label);
>  	if (error < 0) {
>  		dprintk("nfs4_get_root: getattr error = %d\n", -error);
> @@ -2510,6 +2541,9 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *mntfh,
>  	    !nfs_fsid_equal(&server->fsid, &fattr->fsid))
>  		memcpy(&server->fsid, &fattr->fsid, sizeof(server->fsid));
>  
> +	if (server->caps & NFS_CAP_SECURITY_LABEL)
> +		nfs4_label_free(label);
> +

....

>  	return error;
>  }
>  
> @@ -2615,11 +2649,19 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
>  	struct inode *inode = dentry->d_inode;
>  	struct rpc_cred *cred = NULL;
>  	struct nfs4_state *state = NULL;
> +	struct nfs4_label *olabel = NULL;
>  	int status;
>  
>  	if (pnfs_ld_layoutret_on_setattr(inode))
>  		pnfs_return_layout(inode);
>  
> +	olabel = nfs4_label_alloc(GFP_KERNEL);

See above...

> +	if (NFS4_LABEL_ERR(olabel))
> +		return PTR_ERR(olabel);
> +
> +	if (IS_ERR(olabel))
> +		olabel = NULL;

if (IS_ERR(olabel)), we will have returned.

> +
>  	nfs_fattr_init(fattr);
>  	
>  	/* Deal with open(O_TRUNC) */
> @@ -2641,7 +2683,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
>  		}
>  	}
>  
> -	status = nfs4_do_setattr(inode, cred, fattr, sattr, state, NULL, NULL);
> +	status = nfs4_do_setattr(inode, cred, fattr, sattr, state, NULL, olabel);
>  	if (status == 0)
>  		nfs_setattr_update_inode(inode, sattr);
>  	return status;
> @@ -2798,11 +2840,24 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
>  	if (res.fattr == NULL)
>  		return -ENOMEM;
>  
> +	if (server->caps & NFS_CAP_SECURITY_LABEL) {

....

> +		res.label = nfs4_label_alloc(GFP_KERNEL);
> +		if (NFS4_LABEL_ERR(res.label)) {
> +			status = PTR_ERR(res.label);
> +			goto out;
> +		}
> +	}
> +
>  	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
>  	if (!status) {
>  		nfs_access_set_mask(entry, res.access);
>  		nfs_refresh_inode(inode, res.fattr, res.label);
>  	}
> +
> +	if (server->caps & NFS_CAP_SECURITY_LABEL)

....

> +		nfs4_label_free(res.label);
> +
> +out:
>  	nfs_free_fattr(res.fattr);
>  	return status;
>  }
> @@ -2926,6 +2981,7 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
>  	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
>  	if (status == 0)
>  		update_changeattr(dir, &res.cinfo);
> +
>  	return status;
>  }
>  
> @@ -2969,6 +3025,7 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
>  	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
>  		return 0;
>  	update_changeattr(dir, &res->cinfo);
> +
>  	return 1;
>  }
>  
> @@ -3027,12 +3084,31 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
>  		.rpc_resp = &res,
>  	};
>  	int status = -ENOMEM;
> +
> +
> +	if (server->caps & NFS_CAP_SECURITY_LABEL) {

....

> +		res.old_label = nfs4_label_alloc(GFP_NOWAIT);
> +		if (NFS4_LABEL_ERR(res.old_label))
> +			goto out;
> +		res.new_label = nfs4_label_alloc(GFP_NOWAIT);
> +		if (NFS4_LABEL_ERR(res.new_label)) {
> +			nfs4_label_free(res.old_label);
> +			goto out;
> +		}
> +	}
> +
>  	
>  	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
>  	if (!status) {
>  		update_changeattr(old_dir, &res.old_cinfo);
>  		update_changeattr(new_dir, &res.new_cinfo);
>  	}
> +
> +	if (server->caps & NFS_CAP_SECURITY_LABEL) {

....

> +		nfs4_label_free(res.old_label);
> +		nfs4_label_free(res.new_label);
> +	}
> +out:
>  	return status;
>  }
>  
> @@ -3074,11 +3150,22 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
>  	if (res.fattr == NULL)
>  		goto out;
>  
> +	if (server->caps & NFS_CAP_SECURITY_LABEL) {

...

> +		res.label = nfs4_label_alloc(GFP_KERNEL);
> +		if (NFS4_LABEL_ERR(res.label))
> +			goto out;
> +	}
> +
>  	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
>  	if (!status) {
>  		update_changeattr(dir, &res.cinfo);
>  		nfs_post_op_update_inode(inode, res.fattr, res.label);
>  	}
> +
> +
> +	if (server->caps & NFS_CAP_SECURITY_LABEL)
> +		nfs4_label_free(res.label);

...

> +
>  out:
>  	nfs_free_fattr(res.fattr);
>  	return status;
> @@ -3114,6 +3201,12 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
>  	if (data != NULL) {
>  		struct nfs_server *server = NFS_SERVER(dir);
>  
> +		if (server->caps & NFS_CAP_SECURITY_LABEL) {

...

> +			data->label = nfs4_label_alloc(GFP_KERNEL);
> +			if (NFS4_LABEL_ERR(data->label))
> +				goto out_free;
> +		}
> +
>  		data->msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CREATE];
>  		data->msg.rpc_argp = &data->arg;
>  		data->msg.rpc_resp = &data->res;
> @@ -3130,6 +3223,9 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
>  		nfs_fattr_init(data->res.fattr);
>  	}
>  	return data;
> +out_free:
> +	kfree(data);
> +	return NULL;
>  }
>  
>  static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_createdata *data)
> @@ -3145,6 +3241,9 @@ static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_
>  
>  static void nfs4_free_createdata(struct nfs4_createdata *data)
>  {
> +	if (data->arg.server->caps & NFS_CAP_SECURITY_LABEL)

...

> +		nfs4_label_free(data->label);
> +
>  	kfree(data);
>  }
>  
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index c1e8c96..9082979 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -498,10 +498,12 @@ extern struct nfs4_label *nfs4_label_alloc(gfp_t flags);
>  extern void nfs4_label_init(struct nfs4_label *);
>  extern void nfs4_label_free(struct nfs4_label *);
>  #else
> -static inline struct nfs4_label *nfs4_label_alloc(gfp_t flags) { return NULL; }
> +static inline struct nfs4_label *nfs4_label_alloc(gfp_t flags) { return ERR_PTR(ENOTSUPP); }

Why is returning NULL insufficient? All we want to do is ignore the
label.

>  static inline void nfs4_label_init(void *label) {}
>  static inline void nfs4_label_free(void *label) {}
>  #endif
> +#define NFS4_LABEL_ERR(_label) \
> +	(IS_ERR(_label) && PTR_ERR(_label) != -ENOTSUPP)

There should be no need for this.

>  
>  /*
>   * linux/fs/nfs/unlink.c

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
