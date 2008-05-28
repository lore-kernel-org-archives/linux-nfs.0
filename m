From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH] svcrdma: Fix compile warning on 32b platforms
Date: Wed, 28 May 2008 14:49:24 -0500
Message-ID: <1212004164.24822.11.camel@trinity.ogc.int>
References: <20080525202143.GA11997@fieldses.org>
	 <C45F878E.19918%tom@opengridcomputing.com>
	 <20080528190734.GC19542@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:37942 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752725AbYE1TpJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2008 15:45:09 -0400
In-Reply-To: <20080528190734.GC19542@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-05-28 at 15:07 -0400, J. Bruce Fields wrote:
> On Sun, May 25, 2008 at 09:15:58PM -0500, Tom Tucker wrote:
> > 
> > 
> > 
> > On 5/25/08 3:21 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Sun, May 25, 2008 at 03:01:12PM -0400, bfields wrote:
> > >> On Fri, May 23, 2008 at 10:39:53AM -0500, Tom Tucker wrote:
> > >>> The ib_sge is used to store both dma_addr_t and virtual addresses.
> > >>> This causes a warning on 32b platforms when casting ptrs to the
> > >>> u64 addr field of the ib_sge. There is work underway to reduce the
> > >>> memory footprint of the WR context in 2.6.27 the time frame that will
> > >>> remove the overloading of the ib_sge.addr field.
> > >> 
> > >> Naively, this and "svcrdma: Refactor RDMA_WRITE dma mapping logic" still
> > >> look like a step in the wrong direction; the old code seemed to have a
> > >> much more clear separation between kernel addresses (void *'s) and
> > >> on-the-wire addresses (stored in u64's).  Stuff like:
> > >>
> >  
> > >>> +       (void*)(unsigned long)
> > >>> +       sge[i].addr, sge[i].length,
> > >> 
> > >> makes me nervous.
> > >
> > 
> > The mapping of data on the wire to addresses in the client is contained in
> > the RPCRDMA header of the incoming request and needs to be translated into
> > an iovec for subsequent submission as WR. To store this mapping, the code
> > uses a temporarily allocated context. As you've noted, pre-fix this context
> > contained only dma_addr and the WR context contained essentially an empty
> > mapping (ctxt->count==0). The problem is that when the temporary mapping is
> > removed, the SGE are unmapped and this unmap could occur before the WR has
> > actually completed. The fix coded is to have the temporary context contain
> > just the translation and have the WR context contain the dma_addr. This way
> > the unmap occurs when the WR completes, not when the temporary context is
> > put. However, this "solution" introduces the very issue we're discussing.
> 
> Oh, OK.  From the changelog (and what I saw of the code), it looked like
> this what just cleanup; I didn't understand that there was an actual bug
> fixed.
> 
> (Or is the actual bugfix in a later patch ("svcrdma: Move the DMA unmap
> logic to the CQ handler" maybe?) and this is just preparation for that
> fix?  OK, fair enough; but in future maybe a short note to that effect
> might help--just enough so I understand why this is appropriate for the
> current release as opposed to something that could be split out and
> saved for the next merge window.)

It fixes a bug. The splitting out of the DMA unmap fixes _another_ bug
where the dma_unmap occurs too late :-\. On the receive side you must
unmap before attempting to look at the data.

> 
> > For 2.6.27, I will create a separate data structure for the temporary
> > mapping that does not share the same type as the WR context. This will allow
> > the correct data types to be stored without confusion.
> >  
> > > That aside, are those two patches really bugfixes?  We need to keep
> > > bugfixes (for 2.6.26) separate from other stuff (for 2.6.27).
> > > 
> > 
> > I think the changes do in fact fix real bugs, but they are not symptomatic
> > on x86 platforms. It sounds like we should defer to 2.6.27 and I'll fix the
> > design issue above. Sound ok?
> 
> If it's a bugfix then we can still slip it in, but for a rare bug in an
> as-yet fairly new feature, waiting for the next merge window (and a
> cleaner fix) also sounds OK.

Actually Bruce, I've just finished coding the nice, new, and clean (I
hope) design. I'll post it after I've tested it some more. Bottom line,
your comments and instincts are good. I kind of panicked when I realized
how busted the DMA was. I'll post a follow up here shortly... Thanks for
your patience.

Tom
> 
> --b.

