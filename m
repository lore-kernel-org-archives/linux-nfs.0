Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([198.137.202.13]:41074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966047Ab2EOSc1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 14:32:27 -0400
Date: Tue, 15 May 2012 14:30:09 -0400 (EDT)
Message-Id: <20120515.143009.2103212327515966852.davem@davemloft.net>
To: johannes@sipsolutions.net
Cc: joe@perches.com, netdev@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
        coreteam@netfilter.org, linux-wireless@vger.kernel.org,
        dev@openvswitch.org, linux-sctp@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC net-next 0/2] net: Use net_<level>_ratelimit
From: David Miller <davem@davemloft.net>
In-Reply-To: <1337106548.15553.8.camel@jlt3.sipsolutions.net>
References: <1337106094.15553.5.camel@jlt3.sipsolutions.net>
	<20120515.142405.633851408201128056.davem@davemloft.net>
	<1337106548.15553.8.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 15 May 2012 20:29:08 +0200

> On Tue, 2012-05-15 at 14:24 -0400, David Miller wrote:
> 
>> > But don't you have to do something in the sources to actually get
>> > dynamic_debug enabled? I'm concerned this will make mac80211 debugging
>> > inconsistent - the normal bits are just printk() still, and the
>> > rate-limited bits need some special enabling? That seems odd.
>> 
>> You can turn them all off or on with a simple flip of a boolean switch
>> at run-time.  Or, alternatively, you can turn them on or off in a
>> finer grained manner with other run-time facilities.
>> 
>> There should be a transition away from explicit KERN_DEBUG.
> 
> I support that, but I think it's confusing to have things mixed. Also,
> we seem to have printk_ratelimit(), so I'd prefer to have that used in
> mac80211 instead until everything there moves over to newer facilities.

No, you don't want that, it's different from the networking ratelimit
mechanism.  Joe explained this, and I just explaing it to you once
again in another reply.
