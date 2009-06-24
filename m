From: Chrissie Caulfield <christine.caulfield@googlemail.com>
Subject: Re: [PATCH 07/10] decnet: Use rcu_barrier() on module unload.
Date: Wed, 24 Jun 2009 07:23:58 +0100
Message-ID: <4A41C67E.8070301@googlemail.com>
References: <20090623150330.22490.87327.stgit@localhost> <20090623150429.22490.15113.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net,
	axboe@kernel.dk, Patrick McHardy <kaber@trash.net>,
	Trond.Myklebust@netapp.com, linux-wireless@vger.kernel.org,
	johannes@sipsolutions.net, yoshfuji@linux-ipv6.org,
	shemminger@linux-foundation.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org,
	tytso@mit.edu, adilger@sun.com, netfilter-devel@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090623150429.22490.15113.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> The decnet module unloading as been disabled with a '#if 0' statement,
> because it have had issues.  Perhaps using rcu_barrier() will fix
> these issues?
> 
> Any maintainers with input?
> 
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> ---
> 
>  net/decnet/af_decnet.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
> index d351b8d..bff12da 100644
> --- a/net/decnet/af_decnet.c
> +++ b/net/decnet/af_decnet.c
> @@ -2393,6 +2393,10 @@ module_init(decnet_init);
>   * Prevent DECnet module unloading until its fixed properly.
>   * Requires an audit of the code to check for memory leaks and
>   * initialisation problems etc.
> + *
> + * hawk@comx.dk 2009-06-19:
> + *  I have added a rcu_barrier() which should plug some of your
> + *  module unload issues.  Maintainers please try it out...
>   */
>  #if 0
>  static void __exit decnet_exit(void)
> @@ -2413,6 +2417,8 @@ static void __exit decnet_exit(void)
>  	proc_net_remove(&init_net, "decnet");
>  
>  	proto_unregister(&dn_proto);
> +
> +	rcu_barrier_bh(); /* Wait for completion of call_rcu_bh()'s */
>  }
>  module_exit(decnet_exit);
>  #endif
> 

The issues with DECnet module unloading are a little more than just an
RCU leak I think!

Though that area does need reviewing ... when I get some time.

-- 

Chrissie
