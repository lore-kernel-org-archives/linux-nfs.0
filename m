Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:35827 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbbHJLXy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2015 07:23:54 -0400
Received: by ykdz80 with SMTP id z80so24867493ykd.2
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2015 04:23:54 -0700 (PDT)
Date: Mon, 10 Aug 2015 07:23:51 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 03/18] nfsd: convert laundry_wq to something less
 nfsd4 specific
Message-ID: <20150810072351.39b1b189@tlielax.poochiereds.net>
In-Reply-To: <20150810082622.GA18624@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-4-git-send-email-jeff.layton@primarydata.com>
	<20150809071438.GC9772@infradead.org>
	<20150809071137.28ca8f19@tlielax.poochiereds.net>
	<20150810082622.GA18624@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Aug 2015 01:26:22 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Sun, Aug 09, 2015 at 07:11:37AM -0400, Jeff Layton wrote:
> > create_singlethread_workqueue already makes an unbound workqueue. This
> > patch just lifts the "max_active" value to the default, and removes the
> > WQ_MEM_RECLAIM flag.
> > 
> > We certainly could turn this into a bound workqueue, but given the sort
> > of job that the laundromat runs I'm not sure we'd benefit much from the
> > locality.
> > 
> > ...and sure, I can turn this into two patches if you'd prefer.
> 
> The patch was just rather confusing to me.  Do you want the existing
> laundromat to scale better with lots of namespaces?  Sounds reasonable,
> but I don't really see the use case.  
> 
> Looking at the later patches I now see you're overloading a totally
> different job to it.  I don't think there's a point given how cheap
> workqueues are these days.  Even more it seems like you really should
> use the mm/list_lru.c infrastructure and a shrinker for a your file
> cache.

Right, it's a laundry job of a different sort, so I figured using the
laundry_wq would make sense. I also just saw absolutely no reason to
serialize all of the nfsd4 laundromat jobs (if there were ever more
than one on the box at a time), so it was an opportunity to clean that
up.

I did consider a shrinker and LRU list for this. The problem there is
that shrinkers are triggered on memory pressure. Keeping these files
open after they've been idle for a long period of time would prevent
the kernel from handing out leases on them, so closing them after a
reasonable idle period seemed like the right thing to do.

I suppose however we could use a shrinker/LRU _and_ add a mechanism
that would cause the kernel to close idle nfsd_files for an inode when
there is an attempt to do a F_SETLEASE. That would probably work,
unless I'm missing other reasons that keeping unused files open might
be problematic. Are there any?

-- 
Jeff Layton <jlayton@poochiereds.net>
