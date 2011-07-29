Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59623 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844Ab1G2QmT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2011 12:42:19 -0400
Date: Fri, 29 Jul 2011 12:42:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>,
        David Miller <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Greg Banks <gnb@fastmail.fm>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Message-ID: <20110729164214.GI23194@fieldses.org>
References: <1311876249.2346.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311876249.2346.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 28, 2011 at 08:04:09PM +0200, Eric Dumazet wrote:
> Use NUMA aware allocations to reduce latencies and increase throughput.
> 
> sunrpc kthreads can use kthread_create_on_node() if pool_mode is
> "percpu" or "pernode", and svc_prepare_thread()/svc_init_buffer() can
> also take into account NUMA node affinity for memory allocations.
...
> @@ -662,14 +675,16 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
>  		nrservs--;
>  		chosen_pool = choose_pool(serv, pool, &state);
>  
> -		rqstp = svc_prepare_thread(serv, chosen_pool);
> +		node = svc_pool_map_get_node(chosen_pool->sp_id);
> +		rqstp = svc_prepare_thread(serv, chosen_pool, node);

The only correct value for the third argument there is
svc_pool_map_get_node(chosen_pool->sp_id), so let's have
svc_prepare_thread() call that itself.

Seems OK otherwise.

Any suggestions on how we should test this?

--b.

>  		if (IS_ERR(rqstp)) {
>  			error = PTR_ERR(rqstp);
>  			break;
>  		}
>  
>  		__module_get(serv->sv_module);
> -		task = kthread_create(serv->sv_function, rqstp, serv->sv_name);
> +		task = kthread_create_on_node(serv->sv_function, rqstp,
> +					      node, serv->sv_name);
>  		if (IS_ERR(task)) {
>  			error = PTR_ERR(task);
>  			module_put(serv->sv_module);
> 
> 
