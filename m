Return-Path: linux-nfs-owner@vger.kernel.org
Received: from perches-mx.perches.com ([206.117.179.246]:43087 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752498Ab2GTQvA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jul 2012 12:51:00 -0400
Message-ID: <1342803059.21447.45.camel@joe2Laptop>
Subject: Re: [PATCH] sunrpc: clnt: Add missing braces
From: Joe Perches <joe@perches.com>
To: "David S. Miller" <davem@davemloft.net>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Fri, 20 Jul 2012 09:50:59 -0700
In-Reply-To: <1342635431.9551.41.camel@joe2Laptop>
References: <1342635431.9551.41.camel@joe2Laptop>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-07-18 at 11:17 -0700, Joe Perches wrote:
> Add a missing set of braces that commit 4e0038b6b24
> ("SUNRPC: Move clnt->cl_server into struct rpc_xprt")
> forgot.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/sunrpc/clnt.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index f56f045..aaf70aa 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1844,12 +1844,13 @@ call_timeout(struct rpc_task *task)
>  		return;
>  	}
>  	if (RPC_IS_SOFT(task)) {
> -		if (clnt->cl_chatty)
> +		if (clnt->cl_chatty) {
>  			rcu_read_lock();
>  			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
>  				clnt->cl_protname,
>  				rcu_dereference(clnt->cl_xprt)->servername);
>  			rcu_read_unlock();
> +		}
>  		if (task->tk_flags & RPC_TASK_TIMEOUT)
>  			rpc_exit(task, -ETIMEDOUT);
>  		else

Hi David.

I think it'd be good to get this into 3.6 as a bug fix.

This is marked in netdev patchwork as "not applicable".

Do you need the sunrpc maintainers to apply or ack it
and then push it to you?

Trond?  Bruce?

