Return-Path: linux-nfs-owner@vger.kernel.org
Received: from he.sipsolutions.net ([78.46.109.217]:48334 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932419Ab2EOSkw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 14:40:52 -0400
Message-ID: <1337107245.15553.14.camel@jlt3.sipsolutions.net>
Subject: Re: [RFC net-next 0/2] net: Use net_<level>_ratelimit
From: Johannes Berg <johannes@sipsolutions.net>
To: David Miller <davem@davemloft.net>
Cc: joe@perches.com, netdev@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
        coreteam@netfilter.org, linux-wireless@vger.kernel.org,
        dev@openvswitch.org, linux-sctp@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Tue, 15 May 2012 20:40:45 +0200
In-Reply-To: <20120515.142922.1434224550630736456.davem@davemloft.net>
References: <20120515.134531.530903973750646107.davem@davemloft.net>
	 <1337104765.7050.24.camel@joe2Laptop>
	 <1337106430.15553.6.camel@jlt3.sipsolutions.net>
	 <20120515.142922.1434224550630736456.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-05-15 at 14:29 -0400, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Tue, 15 May 2012 20:27:10 +0200
> 
> > On Tue, 2012-05-15 at 10:59 -0700, Joe Perches wrote:
> > 
> >> OK, but fyi, there's a possible issue with !CONFIG_DEBUG
> >> builds because these patches converted some uses of
> >> 	if (net_ratelimit())
> >> 		printk(KERN_DEBUG ...
> >> to
> >> 	net_dbg_ratelimited()
> >> 
> >> These messages are no longer emitted when DEBUG isn't defined
> >> and not using dynamic_debug.  I'm not sure that's a real
> >> problem, but it's a difference.
> >> 
> >> I could produce a net_printk_ratelimited that would keep
> >> the original behavior if necessary.
> >> 
> >> 	net_printk_ratelimited(KERN_DEBUG etc...)
> > 
> > Btw, what would the difference be to just plain printk_ratelimited()?
> 
> printk_ratelimited() drops a local ratelimit cookie into each call-site,
> whereas we have a global one for the networking which these new interfaces
> use.
> 
> Joe explained this completely in his 0/2 patch posting.

I don't see that explicitly mentioned, but it doesn't matter much
anyway.

In the mac80211 case, messages are warnings/hints to the user, we just
don't want them to flood the logs too much. I'd rather have that kind of
change (limit cookie per callsite) in the rate limiting semantics than
the change in the when it gets printed at all.

I simply feel that obscuring the debugging even further wouldn't be a
good thing to do right now. I'd rather have somebody convert all of it
to the new debugging infrastructure but that seems a lot more effort
than changing these back to something that isn't impacted by dynamic
printk.

johannes

