Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:50456 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928AbbHJI0X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2015 04:26:23 -0400
Date: Mon, 10 Aug 2015 01:26:22 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 03/18] nfsd: convert laundry_wq to something less
 nfsd4 specific
Message-ID: <20150810082622.GA18624@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-4-git-send-email-jeff.layton@primarydata.com>
 <20150809071438.GC9772@infradead.org>
 <20150809071137.28ca8f19@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150809071137.28ca8f19@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 09, 2015 at 07:11:37AM -0400, Jeff Layton wrote:
> create_singlethread_workqueue already makes an unbound workqueue. This
> patch just lifts the "max_active" value to the default, and removes the
> WQ_MEM_RECLAIM flag.
> 
> We certainly could turn this into a bound workqueue, but given the sort
> of job that the laundromat runs I'm not sure we'd benefit much from the
> locality.
> 
> ...and sure, I can turn this into two patches if you'd prefer.

The patch was just rather confusing to me.  Do you want the existing
laundromat to scale better with lots of namespaces?  Sounds reasonable,
but I don't really see the use case.  

Looking at the later patches I now see you're overloading a totally
different job to it.  I don't think there's a point given how cheap
workqueues are these days.  Even more it seems like you really should
use the mm/list_lru.c infrastructure and a shrinker for a your file
cache.
