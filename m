Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([198.137.202.13]:40956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932936Ab2EOS0X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 14:26:23 -0400
Date: Tue, 15 May 2012 14:24:05 -0400 (EDT)
Message-Id: <20120515.142405.633851408201128056.davem@davemloft.net>
To: johannes@sipsolutions.net
Cc: joe@perches.com, netdev@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
        coreteam@netfilter.org, linux-wireless@vger.kernel.org,
        dev@openvswitch.org, linux-sctp@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC net-next 0/2] net: Use net_<level>_ratelimit
From: David Miller <davem@davemloft.net>
In-Reply-To: <1337106094.15553.5.camel@jlt3.sipsolutions.net>
References: <1337105028.15553.3.camel@jlt3.sipsolutions.net>
	<20120515.141348.892964316296815698.davem@davemloft.net>
	<1337106094.15553.5.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 15 May 2012 20:21:34 +0200

> On Tue, 2012-05-15 at 14:13 -0400, David Miller wrote:
>> From: Johannes Berg <johannes@sipsolutions.net>
>> Date: Tue, 15 May 2012 20:03:48 +0200
>> 
>> > Oops. Yes, please do that, mac80211 doesn't have DEBUG yet
>> 
>> If you want debugging messages you would turn on dynamic_debug
>> via sysctl or whatever, not define DEBUG in your sources.
>> 
>> I don't think we should add yet another interface just to get
>> KERN_DEBUG in there.
> 
> But don't you have to do something in the sources to actually get
> dynamic_debug enabled? I'm concerned this will make mac80211 debugging
> inconsistent - the normal bits are just printk() still, and the
> rate-limited bits need some special enabling? That seems odd.

You can turn them all off or on with a simple flip of a boolean switch
at run-time.  Or, alternatively, you can turn them on or off in a
finer grained manner with other run-time facilities.

There should be a transition away from explicit KERN_DEBUG.
