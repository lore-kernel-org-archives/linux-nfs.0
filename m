Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:50153 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195AbaFPR4i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Jun 2014 13:56:38 -0400
Received: by mail-ig0-f181.google.com with SMTP id h15so42172igd.8
        for <linux-nfs@vger.kernel.org>; Mon, 16 Jun 2014 10:56:38 -0700 (PDT)
Message-ID: <1402941396.4801.7.camel@leira.trondhjem.org>
Subject: Re: [PATCH Version 2 1/1] NFS NFS test SECINFO RPC_AUTH_GSS
 pseudoflavors for support
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 16 Jun 2014 13:56:36 -0400
In-Reply-To: <1402599752-3168-2-git-send-email-andros@netapp.com>
References: <1402599752-3168-1-git-send-email-andros@netapp.com>
	 <1402599752-3168-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2014-06-12 at 15:02 -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Fix nfs4_negotiate_security to create an rpc_clnt used to test each SECINFO
> returned pseudoflavor. Check credential creation  (and gss_context creation)
> which is important for RPC_AUTH_GSS pseudoflavors which can fail for multiple
> reasons including mis-configuration.
> 
> Don't call nfs4_negotiate in nfs4_submount as it was just called by
> nfs4_proc_lookup_mountpoint (nfs4_proc_lookup_common)
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> 
> Conflicts:
> 	fs/nfs/nfs4namespace.c

Queued for 3.17, but I had to fix a couple of issues with
nfs_find_best_sec() first. See below:


