From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 4/4] NFS: Use cached nlm_host when calling
	nlmclnt_proc()
Date: Thu, 03 Jan 2008 16:59:58 -0500
Message-ID: <1199397599.1913.22.camel@heimdal.trondhjem.org>
References: <20071220200420.3358.66424.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:46208 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752911AbYACWAD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2008 17:00:03 -0500
In-Reply-To: <20071220200420.3358.66424.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2007-12-20 at 15:04 -0500, Chuck Lever wrote:
> Now that each NFS mount point caches its own nlm_host structure, it can be
> passed to nlmclnt_proc() for each lock request.
> 
> By pinning an nlm_host for each mount point, we trade the overhead of
> looking up or creating a fresh nlm_host struct during every NLM procedure
> call for a little extra memory.
> 
> Note that nlm_lookup_host() (just removed from the client's per-request
> NLM processing) could also trigger an nlm_host garbage collection.  Now
> client-side nlm_host garbage collection occurs only during NFS mount
> processing.  Since the NFS client holds a reference on these nlm_host
> structures, they wouldn't have been affected by garbage collection
> anyway.
> 
> Given that nlm_lookup_host() reorders the nlm_host chain after every
> successful lookup, and that a garbage collection could be triggered during
> the call, we've removed a significant amount of per-NLM-request CPU
> processing overhead.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/clntproc.c |   21 ++++-----------------
>  1 files changed, 4 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> index a10343b..e31d10c 100644
> --- a/fs/lockd/clntproc.c
> +++ b/fs/lockd/clntproc.c
> @@ -148,30 +148,17 @@ static void nlmclnt_release_lockargs(struct nlm_rqst *req)
>  /*
>   * This is the main entry point for the NLM client.
>   */
> -int
> -nlmclnt_proc(struct inode *inode, int cmd, struct file_lock *fl)
> +int nlmclnt_proc(struct inode *inode, int cmd, struct file_lock *fl)
>  {
> -	struct rpc_clnt		*client = NFS_CLIENT(inode);
> -	struct sockaddr_in	addr;
> -	struct nfs_server	*nfssrv = NFS_SERVER(inode);
> -	struct nlm_host		*host;
> +	struct nlm_host		*host = NFS_SERVER(inode)->nlm_host;

I'm not overly happy to have the NLM code poke around in the internals
of the nfs_inode. Could we please pass the nlm_host as a parameter to
nlmclnt_proc, and then make a note to chase down the other existing
(ab)uses?

>  	struct nlm_rqst		*call;
>  	sigset_t		oldset;
>  	unsigned long		flags;
> -	int			status, vers;
> -
> -	vers = (NFS_PROTO(inode)->version == 3) ? 4 : 1;
> -	if (NFS_PROTO(inode)->version > 3) {
> -		printk(KERN_NOTICE "NFSv4 file locking not implemented!\n");
> -		return -ENOLCK;
> -	}
> +	int			status;
>  
> -	rpc_peeraddr(client, (struct sockaddr *) &addr, sizeof(addr));
> -	host = nlmclnt_lookup_host(&addr, client->cl_xprt->prot, vers,
> -				   nfssrv->nfs_client->cl_hostname,
> -				   strlen(nfssrv->nfs_client->cl_hostname));
>  	if (host == NULL)
>  		return -ENOLCK;
> +	nlm_get_host(host);
>  
>  	call = nlm_alloc_call(host);
>  	if (call == NULL)
> 

