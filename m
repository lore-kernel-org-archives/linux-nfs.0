Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54482 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754454Ab3HET1H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Aug 2013 15:27:07 -0400
Date: Mon, 5 Aug 2013 15:27:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dawid Stawiarski <neeo@xl.wp.pl>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Odp: Re: Performance/stability problems with nfs shares
Message-ID: <20130805192702.GC1583@fieldses.org>
References: <51ff6748611fb6.11394927@wp.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <51ff6748611fb6.11394927@wp.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 05, 2013 at 10:50:16AM +0200, Dawid Stawiarski wrote:
> Dnia Piątek, 2 Sierpnia 2013 17:47 J. Bruce Fields  napisał(a) 
> > On Fri, Aug 02, 2013 at 04:37:57PM +0200, Dawid Stawiarski wrote:
> > > W dniu 02.08.2013 15:12, Jeff Layton pisze:
> > > >Typically, a stack trace like that indicates that the process is
> > > >waiting for the server to respond. The first thing I would do would be
> > > >to ascertain whether the server is actually responding to these
> > > >requests.
> > > >
> > > 
> > > The same share is accessible on other nodes, so the problem involves
> > > only one of the nodes (completly random) at a time.
> >  
> > It's still conceivable that a server problem could cause it to stop
> > responding to calls only from a single client--it'd be useful if
> > possible to check a trace to see if that's what's happening.  If the
> > traffic is really huge then capturing and analyzing a good trace may be
> > difficult.
> 
> I've managed to capture network traffic on client side, when the problem starts.
> It seems like:
> 0. operation SETATTR before problem works as charm (attached for reference)
> 1. retransmission happens very fast after sending 3 packets for WRITE operation
> 1a. linux is not using jumbo frame (3 packets of ~1K size instead of one)
> 2. linux ignores the ACK received after retransmission (actually it's SACK for the third packet)

I don't see any SACK?

But yes I see it appears to be ACKing a sequence number that should
cover the segment the client keeps retransmitting.

And I don't know what would cause that.

Might be worth asking networking folks?  (netdev@vger.kernel.org).

--b.

> 3. both client and server start to retransmit their packets
> 
> what happens next (not visible in the pcap attached) is that the server sends RST after some time, and client starts new connection - after that, things start to work normally again. So maybe, it's more general problem with TCP stack and not NFS itself?
> 
> D.