> ---
>  fs/nfs/nfs4_fs.h       |   2 +-
>  fs/nfs/nfs4namespace.c | 103 ++++++++++++++++++++++++++++---------------------
>  fs/nfs/nfs4proc.c      |   2 +-
>  net/sunrpc/auth.c      |   1 +
>  4 files changed, 61 insertions(+), 47 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index f63cb87..ba2affa 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -230,7 +230,7 @@ int nfs_atomic_open(struct inode *, struct dentry *, struct file *,
>  extern struct file_system_type nfs4_fs_type;
>  
>  /* nfs4namespace.c */
> -struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
> +struct rpc_clnt *nfs4_negotiate_security(struct rpc_clnt *, struct inode *, struct qstr *);
>  struct vfsmount *nfs4_submount(struct nfs_server *, struct dentry *,
>  			       struct nfs_fh *, struct nfs_fattr *);
>  int nfs4_replace_transport(struct nfs_server *server,
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index 3d5dbf8..5517f02 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -139,19 +139,28 @@ static size_t nfs_parse_server_name(char *string, size_t len,
>   * @server: NFS server struct
>   * @flavors: List of security tuples returned by SECINFO procedure
>   *
> - * Return the pseudoflavor of the first security mechanism in
> - * "flavors" that is locally supported.  Return RPC_AUTH_UNIX if
> - * no matching flavor is found in the array.  The "flavors" array
> + * Return an rpc client that uses the first security mechanism in
> + * "flavors" that is locally supported.  The "flavors" array
>   * is searched in the order returned from the server, per RFC 3530
> - * recommendation.
> + * recommendation and each flavor is checked for membership in the
> + * sec= mount option list if it exists.
> + *
> + * Return -EPERM if no matching flavor is found in the array.
> + *
> + * Please call rpc_shutdown_client() when you are done with this rpc client.
> + *
>   */
> -static rpc_authflavor_t nfs_find_best_sec(struct nfs_server *server,
> +static struct rpc_clnt *nfs_find_best_sec(struct rpc_clnt *clnt,
> +					  struct nfs_server *server,
>  					  struct nfs4_secinfo_flavors *flavors)
>  {
> -	rpc_authflavor_t pseudoflavor;
> +	rpc_authflavor_t pflavor;
>  	struct nfs4_secinfo4 *secinfo;
> +	struct rpc_clnt *new;
>  	unsigned int i;
> +	struct rpc_cred *cred;
>  
> +	new = ERR_PTR(-EPERM);
>  	for (i = 0; i < flavors->num_flavors; i++) {
>  		secinfo = &flavors->flavors[i];
>  
> @@ -159,62 +168,71 @@ static rpc_authflavor_t nfs_find_best_sec(struct nfs_server *server,
>  		case RPC_AUTH_NULL:
>  		case RPC_AUTH_UNIX:
>  		case RPC_AUTH_GSS:
> -			pseudoflavor = rpcauth_get_pseudoflavor(secinfo->flavor,
> +			pflavor = rpcauth_get_pseudoflavor(secinfo->flavor,
>  							&secinfo->flavor_info);
> -			/* make sure pseudoflavor matches sec= mount opt */
> -			if (pseudoflavor != RPC_AUTH_MAXFLAVOR &&
> -			    nfs_auth_info_match(&server->auth_info,
> -						pseudoflavor))
> -				return pseudoflavor;
> -			break;
> +			/* does the pseudoflavor match a sec= mount opt? */
> +			if (pflavor != RPC_AUTH_MAXFLAVOR &&
> +			    nfs_auth_info_match(&server->auth_info, pflavor)) {
> +
> +				/* Cloning creates an rpc_auth for the flavor */
> +				new = rpc_clone_client_set_auth(clnt, pflavor);
> +				if (IS_ERR(new))
> +					continue;

If IS_ERR(new), we can end up returning an error which is not EPERM.

> +				/**
> +				* Check that the user actually can use the
> +				* flavor. This is mostly for RPC_AUTH_GSS
> +				* where cr_init obtains a gss context
> +				*/
> +				cred = rpcauth_lookupcred(new->cl_auth, 0);
> +				if (IS_ERR(cred)) {
> +					rpc_shutdown_client(new);
> +					continue;
> +				}
> +				put_rpccred(cred);
> +				break;

If IS_ERR(cred), we can end up freeing 'new', and then returning the
pointer to the freed client.

> +			}
>  		}
>  	}
> -
> -	/* if there were any sec= options then nothing matched */
> -	if (server->auth_info.flavor_len > 0)
> -		return -EPERM;
> -
> -	return RPC_AUTH_UNIX;
> +	return new;
>  }
>  
> -static rpc_authflavor_t nfs4_negotiate_security(struct inode *inode, struct qstr *name)
> +/**
> + * nfs4_negotiate_security - in response to an NFS4ERR_WRONGSEC on lookup,
> + * return an rpc_clnt that uses the best available security flavor with
> + * respect to the secinfo flavor list and the sec= mount options.
> + *
> + * @clnt: RPC client to clone
> + * @inode: directory inode
> + * @name: lookup name
> + *
> + * Please call rpc_shutdown_client() when you are done with this rpc client.
> + */
> +struct rpc_clnt *
> +nfs4_negotiate_security(struct rpc_clnt *clnt, struct inode *inode,
> +					struct qstr *name)
>  {
>  	struct page *page;
>  	struct nfs4_secinfo_flavors *flavors;
> -	rpc_authflavor_t flavor;
> +	struct rpc_clnt *new = ERR_PTR(-ENOMEM);
>  	int err;
>  
>  	page = alloc_page(GFP_KERNEL);
>  	if (!page)
> -		return -ENOMEM;
> +		return new;
> +
>  	flavors = page_address(page);
>  
>  	err = nfs4_proc_secinfo(inode, name, flavors);
>  	if (err < 0) {
> -		flavor = err;
> +		new = ERR_PTR(err);;
>  		goto out;
>  	}
>  
> -	flavor = nfs_find_best_sec(NFS_SERVER(inode), flavors);
> +	new = nfs_find_best_sec(clnt, NFS_SERVER(inode), flavors);
>  
>  out:
>  	put_page(page);
> -	return flavor;
> -}
> -
> -/*
> - * Please call rpc_shutdown_client() when you are done with this client.
> - */
> -struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *clnt, struct inode *inode,
> -					struct qstr *name)
> -{
> -	rpc_authflavor_t flavor;
> -
> -	flavor = nfs4_negotiate_security(inode, name);
> -	if ((int)flavor < 0)
> -		return ERR_PTR((int)flavor);
> -
> -	return rpc_clone_client_set_auth(clnt, flavor);
> +	return new;
>  }
>  
>  static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
> @@ -397,11 +415,6 @@ struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
>  
>  	if (client->cl_auth->au_flavor != flavor)
>  		flavor = client->cl_auth->au_flavor;
> -	else {
> -		rpc_authflavor_t new = nfs4_negotiate_security(dir, name);
> -		if ((int)new >= 0)
> -			flavor = new;
> -	}
>  	mnt = nfs_do_submount(dentry, fh, fattr, flavor);
>  out:
>  	rpc_shutdown_client(client);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 68dd81e..fe14063 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3247,7 +3247,7 @@ static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
>  			err = -EPERM;
>  			if (client != *clnt)
>  				goto out;
> -			client = nfs4_create_sec_client(client, dir, name);
> +			client = nfs4_negotiate_security(client, dir, name);
>  			if (IS_ERR(client))
>  				return PTR_ERR(client);
>  
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 5285ead..1d97e19 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -592,6 +592,7 @@ rpcauth_lookupcred(struct rpc_auth *auth, int flags)
>  	put_group_info(acred.group_info);
>  	return ret;
>  }
> +EXPORT_SYMBOL_GPL(rpcauth_lookupcred);
>  
>  void
>  rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


