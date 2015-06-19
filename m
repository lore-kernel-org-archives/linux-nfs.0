Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:40709 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754252AbbFSKPE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jun 2015 06:15:04 -0400
Received: from public by plane.gmane.org with local (Exim 4.69)
	(envelope-from <public@plane.gmane.org>)
	id 1Z5tJy-00053E-3x
	for linux-nfs@vger.kernel.org; Fri, 19 Jun 2015 12:14:50 +0200
Date: Fri, 19 Jun 2015 06:11:53 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Weston Andros Adamson
	<public-dros-7I+n7zu2hftEKMMhf/gKZA@plane.gmane.org>
cc: public-linux-nfs-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org
Subject: Re: [PATCH 0/5] pgio: fix buffered write retry path
In-Reply-To: <1405088449-11268-1-git-send-email-dros@primarydata.com>
Message-ID: <alpine.OSX.2.19.9992.1506190547060.4030@ip0af51906.int.uvm.edu>
References: <1405088449-11268-1-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On Fri, 11 Jul 2014, Weston Andros Adamson wrote:

> My recent pgio work added the ability to split requests into sub-page
> regions, but didn't handle a few places in the writeback code where
> requests are looked up by struct page and may already be split into
> multiple requests.
>
> This patchset adds a function "nfs_lock_and_join_requests" in patch
> "nfs: handle multiple reqs in nfs_page_async_flush", which:
>   - takes mutex lock
>   - looks up head request
>   - grabs request lock for each subrequest
>      - if unsuccessful, unrolls old locks and waits on subrequest
>   - removes all requests from commit lists
>   - merges range of subrequests into the head requests
>   - unlinks and destroys the old subrequests.
>
> The other patches are related fixes.
>
> The problem showed up when mounting with wsize < PAGE_SIZE - this would
> cause multiple requests per page. If a commit failed, nfs_page_async_flush
> would operate just on the head request, leading to a hang.
>
> The nfs_wb_page_cancel patch leverages the same function -
> nfs_lock_and_join_requests cancels all operations on the page group.  I've had
> a really hard time testing nfs_wb_page_cancel, I've only hit it once in weeks of
> testing. Any ideas on how to reliably trigger this is appreciated - it's not
> as easy as just kicking off a ton of writeback then truncating. The one time I
> did see it was with a ton of i/o on a VM with 256M of RAM, which was swapping
> like crazy, along with restarting the server repeatedly (to get commit verifier
> mismatch).

Hey Dros, it's a year later -- but I want to report that this set fixes a
rare race where nfs_wb_page_cancel() and nfs_commit_release_pages() both
remove the same request from an inode, resulting in an underflow in
nfs_inode->nrequests, and finally a BUG (now changed to a WARN) when the
inode is cleaned up.

The fix is that nfs_lock_and_join_requests() holds i_lock for the duration
of checking PagePrivate and trying to lock the nfs_page, and retrying or
returning NULL.  Previously, nfs_wb_page_cancel() held the i_lock while
checking PagePrivate, then released it which allowed the page to be removed
and then unlocked in nfs_commit_release_pages(), and then
nfs_wb_page_cancel() could lock and remove it as well.

I've had good luck exercising nfs_wb_page_cancel() by racing writes and
truncates on a mount with small nfs page size.. but there are lots of
wait_on_page_writeback() and friends in the pagth that close the race
window.  Better luck can be had using madvise w/ the hardware poision flag,
since that jumps you past a bunch of page invalidation checks, but I wonder
if that is a realistic test of real world conditions..

Anyway, thanks for these.. I have to see what of this work I can move back
into the already long-in-the-tooth RHEL6.

Ben


