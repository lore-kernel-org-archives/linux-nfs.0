From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 111/112] NFS: Add an asynchronous delegreturn operation
	for use in nfs_clear_inode
Date: Fri, 25 Jan 2008 13:20:18 -0500
Message-ID: <1201285218.24283.101.camel@heimdal.trondhjem.org>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080125163803.31887.55930.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:48884 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755704AbYAYSU4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 13:20:56 -0500
Received: from mail-mx8.uio.no ([129.240.10.38])
	by pat.uio.no with esmtp (Exim 4.67)
	(envelope-from <trond.myklebust@fys.uio.no>)
	id 1JITAc-0000nd-He
	for linux-nfs@vger.kernel.org; Fri, 25 Jan 2008 19:20:54 +0100
Received: from smtp.uio.no ([129.240.10.9] helo=mail-mx8.uio.no)
	by mail-mx8.uio.no with esmtp (Exim 4.67)
	(envelope-from <trond.myklebust@fys.uio.no>)
	id 1JITA5-0000dK-2f
	for linux-nfs@vger.kernel.org; Fri, 25 Jan 2008 19:20:21 +0100
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120] helo=[192.168.0.101])
	by mail-mx8.uio.no with esmtpsa (SSLv3:AES256-SHA:256)
	(Exim 4.67)
	(envelope-from <trond.myklebust@fys.uio.no>)
	id 1JITA4-0000cq-Bc
	for linux-nfs@vger.kernel.org; Fri, 25 Jan 2008 19:20:21 +0100
In-Reply-To: <20080125163803.31887.55930.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-01-25 at 11:38 -0500, Trond Myklebust wrote:
> Otherwise, there is a potential deadlock if the last dput() from an NFSv4
> close() or other asynchronous operation leads to nfs_clear_inode calling
> the synchronous delegreturn.

Full marks to any of you who noticed that I got the 'issync' parameters
in all the calls to nfs_do_return_delegation() wrong.

Sigh,..

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/delegation.c |   29 +++++++++++++++++++++++++----
>  fs/nfs/delegation.h |    3 ++-
>  fs/nfs/inode.c      |    2 +-
>  fs/nfs/nfs4proc.c   |   22 +++++++++++++---------
>  4 files changed, 41 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index b03dcd8..6970ebe 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -174,11 +174,11 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
>  	return status;
>  }
>  
> -static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *delegation)
> +static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *delegation, int issync)
>  {
>  	int res = 0;
>  
> -	res = nfs4_proc_delegreturn(inode, delegation->cred, &delegation->stateid);
> +	res = nfs4_proc_delegreturn(inode, delegation->cred, &delegation->stateid, issync);
>  	nfs_free_delegation(delegation);
>  	return res;
>  }
> @@ -208,7 +208,7 @@ static int __nfs_inode_return_delegation(struct inode *inode, struct nfs_delegat
>  	up_read(&clp->cl_sem);
>  	nfs_msync_inode(inode);
>  
> -	return nfs_do_return_delegation(inode, delegation);
> +	return nfs_do_return_delegation(inode, delegation, 0);
							     ^
						   should be 1
>  }
>  
>  static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
> @@ -228,6 +228,27 @@ nomatch:
>  	return NULL;
>  }
>  
> +/*
> + * This function returns the delegation without reclaiming opens
> + * or protecting against delegation reclaims.
> + * It is therefore really only safe to be called from
> + * nfs4_clear_inode()
> + */
> +void nfs_inode_return_delegation_noreclaim(struct inode *inode)
> +{
> +	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
> +	struct nfs_inode *nfsi = NFS_I(inode);
> +	struct nfs_delegation *delegation;
> +
> +	if (rcu_dereference(nfsi->delegation) != NULL) {
> +		spin_lock(&clp->cl_lock);
> +		delegation = nfs_detach_delegation_locked(nfsi, NULL);
> +		spin_unlock(&clp->cl_lock);
> +		if (delegation != NULL)
> +			nfs_do_return_delegation(inode, delegation, 1);
								      ^
						   	    should be 0
> +	}
> +}
> +
>  int nfs_inode_return_delegation(struct inode *inode)
>  {
>  	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
> @@ -388,7 +409,7 @@ static int recall_thread(void *data)
>  	nfs_msync_inode(inode);
>  
>  	if (delegation != NULL)
> -		nfs_do_return_delegation(inode, delegation);
> +		nfs_do_return_delegation(inode, delegation, 0);
							      ^
						    should be 1
>  	iput(inode);
>  	module_put_and_exit(0);
>  }
> diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
> index 5874ce7..f1c5e2a 100644
> --- a/fs/nfs/delegation.h
> +++ b/fs/nfs/delegation.h
> @@ -29,6 +29,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
>  void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
>  int nfs_inode_return_delegation(struct inode *inode);
>  int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid);
> +void nfs_inode_return_delegation_noreclaim(struct inode *inode);
>  
>  struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs_fh *fhandle);
>  void nfs_return_all_delegations(struct super_block *sb);
> @@ -39,7 +40,7 @@ void nfs_delegation_mark_reclaim(struct nfs_client *clp);
>  void nfs_delegation_reap_unclaimed(struct nfs_client *clp);
>  
>  /* NFSv4 delegation-related procedures */
> -int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid);
> +int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync);
>  int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid);
>  int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl);
>  int nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode);
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 5d381cf..3f332e5 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1145,7 +1145,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  void nfs4_clear_inode(struct inode *inode)
>  {
>  	/* If we are holding a delegation, return it! */
> -	nfs_inode_return_delegation(inode);
> +	nfs_inode_return_delegation_noreclaim(inode);
>  	/* First call standard NFS clear_inode() code */
>  	nfs_clear_inode(inode);
>  }
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index ffe5584..90392a2 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2995,7 +2995,7 @@ static const struct rpc_call_ops nfs4_delegreturn_ops = {
>  	.rpc_release = nfs4_delegreturn_release,
>  };
>  
> -static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid)
> +static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync)
>  {
>  	struct nfs4_delegreturndata *data;
>  	struct nfs_server *server = NFS_SERVER(inode);
> @@ -3009,7 +3009,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
>  		.callback_ops = &nfs4_delegreturn_ops,
>  		.flags = RPC_TASK_ASYNC,
>  	};
> -	int status;
> +	int status = 0;
>  
>  	data = kmalloc(sizeof(*data), GFP_KERNEL);
>  	if (data == NULL)
> @@ -3032,23 +3032,27 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
>  	task = rpc_run_task(&task_setup_data);
>  	if (IS_ERR(task))
>  		return PTR_ERR(task);
> +	if (!issync)
> +		goto out;
>  	status = nfs4_wait_for_completion_rpc_task(task);
> -	if (status == 0) {
> -		status = data->rpc_status;
> -		if (status == 0)
> -			nfs_refresh_inode(inode, &data->fattr);
> -	}
> +	if (status != 0)
> +		goto out;
> +	status = data->rpc_status;
> +	if (status != 0)
> +		goto out;
> +	nfs_refresh_inode(inode, &data->fattr);
> +out:
>  	rpc_put_task(task);
>  	return status;
>  }
>  
> -int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid)
> +int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync)
>  {
>  	struct nfs_server *server = NFS_SERVER(inode);
>  	struct nfs4_exception exception = { };
>  	int err;
>  	do {
> -		err = _nfs4_proc_delegreturn(inode, cred, stateid);
> +		err = _nfs4_proc_delegreturn(inode, cred, stateid, issync);
>  		switch (err) {
>  			case -NFS4ERR_STALE_STATEID:
>  			case -NFS4ERR_EXPIRED:
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

