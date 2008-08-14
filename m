From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] knfsd: allocate readahead cache in individual chunks
Date: Thu, 14 Aug 2008 15:14:31 -0400
Message-ID: <20080814151431.58095483@barsoom.rdu.redhat.com>
References: <1218679407-11364-1-git-send-email-jlayton@redhat.com>
	<20080814180635.GC23859@fieldses.org>
	<20080814145227.15efe087@barsoom.rdu.redhat.com>
	<1218741086.7328.24.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760140AbYHNTOg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2008 15:14:36 -0400
In-Reply-To: <1218741086.7328.24.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 14 Aug 2008 15:11:26 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Thu, 2008-08-14 at 14:52 -0400, Jeff Layton wrote:
> > 1) do what I did here (individual kmalloc for each raparm)
> > 
> > 2) do an allocation of an raparms array for each hash bucket, but when
> > we get to larger thread counts, these will still require multi-page
> > allocations:
> > 
> > 8192 threads * 2 / 16 buckets * 72 bytes = 73728 byte allocation
> > 
> > 3) declare a separate slabcache for this and allocate each raparm
> > individually from that
> > 
> > ...#3 might be reasonable, but we could end up wasting even more memory
> > that way when we only have a few threads. Tough call...
> 
> How about
>   4) Set an upper cap on the size of the raparm array
> 
> Readahead is only useful in moderation. You don't want to reach a
> situation where the various threads' readahead activities start causing
> thrashing...
> 

That sounds like it would be a good idea in conjunction with this
patch. What would be a reasonable upper limit?

-- 
Jeff Layton <jlayton@redhat.com>
