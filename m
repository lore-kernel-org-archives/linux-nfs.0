Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:59276 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751574AbcIHUHL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Sep 2016 16:07:11 -0400
Subject: Re: [PATCH 8/9] nfs: ensure that the filehandle in CB_NOTIFY_LOCK
 request matches the inode
To: Jeff Layton <jlayton@redhat.com>, <trond.myklebust@primarydata.com>
References: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
 <1473174760-29859-9-git-send-email-jlayton@redhat.com>
CC: <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <f366315b-817d-4040-64d5-8338a7f405dc@Netapp.com>
Date: Thu, 8 Sep 2016 16:07:07 -0400
MIME-Version: 1.0
In-Reply-To: <1473174760-29859-9-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

On 09/06/2016 11:12 AM, Jeff Layton wrote:
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/callback_proc.c |  2 +-
>  fs/nfs/nfs4proc.c      | 13 +++++++++++--
>  2 files changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 4ba6a8763f91..39a34d5083fe 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -645,7 +645,7 @@ __be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args, void *dummy,
>  	fc_tbl = &cps->clp->cl_session->fc_slot_table;
>  
>  	status = htonl(NFS4_OK);
> -	__wake_up(&cps->clp->cl_lock_waitq, TASK_NORMAL, 0, &args->cbnl_owner);
> +	__wake_up(&cps->clp->cl_lock_waitq, TASK_NORMAL, 0, args);
>  	return status;
>  }
>  #endif /* CONFIG_NFS_V4_1 */
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 3a6669063c44..6829b998776d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5533,6 +5533,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
>  
>  struct nfs4_lock_waiter {
>  	struct task_struct	*task;
> +	struct inode		*inode;
>  	struct nfs_lowner	*owner;
>  	bool			notified;
>  };
> @@ -5541,8 +5542,10 @@ static int
>  nfs4_wake_lock_waiter(wait_queue_t *wait, unsigned int mode, int flags, void *key)
>  {
>  	int ret;
> +	struct cb_notify_lock_args *cbnl = key;

I get this when I try compiling with CONFIG_NFS_V4=m but CONFIG_NFS_V4_1=n:

fs/nfs/nfs4proc.c: In function 'nfs4_wake_lock_waiter':
fs/nfs/nfs4proc.c:5491:35: error: dereferencing pointer to incomplete type 'struct cb_notify_lock_args'
  struct nfs_lowner *lowner = &cbnl->cbnl_owner,


Just thought you should know :)
Anna
                                   ^~
>  	struct nfs4_lock_waiter	*waiter	= wait->private;
> -	struct nfs_lowner	*lowner = key, *wowner = waiter->owner;
> +	struct nfs_lowner	*lowner = &cbnl->cbnl_owner,
> +				*wowner = waiter->owner;
>  
>  	/* Don't wake anybody if the string looked bogus */
>  	if (!lowner->id && !lowner->s_dev)
> @@ -5554,6 +5557,10 @@ nfs4_wake_lock_waiter(wait_queue_t *wait, unsigned int mode, int flags, void *ke
>  	    lowner->s_dev != wowner->s_dev)
>  		return 0;
>  
> +	/* Make sure it's for the right inode */
> +	if (nfs_compare_fh(NFS_FH(waiter->inode), &cbnl->cbnl_fh))
> +		return 0;
> +
>  	waiter->notified = true;
>  
>  	/* override "private" so we can use default_wake_function */
> @@ -6274,12 +6281,14 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
>  
>  	do {
>  		struct nfs4_lock_state *lsp = request->fl_u.nfs4_fl.owner;
> -		struct nfs_server *server = NFS_SERVER(lsp->ls_state->inode);
> +		struct inode *inode = lsp->ls_state->inode;
> +		struct nfs_server *server = NFS_SERVER(inode);
>  		struct nfs_client *clp = server->nfs_client;
>  		struct nfs_lowner owner = { .clientid = clp->cl_clientid,
>  					    .id = lsp->ls_seqid.owner_id,
>  					    .s_dev = server->s_dev };
>  		struct nfs4_lock_waiter waiter = { .task  = current,
> +						   .inode = inode,
>  						   .owner = &owner,
>  						   .notified = false };
>  		wait_queue_t wait;
> 

