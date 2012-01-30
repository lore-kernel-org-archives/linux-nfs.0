Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.eu.citrix.com ([62.200.22.115]:57723 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152Ab2A3Qnq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 11:43:46 -0500
Subject: Re: [PATCH v3 6/6] sunrpc: use SKB fragment destructors to delay
 completion until page is released by network stack.
From: Ian Campbell <Ian.Campbell@citrix.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
CC: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Mon, 30 Jan 2012 16:43:33 +0000
In-Reply-To: <20120130162306.GB9345@redhat.com>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
	 <1327494434-21566-6-git-send-email-ian.campbell@citrix.com>
	 <20120126131136.GA16400@redhat.com>
	 <1327938713.26983.248.camel@zakaz.uk.xensource.com>
	 <20120130162306.GB9345@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1327941813.26983.270.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-01-30 at 16:23 +0000, Michael S. Tsirkin wrote:
> On Mon, Jan 30, 2012 at 03:51:53PM +0000, Ian Campbell wrote:
> > On Thu, 2012-01-26 at 13:11 +0000, Michael S. Tsirkin wrote:
> > > On Wed, Jan 25, 2012 at 12:27:14PM +0000, Ian Campbell wrote:
> > > > This prevents an issue where an ACK is delayed, a retransmit is queued (either
> > > > at the RPC or TCP level) and the ACK arrives before the retransmission hits the
> > > > wire. If this happens to an NFS WRITE RPC then the write() system call
> > > > completes and the userspace process can continue, potentially modifying data
> > > > referenced by the retransmission before the retransmission occurs.
> > > > 
> > > > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > > > Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > Cc: "David S. Miller" <davem@davemloft.net>
> > > > Cc: Neil Brown <neilb@suse.de>
> > > > Cc: "J. Bruce Fields" <bfields@fieldses.org>
> > > > Cc: linux-nfs@vger.kernel.org
> > > > Cc: netdev@vger.kernel.org
> > > 
> > > This doesn't include either of the two options you proposed to address
> > > the sender blocked forever by receiver issue with bridged septups and
> > > endpoints such a tap device or a socket on the same box,
> > > does it?
> > 
> > There was never any response to Bruce's question:
> > http://thread.gmane.org/gmane.linux.network/210873/focus=44849
> > 
> >         Stupid question: Is it a requirement that you be safe against DOS by a
> >         rogue process with a tap device?  (And if so, does current code satisfy
> >         that requirement?)
> > 
> > IMHO the answer to both questions is no, there are plenty of ways a
> > rogue process with a tap device can wreak havoc.
> 
> I thought the answer is an obviious yes :(
> What are these ways tap can wreak havoc?

Can't they spoof traffic and all sorts of things like that? Hrm. I
suppose that the same as any peer on the network so we already handle
that sort of thing. Maybe that's a red herring then.

> > > How about patching __skb_queue_tail to do a deep copy?
> > > That would seem to handle both tap and socket cases -
> > > any other ones left?
> > 
> > Wouldn't that mean we were frequently (almost always) copying for lots
> > of other cases too? That would rather defeat the purpose of being able
> > to hand pages off to the network stack in a zero copy fashion.
> 
> Yes but the case of an rpc connection to the same box
> is very rare I think, not worth optimizing for.

But changing __skb_queue_tail doesn't only impact rpc connections to the
same box, does it? At least I can see plenty of callers of
__skb_queue_tail which don't look like they would want a copy to occur
-- plenty of drivers for one thing.

Perhaps in combination with a per-queue flag or per-socket flag to
enable it though it might work though?

> > > If we do this, I think it would be beneficial to pass a flag
> > > to the destructor indicating that a deep copy was done:
> > > this would allow senders to detect that and adapt.
> > 
> > If you were doing a deep copy anyway you might as well create a
> > completely new skb and release the old one, thereby causing the
> > destructors to fire in the normal way for it SKB. The copy wouldn't have
> > destructors because the pages would no longer be owned by the sender.
> > 
> > Ian.
> 
> What I mean is that page pin + deep copy might be more expensive
> than directly copying. So the owner of the original skb
> cares whether we did a deep copy or zero copy transmit worked.

You mean so they can adaptively do a copy directly next time?

I think that would add a fair bit more complexity to what, as you point
out, is a fairly rare occurrence.

Ian.


