From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH] svcrdma: Fix compile warning on 32b platforms
Date: Tue, 27 May 2008 09:08:38 -0500
Message-ID: <1211897318.4114.53.camel@trinity.ogc.int>
References: <1211557193.4114.21.camel@trinity.ogc.int>
	 <20080525190112.GC8094@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:60519 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757251AbYE0OE3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 May 2008 10:04:29 -0400
In-Reply-To: <20080525190112.GC8094@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sun, 2008-05-25 at 15:01 -0400, J. Bruce Fields wrote:
> On Fri, May 23, 2008 at 10:39:53AM -0500, Tom Tucker wrote:
> > The ib_sge is used to store both dma_addr_t and virtual addresses.
> > This causes a warning on 32b platforms when casting ptrs to the
> > u64 addr field of the ib_sge. There is work underway to reduce the
> > memory footprint of the WR context in 2.6.27 the time frame that will
> > remove the overloading of the ib_sge.addr field.
> 
> Naively, this and "svcrdma: Refactor RDMA_WRITE dma mapping logic" still
> look like a step in the wrong direction; the old code seemed to have a
> much more clear separation between kernel addresses (void *'s) and
> on-the-wire addresses (stored in u64's).  Stuff like:
> 
> > +					  (void*)(unsigned long)
> > +					  sge[i].addr, sge[i].length,
> 
> makes me nervous.
> 

The svc_rdma_op_ctxt is being used for both the context of the NFS_ RPC
request (that can map up to 2M) and the RDMA WR (which is bounded by the
SGE limit of the device). 

What changed is when the dma_map is performed. Originally it was
performed when the NFS_ request was mapped to a local SGL. The problem
with this is that the temporary context used to keep this mapping is
freed (and unmapped) before the WR completes and therefore the memory
could be unmapped too early. Since the unmap is a no-op on x86 -- this
never caused a problem, however, for IA64 and others -- it is a problem.

What needs to be done is to replace the svc_rdma_op_ctxt with a suitable
temporary mapping structure with the appropriate type. I will have this
patch soon. 

I knew it was broken and was concerned that it would be found in the
field, but since we don't hear the screams - it sounds like we should
just ditch these interim dma changes and then we won't have code
upstream that has this interim typing issue.

If someone does find this problem, I can point them at my tree to give
it whirl.

Sound ok?

Tom
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

