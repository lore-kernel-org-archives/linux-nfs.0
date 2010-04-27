From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Possible problem with commit a6305ddb080 : NFS: Fix a race
 with the new commit code
Date: Tue, 27 Apr 2010 08:00:34 -0400
Message-ID: <1272369635.16814.52.camel@localhost.localdomain>
References: <20100427143542.001f8dbe@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:36443 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752690Ab0D0MAj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Apr 2010 08:00:39 -0400
In-Reply-To: <20100427143542.001f8dbe-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-04-27 at 14:35 +1000, Neil Brown wrote: 
> Hi Trond,
>  I think the above mentioned commit might have added a new race to replace
> the old ....
> 
>  I have report of a BUG in nfs_page_async_flush.
> 
> It isn't a vanilla upstream kernel - there are a bunch of SUSE patches
> in there - so quoting the line-number won't help you, but it is the
>     BUG_ON(ret != 0);
> after the call to nfs_set_page_writeback.
> (https://bugzilla.novell.com/show_bug.cgi?id=599628)
> 
> This implies that nfs_find_and_lock_request got a new lock on the page,
> and then we found that it was already flagged for writeback.

That's odd. Callers such as write_cache_pages() should normally be doing
a wait_on_page_writeback() after taking the page lock but prior to
calling the filesystem.

> The commit mentioned create just such an opportunity.  It reorders things
> so that a page is unlocked before writeback is cleared, thus creating a window
> for that BUG to fire.
> 
> What is the race that you were trying to fix?

I want to ensure that the call to write_inode() immediately after
filemap_fdatawait() in the function writeback_single_inode() works
correctly. Prior to this fix, there was a race whereby the Pg_writeback
flag could be cleared, but the nfs_page structure would still be locked.
This again would result in the page being skipped by nfs_scan_list() and
so it wouldn't be registered as COMMITed.

Cheers
  Trond

