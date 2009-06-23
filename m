From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 10/10] nf_conntrack: Use rcu_barrier().
Date: Tue, 23 Jun 2009 18:23:33 +0200
Message-ID: <4A410185.3090706@trash.net>
References: <20090623150330.22490.87327.stgit@localhost> <20090623150444.22490.27931.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net,
	axboe@kernel.dk, christine.caulfield@googlemail.com,
	Trond.Myklebust@netapp.com, linux-wireless@vger.kernel.org,
	johannes@sipsolutions.net, yoshfuji@linux-ipv6.org,
	shemminger@linux-foundation.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org,
	tytso@mit.edu, adilger@sun.com, netfilter-devel@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <20090623150444.22490.27931.stgit@localhost>
Sender: linux-ext4-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> I'm not sure which is are most optimal place to call rcu_barrier().
> The patch probably calls rcu_barrier() too much, but its a better
> safe than sorry approach.
> 
> There is embedded some comments that I would like Patrick McHardy
> to look at.
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 5f72b94..cea4537 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1084,6 +1084,8 @@ static void nf_conntrack_cleanup_init_net(void)
>  {
>  	nf_conntrack_helper_fini();
>  	nf_conntrack_proto_fini();
> +	rcu_barrier();
> +	/* Need to wait for call_rcu() before dealloc the kmem_cache */
>  	kmem_cache_destroy(nf_conntrack_cachep);

Which call_rcu() is this referring to? If its the conntrack destruction,
that one is gone in the current kernel and I think destruction is
handled properly by the sl*b-allocators (SLAB_DESTROY_BY_RCU).

> @@ -1118,6 +1120,9 @@ void nf_conntrack_cleanup(struct net *net)
>  	/* This makes sure all current packets have passed through
>  	   netfilter framework.  Roll on, two-stage module
>  	   delete... */
> +	/* hawk@comx.dk 2009-06-20: Think this should be replaced by a
> +          rcu_barrier() ???
> +	*/
>  	synchronize_net();

AFAICT this one is used to make sure the old value of the ip_ct_attach
hook is not visible anymore before beginning cleanup and is not needed
for anything else.

>  	nf_conntrack_cleanup_net(net);
> diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
> index 1935153..29c6cd0 100644
> --- a/net/netfilter/nf_conntrack_standalone.c
> +++ b/net/netfilter/nf_conntrack_standalone.c
> @@ -500,6 +500,8 @@ static void nf_conntrack_net_exit(struct net *net)
>  	nf_conntrack_standalone_fini_sysctl(net);
>  	nf_conntrack_standalone_fini_proc(net);
>  	nf_conntrack_cleanup(net);
> +	/* hawk@comx.dk: Think rcu_barrier() should to be called earlier? */
> +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
>  }

Which call_rcu() is this referring to? We should place them in
the cleanup sub-functions to make this clearly visible.
