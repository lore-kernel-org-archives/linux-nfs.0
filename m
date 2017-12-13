Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39388 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752816AbdLMRSP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Dec 2017 12:18:15 -0500
Date: Wed, 13 Dec 2017 12:18:15 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Cc: hch@infradead.org
Subject: Re: spurious sillyrename after O_DIRECT writes get ENOSPC
Message-ID: <20171213171815.GB9205@fieldses.org>
References: <20171208221626.GB22508@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171208221626.GB22508@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 08, 2017 at 05:16:26PM -0500, J. Bruce Fields wrote:
> Last year Christoph noticed a bug that could result in a file being
> unnecessarily sillyrenamed after O_DIRECT writes get ENOSPC:
> 
> 	http://lkml.kernel.org/r/20160616150146.GA14015@infradead.org
> 
> It's reproduceable on upstream, over v3 or v4.
> 
> I looked into it some more, and it seems to reproduce whenever a write
> system call results in multiple WRITE calls, only some of which receive
> ENOSPC.  I think that's resulting in a leak of the wb_kref on some
> nfs_pages (possibly the ones corresponding to the ENOSPC failures?).
> Those nfs_pages in turn hold references on nfs_{lock,open}_contexts.  So
> a "rm" on the client (even after the file is closed) results in a
> sillyrename.
> 
> I'll keep looking at this, but the relevant code is pretty opaque to me
> so far.  Any ideas welcomed.

Actually it looks like a leak of dreq->io_count?  That prevents commits
from being sent (which I'm also seeing in network traces--the succesfull
WRITEs are unstable but never get committed), which means
nfs_direct_commit_complete() is never called, and the reference taken on
wb_kref in the request_commit case of nfs_direct_write_completion is
never put.

--b.
