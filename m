From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/5] can: af_can.c use rcu_barrier() on module unload.
Date: Mon, 8 Jun 2009 09:13:29 -0700
Message-ID: <20090608161329.GD6961@linux.vnet.ibm.com>
References: <20090608130959.10052.54590.stgit@localhost> <20090608131138.10052.5408.stgit@localhost>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de, wg@grandegger.com,
	vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090608131138.10052.5408.stgit@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 08, 2009 at 03:11:38PM +0200, Jesper Dangaard Brouer wrote:
> This module uses rcu_call() thus it should use rcu_barrier()
> on module unload.

This does appear to make things better!!!

However, I don't understand why it is safe to do the following in
can_exit():

	hlist_for_each_entry_safe(d, n, next, &can_rx_dev_list, list) {
		hlist_del(&d->list);
		kfree(d);
	}

Given that this list is scanned by RCU readers, shouldn't this kfree()
be something like "call_rcu(&d->rcu, can_rx_delete_device);"?

Also, what frees up the "struct receiver" structures?

							Thanx, Paul

> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> ---
> 
>  net/can/af_can.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/can/af_can.c b/net/can/af_can.c
> index 10f0528..e733725 100644
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -903,6 +903,8 @@ static __exit void can_exit(void)
>  	}
>  	spin_unlock(&can_rcvlists_lock);
> 
> +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
> +
>  	kmem_cache_destroy(rcv_cache);
>  }
> 
> 
