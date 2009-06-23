From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 04/10] sunrpc: Use rcu_barrier() on unload.
Date: Tue, 23 Jun 2009 12:59:13 -0400
Message-ID: <1245776353.9586.1.camel@heimdal.trondhjem.org>
References: <20090623150330.22490.87327.stgit@localhost>
	 <20090623150414.22490.14888.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net,
	axboe@kernel.dk, Patrick McHardy <kaber@trash.net>,
	christine.caulfield@googlemail.com, linux-wireless@vger.kernel.org,
	johannes@sipsolutions.net, yoshfuji@linux-ipv6.org,
	shemminger@linux-foundation.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org,
	tytso@mit.edu, adilger@sun.com, netfilter-devel@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090623150414.22490.14888.stgit@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-06-23 at 17:04 +0200, Jesper Dangaard Brouer wrote:
> The sunrpc module uses rcu_call() thus it should use rcu_barrier() on
> module unload.
> 
> Have not verified that the possibility for new call_rcu() callbacks
> has been disabled.  As a hint for checking, the functions calling
> call_rcu() (unx_destroy_cred and generic_destroy_cred) are
> registered as crdestroy function pointer in struct rpc_credops.
> 
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> ---
> 
>  net/sunrpc/sunrpc_syms.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
> index 843629f..adaa819 100644
> --- a/net/sunrpc/sunrpc_syms.c
> +++ b/net/sunrpc/sunrpc_syms.c
> @@ -66,6 +66,7 @@ cleanup_sunrpc(void)
>  #ifdef CONFIG_PROC_FS
>  	rpc_proc_exit();
>  #endif
> +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
>  }
>  MODULE_LICENSE("GPL");
>  module_init(init_sunrpc);
> 

Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
