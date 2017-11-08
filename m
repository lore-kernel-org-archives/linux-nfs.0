Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50816 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752354AbdKHUTe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Nov 2017 15:19:34 -0500
Date: Wed, 8 Nov 2017 15:19:33 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH 2/4] lockd: remove net pointer from messages
Message-ID: <20171108201933.GO24262@fieldses.org>
References: <4095144d-bdb0-23ed-a126-06ebb6796023@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4095144d-bdb0-23ed-a126-06ebb6796023@virtuozzo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applying for 4.15.

--b.

On Wed, Nov 08, 2017 at 08:55:55AM +0300, Vasily Averin wrote:
> Publishing of net pointer is not safe,
> use net->ns.inum as net ID in debug messages
> 
> [  171.757678] lockd_up_net: per-net data created; net=f00001e7
> [  171.767188] NFSD: starting 90-second grace period (net f00001e7)
> [  300.653313] lockd: nuking all hosts in net f00001e7...
> [  300.653641] lockd: host garbage collection for net f00001e7
> [  300.653968] lockd: nlmsvc_mark_resources for net f00001e7
> [  300.711483] lockd_down_net: per-net data destroyed; net=f00001e7
> [  300.711847] lockd: nuking all hosts in net 0...
> [  300.711847] lockd: host garbage collection for net 0
> [  300.711848] lockd: nlmsvc_mark_resources for net 0
> 
> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> ---
>  fs/lockd/host.c    | 21 +++++++++++++--------
>  fs/lockd/mon.c     |  3 ++-
>  fs/lockd/svc.c     |  9 +++++----
>  fs/lockd/svcsubs.c |  2 +-
>  4 files changed, 21 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 0d4e590..f90f6d5 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -578,8 +578,10 @@ static void nlm_complain_hosts(struct net *net)
>  
>  		if (ln->nrhosts == 0)
>  			return;
> -		printk(KERN_WARNING "lockd: couldn't shutdown host module for net %p!\n", net);
> -		dprintk("lockd: %lu hosts left in net %p:\n", ln->nrhosts, net);
> +		pr_warn("lockd: couldn't shutdown host module for net %x!\n",
> +			net->ns.inum);
> +		dprintk("lockd: %lu hosts left in net %x:\n", ln->nrhosts,
> +			net->ns.inum);
>  	} else {
>  		if (nrhosts == 0)
>  			return;
> @@ -590,9 +592,9 @@ static void nlm_complain_hosts(struct net *net)
>  	for_each_host(host, chain, nlm_server_hosts) {
>  		if (net && host->net != net)
>  			continue;
> -		dprintk("       %s (cnt %d use %d exp %ld net %p)\n",
> +		dprintk("       %s (cnt %d use %d exp %ld net %x)\n",
>  			host->h_name, atomic_read(&host->h_count),
> -			host->h_inuse, host->h_expires, host->net);
> +			host->h_inuse, host->h_expires, host->net->ns.inum);
>  	}
>  }
>  
> @@ -605,7 +607,8 @@ nlm_shutdown_hosts_net(struct net *net)
>  	mutex_lock(&nlm_host_mutex);
>  
>  	/* First, make all hosts eligible for gc */
> -	dprintk("lockd: nuking all hosts in net %p...\n", net);
> +	dprintk("lockd: nuking all hosts in net %x...\n",
> +		net ? net->ns.inum : 0);
>  	for_each_host(host, chain, nlm_server_hosts) {
>  		if (net && host->net != net)
>  			continue;
> @@ -646,7 +649,8 @@ nlm_gc_hosts(struct net *net)
>  	struct hlist_node *next;
>  	struct nlm_host	*host;
>  
> -	dprintk("lockd: host garbage collection for net %p\n", net);
> +	dprintk("lockd: host garbage collection for net %x\n",
> +		net ? net->ns.inum : 0);
>  	for_each_host(host, chain, nlm_server_hosts) {
>  		if (net && host->net != net)
>  			continue;
> @@ -662,9 +666,10 @@ nlm_gc_hosts(struct net *net)
>  		if (atomic_read(&host->h_count) || host->h_inuse
>  		 || time_before(jiffies, host->h_expires)) {
>  			dprintk("nlm_gc_hosts skipping %s "
> -				"(cnt %d use %d exp %ld net %p)\n",
> +				"(cnt %d use %d exp %ld net %x)\n",
>  				host->h_name, atomic_read(&host->h_count),
> -				host->h_inuse, host->h_expires, host->net);
> +				host->h_inuse, host->h_expires,
> +				host->net->ns.inum);
>  			continue;
>  		}
>  		nlm_destroy_host_locked(host);
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 9fbbd11..96cfb29 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -110,7 +110,8 @@ static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res,
>  	clnt = nsm_create(host->net, host->nodename);
>  	if (IS_ERR(clnt)) {
>  		dprintk("lockd: failed to create NSM upcall transport, "
> -			"status=%ld, net=%p\n", PTR_ERR(clnt), host->net);
> +			"status=%ld, net=%x\n", PTR_ERR(clnt),
> +			host->net->ns.inum);
>  		return PTR_ERR(clnt);
>  	}
>  
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index b995bdc..5a1d8dc 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -259,7 +259,7 @@ static int lockd_up_net(struct svc_serv *serv, struct net *net)
>  	if (error < 0)
>  		goto err_bind;
>  	set_grace_period(net);
> -	dprintk("lockd_up_net: per-net data created; net=%p\n", net);
> +	dprintk("%s: per-net data created; net=%x\n", __func__, net->ns.inum);
>  	return 0;
>  
>  err_bind:
> @@ -275,11 +275,12 @@ static void lockd_down_net(struct svc_serv *serv, struct net *net)
>  		if (--ln->nlmsvc_users == 0) {
>  			nlm_shutdown_hosts_net(net);
>  			svc_shutdown_net(serv, net);
> -			dprintk("lockd_down_net: per-net data destroyed; net=%p\n", net);
> +			dprintk("%s: per-net data destroyed; net=%x\n",
> +				__func__, net->ns.inum);
>  		}
>  	} else {
> -		printk(KERN_ERR "lockd_down_net: no users! task=%p, net=%p\n",
> -				nlmsvc_task, net);
> +		pr_err("%s: no users! task=%p, net=%x\n",
> +			__func__, nlmsvc_task, net->ns.inum);
>  		BUG();
>  	}
>  }
> diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
> index a563ddb..4ec3d6e 100644
> --- a/fs/lockd/svcsubs.c
> +++ b/fs/lockd/svcsubs.c
> @@ -370,7 +370,7 @@ nlmsvc_mark_resources(struct net *net)
>  {
>  	struct nlm_host hint;
>  
> -	dprintk("lockd: nlmsvc_mark_resources for net %p\n", net);
> +	dprintk("lockd: %s for net %x\n", __func__, net ? net->ns.inum : 0);
>  	hint.net = net;
>  	nlm_traverse_files(&hint, nlmsvc_mark_host, NULL);
>  }
> -- 
> 2.7.4
