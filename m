Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60368 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932595AbdGKUuk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 16:50:40 -0400
Date: Tue, 11 Jul 2017 16:50:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1] sunrpc: Allocate up to RPCSVC_MAXPAGES per svc_rqst
Message-ID: <20170711205039.GA2303@fieldses.org>
References: <20170630160258.11995.10205.stgit@klimt.1015granger.net>
 <20170630201653.GD14868@fieldses.org>
 <222F5E88-CC11-418B-B9FF-1EF10DE60BEB@oracle.com>
 <20170630204733.GE14868@fieldses.org>
 <794E47E1-E7D0-4B10-A5C7-0C5DF97F9DB9@oracle.com>
 <5E60EBFD-F5D6-4959-A590-34ACBDC95202@oracle.com>
 <20170706140216.GB29025@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170706140216.GB29025@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 06, 2017 at 10:02:16AM -0400, J. Bruce Fields wrote:
> On Wed, Jul 05, 2017 at 10:36:17AM -0400, Chuck Lever wrote:
> > I would like to get this resolved quickly so that my nfsd-rdma-for-4.13
> > series can be included in v4.13.
> 
> It will be in 4.13.
> 
> > Is the v1 patch acceptable, or do we need a comment here? If a comment
> > is necessary, please provide the text you want to see.
> 
> It's fine, we can do more later.
> 
> The holdup is I'm still confused about the non-RDMA case: it looks to me
> like we're not reserving quite enough for an unaligned maximum-length
> read, but a pynfs test doesn't seem to be hitting any problem, so I
> think I'm misunderstanding that case....

OK, I see my confusion: that final NULL that svc_alloc_arg sets isn't a
"sentinel NULL" exactly.  There's no code that assumes that rq_pages is
NULL-terminated.

We initialize that final entry to NULL just so that nfsd_splice_actor
doesn't call put_page() on an unitialized value.  That final entry is
*only* needed in the splice case, to handle maximum-length
non-page-aligned zero-copy reads.  And in the splice case we don't need
an actual allocated page, we're just going to put_page() whatever's
there to replace with an entry from the page cache....

So, in the tcp case to handle a big read request, assuming 4k pages, we
need 2 pages for the request and the head and tail of the reply, and,
either: 256 allocated pages to copy data into in the readv case, or 257
(not necessarily allocated) array entries to store page array references
to in the splice case.

Hence a 259-entry array with only 258 allocated entries and one NULL.

--b.
