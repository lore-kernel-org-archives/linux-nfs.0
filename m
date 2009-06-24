From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH 09/10] cfq-iosched: Uses its own open-coded rcu_barrier.
Date: Wed, 24 Jun 2009 08:42:37 +0200
Message-ID: <20090624064236.GE31415@kernel.dk>
References: <20090623150330.22490.87327.stgit@localhost> <20090623150439.22490.14657.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net,
	Patrick McHardy <kaber@trash.net>,
	christine.caulfield@googlemail.com, Trond.Myklebust@netapp.com,
	linux-wireless@vger.kernel.org, johannes@sipsolutions.net,
	yoshfuji@linux-ipv6.org, shemminger@linux-foundation.org,
	linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-ext4@vger.kernel.org, tytso@mit.edu, adilger-xsfywfwIY+M@public.gmane.org,
	netfilter-devel@vger.kernel.org
To: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brick.kernel.dk ([93.163.65.50]:54784 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752931AbZFXGmf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 02:42:35 -0400
In-Reply-To: <20090623150439.22490.14657.stgit@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 23 2009, Jesper Dangaard Brouer wrote:
> This module cfq-iosched, has discovered the value of waiting for
> call_rcu() completion, but its has its own open-coded implementation
> of rcu_barrier(), which I don't think is 'strong' enough.
> 
> This patch only leaves a comment for the maintainers to consider.

We need a stronger primitive and rcu_barrier(), since we also need to
wait for the rcu calls to even be scheduled. So I don't think the below
can be improved, it's already fine.

> 
> Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
> ---
> 
>  block/cfq-iosched.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index 833ec18..c15555b 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -2657,6 +2657,12 @@ static void __exit cfq_exit(void)
>  	/*
>  	 * this also protects us from entering cfq_slab_kill() with
>  	 * pending RCU callbacks
> +	 *
> +	 * hawk-4UpuNZONu4c@public.gmane.org 2009-06-18: Maintainer please consider using
> +	 *  rcu_barrier() instead of this open-coded wait for
> +	 *  completion implementation.  I think it provides a better
> +	 *  guarantee that all CPUs are finished, although
> +	 *  elv_ioc_count_read() do consider all CPUs.
>  	 */
>  	if (elv_ioc_count_read(ioc_count))
>  		wait_for_completion(&all_gone);
> 

-- 
Jens Axboe

