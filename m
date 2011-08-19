Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab1HSOEy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 10:04:54 -0400
Date: Fri, 19 Aug 2011 07:04:51 -0700 (PDT)
Message-Id: <20110819.070451.1651299907098952592.davem@davemloft.net>
To: Ian.Campbell@citrix.com
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC v3 0/75] enable SKB paged fragment lifetime
 visibility
From: David Miller <davem@davemloft.net>
In-Reply-To: <20110819.063410.475175569086272526.davem@davemloft.net>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
	<20110819.062958.1560313540665582388.davem@davemloft.net>
	<20110819.063410.475175569086272526.davem@davemloft.net>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: David Miller <davem@davemloft.net>
Date: Fri, 19 Aug 2011 06:34:10 -0700 (PDT)

> From: David Miller <davem@davemloft.net>
> Date: Fri, 19 Aug 2011 06:29:58 -0700 (PDT)
> 
>> From: Ian Campbell <Ian.Campbell@citrix.com>
>> Date: Fri, 19 Aug 2011 14:26:33 +0100
>> 
>>> This is v3 of my series to enable visibility into SKB paged fragment's
>> 
>> Please tone down the patch count :-/  I'm not going to review anything more
>> than ~20 or so patches at a time from any one person.
> 
> Also none of your patches will even apply to net-next GIT since nearly
> all the ethernet drivers have been moved under drivers/net/ethernet

Ian, please acknowledge my grievances here.  I see you replying to other
people, but not to me and I'm the one who has to process all of this
stuff eventually.

If you want this series to be taken seriously:

1) Make your patches against net-next GIT, none of your driver patches will
   apply because they have all been moved around to different locations
   under drivers/net

2) Submit this in a _SANE_ way.  This means, get the first patch that adds
   the new interfaces approved and merged.  Then slowly and carefuly submit
   small, reasonably sized, sets of patches that convert the drivers over.

Otherwise there is no way I'm even looking at this stuff, let alone actually
apply it.

Realize that every time you patch bomb rediculiously like this I have
to click and classify every single patch in your bomb at
http://patchwork.ozlabs.org/project/netdev/list/
