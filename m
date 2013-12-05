Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43530 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932560Ab3LEPuf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Dec 2013 10:50:35 -0500
Date: Thu, 5 Dec 2013 10:50:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 1/3] nfsd: don't try to reuse an expired DRC entry
 off the list
Message-ID: <20131205155024.GC30113@fieldses.org>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
 <1386241253-5781-2-git-send-email-jlayton@redhat.com>
 <20131205132919.GC3381@infradead.org>
 <20131205084156.5a9a2545@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131205084156.5a9a2545@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 05, 2013 at 08:41:56AM -0500, Jeff Layton wrote:
> On Thu, 5 Dec 2013 05:29:19 -0800
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Thu, Dec 05, 2013 at 06:00:51AM -0500, Jeff Layton wrote:
> > > Currently when we are processing a request, we try to scrape an expired
> > > or over-limit entry off the list in preference to allocating a new one
> > > from the slab.
> > > 
> > > This is unnecessarily complicated. Just use the slab layer.
> > 
> > I really don't think pruning caches from lookup functions is a good
> > idea. To many chances for locking inversions, unbounded runtime and
> > other issues.  So I'd prefer my earlier version of the patch to
> > remove it entirely if we want to change anything beyond your minimal
> > fix.
> > 
> 
> It's not likely to hit a locking inversion here since we don't have a
> lot of different locks, but point taken...
> 
> If we take that out, then that does mean that the cache may grow larger
> than the max...possibly much larger since the pruner workqueue job
> only runs every 120s and you can put a lot more entries into the cache
> in that period.

Yeah, this scares me.

I looked through my old mail but couldn't find your previous results:
how long did you find the hash buckets needed to be before the
difference was noticeable on your setup?

We typically do a failed-lookup-and-insert on every cached operation so
I wouldn't be surprised if a workload of small random writes, for
example, could produce an unreasonably large cache in that time.

--b.

> 
> That said, I don't feel too strongly about it, so if you think leaving
> it to the workqueue job and the shrinker is the right thing to do, then
> so be it.
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
