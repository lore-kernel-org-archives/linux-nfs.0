Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28586 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbcFVOsM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 10:48:12 -0400
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v3 25/25] IB/mlx4: Workaround for mlx4_alloc_priv_pages() array allocator
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <576A9AE6.4070500@grimberg.me>
Date: Wed, 22 Jun 2016 10:47:27 -0400
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <A9F49204-8E84-4B58-BAA4-5B4B360FD22F@oracle.com>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net> <20160620161200.10809.45762.stgit@manet.1015granger.net> <576A9AE6.4070500@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 22, 2016, at 10:04 AM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> 
>> +    /* This is overkill, but hardware requires that the
>> +     * PBL array begins at a properly aligned address and
>> +     * never occupies the last 8 bytes of a page.
>> +     */
>> +    mr->pages = (__be64 *)get_zeroed_page(GFP_KERNEL);
>> +    if (!mr->pages)
>>          return -ENOMEM;
> 
> Again, I'm not convinced that this is a better choice then allocating
> the exact needed size as dma coherent, but given that the dma coherent
> allocations are always page aligned I wander if it's not the same
> effect...

My concerns with DMA coherent were:

1. That pool may be a somewhat limited resource?

2. IMO DMA-API.txt suggests DMA coherent will perform less
well in some cases. Macro benchmarks I ran seemed to show
there was a slight performance hit with that approach, though
it was nearly in the noise.

I agree that the over-allocation in the streaming solution is a
concern. But as you say, there may be little we can do about it.

Wrt to Or's comment, the device's maximum page list depth
is advertised to consumers via the device's attributes. However,
it would be defensive if there was a sanity check added in
mlx4_alloc_priv_pages to ensure that the max_pages argument
is a reasonable value (ie, that the calculated array size does
indeed fit into a page).

> In any event, we can move forward with this for now:
> 
> Reviewed-by: Sagi Grimberg <sagi@grimberg.me>

Thanks, I'll add that! Though as before, I'm happy to drop this
patch if there is a different preferred official fix.
