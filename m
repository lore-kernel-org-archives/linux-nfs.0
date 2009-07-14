From: David Miller <davem@davemloft.net>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W}
 usage
Date: Tue, 14 Jul 2009 09:04:32 -0700 (PDT)
Message-ID: <20090714.090432.13343695.davem@davemloft.net>
References: <20090709.171355.09466097.davem@davemloft.net>
	<20090710080017.GA24168@localhost>
	<20090710080247.GA2693@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: fengguang.wu@intel.com, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54465
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753351AbZGNQE2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2009 12:04:28 -0400
In-Reply-To: <20090710080247.GA2693-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Date: Fri, 10 Jul 2009 16:02:47 +0800

> On Fri, Jul 10, 2009 at 04:00:17PM +0800, Wu Fengguang wrote:
>> 
>> The (sk_allocation & ~__GFP_WAIT) cases should be rare, but I guess
>> the networking code shall do it anyway, because sk_allocation defaults
>> to GFP_KERNEL. It seems that currently the networking code simply uses
>> a lot of GFP_ATOMIC, do they really mean "I cannot sleep"?
> 
> Yep because they're done from softirq context.

Yes, this is the core issue.

All of Wu's talk about how "GFP_ATOMIC will wake up kswapd and
therefore can succeed just as well as GFP_KERNEL" is not relevant,
because GFP_ATOMIC means sleeping is not allowed.
