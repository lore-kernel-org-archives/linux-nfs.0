Return-Path: linux-nfs-owner@vger.kernel.org
Received: from he.sipsolutions.net ([78.46.109.217]:46905 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932383Ab2EOSVj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 14:21:39 -0400
Message-ID: <1337106094.15553.5.camel@jlt3.sipsolutions.net>
Subject: Re: [RFC net-next 0/2] net: Use net_<level>_ratelimit
From: Johannes Berg <johannes@sipsolutions.net>
To: David Miller <davem@davemloft.net>
Cc: joe@perches.com, netdev@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
        coreteam@netfilter.org, linux-wireless@vger.kernel.org,
        dev@openvswitch.org, linux-sctp@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Tue, 15 May 2012 20:21:34 +0200
In-Reply-To: <20120515.141348.892964316296815698.davem@davemloft.net>
References: <20120515.134531.530903973750646107.davem@davemloft.net>
	 <1337104765.7050.24.camel@joe2Laptop>
	 <1337105028.15553.3.camel@jlt3.sipsolutions.net>
	 <20120515.141348.892964316296815698.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-05-15 at 14:13 -0400, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Tue, 15 May 2012 20:03:48 +0200
> 
> > Oops. Yes, please do that, mac80211 doesn't have DEBUG yet
> 
> If you want debugging messages you would turn on dynamic_debug
> via sysctl or whatever, not define DEBUG in your sources.
> 
> I don't think we should add yet another interface just to get
> KERN_DEBUG in there.

But don't you have to do something in the sources to actually get
dynamic_debug enabled? I'm concerned this will make mac80211 debugging
inconsistent - the normal bits are just printk() still, and the
rate-limited bits need some special enabling? That seems odd.

johannes

