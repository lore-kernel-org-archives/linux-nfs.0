Return-Path: linux-nfs-owner@vger.kernel.org
Received: from he.sipsolutions.net ([78.46.109.217]:54385 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965999Ab2EOS1P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 14:27:15 -0400
Message-ID: <1337106430.15553.6.camel@jlt3.sipsolutions.net>
Subject: Re: [RFC net-next 0/2] net: Use net_<level>_ratelimit
From: Johannes Berg <johannes@sipsolutions.net>
To: Joe Perches <joe@perches.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
        coreteam@netfilter.org, linux-wireless@vger.kernel.org,
        dev@openvswitch.org, linux-sctp@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Tue, 15 May 2012 20:27:10 +0200
In-Reply-To: <1337104765.7050.24.camel@joe2Laptop> (sfid-20120515_195955_463081_DA730895)
References: <cover.1336981915.git.joe@perches.com>
	 <20120515.134531.530903973750646107.davem@davemloft.net>
	 <1337104765.7050.24.camel@joe2Laptop>
	 (sfid-20120515_195955_463081_DA730895)
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-05-15 at 10:59 -0700, Joe Perches wrote:

> OK, but fyi, there's a possible issue with !CONFIG_DEBUG
> builds because these patches converted some uses of
> 	if (net_ratelimit())
> 		printk(KERN_DEBUG ...
> to
> 	net_dbg_ratelimited()
> 
> These messages are no longer emitted when DEBUG isn't defined
> and not using dynamic_debug.  I'm not sure that's a real
> problem, but it's a difference.
> 
> I could produce a net_printk_ratelimited that would keep
> the original behavior if necessary.
> 
> 	net_printk_ratelimited(KERN_DEBUG etc...)

Btw, what would the difference be to just plain printk_ratelimited()?

johannes

