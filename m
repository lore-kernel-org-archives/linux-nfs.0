From: David Miller <davem@davemloft.net>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W}
 usage
Date: Thu, 09 Jul 2009 17:13:55 -0700 (PDT)
Message-ID: <20090709.171355.09466097.davem@davemloft.net>
References: <20090608023757.GA6244@localhost>
	<20090706105216.GA19124@gondor.apana.org.au>
	<20090709131746.GA27965@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751104AbZGJANw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2009 20:13:52 -0400
In-Reply-To: <20090709131746.GA27965@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wu Fengguang <fengguang.wu@intel.com>
Date: Thu, 9 Jul 2009 21:17:46 +0800

> @@ -2100,7 +2100,8 @@ void tcp_send_fin(struct sock *sk)
>  	} else {
>  		/* Socket is locked, keep trying until memory is available. */
>  		for (;;) {
> -			skb = alloc_skb_fclone(MAX_TCP_HEADER, GFP_KERNEL);
> +			skb = alloc_skb_fclone(MAX_TCP_HEADER,
> +					       sk->sk_allocation);
>  			if (skb)
>  				break;
>  			yield();

I think this specific case needs more thinking.

If the allocation fails, and it's GFP_ATOMIC, we are going to yield()
(which sleeps) and loop endlessly waiting for the allocation to
succeed.
