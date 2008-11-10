From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 4/9] rpc: add an rpc_pipe_open method
Date: Mon, 10 Nov 2008 16:48:42 -0500
Message-ID: <1226353722.7599.105.camel@heimdal.trondhjem.org>
References: <20081109204621.GD27376@fieldses.org>
	 <1226264683-28650-1-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-2-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-3-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-4-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-5-git-send-email-bfields@citi.umich.edu>
	 <1226349322.7599.59.camel@heimdal.trondhjem.org>
	 <20081110203757.GI19053@fieldses.org> <20081110211856.GL19053@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30222 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbYKJVte (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2008 16:49:34 -0500
In-Reply-To: <20081110211856.GL19053@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-11-10 at 16:18 -0500, J. Bruce Fields wrote:
> On Mon, Nov 10, 2008 at 03:37:57PM -0500, bfields wrote:
> > On Mon, Nov 10, 2008 at 03:35:22PM -0500, Trond Myklebust wrote:
> > > BTW: This is racy. You have to set first_open _after_ you take the
> > > inode->i_mutex.
> > 
> > Whoops!  Good catch, thanks--fixed.
> 
> (Updated version follows.)

Err... This doesn't look right. This would be a mix of 4/9 and 5/9...

> --b.
> 
> commit 7f5c491a32857dc8ba587cc365a2d70024f7b33e
> Author: J. Bruce Fields <bfields@citi.umich.edu>
> Date:   Fri Nov 7 18:53:24 2008 -0500
> 
>     rpc: call release_pipe only on last close
>     
>     I can't see any reason we need to call this until either the kernel or
>     the last gssd closes the pipe.
>     
>     Also, this allows to guarantee that open_pipe and release_pipe are
>     called strictly in pairs; open_pipe on gssd's first open, release_pipe
>     on gssd's last close (or on the close of the kernel side of the pipe, if
>     that comes first).
>     
>     That will make it very easy for the gss code to keep track of which
>     pipes gssd is using.
>     
>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> 
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 4171ab7..f734103 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -126,13 +126,14 @@ rpc_close_pipes(struct inode *inode)
>  {
>  	struct rpc_inode *rpci = RPC_I(inode);
>  	struct rpc_pipe_ops *ops;
> +	int still_open;
>  
>  	mutex_lock(&inode->i_mutex);
>  	ops = rpci->ops;
>  	if (ops != NULL) {
>  		LIST_HEAD(free_list);
> -
>  		spin_lock(&inode->i_lock);
> +		still_open = rpci->nreaders != 0 || rpci->nwriters != 0;
>  		rpci->nreaders = 0;
>  		list_splice_init(&rpci->in_upcall, &free_list);
>  		list_splice_init(&rpci->pipe, &free_list);
> @@ -141,7 +142,7 @@ rpc_close_pipes(struct inode *inode)
>  		spin_unlock(&inode->i_lock);
>  		rpc_purge_list(rpci, &free_list, ops->destroy_msg, -EPIPE);
>  		rpci->nwriters = 0;
> -		if (ops->release_pipe)
> +		if (still_open && ops->release_pipe)
>  			ops->release_pipe(inode);
>  		cancel_delayed_work_sync(&rpci->queue_timeout);
>  	}
> @@ -169,12 +170,13 @@ static int
>  rpc_pipe_open(struct inode *inode, struct file *filp)
>  {
>  	struct rpc_inode *rpci = RPC_I(inode);
> -	int first_open = rpci->nreaders == 0 && rpci->nwriters == 0;
> +	int first_open;
>  	int res = -ENXIO;
>  
>  	mutex_lock(&inode->i_mutex);
>  	if (rpci->ops == NULL)
>  		goto out;
> +	first_open = rpci->nreaders == 0 && rpci->nwriters == 0;
>  	if (first_open && rpci->ops->open_pipe) {
>  		res = rpci->ops->open_pipe(inode);
>  		if (res)
> @@ -195,6 +197,7 @@ rpc_pipe_release(struct inode *inode, struct file *filp)
>  {
>  	struct rpc_inode *rpci = RPC_I(inode);
>  	struct rpc_pipe_msg *msg;
> +	int last_close;
>  
>  	mutex_lock(&inode->i_mutex);
>  	if (rpci->ops == NULL)
> @@ -221,7 +224,8 @@ rpc_pipe_release(struct inode *inode, struct file *filp)
>  					rpci->ops->destroy_msg, -EAGAIN);
>  		}
>  	}
> -	if (rpci->ops->release_pipe)
> +	last_close = rpci->nwriters == 0 && rpci->nreaders == 0;
> +	if (last_close && rpci->ops->release_pipe)
>  		rpci->ops->release_pipe(inode);
>  out:
>  	mutex_unlock(&inode->i_mutex);
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
