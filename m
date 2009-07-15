From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W}
	usage
Date: Wed, 15 Jul 2009 15:45:03 +0800
Message-ID: <20090715074503.GC6145@localhost>
References: <20090709.171355.09466097.davem@davemloft.net> <20090710080017.GA24168@localhost> <20090710080247.GA2693@gondor.apana.org.au> <20090714.090432.13343695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org" <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:27469 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751619AbZGOHpN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jul 2009 03:45:13 -0400
In-Reply-To: <20090714.090432.13343695.davem@davemloft.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 15, 2009 at 12:04:32AM +0800, David Miller wrote:
> From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
> Date: Fri, 10 Jul 2009 16:02:47 +0800
> 
> > On Fri, Jul 10, 2009 at 04:00:17PM +0800, Wu Fengguang wrote:
> >> 
> >> The (sk_allocation & ~__GFP_WAIT) cases should be rare, but I guess
> >> the networking code shall do it anyway, because sk_allocation defaults
> >> to GFP_KERNEL. It seems that currently the networking code simply uses
> >> a lot of GFP_ATOMIC, do they really mean "I cannot sleep"?
> > 
> > Yep because they're done from softirq context.
> 
> Yes, this is the core issue.

Yes, that's general true. But..

> All of Wu's talk about how "GFP_ATOMIC will wake up kswapd and
> therefore can succeed just as well as GFP_KERNEL" is not relevant,
> because GFP_ATOMIC means sleeping is not allowed.

We are talking about tcp_send_fin() here, which can sleep.

Thanks,
Fengguang
