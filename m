Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:22206 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab2FZSY3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jun 2012 14:24:29 -0400
Subject: Re: [PATCH] NFS: Check if rpcauth_create() returns an error code
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1340734373-5596-1-git-send-email-bjschuma@netapp.com>
Date: Tue, 26 Jun 2012 14:23:24 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9ED25AEF-945E-4908-8D78-4CC040D9A26A@oracle.com>
References: <1340734373-5596-1-git-send-email-bjschuma@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 26, 2012, at 2:12 PM, bjschuma@netapp.com wrote:

> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> I was treating a NULL return value as an error, but this function will
> instead return an ERR_PTR().  Now that I'm checking if the function
> returns an error, I should also pass the error up the call stack.


> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
> fs/nfs/nfs4namespace.c |  4 ++--
> fs/nfs/nfs4proc.c      | 15 ++++-----------
> 2 files changed, 6 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index 017b4b0..a8aafc6 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -205,9 +205,9 @@ struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *clnt, struct inode *ino
> 		return clone;
> 
> 	auth = rpcauth_create(flavor, clone);
> -	if (!auth) {
> +	if (IS_ERR(auth)) {
> 		rpc_shutdown_client(clone);
> -		clone = ERR_PTR(-EIO);
> +		clone = ERR_CAST(auth);
> 	}

This echoes nfs_init_server_rpcclient(), so it should be adequate.

> 
> 	return clone;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 5a7b372..f817587 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2356,17 +2356,10 @@ out:
> static int nfs4_lookup_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
> 				struct nfs_fsinfo *info, rpc_authflavor_t flavor)
> {
> -	struct rpc_auth *auth;
> -	int ret;
> -
> -	auth = rpcauth_create(flavor, server->client);
> -	if (!auth) {
> -		ret = -EIO;
> -		goto out;
> -	}
> -	ret = nfs4_lookup_root(server, fhandle, info);
> -out:
> -	return ret;
> +	struct rpc_auth *auth = rpcauth_create(flavor, server->client);
> +	if (IS_ERR(auth))
> +		return PTR_ERR(auth);
> +	return nfs4_lookup_root(server, fhandle, info);
> }
> 
> static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,

This logic calls rpcauth_create() in a loop, correct?  The expectation is that rpcauth_create() should simply replace the nfs_client's rpc_auth with the next flavor each time it is called?

With the current code in nfs4_find_root_sec(), rpcauth_create() with a GSS flavor fails the second time you call it because (I suspect) there's a pipe dentry left over from the previous call.  So there's no way to walk an entire list returned from gss_mech_list_flavors(), it will fail on the second GSS flavor every time.

We could:

  a)  have gss_pipes_dentries_create_net() ignore -EEXIST and return zero instead, or

  b)  make sure rpcauth_create() releases the old rpc_auth before calling op->create()

  c)  ??

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




