Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34824 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689Ab1KKUAi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Nov 2011 15:00:38 -0500
Date: Fri, 11 Nov 2011 15:00:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] sunrpc: use SKB fragment destructors to delay
 completion until page is released by network stack.
Message-ID: <20111111200032.GA20853@fieldses.org>
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
> 
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
> 
> A simpler option would be to have an end points such as a tap device
> which can swallow skbs for arbitrary times implement a policy in this
> regard, either to deep copy or drop after a timeout?

Stupid question: Is it a requirement that you be safe against DOS by a
rogue process with a tap device?  (And if so, does current code satisfy
that requirement?)

--b.
