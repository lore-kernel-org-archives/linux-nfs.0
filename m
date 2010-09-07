Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33794 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932142Ab0IGRZK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 13:25:10 -0400
Date: Tue, 7 Sep 2010 13:24:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix race corrupting rpc upcall list
Message-ID: <20100907172420.GA13022@fieldses.org>
References: <20100828170953.GB5104@fieldses.org>
 <20100830175728.GA18764@fieldses.org>
 <20100907050142.GA14584@fieldses.org>
 <20100907051241.GB14584@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100907051241.GB14584@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Oh, and I have no idea why this problem is suddenly easier to reproduce
on 2.6.36.  Maybe there's some obvious patch I overlooked, but I didn't
see anything on a quick skim of the history.  I made an attempt at
bisecting, but couldn't get a test case that reproduced the problem
reliably enough.

--b.

On Tue, Sep 07, 2010 at 01:12:41AM -0400, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@redhat.com>
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
> We could just add a list_del(&gss_msg->msg.list) here.  But I can see no
> reason for doing all this cleanup here; the preceding rpc_purge_list()
> should have done the job, except possibly for any newly queued upcalls
> as above, which can safely be left to wait for another opener.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 36eee66..8ad9a34 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -744,23 +744,6 @@ static int gss_pipe_open_v1(struct inode *inode)
>  static void
>  gss_pipe_release(struct inode *inode)
>  {
> -	struct rpc_inode *rpci = RPC_I(inode);
> -	struct gss_upcall_msg *gss_msg;
> -
> -	spin_lock(&inode->i_lock);
> -	while (!list_empty(&rpci->in_downcall)) {
> -
> -		gss_msg = list_entry(rpci->in_downcall.next,
> -				struct gss_upcall_msg, list);
> -		gss_msg->msg.errno = -EPIPE;
> -		atomic_inc(&gss_msg->count);
> -		__gss_unhash_msg(gss_msg);
> -		spin_unlock(&inode->i_lock);
> -		gss_release_msg(gss_msg);
> -		spin_lock(&inode->i_lock);
> -	}
> -	spin_unlock(&inode->i_lock);
> -
>  	put_pipe_version();
>  }
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
