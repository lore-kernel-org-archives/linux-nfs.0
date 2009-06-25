From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/10] decnet: Use rcu_barrier() on module unload.
Date: Thu, 25 Jun 2009 16:10:46 -0700 (PDT)
Message-ID: <20090625.161046.19938291.davem@davemloft.net>
References: <1245845367.24921.3.camel@localhost.localdomain>
	<5A680E0A-EFEB-44EA-9F06-F338E6CBD6D1@googlemail.com>
	<1245930729.24921.67.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: christine.caulfield@googlemail.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, axboe@kernel.dk, kaber@trash.net,
	Trond.Myklebust@netapp.com, johannes@sipsolutions.net,
	yoshfuji@linux-ipv6.org, shemminger@linux-foundation.org,
	linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-ext4@vger.kernel.org, tytso@mit.edu, adilger-xsfywfwIY+M@public.gmane.org,
	netfilter-devel@vger.kernel.org
To: jdb-4UpuNZONu4c@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55640
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752782AbZFYXKm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2009 19:10:42 -0400
In-Reply-To: <1245930729.24921.67.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb-4UpuNZONu4c@public.gmane.org>
Date: Thu, 25 Jun 2009 13:52:09 +0200

> On Wed, 2009-06-24 at 14:50 +0100, Chrissie Caulfield wrote:
>> I don't have any objection to the patch at all, 
> 
> Thus assuming an:
> 
> Acked-by: Chrissie Caulfield <christine.caulfield@googlemail.com>
> 
> (wondering if patchworks picks this up...)

It usually does.

However, could you formally resubmit just the networking bits
as that would make life a lot easier for me.

Thanks a lot Jesper!
