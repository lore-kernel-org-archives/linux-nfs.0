From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] svcrdma: Fix compile warning on 32b platforms
Date: Sun, 25 May 2008 16:21:43 -0400
Message-ID: <20080525202143.GA11997@fieldses.org>
References: <1211557193.4114.21.camel@trinity.ogc.int> <20080525190112.GC8094@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57252 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756292AbYEYUVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 25 May 2008 16:21:46 -0400
In-Reply-To: <20080525190112.GC8094@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 25, 2008 at 03:01:12PM -0400, bfields wrote:
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

That aside, are those two patches really bugfixes?  We need to keep
bugfixes (for 2.6.26) separate from other stuff (for 2.6.27).

--b.
