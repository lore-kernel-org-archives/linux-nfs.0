Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52800 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754065Ab0ILXsv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Sep 2010 19:48:51 -0400
Date: Sun, 12 Sep 2010 19:47:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix race corrupting rpc upcall list
Message-ID: <20100912234748.GC9402@fieldses.org>
References: <20100828170953.GB5104@fieldses.org>
 <20100830175728.GA18764@fieldses.org>
 <20100907050142.GA14584@fieldses.org>
 <20100907051241.GB14584@fieldses.org>
 <1284325666.11048.69.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1284325666.11048.69.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Sep 12, 2010 at 05:07:46PM -0400, Trond Myklebust wrote:
> On Tue, 2010-09-07 at 01:12 -0400, J. Bruce Fields wrote:
> > From: J. Bruce Fields <bfields@redhat.com>
> > 
> > If rpc_queue_upcall() adds a new upcall to the rpci->pipe list just
> > after rpc_pipe_release calls rpc_purge_list(), but before it calls
> > gss_pipe_release (as rpci->ops->release_pipe(inode)), then the latter
> > will free a message without deleting it from the rpci->pipe list.
> > 
> > We will be left with a freed object on the rpc->pipe list.  Most
> > frequent symptoms are kernel crashes in rpc.gssd system calls on the
> > pipe in question.
> > 
> > We could just add a list_del(&gss_msg->msg.list) here.  But I can see no
> > reason for doing all this cleanup here; the preceding rpc_purge_list()
> > should have done the job, except possibly for any newly queued upcalls
> > as above, which can safely be left to wait for another opener.
> 
> Hi Bruce,
> 
> Looking again at this issue, I think I see why the ->release_pipe() is
> needed. While the call to rpc_purge_list() does indeed clear the list of
> all those messages that are waiting for their upcall to complete, it
> does nothing for the messages that have successfully been read by the
> daemon, but are now waiting for a reply.

Doh!

> How about something like the patch below instead?

I read it over, and it looks sensible to me.

It's also survived a few testing iterations.  I'll give it a few more
just out of paranoia, but would be surprised if they find the problem
isn't resolved.

--b.

> 
> Cheers
>   Trond
> 
> -------------------------------------------------------------------------------------------
> SUNRPC: Fix race corrupting rpc upcall
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> If rpc_queue_upcall() adds a new upcall to the rpci->pipe list just
> after rpc_pipe_release calls rpc_purge_list(), but before it calls
> gss_pipe_release (as rpci->ops->release_pipe(inode)), then the latter
> will free a message without deleting it from the rpci->pipe list.
> 
> We will be left with a freed object on the rpc->pipe list.  Most
> frequent symptoms are kernel crashes in rpc.gssd system calls on the
> pipe in question.
> 
> Reported-by: J. Bruce Fields <bfields@redhat.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  net/sunrpc/auth_gss/auth_gss.c |    9 +++++----
>  net/sunrpc/rpc_pipe.c          |    6 +++---
>  2 files changed, 8 insertions(+), 7 deletions(-)
> 
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index dcfc66b..12c4859 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -745,17 +745,18 @@ gss_pipe_release(struct inode *inode)
>  	struct rpc_inode *rpci = RPC_I(inode);
>  	struct gss_upcall_msg *gss_msg;
>  
> +restart:
>  	spin_lock(&inode->i_lock);
> -	while (!list_empty(&rpci->in_downcall)) {
> +	list_for_each_entry(gss_msg, &rpci->in_downcall, list) {
>  
> -		gss_msg = list_entry(rpci->in_downcall.next,
> -				struct gss_upcall_msg, list);
> +		if (!list_empty(&gss_msg->msg.list))
> +			continue;
>  		gss_msg->msg.errno = -EPIPE;
>  		atomic_inc(&gss_msg->count);
>  		__gss_unhash_msg(gss_msg);
>  		spin_unlock(&inode->i_lock);
>  		gss_release_msg(gss_msg);
> -		spin_lock(&inode->i_lock);
> +		goto restart;
>  	}
>  	spin_unlock(&inode->i_lock);
>  
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 95ccbcf..41a762f 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -48,7 +48,7 @@ static void rpc_purge_list(struct rpc_inode *rpci, struct list_head *head,
>  		return;
>  	do {
>  		msg = list_entry(head->next, struct rpc_pipe_msg, list);
> -		list_del(&msg->list);
> +		list_del_init(&msg->list);
>  		msg->errno = err;
>  		destroy_msg(msg);
>  	} while (!list_empty(head));
> @@ -208,7 +208,7 @@ rpc_pipe_release(struct inode *inode, struct file *filp)
>  	if (msg != NULL) {
>  		spin_lock(&inode->i_lock);
>  		msg->errno = -EAGAIN;
> -		list_del(&msg->list);
> +		list_del_init(&msg->list);
>  		spin_unlock(&inode->i_lock);
>  		rpci->ops->destroy_msg(msg);
>  	}
> @@ -268,7 +268,7 @@ rpc_pipe_read(struct file *filp, char __user *buf, size_t len, loff_t *offset)
>  	if (res < 0 || msg->len == msg->copied) {
>  		filp->private_data = NULL;
>  		spin_lock(&inode->i_lock);
> -		list_del(&msg->list);
> +		list_del_init(&msg->list);
>  		spin_unlock(&inode->i_lock);
>  		rpci->ops->destroy_msg(msg);
>  	}
> 
