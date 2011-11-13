Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8365 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750944Ab1KMKQJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Nov 2011 05:16:09 -0500
Date: Sun, 13 Nov 2011 12:17:14 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] sunrpc: use SKB fragment destructors to delay
 completion until page is released by network stack.
Message-ID: <20111113101713.GB15322@redhat.com>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
 <1320850927-30240-4-git-send-email-ian.campbell@citrix.com>
 <20111111123824.GA23902@redhat.com>
 <1321017627.955.254.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321017627.955.254.camel@zakaz.uk.xensource.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 11, 2011 at 01:20:27PM +0000, Ian Campbell wrote:
> On Fri, 2011-11-11 at 12:38 +0000, Michael S. Tsirkin wrote:
> > On Wed, Nov 09, 2011 at 03:02:07PM +0000, Ian Campbell wrote:
> > > This prevents an issue where an ACK is delayed, a retransmit is queued (either
> > > at the RPC or TCP level) and the ACK arrives before the retransmission hits the
> > > wire. If this happens to an NFS WRITE RPC then the write() system call
> > > completes and the userspace process can continue, potentially modifying data
> > > referenced by the retransmission before the retransmission occurs.
> > > 
> > > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > > Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > Cc: "David S. Miller" <davem@davemloft.net>
> > > Cc: Neil Brown <neilb@suse.de>
> > > Cc: "J. Bruce Fields" <bfields@fieldses.org>
> > > Cc: linux-nfs@vger.kernel.org
> > > Cc: netdev@vger.kernel.org
> > 
> > So this blocks the system call until all page references
> > are gone, right?
> 
> Right. The alternative is to return to userspace while the network stack
> still has a reference to the buffer which was passed in -- that's the
> exact class of problem this patch is supposed to fix.

BTW, the increased latency and the overhead extra wakeups might for some
workloads be greater than the cost of the data copy.

> > But, there's no upper limit on how long the
> > page is referenced, correct?
> 
> Correct.
> 
> >  consider a bridged setup
> > with an skb queued at a tap device - this cause one process
> > to block another one by virtue of not consuming a cloned skb?
> 
> Hmm, yes.
> 
> One approach might be to introduce the concept of an skb timeout to the
> stack as a whole and cancel (or deep copy) after that timeout occurs.
> That's going to be tricky though I suspect...

Further, an application might use signals such as SIGALARM,
delaying them significantly will cause trouble.

> A simpler option would be to have an end points such as a tap device

Which end points would that be? Doesn't this affect a packet socket
with matching filters? A userspace TCP socket that happens to
reside on the same box?  It also seems that at least with a tap device
an skb can get queued in a qdisk, also indefinitely, right?

> which can swallow skbs for arbitrary times implement a policy in this
> regard, either to deep copy or drop after a timeout?
> 
> Ian.

Or deep copy immediately?

-- 
MST
