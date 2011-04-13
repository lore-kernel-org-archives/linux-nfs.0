Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2453 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757105Ab1DMTEP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Apr 2011 15:04:15 -0400
Date: Wed, 13 Apr 2011 15:04:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Andy Adamson <andros@netapp.com>,
        Badari Pulavarty <pbadari@us.ibm.com>, linux-nfs@vger.kernel.org,
        khoa@us.ibm.com
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
Message-ID: <20110413150419.7ec07418@corrin.poochiereds.net>
In-Reply-To: <D860A5B3-B6D5-4810-936B-ADC78E097997@oracle.com>
References: <1302622335.3877.62.camel@badari-desktop>
	<0DC51758-AE6C-4DD2-A959-8C8E701FEA4E@oracle.com>
	<1302624935.3877.66.camel@badari-desktop>
	<FF1EE11E-62EB-42B9-A4C9-7A2FE4C60D2F@oracle.com>
	<1302630360.3877.72.camel@badari-desktop>
	<20110413083656.12e54a91@tlielax.poochiereds.net>
	<4DA5A899.3040202@us.ibm.com>
	<20110413100228.680ace66@tlielax.poochiereds.net>
	<1302704533.8571.12.camel@lade.trondhjem.org>
	<20110413132034.459c68bb@corrin.poochiereds.net>
	<7497FEC4-F173-4E10-B571-B856471CB9FD@netapp.com>
	<1302718471.8571.48.camel@lade.trondhjem.org>
	<D860A5B3-B6D5-4810-936B-ADC78E097997@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 13 Apr 2011 14:47:05 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Apr 13, 2011, at 2:14 PM, Trond Myklebust wrote:
> 
> > On Wed, 2011-04-13 at 13:56 -0400, Andy Adamson wrote:
> >> On Apr 13, 2011, at 1:20 PM, Jeff Layton wrote:
> >> 
> >>> On Wed, 13 Apr 2011 10:22:13 -0400
> >>> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> >>> 
> >>>> On Wed, 2011-04-13 at 10:02 -0400, Jeff Layton wrote:
> >>>>> We could put the rpc_rqst's into a slabcache, and give each rpc_xprt a
> >>>>> mempool with a minimum number of slots. Have them all be allocated with
> >>>>> GFP_NOWAIT. If it gets a NULL pointer back, then the task can sleep on
> >>>>> the waitqueue like it does today. Then, the clients can allocate
> >>>>> rpc_rqst's as they need as long as memory holds out for it.
> >>>>> 
> >>>>> We have the reserve_xprt stuff to handle congestion control anyway so I
> >>>>> don't really see the value in the artificial limits that the slot table
> >>>>> provides.
> >>>>> 
> >>>>> Maybe I should hack up a patchset for this...
> >>>> 
> >>>> This issue has come up several times recently. My preference would be to
> >>>> tie the availability of slots to the TCP window size, and basically say
> >>>> that if the SOCK_ASYNC_NOSPACE flag is set on the socket, then we hold
> >>>> off allocating more slots until we get a ->write_space() callback which
> >>>> clears that flag.
> >>>> 
> >>>> For the RDMA case, we can continue to use the current system of a fixed
> >>>> number of preallocated slots.
> >>>> 
> >>> 
> >>> I take it then that we'd want a similar scheme for UDP as well? I guess
> >>> I'm just not sure what the slot table is supposed to be for.
> >> 
> >> [andros] I look at the rpc_slot table as a representation of the amount of data the connection to the server
> >> can handle - basically the #slots should = double the bandwidth-delay product divided by the max(rsize/wsize).
> >> For TCP, this is the window size. (ping of max MTU packet * interface bandwidth).
> >> There is no reason to allocate more rpc_rqsts that can fit on the wire. 
> > 
> > Agreed, but as I said earlier, there is no reason to even try to use UDP
> > on high bandwidth links, so I suggest we just leave it as-is.
> 
> I think Jeff is suggesting that all the transports should use the same logic, but UDP and RDMA should simply have fixed upper limits on their slot table size.  UDP would then behave the same as before, but would share code with the others.  That might be cleaner than maintaining separate slot allocation mechanisms for each transport.
> 
> In other words, share the code, but parametrize it so that UDP and RDMA have effectively fixed slot tables as before, but TCP is allowed to expand.
>

That was my initial thought, but Trond has a point that there's no
reason to allocate info for a call that we're not able to send.

The idea of hooking up congestion feedback from the networking layer
into the slot allocation code sounds intriguing, so for now I'll stop
armchair quarterbacking and just wait to see what Andy comes up with :)

-- 
Jeff Layton <jlayton@redhat.com>
