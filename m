From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH][RESEND] tcp: replace hard coded GFP_KERNEL with
	sk_allocation
Date: Thu, 3 Sep 2009 15:01:16 +0800
Message-ID: <20090903070116.GA27444@localhost>
References: <20090903040407.GA20094@localhost> <20090902.231017.31926895.davem@davemloft.net> <20090902.233225.203837229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"acme@ghostprotocols.net" <acme@ghostprotocols.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090902.233225.203837229.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 03, 2009 at 02:32:25PM +0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 02 Sep 2009 23:10:17 -0700 (PDT)
> 
> > From: Wu Fengguang <fengguang.wu@intel.com>
> > Date: Thu, 3 Sep 2009 12:04:07 +0800
> > 
> >> This fixed a lockdep warning which appeared when doing stress
> >> memory tests over NFS:
> >> 
> >> 	inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
> >> 
> >> 	page reclaim => nfs_writepage => tcp_sendmsg => lock sk_lock
> >> 
> >> 	mount_root => nfs_root_data => tcp_close => lock sk_lock =>
> >> 			tcp_send_fin => alloc_skb_fclone => page reclaim
> >> 
> >> David raised a concern that if the allocation fails in tcp_send_fin(), and it's
> >> GFP_ATOMIC, we are going to yield() (which sleeps) and loop endlessly waiting
> >> for the allocation to succeed.
> >> 
> >> But fact is, the original GFP_KERNEL also sleeps. GFP_ATOMIC+yield() looks
> >> weird, but it is no worse the implicit sleep inside GFP_KERNEL. Both could
> >> loop endlessly under memory pressure.
> >> 
> >> CC: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> >> CC: David S. Miller <davem@davemloft.net>
> >> CC: Herbert Xu <herbert@gondor.apana.org.au>
> >> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > 
> > Applied to net-next-2.6, thanks!
> 
> You obviously didn't build test this with TCP MD5 support
> enabled, that fails.

Ah sorry! I compile bare kernels on my laptop..

> I'm fixing it up, but if you're going to go through the motions
> of submitting a patch multiple times, at least do a thorough
> build test of the code you're changing.

Good advice.  I'll consider a build server.

Thanks,
Fengguang
