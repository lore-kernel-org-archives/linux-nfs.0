Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:57363 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754821AbbCCPSY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 10:18:24 -0500
Date: Tue, 3 Mar 2015 10:18:22 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: use jiffies_to_msecs for converting jiffies
Message-ID: <20150303151822.GA19439@fieldses.org>
References: <1425374665-446-1-git-send-email-hofrat@osadl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1425374665-446-1-git-send-email-hofrat@osadl.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'll assume Trond or Anna gets this one.--b.

On Tue, Mar 03, 2015 at 04:24:25AM -0500, Nicholas Mc Guire wrote:
> Use jiffies_to_msecs for converting jiffies as it handles all of the corner
> cases reliably and also helps readability.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> ---
> 
> This was only compile tested for x86_64_defconfig (implies CONFIG_SUNRPC=y)
> 
> Patch is against 4.0-rc1 (localversion-next is -next-20150303)
> 
>  net/sunrpc/sched.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index b91fd9c..c234e7f 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -90,7 +90,7 @@ __rpc_add_timer(struct rpc_wait_queue *queue, struct rpc_task *task)
>  		return;
>  
>  	dprintk("RPC: %5u setting alarm for %lu ms\n",
> -			task->tk_pid, task->tk_timeout * 1000 / HZ);
> +			task->tk_pid, jiffies_to_msecs(task->tk_timeout));
>  
>  	task->u.tk_wait.expires = jiffies + task->tk_timeout;
>  	if (list_empty(&queue->timer_list.list) || time_before(task->u.tk_wait.expires, queue->timer_list.expires))
> -- 
> 1.7.10.4
