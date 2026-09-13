Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B1F736B93E
	for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 16:40:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789317629; cv=none; b=XU7iOAmUcfTRAhWBmXnQuwUhKlFOIs+fO7X6Z5tYarE2VMM22Pt0xeeNlmCpbevH0bZb5bGZ/UcM2rSSdQ54aJyydtSQg27jZyo5vmLESK/h9NkoZoyheNvKq6CdpkO8KhSsI9LXIqirsco+f0MEB2UTEUp/HzVK5t0Juz4Ckac=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789317629; c=relaxed/simple;
	bh=tMfD4U8sXM1Kdp3Gt8o9CUjZGm0VMF0SmC9x8z4SEAU=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=JzJweNPixh3uObbxmpW4wL6nkmo4qCC4iuuNnb3ZaiSOGa0V/fYdIi6x/CQDiNJSMbor+kxljClofAKzHwKYv3XrZONsk6/NWNy04CdP8DKkurjTsYQhiui5u4f3ETM8WykTbUSNioLpI1YrROQLKl33xZdsoNXOHefHJgTwKms=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=V+vcUQKe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="V+vcUQKe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E65091F00893;
	Sun, 13 Sep 2026 16:40:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789317628;
	bh=WKlFA/1iKCmyKjjNE4oSRzDeTGJ9jpqkUqBXMGoOSiQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=V+vcUQKeAxi7Nnlm3js33pq5dRbZp37ih4xUp05G8kQNKBOa55xIa7D+6RJL/0zdU
	 6vIaqW4yS9C1Goqp48iz7Rp+88C8q61RTHcpQhkXEY+xgz7xiZgMeMnIo8jPLzZeJO
	 LuRxzPaqQgy2OT5Oa3opK5ziWzP4Uti4D7uIkg6NwHPyhZ8/4hEJNRaXILPmSux/eL
	 XpalKQYKXlL5LGD9aU/hsoxkcYLM/CDfWAwSXAraD+isC8/qXINjIOeUxaeTjDjTjS
	 E8paifR9DS0ez5gcx4GpaUpIMrhRmhEdhuAPTSsK1MOGrDS4RlN8SfarwHjpddLaMt
	 HMaaWkB4zILGQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 15507F40066;
	Sun, 13 Sep 2026 12:40:27 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 13 Sep 2026 12:40:27 -0400
X-ME-Sender: <xms:-9GmasjarLVvzQE8qZqJL7oT8jhUDyyMjyp-tmhx_Ne-HuEsdbLyRQ>
    <xme:-9Gmav2qF6NotYxFqbirB-2Y10CcYbKi4eRQgwhXGRE3tstgUmGeNYqau5Hl5Xf5O
    LA5cuel7BOXXb-rDCw2mXKvDZx6gkBEVkPOejmHgFuyzcCJe21CC6Hk>
X-ME-Proxy-Cause: dmFkZTFwQ3pVX8I60PtLIlwa3RkSKxgH5rzc9PfJEjDCzY4yxubKJ+nbUXmK5RAEsUipnN
    VrRVM5oDgt+YzecNtjGoAqVrXyK+Wmdb3SPfjyqXCuQJh7gPswT4IArUfqsyp3I8fG/3Or
    Z5rjxkAbcfm40AteikWxylerL8Y4v9fB0rmlPRXtj5YEcc8yr2zfkpQM30hN9tCTbQvlWj
    d5E5Pdv64ZOA2hdvRfrDaxI1mgHyqc/+lSED8RLK2zrGU/RiMne/YPyrIczk7aG7S6h8uJ
    CZwDtAORV6bojvWiNYcIAKfapfDiY02WtRBxKJi25RoYrfSjK2QvGOnp7kR3dVfci4t4gS
    0Cy5gQxtfCDadKU+Pi2k7qFmVdSu5pB+FZ9w6iWntbvvjOFQzDRizLgv5gz+73eOHhhqbr
    NrWok4FZzXIIM+BhdQPIMPZoOjmcYHK9ZdbB0HWO8t3rS+3GnU/GLFh2jiDWVvjLj17Gpr
    w3oFlAOwyJKTFLhDqtu0MJhW1KXqn40nHnJcD738P6fflUaGn4vbBo+QXkMLRI/UhTzoR3
    8QzcxOzdaw7lXOz/mMklF3ej2JrwSg7w7Q44A85D8L99OTyaTQyGd+9PHrP5wYD8k+8Qzi
    iNl/QezlycYAws9ZgR6h6JrDkaOZhtCg0QnJVJXPdyCEnN4a3C9dPI7NUE0g
