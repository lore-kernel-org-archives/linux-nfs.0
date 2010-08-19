Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:46850 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984Ab0HSOhL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Aug 2010 10:37:11 -0400
Date: Thu, 19 Aug 2010 10:37:10 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>, fengguang.wu@gmail.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100819143710.GA4752@infradead.org>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100819101525.076831ad@barsoom.rdu.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 19, 2010 at 10:15:25AM -0400, Jeff Layton wrote:
> I'm looking at backporting some upstream changes to earlier kernels,
> and ran across something I don't quite understand...
> 
> In nfs_commit_unstable_pages, we set the flags to FLUSH_SYNC. We then
> zero out the flags if wbc->nonblocking or wbc->for_background is set.
> 
> Shouldn't we also clear it out if wbc->sync_mode == WB_SYNC_NONE ?
> WB_SYNC_NONE means "don't wait on anything", so shouldn't that include
> not waiting on the COMMIT to complete?

I've been trying to figure out what the nonblocking flag is supposed
to mean for a while now.

It basically disappeared in commit 0d99519efef15fd0cf84a849492c7b1deee1e4b7

	"writeback: remove unused nonblocking and congestion checks"

from Wu.  What's left these days is a couple of places in local copies
of write_cache_pages (afs, cifs), and a couple of checks in random
writepages instances (afs, block_write_full_page, ceph, nfs, reiserfs, xfs)
and the use in nfs_write_inode.  It's only actually set for memory
migration and pageout, that is VM writeback.

To me it really doesn't make much sense, but maybe someone has a better
idea what it is for.

> +	if (wbc->nonblocking || wbc->for_background ||
> +	    wbc->sync_mode == WB_SYNC_NONE)

You could remove the nonblocking and for_background checks as
these impliy WB_SYNC_NONE.

