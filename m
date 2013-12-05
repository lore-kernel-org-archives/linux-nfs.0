Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64919 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696Ab3LENhz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Dec 2013 08:37:55 -0500
Date: Thu, 5 Dec 2013 08:37:32 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Dave Chinner <dchinner@redhat.com>
Subject: Re: [PATCH RFC 0/3] nfsd: convert nfsd DRC code to use list_lru
 infrastructure
Message-ID: <20131205083732.425e9d44@tlielax.poochiereds.net>
In-Reply-To: <20131205132717.GB3381@infradead.org>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
	<20131205132717.GB3381@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 5 Dec 2013 05:27:17 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Dec 05, 2013 at 06:00:50AM -0500, Jeff Layton wrote:
> > This patchset converts the LRU list in the nfsd duplicate reply cache to
> > use the new list_lru infrastrucure. Note that this is based on top of
> > the patch that I sent to Bruce earlier this week that fixes the
> > svc_cacherep direct reclaim bug. I'm sending this as an RFC since I'm
> > not 100% convinced it's an improvement.
> > 
> > The majorly unintuitive thing about list_lru that I've found is that
> > you can't call call list_lru_del from list_lru_walk. So, you need
> > different routines to free an object depending on how it's being freed.
> 
> That's because list_lru_walk already does all the accounting.  You can
> simply do an list_del_init and then return LRU_MOVED and you're done.
> 

Well no...we have to take it off the hlist too, kmem_cache_free the
object and fix up the accounting for the stats.

list_lru handles the accounting for the lru list itself, but not for
the rest of the housekeeping we have to do.

-- 
Jeff Layton <jlayton@redhat.com>
