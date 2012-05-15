Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([198.137.202.13]:40845 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932887Ab2EOSQP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 14:16:15 -0400
Date: Tue, 15 May 2012 14:13:48 -0400 (EDT)
Message-Id: <20120515.141348.892964316296815698.davem@davemloft.net>
To: johannes@sipsolutions.net
Cc: joe@perches.com, netdev@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
        coreteam@netfilter.org, linux-wireless@vger.kernel.org,
        dev@openvswitch.org, linux-sctp@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC net-next 0/2] net: Use net_<level>_ratelimit
From: David Miller <davem@davemloft.net>
In-Reply-To: <1337105028.15553.3.camel@jlt3.sipsolutions.net>
References: <20120515.134531.530903973750646107.davem@davemloft.net>
	<1337104765.7050.24.camel@joe2Laptop>
	<1337105028.15553.3.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 15 May 2012 20:03:48 +0200

> Oops. Yes, please do that, mac80211 doesn't have DEBUG yet

If you want debugging messages you would turn on dynamic_debug
via sysctl or whatever, not define DEBUG in your sources.

I don't think we should add yet another interface just to get
KERN_DEBUG in there.
