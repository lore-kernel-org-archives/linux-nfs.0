From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH v2] flow control for WRITE requests
Date: Tue, 02 Jun 2009 14:37:27 -0400
Message-ID: <4A257167.9090304@redhat.com>
References: <49C93526.70303@redhat.com>	 <20090324211917.GJ19389@fieldses.org>  <4A1D9210.8070102@redhat.com>	 <1243457149.8522.68.camel@heimdal.trondhjem.org>	 <4A1EB09A.8030809@redhat.com> <1243892886.4868.74.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54072 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbZFBShc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2009 14:37:32 -0400
In-Reply-To: <1243892886.4868.74.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
>
> So, how about doing this by modifying balance_dirty_pages() instead?
> Limiting pages on a per-inode basis isn't going to solve the common
> problem of 'ls -l' performance, where you have to stat a whole bunch of
> files, all of which may be dirty. To deal with that case, you really
> need an absolute limit on the number of dirty pages.
>
> Currently, we have only relative limits: a given bdi is allowed a
> maximum percentage value of the total write back cache size... We could
> add a 'max_pages' field, that specifies an absolute limit at which the
> vfs should start writeback.

Interesting thought.  From a high level, it sounds like a good
strategy.  The details start to get a little troubling to me
though.

First thing that strikes me is that this may result in
suboptimal WRITE requests being issued over the wire.  If the
page quota is filled with many pages from one file and just a
few from another due to timing, we may end up issuing small
over the wire WRITE requests for the one file, even during
normal operations.

We don't want to flush pages in the page cache until an entire
wsize'd transfer can be constructed for the specific file.
Thus, it seems to me that we still need to track the number of
dirty pages per file.

We also need to know that those pages are contiguous in the
file.  We can determine, heuristically, whether the pages are
contiguous in the file or not by tracking the access pattern.
For random access, we can assume that the pages are not
contiguous and we can assume that they are contiguous for
sequential access.  This isn't perfect and can be fooled,
but should hold for most applications which access files
sequentially.

Also, we don't want to proactively flush the cache if the
application is doing random access.  The application may come
back to the page and we could get away with a single WRITE
instead of multiple WRITE requests for the same page.  With
sequential access, we can generally know that it is safe to
proactively flush pages because the application won't be
accessing them again.  Once again, this heuristic is not
foolproof, but holds most of the time.

For the ls case, we really want to manage the page cache on a
per-directory of files case.  I don't think that this is going
to happen.  The only directions to go from there are more
coarse, per-bdi, or less coarse, per-file.

If we go the per-bdi approach, then we would need to stop
all modifications to the page cache for that particular bdi
during the duration of the ls processing.  Otherwise, as we
stat 1 file at a time, the other files still needing to be
stat'd would just refill the page cache with dirty pages.
We could solve this by setting the max_pages limit to be a
reasonable number to flush per file, but then that would be
too small a limit for the entire file system.

So, I don't see how to get around managing the page cache on
a per-file basis, at least to some extent, in order to manage
the amount of dirty data that must be flushed.

It does seem like the right way to do this is via a combination
of per-bdi and per-file support, but I am not sure that we have
the right information at the right levels to achieve this now.

    Thanx...

       ps
