Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:6068 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755535Ab2D0QMS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 12:12:18 -0400
Message-ID: <4F9AC556.9020201@netapp.com>
Date: Fri, 27 Apr 2012 12:12:06 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "steved@redhat.com" <steved@redhat.com>
Subject: Re: [PATCH v4 6/9] NFS: Remove unused function nfs_lookup_with_sec()
References: <1335473772-4401-1-git-send-email-bjschuma@netapp.com>  <1335473772-4401-7-git-send-email-bjschuma@netapp.com> <1335542792.3910.12.camel@lade.trondhjem.org>
In-Reply-To: <1335542792.3910.12.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/27/12 12:06, Myklebust, Trond wrote:

> On Thu, 2012-04-26 at 16:56 -0400, bjschuma@netapp.com wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> This fixes a compiler warning.
>>
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>>  fs/nfs/namespace.c |   84 ++++++++++------------------------------------------
>>  1 file changed, 15 insertions(+), 69 deletions(-)
>>
>> diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
>> index 779f06a..d51868e 100644
>> --- a/fs/nfs/namespace.c
>> +++ b/fs/nfs/namespace.c
>> @@ -148,84 +148,31 @@ rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
>>  	return pseudoflavor;
>>  }
>>  
>> -static int nfs_negotiate_security(const struct dentry *parent,
>> -				  const struct dentry *dentry,
>> -				  rpc_authflavor_t *flavor)
>> -{
>> -	struct page *page;
>> -	struct nfs4_secinfo_flavors *flavors;
>> -	int (*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
>> -	int ret = -EPERM;
>> -
>> -	secinfo = NFS_PROTO(parent->d_inode)->secinfo;
>> -	if (secinfo != NULL) {
>> -		page = alloc_page(GFP_KERNEL);
>> -		if (!page) {
>> -			ret = -ENOMEM;
>> -			goto out;
>> -		}
>> -		flavors = page_address(page);
>> -		ret = secinfo(parent->d_inode, &dentry->d_name, flavors);
>> -		*flavor = nfs_find_best_sec(flavors);
>> -		put_page(page);
>> -	}
>> -
>> -out:
>> -	return ret;
>> -}
>> -
>> -static int nfs_lookup_with_sec(struct nfs_server *server, struct dentry *parent,
>> -			       struct dentry *dentry, struct path *path,
>> -			       struct nfs_fh *fh, struct nfs_fattr *fattr,
>> -			       rpc_authflavor_t *flavor)
>> -{
>> -	struct rpc_clnt *clone;
>> -	struct rpc_auth *auth;
>> -	int err;
>> -
>> -	err = nfs_negotiate_security(parent, path->dentry, flavor);
>> -	if (err < 0)
>> -		goto out;
>> -	clone  = rpc_clone_client(server->client);
>> -	auth   = rpcauth_create(*flavor, clone);
>> -	if (!auth) {
>> -		err = -EIO;
>> -		goto out_shutdown;
>> -	}
>> -	err = server->nfs_client->rpc_ops->lookup(clone, parent->d_inode,
>> -						  &path->dentry->d_name,
>> -						  fh, fattr);
>> -out_shutdown:
>> -	rpc_shutdown_client(clone);
>> -out:
>> -	return err;
>> -}
>> -
>>  static struct rpc_clnt *nfs_lookup_mountpoint(struct inode *dir,
>>  					      struct qstr *name,
>>  					      struct nfs_fh *fh,
>>  					      struct nfs_fattr *fattr)
>>  {
>> -	if (NFS_PROTO(dir)->version != 4)
>> -		return rpc_clone_client(NFS_SERVER(dir)->client);
>> -	return nfs4_proc_lookup_mountpoint(dir, name, fh, fattr);
>> +	int err;
>> +
>> +	if (NFS_PROTO(dir)->version == 4)
>> +		return nfs4_proc_lookup_mountpoint(dir, name, fh, fattr);
>> +
>> +	err = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, name, fh, fattr);
>> +	if (err)
>> +		return ERR_PTR(err);
>> +	return rpc_clone_client(NFS_SERVER(dir)->client);
> 
> Where does this come from, and how is it relevant to removing
> nfs_lookup_with_sec?


It made sense to me at the time... but it really should be worked into the previous patches.  I'll fix that now.

- Bryan

> 
>>  }
>>  #else /* CONFIG_NFS_V4 */
>> -static inline int nfs_lookup_with_sec(struct nfs_server *server,
>> -				      struct dentry *parent, struct dentry *dentry,
>> -				      struct path *path, struct nfs_fh *fh,
>> -				      struct nfs_fattr *fattr,
>> -				      rpc_authflavor_t *flavor)
>> -{
>> -	return -EPERM;
>> -}
>> -
>> -static inline struct rpc_clnt *nfs_lookup_mountpoint(struct inode *inode,
>> +static inline struct rpc_clnt *nfs_lookup_mountpoint(struct inode *dir,
>>  						     struct qstr *name,
>>  						     struct nfs_fh *fh,
>>  						     struct nfs_fattr *fattr)
>>  {
>> -	return rpc_clone_client(NFS_SERVER(inode)->client);
>> +	int err = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, name, fh, fattr);
>> +	if (err)
>> +		return ERR_PTR(err);
> 
> Ditto. This definitely belongs in a separate patch.
> 
>> +	return rpc_clone_client(NFS_SERVER(dir)->client);
>>  }
>>  #endif /* CONFIG_NFS_V4 */
>>  
>> @@ -248,7 +195,6 @@ struct vfsmount *nfs_d_automount(struct path *path)
>>  	struct nfs_fh *fh = NULL;
>>  	struct nfs_fattr *fattr = NULL;
>>  	struct rpc_clnt *client;
>> -	rpc_authflavor_t flavor = RPC_AUTH_UNIX;
>>  
>>  	dprintk("--> nfs_d_automount()\n");
>>  
>> @@ -276,7 +222,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
>>  	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
>>  		mnt = nfs_do_refmount(client, path->dentry);
>>  	else
>> -		mnt = nfs_do_submount(path->dentry, fh, fattr, flavor);
>> +		mnt = nfs_do_submount(path->dentry, fh, fattr, client->cl_auth->au_flavor);
>>  	rpc_shutdown_client(client);
>>  
>>  	if (IS_ERR(mnt))
> 


