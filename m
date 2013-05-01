Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:20660 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755858Ab3EATD2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 May 2013 15:03:28 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        "Linux FS devel list" <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 13/17] NFS: Client implementation of Labeled-NFS
Date: Wed, 1 May 2013 19:03:26 +0000
Message-ID: <1367435005.4189.36.camel@leira.trondhjem.org>
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
	 <1367240239-19326-14-git-send-email-SteveD@redhat.com>
In-Reply-To: <1367240239-19326-14-git-send-email-SteveD@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-04-29 at 08:57 -0400, Steve Dickson wrote:
> From: David Quigley <dpquigl@davequigley.com>
> 
> This patch implements the client transport and handling support for labeled
> NFS. The patch adds two functions to encode and decode the security label
> recommended attribute which makes use of the LSM hooks added earlier. It also
> adds code to grab the label from the file attribute structures and encode the
> label to be sent back to the server.
> 
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> ---
>  fs/nfs/inode.c            |  57 ++++++++-
>  fs/nfs/nfs4proc.c         | 318 +++++++++++++++++++++++++++++++++++++++++++---
>  fs/nfs/nfs4xdr.c          | 168 ++++++++++++++++++------
>  fs/nfs/pnfs.c             |   2 +-
>  fs/nfs/super.c            |  17 ++-
>  include/linux/nfs_fs.h    |  13 ++
>  include/linux/nfs_fs_sb.h |   7 +
>  security/selinux/hooks.c  |   4 +
>  8 files changed, 524 insertions(+), 62 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 4e92dfb..cc1c85d 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -162,11 +162,19 @@ static void nfs_zap_caches_locked(struct inode *inode)
>  
>  	memset(NFS_I(inode)->cookieverf, 0, sizeof(NFS_I(inode)->cookieverf));
>  	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode)) {
> -		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
>  		nfs_fscache_invalidate(inode);
> -	} else {
> -		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
> -	}
> +		nfsi->cache_validity |= NFS_INO_INVALID_ATTR
> +					| NFS_INO_INVALID_LABEL
> +					| NFS_INO_INVALID_DATA
> +					| NFS_INO_INVALID_ACCESS
> +					| NFS_INO_INVALID_ACL
> +					| NFS_INO_REVAL_PAGECACHE;
> +	} else
> +		nfsi->cache_validity |= NFS_INO_INVALID_ATTR
> +					| NFS_INO_INVALID_LABEL
> +					| NFS_INO_INVALID_ACCESS
> +					| NFS_INO_INVALID_ACL
> +					| NFS_INO_REVAL_PAGECACHE;
>  }
>  
>  void nfs_zap_caches(struct inode *inode)
> @@ -258,6 +266,24 @@ nfs_init_locked(struct inode *inode, void *opaque)
>  }
>  
>  #ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
> +					struct nfs4_label *label)
> +{
> +	int error;
> +
> +	if ((fattr->valid & NFS_ATTR_FATTR_V4_SECURITY_LABEL) &&
> +			label && inode->i_security) {
> +		error = security_inode_notifysecctx(inode, label->label,
> +				label->len);
> +		if (error)
> +			printk(KERN_ERR "%s() %s %d "
> +					"security_inode_notifysecctx() %d\n",
> +					__func__,
> +					(char *)label->label,
> +					label->len, error);
> +	}
> +}
> +
>  struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags)
>  {
>  	struct nfs4_label *label = NULL;
> @@ -283,7 +309,13 @@ struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags)
>  	return label;
>  }
>  EXPORT_SYMBOL_GPL(nfs4_label_alloc);
> +#else
> +void inline nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
> +					struct nfs4_label *label)
> +{
> +}
>  #endif
> +EXPORT_SYMBOL_GPL(nfs_setsecurity);
>  
>  /*
>   * This is our front-end to iget that looks up inodes by file handle
> @@ -412,6 +444,9 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
>  			 */
>  			inode->i_blocks = nfs_calc_block_size(fattr->du.nfs3.used);
>  		}
> +
> +		nfs_setsecurity(inode, fattr, label);
> +
>  		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
>  		nfsi->attrtimeo_timestamp = now;
>  		nfsi->access_cache = RB_ROOT;
> @@ -771,6 +806,7 @@ struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_c
>  	spin_unlock(&inode->i_lock);
>  	return ctx;
>  }
> +EXPORT_SYMBOL_GPL(nfs_find_open_context);
>  
>  static void nfs_file_clear_open_context(struct file *filp)
>  {
> @@ -899,7 +935,8 @@ static int nfs_attribute_cache_expired(struct inode *inode)
>   */
>  int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
>  {
> -	if (!(NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATTR)
> +	if (!(NFS_I(inode)->cache_validity &
> +			(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL))
>  			&& !nfs_attribute_cache_expired(inode))
>  		return NFS_STALE(inode) ? -ESTALE : 0;
>  	return __nfs_revalidate_inode(server, inode);
> @@ -1240,6 +1277,9 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_
>  	status = nfs_refresh_inode_locked(inode, fattr, label);
>  	spin_unlock(&inode->i_lock);
>  
> +	if (label && !status)
> +		nfs_setsecurity(inode, fattr, label);
> +
>  	return status;
>  }
>  EXPORT_SYMBOL_GPL(nfs_refresh_inode);
> @@ -1279,6 +1319,10 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr, struc
>  	spin_lock(&inode->i_lock);
>  	status = nfs_post_op_update_inode_locked(inode, fattr, label);
>  	spin_unlock(&inode->i_lock);
> +	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL)) {
> +		if (label && !status)
> +			nfs_setsecurity(inode, fattr, label);
> +	}
>  	return status;
>  }
>  EXPORT_SYMBOL_GPL(nfs_post_op_update_inode);
> @@ -1519,7 +1563,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr, struct
>  		inode->i_blocks = fattr->du.nfs2.blocks;
>  
>  	/* Update attrtimeo value if we're out of the unstable period */
> -	if (invalid & NFS_INO_INVALID_ATTR) {
> +	if (invalid & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL)) {
>  		nfs_inc_stats(inode, NFSIOS_ATTRINVALIDATE);
>  		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
>  		nfsi->attrtimeo_timestamp = now;
> @@ -1532,6 +1576,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr, struct
>  		}
>  	}
>  	invalid &= ~NFS_INO_INVALID_ATTR;
> +	invalid &= ~NFS_INO_INVALID_LABEL;
>  	/* Don't invalidate the data if we were to blame */
>  	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
>  				|| S_ISLNK(inode->i_mode)))
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 56f24c0..0e5b319 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -87,6 +87,52 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>  static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *);
>  static int nfs41_free_stateid(struct nfs_server *, nfs4_stateid *);
>  #endif
> +
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +static inline struct nfs4_label *
> +nfs4_label_init_security(struct inode *dir, struct dentry *dentry, 
> +	struct iattr *sattr, struct nfs4_label *l)
> +{
> +	int err;
> +	int minor_version = NFS_SERVER(dir)->nfs_client->cl_minorversion;
> +
> +	if (minor_version < 2)
> +		return NULL;
> +
> +	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
> +		err = security_dentry_init_security(dentry, sattr->ia_mode,
> +					&dentry->d_name, (void **)&l->label, &l->len);
> +		if (err == 0)
> +			return l;
> +	}
> +	return NULL;
> +}
> +static inline void 
> +nfs4_label_release_security(struct nfs4_label *label) 
> +{
> +	if (label)
> +		security_release_secctx(label->label, label->len);
> +}
> +static inline u32 *nfs4_bitmask(struct nfs_server *server, struct nfs4_label *label)
> +{
> +	if (label)
> +		return server->attr_bitmask;
> +
> +	return server->attr_bitmask_nl;
> +}
> +#else
> +static inline struct nfs4_label *
> +nfs4_label_init_security(struct inode *dir, struct dentry *dentry, 
> +	struct iattr *sattr, struct nfs4_label *l)
> +{ return NULL; }
> +static inline void 
> +nfs4_label_release_security(struct nfs4_label *label) 
> +{ return; }
> +static inline u32 *
> +nfs4_bitmask(struct nfs_server *server, struct nfs4_label *label)
> +{ return server->attr_bitmask; }
> +#endif
> +
>  /* Prevent leaks of NFSv4 errors into userland */
>  static int nfs4_map_errors(int err)
>  {
> @@ -133,7 +179,10 @@ const u32 nfs4_fattr_bitmap[3] = {
>  	| FATTR4_WORD1_SPACE_USED
>  	| FATTR4_WORD1_TIME_ACCESS
>  	| FATTR4_WORD1_TIME_METADATA
> -	| FATTR4_WORD1_TIME_MODIFY
> +	| FATTR4_WORD1_TIME_MODIFY,
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +	FATTR4_WORD2_SECURITY_LABEL
> +#endif
>  };
>  
>  static const u32 nfs4_pnfs_open_bitmap[3] = {
> @@ -817,7 +866,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
>  	p->o_arg.id.uniquifier = sp->so_seqid.owner_id;
>  	p->o_arg.name = &dentry->d_name;
>  	p->o_arg.server = server;
> -	p->o_arg.bitmask = server->attr_bitmask;
> +	p->o_arg.bitmask = nfs4_bitmask(server, label);
>  	p->o_arg.open_bitmap = &nfs4_fattr_bitmap[0];
>  	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
>  	p->o_arg.label = label;
> @@ -1973,6 +2022,7 @@ static int _nfs4_do_open(struct inode *dir,
>  		if (status == 0) {
>  			nfs_setattr_update_inode(state->inode, sattr);
>  			nfs_post_op_update_inode(state->inode, opendata->o_res.f_attr, olabel);
> +			nfs_setsecurity(state->inode, opendata->o_res.f_attr, olabel);
>  		}
>  	}
>  
> @@ -2086,6 +2136,10 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>  	unsigned long timestamp = jiffies;
>  	int status;
>  
> +	arg.bitmask = nfs4_bitmask(server, ilabel);
> +	if (ilabel)
> +		arg.bitmask = nfs4_bitmask(server, olabel);
> +
>  	nfs_fattr_init(fattr);
>  
>  	if (state != NULL) {
> @@ -2315,7 +2369,7 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
>  	if (calldata->arg.seqid == NULL)
>  		goto out_free_calldata;
>  	calldata->arg.fmode = 0;
> -	calldata->arg.bitmask = server->cache_consistency_bitmask;
> +	calldata->arg.bitmask = server->cache_consistency_bitmask_nl;
>  	calldata->res.fattr = &calldata->fattr;
>  	calldata->res.seqid = calldata->arg.seqid;
>  	calldata->res.server = server;
> @@ -2345,11 +2399,16 @@ static struct inode *
>  nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags, struct iattr *attr)
>  {
>  	struct nfs4_state *state;
> -	struct nfs4_label *label = NULL;
> +	struct nfs4_label l = {0, 0, 0, NULL}, *label = NULL;
> +
> +	label = nfs4_label_init_security(dir, ctx->dentry, attr, &l);
>  
>  	/* Protect against concurrent sillydeletes */
>  	state = nfs4_do_open(dir, ctx->dentry, ctx->mode, open_flags, attr, label,
>  			     ctx->cred, &ctx->mdsthreshold);
> +
> +	nfs4_label_release_security(label);
> +
>  	if (IS_ERR(state))
>  		return ERR_CAST(state);
>  	ctx->state = state;
> @@ -2409,10 +2468,26 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
>  			server->caps |= NFS_CAP_CTIME;
>  		if (res.attr_bitmask[1] & FATTR4_WORD1_TIME_MODIFY)
>  			server->caps |= NFS_CAP_MTIME;
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +		if (res.attr_bitmask[2] & FATTR4_WORD2_SECURITY_LABEL)
> +			server->caps |= NFS_CAP_SECURITY_LABEL;
> +#endif
> +		memcpy(server->attr_bitmask_nl, res.attr_bitmask, 
> +				sizeof(server->attr_bitmask));
> +
> +		if (server->caps & NFS_CAP_SECURITY_LABEL)
> +			server->attr_bitmask_nl[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
>  
>  		memcpy(server->cache_consistency_bitmask, res.attr_bitmask, sizeof(server->cache_consistency_bitmask));
>  		server->cache_consistency_bitmask[0] &= FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
> -		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
> +		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA |
> +							FATTR4_WORD1_TIME_MODIFY;
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +		server->cache_consistency_bitmask[2] &= FATTR4_WORD2_SECURITY_LABEL;

Why? How is the security label relevant to cache consistency?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
