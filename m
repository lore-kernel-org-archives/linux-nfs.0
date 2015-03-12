Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:42462 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928AbbCLP6O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2015 11:58:14 -0400
Received: by igkb16 with SMTP id b16so17624202igk.1
        for <linux-nfs@vger.kernel.org>; Thu, 12 Mar 2015 08:58:14 -0700 (PDT)
Message-ID: <1426175891.15787.2.camel@primarydata.com>
Subject: Re: [PATCH] SUNRPC: use jiffies_to_msecs for converting jiffies
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Nicholas Mc Guire <hofrat@osadl.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 12 Mar 2015 11:58:11 -0400
In-Reply-To: <1425374665-446-1-git-send-email-hofrat@osadl.org>
References: <1425374665-446-1-git-send-email-hofrat@osadl.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2015-03-03 at 04:24 -0500, Nicholas Mc Guire wrote:
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

Thanks! Applied.
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com




