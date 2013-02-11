Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:52945 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369Ab3BKGTl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2013 01:19:41 -0500
Message-ID: <51188D2A.4070605@parallels.com>
Date: Mon, 11 Feb 2013 10:18:18 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <akpm@linux-foundation.org>, <linux-nfs@vger.kernel.org>,
        <Trond.Myklebust@netapp.com>, <linux-kernel@vger.kernel.org>,
        <devel@openvz.org>
Subject: Re: [PATCH 0/2] NFSD: fix races in service per-net resources allocation
References: <20130201111046.24066.72836.stgit@localhost.localdomain> <20130211002558.GD10161@fieldses.org>
In-Reply-To: <20130211002558.GD10161@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.02.2013 04:25, J. Bruce Fields пишет:
> On Fri, Feb 01, 2013 at 02:28:21PM +0300, Stanislav Kinsbursky wrote:
>> After "NFS" (SUNRPC + NFSd actually) containerization work some basic
>> principles of SUNRPC service initialization and deinitialization has been
>> changed: now one service can be shared between different network namespaces
>> and network "resources" can be attached or detached from the running service.
>> This leads to races, described here:
>>
>> https://bugzilla.redhat.com/show_bug.cgi?id=904870
>>
>> and which this small patch set is aimed to solve by using per-cpu rw semphores
>> to sync per-net resources processing and shutdown.
>
> Sorry for the slow response.  I think this is probably correct.
>
> But I think we got into this mess because the server shutdown logic is
> too complicated.  So I'd prefer to find a way to fix the problem by
> simplifying things rather than by adding another lock.
>

Yeah, I wasn't satisfied with the patch I send. It was just an attempt to fix the issue fast.
Simplifying the logic instead of one more lock (there are too many of them already) is much better.
Thanks!

> Do you see anything wrong with the following?
>

This one looks a bit complicated and confusing to me. Probably because I'm not that familiar with service transports processing logic.
So, as I can see, we now try to run over all per-net pool-assigned transports, remove them from "ready" queue and delete one by one.
Then we try to enqueue all temporary sockets. But where in enqueueing of permanent sockets? I.e. how does they be destroyed with this patch?
Then we once again try to run over all per-net pool-assigned transports, remove them from "ready" queue and delete one by one.
Why twice? I.e. why not just lose them, then enqueue them and svc_clean_up_xprts()?

> --b
>
> commit e8202f39f84b8863337f55159dd18478b9ccb616
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Sun Feb 10 16:08:11 2013 -0500
>
>      svcrpc: fix and simplify server shutdown
>
>      Simplify server shutdown, and make it correct whether or not there are
>      still threads running (as will happen in the case we're only shutting
>      down the service in one network namespace).
>
>      Do that by doing what we'd do in normal circumstances: just CLOSE each
>      socket, then enqueue it.
>
>      Since there may not be threads to handle the resulting queued xprts,
>      also run a simplified version of the svc_recv() loop run by a server to
>      clean up any closed xprts afterwards.
>
>      Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 024a241..a98e818 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -966,12 +966,12 @@ static void svc_close_list(struct svc_serv *serv, struct list_head *xprt_list, s
>   		if (xprt->xpt_net != net)
>   			continue;
>   		set_bit(XPT_CLOSE, &xprt->xpt_flags);
> -		set_bit(XPT_BUSY, &xprt->xpt_flags);
> +		svc_xprt_enqueue(xprt);
>   	}
>   	spin_unlock(&serv->sv_lock);
>   }
>
> -static void svc_clear_pools(struct svc_serv *serv, struct net *net)
> +static struct svc_xprt *svc_dequeue_net(struct svc_serv *serv, struct net *net)
>   {
>   	struct svc_pool *pool;
>   	struct svc_xprt *xprt;
> @@ -986,42 +986,31 @@ static void svc_clear_pools(struct svc_serv *serv, struct net *net)
>   			if (xprt->xpt_net != net)
>   				continue;
>   			list_del_init(&xprt->xpt_ready);
> +			spin_unlock_bh(&pool->sp_lock);
> +			return xprt;
>   		}
>   		spin_unlock_bh(&pool->sp_lock);
>   	}
> +	return NULL;
>   }
>
> -static void svc_clear_list(struct svc_serv *serv, struct list_head *xprt_list, struct net *net)
> +static void svc_clean_up_xprts(struct svc_serv *serv, struct net *net)
>   {
>   	struct svc_xprt *xprt;
> -	struct svc_xprt *tmp;
> -	LIST_HEAD(victims);
>
> -	spin_lock(&serv->sv_lock);
> -	list_for_each_entry_safe(xprt, tmp, xprt_list, xpt_list) {
> -		if (xprt->xpt_net != net)
> -			continue;
> -		list_move(&xprt->xpt_list, &victims);
> -	}
> -	spin_unlock(&serv->sv_lock);
> -
> -	list_for_each_entry_safe(xprt, tmp, &victims, xpt_list)
> +	while ((xprt = svc_dequeue_net(serv, net))) {
> +		if (!test_bit(XPT_CLOSE, &xprt->xpt_flags))
> +			pr_err("found un-closed xprt on service shutdown\n");
>   		svc_delete_xprt(xprt);
> +	}
>   }
>
>   void svc_close_net(struct svc_serv *serv, struct net *net)
>   {
> -	svc_close_list(serv, &serv->sv_tempsocks, net);
>   	svc_close_list(serv, &serv->sv_permsocks, net);
> -
> -	svc_clear_pools(serv, net);
> -	/*
> -	 * At this point the sp_sockets lists will stay empty, since
> -	 * svc_xprt_enqueue will not add new entries without taking the
> -	 * sp_lock and checking XPT_BUSY.
> -	 */
> -	svc_clear_list(serv, &serv->sv_tempsocks, net);
> -	svc_clear_list(serv, &serv->sv_permsocks, net);
> +	svc_clean_up_xprts(serv, net);
> +	svc_close_list(serv, &serv->sv_tempsocks, net);
> +	svc_clean_up_xprts(serv, net);
>   }
>
>   /*
>


-- 
Best regards,
Stanislav Kinsbursky