X-ME-Proxy: <xmx:-9GmalwtR6g4Qvh-M_MVOgaH_F4SRyUfJpWrBL0-mZC9IfHn-DUUYQ>
    <xmx:-9GmaluugEO7pByUYHuKOuXWGgSmFj2ml7QUY6BF0HDkcywb6BZ6lA>
    <xmx:-9GmagD7WsnczHrNqdIkN8T9DSUuHGF--1GUqsxQcwJ_FMkmEyRIEQ>
    <xmx:-9GmavHFClVBgndgnLicb2Qu1SHIBSTnOGY03RwG2lo1PAvT3uqTBQ>
    <xmx:-9GmaoAGP8-F3MaRoEdh4WQhjVn5HHhWu4H_hVZoxtArCKbKfNAmipbt>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id EBF41780070; Sun, 13 Sep 2026 12:40:26 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AgpFG2YqzZmg
Date: Sun, 13 Sep 2026 12:40:02 -0400
From: "Chuck Lever" <cel@kernel.org>
To: tmenninger@purestorage.com
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Tejun Heo" <tj@kernel.org>,
 "Lai Jiangshan" <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Eric Badger" <ebadger@everpuredata.com>,
 "Jon Curley" <jcurley@everpuredata.com>
Message-Id: <611738b5-e115-4531-8d08-62607dc7f8ff@slotpi15m67>
In-Reply-To: <20260913131354.1026639-1-tmenninger@purestorage.com>
References: <e18e121c-5c05-4caa-96ea-e0886594ee07@slotpi15m67>
 <20260913131354.1026639-1-tmenninger@purestorage.com>
Subject: Re: [PATCH RFC 6/8] SUNRPC: Reduce rpciod workqueue contention
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 13 Sep 2026, Tim Menninger wrote:
>                         unpinned       node0 pinned
>     free_fastpath:     +49,161,373    +119,680,629
>     free_slowpath:     +70,391,872          +8,999
>     sheaf_flush:        +1,582,440     +13,436,760
>     barn_put:             +673,877      +1,596,175
>     barn_put_fail:         +26,374        +223,950
>     barn_get:             +673,860      +1,596,219
>     barn_get_fail:      +1,199,576        +224,090
>     alloc_slowpath:              0               0
>
> So free_slowpath does in fact drop essentially to zero when allocation
> and completion/freeing are kept on the same NUMA node.

Thanks, that settles the remote-free question.


> The dominant slab lock was still heavily contended in that run.
> Filtering it by caller gave:
>
>     2,907,948   __slab_free+0x126
>       269,174   get_partial_node_bulk+0x9c
>       175,965   __refill_objects_node+0x4d0

Set beside the unpinned profile from your Sep 12 mail:

                            unpinned    node0 pinned
    __slab_free            2,845,710       2,907,948
    get_partial_node_bulk    318,458         269,174
    __refill_objects_node    181,842         175,965

The lock profile did not move. free_slowpath fell by four orders
of magnitude and __slab_free took list_lock just as often. So the
list_lock contention is not the remote frees, and it never was!

The counters show where it comes from instead. sheaf_flush rose to
13,436,760 objects, and 13,436,760 / 60 = 223,946, which is your
barn_put_fail. That is the barn-full path in free_to_pcs: once the
node's barn holds MAX_FULL_SHEAVES (10) full sheaves, a put fails,
the spare sheaf is flushed through sheaf_flush_unused and
__kmem_cache_free_bulk, and __slab_free takes list_lock for each
slab in the flush. That route never increments FREE_SLOWPATH,
which is why the counter went quiet while the lock did not. It is
also why sheaf_flush_unused and __kmem_cache_free_bulk never
appeared as callers: perf lock charges the acquisition to
__slab_free on both routes.

barn_get_fail matches barn_put_fail almost exactly, and barn_get
matches barn_put. The barn is a bounded buffer between the CPUs
that allocate nfs_page objects and the rpciod CPUs that free them,
and about 12% of the time it is over- or underflowing.

So the cross-node placement adds roughly 2-4 GB/s of penalty, some
of which is node 0 itself (45 vs 46-47 with balanced CQs), while
the lock profile is unchanged. That points at the per-object cost
of 70M individual remote __slab_free calls, not at list_lock
queueing.

Three numbers you likely already have on disk would help clarify
this... no new runs needed:

- Total and average wait for the list_lock address in the pinned
  run. The unpinned run showed 5.05 min and 90 us average; if the
  pinned run is similar, the lock absorbs the same time whichever
  way the frees go.
- mpstat idle for node 0 in both runs, to tell whether that wait
  is idle time being spent or throughput being lost.
- Throughput for the node 0 / node 0 run that produced the counter
  table above. It is the one configuration missing from your
  throughput table.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
