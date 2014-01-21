Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40067 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754295AbaAUTWf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jan 2014 14:22:35 -0500
Date: Tue, 21 Jan 2014 14:21:59 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/7] nfs: page cache invalidation for dio
Message-ID: <20140121142159.210ca0b8@tlielax.poochiereds.net>
In-Reply-To: <20131115103324.6a3cf978@tlielax.poochiereds.net>
References: <20131114165027.355613182@bombadil.infradead.org>
	<20131114165042.205194841@bombadil.infradead.org>
	<20131114133551.5d08b5cd@tlielax.poochiereds.net>
	<20131115142847.GA1107@infradead.org>
	<20131115095241.2c5e1cfb@tlielax.poochiereds.net>
	<20131115150204.GA8105@infradead.org>
	<20131115103324.6a3cf978@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 15 Nov 2013 10:33:24 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Fri, 15 Nov 2013 07:02:04 -0800
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Fri, Nov 15, 2013 at 09:52:41AM -0500, Jeff Layton wrote:
> > > Do you have these patches in a git tree someplace? If so, I wouldn't
> > > mind running this reproducer against it to see if it helps. It's a bit
> > > of a longshot, but what the heck...
> > 
> > While I do have a local git tree I don't really have anywhere to push
> > it to.  But applying these patches shouldn't be all that hard.
> > 
> 
> It's not -- I'm just lazy...
> 
> FWIW, I tried this set and it didn't make any difference on the bug, so
> I'll just keep soldiering on to track it down...
> 

I just tried this set again, and it *did* seem to help that bug.

I think the reason it didn't before was that I had applied this set on
top of a tree that held a different patch that introduced a race in the
nfs_revalidate_mapping() code.

In any case, this helps but it's a little odd. With this patch, you add
an invalidate_inode_pages2 call prior to doing the DIO. But, you've
also left in the call to nfs_zap_mapping in the completion codepath.

So now, we shoot down the mapping prior to doing a DIO write, and then
mark the mapping for invalidation again when the write completes. Was
that intentional?

It seems a little excessive and might hurt performance in some cases.
OTOH, if you mix buffered and DIO you're asking for trouble anyway and
this approach seems to give better cache coherency.
-- 
Jeff Layton <jlayton@redhat.com>
