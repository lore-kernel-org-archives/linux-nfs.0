Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([198.137.202.13]:40562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656Ab2EORqw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 13:46:52 -0400
Date: Tue, 15 May 2012 13:45:31 -0400 (EDT)
Message-Id: <20120515.134531.530903973750646107.davem@davemloft.net>
To: joe@perches.com
Cc: netdev@vger.kernel.org, linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
        coreteam@netfilter.org, linux-wireless@vger.kernel.org,
        dev@openvswitch.org, linux-sctp@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC net-next 0/2] net: Use net_<level>_ratelimit
From: David Miller <davem@davemloft.net>
In-Reply-To: <cover.1336981915.git.joe@perches.com>
References: <cover.1336981915.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 14 May 2012 00:56:24 -0700

> net_ratelimit() like __ratelimit() is too easy to misuse.
> 
> Add simplifying macros similar to pr_<level>_ratelimited
> that combines the test of net_ratelimit and logging.
> 
> Joe Perches (2):
>   net: Add net_ratelimited_function and net_<level>_ratelimited macros
>   net: Convert net_ratelimit uses to net_<level>_ratelimited

These look fine to me so I've applied them to net-next and am
sanity checking the build right now.

Thanks Joe.
