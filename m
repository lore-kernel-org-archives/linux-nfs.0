Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:42366 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbaHDLpt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Aug 2014 07:45:49 -0400
Received: by mail-qg0-f45.google.com with SMTP id f51so8440349qge.4
        for <linux-nfs@vger.kernel.org>; Mon, 04 Aug 2014 04:45:48 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 4 Aug 2014 07:45:46 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/6] NFS DRC scalability patches
Message-ID: <20140804074546.7c63e725@tlielax.poochiereds.net>
In-Reply-To: <1407085564-3227-1-git-send-email-trond.myklebust@primarydata.com>
References: <1407085564-3227-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun,  3 Aug 2014 13:05:58 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

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

Consider adding some FIXME comments to that effect? While not terribly
important, it would be good to fix them at some point.

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
>  fs/nfsd/nfscache.c | 205 +++++++++++++++++++++++++++++------------------------
>  2 files changed, 113 insertions(+), 93 deletions(-)
> 

Looks good. Nice work! You can add this to each since they all look
good to me. It would be good to fix up the stats collection and the
comments, but I wouldn't want to hold up this work for that.

    Reviewed-by: Jeff Layton <jlayton@primarydata.com>
