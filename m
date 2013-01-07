Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f45.google.com ([209.85.212.45]:40728 "EHLO
	mail-vb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785Ab3AGUU3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2013 15:20:29 -0500
Received: by mail-vb0-f45.google.com with SMTP id p1so19763156vbi.4
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jan 2013 12:20:28 -0800 (PST)
Date: Mon, 7 Jan 2013 15:20:21 -0500
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Possible Race Condition on SIGKILL
Message-ID: <20130107202021.GC16957@nyc-qws-132.nyc.delacy.com>
References: <20130107185848.GB16957@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91199197E@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91199197E@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 07, 2013 at 07:50:10PM +0000, Myklebust, Trond wrote:
> Hi Chris,
> 
> Excellent sleuthing! Given the thoroughness of your explanation, I'm
> pretty sure that the attached patch should fix the problem.
> 
> Cheers
>   Trond
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

> From ec8cbb4aff21cd0eac2c6f3fc4273ac72cdd91ef Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Mon, 7 Jan 2013 14:30:46 -0500
> Subject: [PATCH] SUNRPC: Ensure we release the socket write lock if the
>  rpc_task exits early
> 
> If the rpc_task exits while holding the socket write lock before it has
> allocated an rpc slot, then the usual mechanism for releasing the write
> lock in xprt_release() is defeated.
> 
> The problem occurs if the call to xprt_lock_write() initially fails, so
> that the rpc_task is put on the xprt->sending wait queue. If the task
> exits after being assigned the lock by __xprt_lock_write_func, but
> before it has retried the call to xprt_lock_and_alloc_slot(), then
> it calls xprt_release() while holding the write lock, but will
> immediately exit due to the test for task->tk_rqstp != NULL.
> 
> Reported-by: Chris Perl <chris.perl@gmail.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: stable@vger.kernel.org [>= 3.1]
> ---
>  net/sunrpc/xprt.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index bd462a5..6676457 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1136,10 +1136,12 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
>  void xprt_release(struct rpc_task *task)
>  {
>  	struct rpc_xprt	*xprt;
> -	struct rpc_rqst	*req;
> +	struct rpc_rqst	*req = task->tk_rqstp;
>  
> -	if (!(req = task->tk_rqstp))
> +	if (req == NULL) {
> +		xprt_release_write(task->tk_xprt, task);
>  		return;
> +	}
>  
>  	xprt = req->rq_xprt;
>  	if (task->tk_ops->rpc_count_stats != NULL)
> -- 
> 1.7.11.7
> 

Ah, I totally missed the call to `rpc_release_task' at the bottom of the
`__rpc_execute' loop (at least thats how I think we'd get to this function
you're patching).

But wouldn't we need to update the call site in
`rpc_release_resources_task' as well?  It contains an explicit check for
`task->tk_rqstp' being non null.
