Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65022 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753126Ab1AFUMe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Jan 2011 15:12:34 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p06KCXCv007747
	for <linux-nfs@vger.kernel.org>; Thu, 6 Jan 2011 12:12:33 -0800 (PST)
Subject: Re: [PATCH v2 4/5] NFS: use secinfo when crossing mountpoints
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4D24CB31.7020806@netapp.com>
References: <4D24CB31.7020806@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 06 Jan 2011 15:12:32 -0500
Message-ID: <1294344752.2905.15.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-05 at 14:49 -0500, Bryan Schumaker wrote: 
> A submount may use different security than the parent
> mount does.  We should figure out what sec flavor the
> submount uses at mount time.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/inode.c                        |    8 ++-
>  fs/nfs/internal.h                     |    6 ++
>  fs/nfs/namespace.c                    |  102 ++++++++++++++++++++++++++++++++-
>  fs/nfs/nfs4proc.c                     |   14 +++++
>  fs/nfs/nfs4xdr.c                      |   12 ++--
>  include/linux/nfs_xdr.h               |    1 +
>  net/sunrpc/auth_gss/gss_mech_switch.c |   22 +++++++
>  7 files changed, 154 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 43a69da..37fdd4f 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -249,7 +249,9 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
>  	struct inode *inode = ERR_PTR(-ENOENT);
>  	unsigned long hash;
>  
> -	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0)
> +	nfs_attr_check_mountpoint(sb, fattr);
> +
> +	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0 && (fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT) == 0)
>  		goto out_no_inode;
>  	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) == 0)
>  		goto out_no_inode;
> @@ -293,8 +295,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
>  			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS))
>  				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
>  			/* Deal with crossing mountpoints */
> -			if ((fattr->valid & NFS_ATTR_FATTR_FSID)
> -					&& !nfs_fsid_equal(&NFS_SB(sb)->fsid, &fattr->fsid)) {
> +			if (fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT ||
> +					fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) {
>  				if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
>  					inode->i_op = &nfs_referral_inode_operations;
>  				else
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 4f5c808..5f46e0a 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -39,6 +39,12 @@ static inline int nfs4_has_persistent_session(const struct nfs_client *clp)
>  	return 0;
>  }
>  
> +static inline void nfs_attr_check_mountpoint(struct super_block *parent, struct nfs_fattr *fattr)
> +{
> +	if (!nfs_fsid_equal(&NFS_SB(parent)->fsid, &fattr->fsid))
> +		fattr->valid |= NFS_ATTR_FATTR_MOUNTPOINT;
> +}
> +
>  struct nfs_clone_mount {
>  	const struct super_block *sb;
>  	const struct dentry *dentry;
> diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
> index 3c361f8..8d335b7 100644
> --- a/fs/nfs/namespace.c
> +++ b/fs/nfs/namespace.c
> @@ -15,6 +15,7 @@
>  #include <linux/string.h>
>  #include <linux/sunrpc/clnt.h>
>  #include <linux/vfs.h>
> +#include <linux/sunrpc/gss_api.h>
>  #include "internal.h"
>  
>  #define NFSDBG_FACILITY		NFSDBG_VFS
> @@ -28,7 +29,8 @@ int nfs_mountpoint_expiry_timeout = 500 * HZ;
>  static struct vfsmount *nfs_do_submount(const struct vfsmount *mnt_parent,
>  					const struct dentry *dentry,
>  					struct nfs_fh *fh,
> -					struct nfs_fattr *fattr);
> +					struct nfs_fattr *fattr,
> +					rpc_authflavor_t authflavor);
>  
>  /*
>   * nfs_path - reconstruct the path given an arbitrary dentry
> @@ -87,6 +89,90 @@ Elong:
>  	return ERR_PTR(-ENAMETOOLONG);
>  }
>  
> +rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors, struct inode *inode)

These 3 functions need to be declared 'static', since they are not used
outside fs/nfs/namespace.c

> +{
> +	struct gss_api_mech *mech;
> +	struct xdr_netobj oid;
> +	int i;
> +	rpc_authflavor_t pseudoflavor = RPC_AUTH_UNIX;
> +
> +	for (i = 0; i < flavors->num_flavors; i++) {
> +		struct nfs4_secinfo_flavor *flavor;
> +		flavor = &flavors->flavors[i];
> +
> +		if (flavor->flavor == RPC_AUTH_NULL || flavor->flavor == RPC_AUTH_UNIX) {
> +			pseudoflavor = flavor->flavor;
> +			break;
> +		} else if (flavor->flavor == RPC_AUTH_GSS) {
> +			oid.len  = flavor->gss.sec_oid4.len;
> +			oid.data = flavor->gss.sec_oid4.data;
> +			mech = gss_mech_get_by_OID(&oid);
> +			if (!mech)
> +				continue;
> +			pseudoflavor = gss_svc_to_pseudoflavor(mech, flavor->gss.service);
> +			gss_mech_put(mech);
> +			break;
> +		}
> +	}
> +
> +	return pseudoflavor;
> +}
> +
> +rpc_authflavor_t nfs_negotiate_security(const struct dentry *parent, const struct dentry *dentry)
> +{
> +	int status = 0;
> +	struct page *page;
> +	struct nfs4_secinfo_flavors *flavors;
> +	int (*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
> +	rpc_authflavor_t flavor = RPC_AUTH_UNIX;
> +
> +	secinfo = NFS_PROTO(parent->d_inode)->secinfo;
> +	if (secinfo != NULL) {
> +		page = alloc_page(GFP_KERNEL);
> +		if (!page) {
> +			status = -ENOMEM;
> +			goto out;
> +		}
> +		flavors = page_address(page);
> +		status = secinfo(parent->d_inode, &dentry->d_name, flavors);
> +		flavor = nfs_find_best_sec(flavors, dentry->d_inode);
> +		put_page(page);
> +	}
> +
> +	return flavor;
> +
> +out:
> +	status = -ENOMEM;
> +	return status;
> +}
> +
> +rpc_authflavor_t nfs_lookup_with_sec(struct nfs_server *server, struct dentry *parent,
> +				     struct dentry *dentry, struct nameidata *nd,
> +				     struct nfs_fh *fh, struct nfs_fattr *fattr)
> +{
> +	rpc_authflavor_t flavor;
> +	struct rpc_clnt *clone;
> +	struct rpc_auth *auth;
> +	int err;
> +
> +	flavor = nfs_negotiate_security(parent, nd->path.dentry);
> +	if (flavor < 0)
> +		goto out;
> +	clone  = rpc_clone_client(server->client);
> +	auth   = rpcauth_create(flavor, clone);
> +	if (!auth) {
> +		flavor = -EIO;
> +		goto out;
> +	}
> +	err = server->nfs_client->rpc_ops->lookup(clone, parent->d_inode,
> +						  &nd->path.dentry->d_name,
> +						  fh, fattr);
> +	if (err < 0)
> +		flavor = err;
> +out:
> +	return flavor;
> +}
> +
>  /*
>   * nfs_follow_mountpoint - handle crossing a mountpoint on the server
>   * @dentry - dentry of mountpoint
> @@ -108,6 +194,7 @@ static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
>  	struct nfs_fh *fh = NULL;
>  	struct nfs_fattr *fattr = NULL;
>  	int err;
> +	rpc_authflavor_t flavor = 1;
>  
>  	dprintk("--> nfs_follow_mountpoint()\n");
>  
> @@ -130,6 +217,13 @@ static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
>  	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
>  						  &nd->path.dentry->d_name,
>  						  fh, fattr);
> +	if (err == -EPERM) {
> +		flavor = nfs_lookup_with_sec(server, parent, dentry, nd, fh, fattr);
> +		if (flavor < 0)
> +			err = flavor;
> +		else
> +			err = 0;
> +	}
>  	dput(parent);
>  	if (err != 0)
>  		goto out_err;
> @@ -138,7 +232,7 @@ static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
>  		mnt = nfs_do_refmount(nd->path.mnt, nd->path.dentry);
>  	else
>  		mnt = nfs_do_submount(nd->path.mnt, nd->path.dentry, fh,
> -				      fattr);
> +				      fattr, flavor);
>  	err = PTR_ERR(mnt);
>  	if (IS_ERR(mnt))
>  		goto out_err;
> @@ -232,13 +326,15 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
>  static struct vfsmount *nfs_do_submount(const struct vfsmount *mnt_parent,
>  					const struct dentry *dentry,
>  					struct nfs_fh *fh,
> -					struct nfs_fattr *fattr)
> +					struct nfs_fattr *fattr,
> +					rpc_authflavor_t authflavor)
>  {
>  	struct nfs_clone_mount mountdata = {
>  		.sb = mnt_parent->mnt_sb,
>  		.dentry = dentry,
>  		.fh = fh,
>  		.fattr = fattr,
> +		.authflavor = authflavor,
>  	};
>  	struct vfsmount *mnt = ERR_PTR(-ENOMEM);
>  	char *page = (char *) __get_free_page(GFP_USER);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 3fdf821..4a1d79e 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -86,6 +86,8 @@ static int nfs4_map_errors(int err)
>  	switch (err) {
>  	case -NFS4ERR_RESOURCE:
>  		return -EREMOTEIO;
> +	case -NFS4ERR_WRONGSEC:
> +		return -EPERM;
>  	default:
>  		dprintk("%s could not handle NFSv4 error %d\n",
>  				__func__, -err);
> @@ -2363,6 +2365,16 @@ static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
>  	return status;
>  }
>  
> +void nfs_fixup_secinfo_attributes(struct nfs_fattr *fattr, struct nfs_fh *fh)
> +{
> +	memset(fh, 0, sizeof(struct nfs_fh));
> +	fattr->fsid.major = 1;
> +	fattr->valid |= NFS_ATTR_FATTR_TYPE | NFS_ATTR_FATTR_MODE |
> +		NFS_ATTR_FATTR_NLINK | NFS_ATTR_FATTR_FSID | NFS_ATTR_FATTR_MOUNTPOINT;
> +	fattr->mode = S_IFDIR | S_IRUGO | S_IXUGO;
> +	fattr->nlink = 2;
> +}
> +
>  static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
>  			    struct nfs_fh *fhandle, struct nfs_fattr *fattr)
>  {
> @@ -2372,6 +2384,8 @@ static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qst
>  		err = nfs4_handle_exception(NFS_SERVER(dir),
>  				_nfs4_proc_lookup(clnt, dir, name, fhandle, fattr),
>  				&exception);
> +		if (err == -EPERM)
> +			nfs_fixup_secinfo_attributes(fattr, fhandle);
>  	} while (exception.retry);
>  	return err;
>  }
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 020fa88..3d5298c 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -61,6 +61,7 @@
>  #define errno_NFSERR_IO		EIO
>  
>  static int nfs4_stat_to_errno(int);
> +void nfs_fixup_secinfo_attributes(struct nfs_fattr *, struct nfs_fh *);

Please put this declaration in fs/nfs/internal.h

> 
>  /* NFSv4 COMPOUND tags are only wanted for debugging purposes */
>  #ifdef DEBUG
> @@ -113,7 +114,7 @@ static int nfs4_stat_to_errno(int);
>  #define encode_restorefh_maxsz  (op_encode_hdr_maxsz)
>  #define decode_restorefh_maxsz  (op_decode_hdr_maxsz)
>  #define encode_fsinfo_maxsz	(encode_getattr_maxsz)
> -#define decode_fsinfo_maxsz	(op_decode_hdr_maxsz + 11)
> +#define decode_fsinfo_maxsz	(op_decode_hdr_maxsz + 15)
>  #define encode_renew_maxsz	(op_encode_hdr_maxsz + 3)
>  #define decode_renew_maxsz	(op_decode_hdr_maxsz)
>  #define encode_setclientid_maxsz \
> @@ -2963,6 +2964,7 @@ static int decode_attr_error(struct xdr_stream *xdr, uint32_t *bitmap)
>  		if (unlikely(!p))
>  			goto out_overflow;
>  		bitmap[0] &= ~FATTR4_WORD0_RDATTR_ERROR;
> +		return -be32_to_cpup(p);
>  	}
>  	return 0;
>  out_overflow:
> @@ -3950,6 +3952,10 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
>  	fattr->valid |= status;
>  
>  	status = decode_attr_error(xdr, bitmap);
> +	if (status == -NFS4ERR_WRONGSEC) {
> +		nfs_fixup_secinfo_attributes(fattr, fh);
> +		status = 0;
> +	}
>  	if (status < 0)
>  		goto xdr_error;
>  
> @@ -6315,10 +6321,6 @@ static struct {
>  	{ NFS4ERR_SYMLINK,	-ELOOP		},
>  	{ NFS4ERR_OP_ILLEGAL,	-EOPNOTSUPP	},
>  	{ NFS4ERR_DEADLOCK,	-EDEADLK	},
> -	{ NFS4ERR_WRONGSEC,	-EPERM		}, /* FIXME: this needs
> -						    * to be handled by a
> -						    * middle-layer.
> -						    */

Can you please add an entry for this mapping into nfs4_map_errors(), so
that we don't leak NFS4ERR_WRONGSEC to userland.


> 	{ -1,			-EIO		}
>  };
>  
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index edd74e7..49256a2 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -79,6 +79,7 @@ struct nfs_fattr {
>  #define NFS_ATTR_FATTR_CHANGE		(1U << 17)
>  #define NFS_ATTR_FATTR_PRECHANGE	(1U << 18)
>  #define NFS_ATTR_FATTR_V4_REFERRAL	(1U << 19)	/* NFSv4 referral */
> +#define NFS_ATTR_FATTR_MOUNTPOINT	(1U << 20)	/* Treat as mountpoint */
>  
>  #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
>  		| NFS_ATTR_FATTR_MODE \
> diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
> index 8b40610..6c844b0 100644
> --- a/net/sunrpc/auth_gss/gss_mech_switch.c
> +++ b/net/sunrpc/auth_gss/gss_mech_switch.c
> @@ -160,6 +160,28 @@ gss_mech_get_by_name(const char *name)
>  
>  EXPORT_SYMBOL_GPL(gss_mech_get_by_name);
>  
> +struct gss_api_mech *
> +gss_mech_get_by_OID(struct xdr_netobj *obj)
> +{
> +	struct gss_api_mech	*pos, *gm = NULL;
> +
> +	spin_lock(&registered_mechs_lock);
> +	list_for_each_entry(pos, &registered_mechs, gm_list) {
> +		if (obj->len == pos->gm_oid.len) {
> +			if (0 == memcmp(obj->data, pos->gm_oid.data, obj->len)) {
> +				if (try_module_get(pos->gm_owner))
> +					gm = pos;
> +				break;
> +			}
> +		}
> +	}
> +	spin_unlock(&registered_mechs_lock);
> +	return gm;
> +
> +}
> +
> +EXPORT_SYMBOL_GPL(gss_mech_get_by_OID);
> +
>  static inline int
>  mech_supports_pseudoflavor(struct gss_api_mech *gm, u32 pseudoflavor)
>  {

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

