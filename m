Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35730 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751239AbaHLUiv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 16:38:51 -0400
Date: Tue, 12 Aug 2014 16:38:50 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/6] NFS DRC scalability patches
Message-ID: <20140812203850.GG25914@fieldses.org>
References: <1407347065-17463-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1407347065-17463-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 06, 2014 at 01:44:19PM -0400, Trond Myklebust wrote:
> Hi Bruce,
> 
> Rebased onto your nfsd-next branch

Thanks, I'm applying these (but won't actually publish that branch till
-rc1 is out.)

--b.

> 
> Cheers
>   Trond
> 
> ---------------------------
> 
> Hi Bruce,
> 
> The following patchset is again more an FYI than a must have, but it
> addresses a significant scalability problem for NFSv3 when running
> over 10GigE and 40GigE networks. At one point, I was seeing >60% CPU
> spinning on the DRC global spinlock...
> 
> The one thing to note is that because the statistics are moved outside
> spinlocking, then their accuracy is slightly reduced (I do convert the
> number of entries into an atomic, so that is still 100% correct). The
> right thing to do there is probably to convert those into per-cpu
> counters, however I've not had time to do so for now.
> 
> Cheers,
>   Trond
> 
> Trond Myklebust (6):
>   nfsd: Clean up drc cache in preparation for global spinlock
>     elimination
>   nfsd: convert the lru list into a per-bucket thing
>   nfsd: Remove the cache_hash list
>   nfsd: convert num_drc_entries to an atomic_t
>   nfsd: split DRC global spinlock into per-bucket locks
>   nfsd: Reorder nfsd_cache_match to check more powerful discriminators
>     first
> 
>  fs/nfsd/cache.h    |   1 -
>  fs/nfsd/nfscache.c | 214 ++++++++++++++++++++++++++++-------------------------
>  2 files changed, 113 insertions(+), 102 deletions(-)
> 
> -- 
> 1.9.3
> 
