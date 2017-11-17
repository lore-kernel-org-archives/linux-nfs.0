Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37940 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966216AbdKQRkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Nov 2017 12:40:03 -0500
Date: Fri, 17 Nov 2017 12:40:02 -0500
To: Jay Fenlason <hack@nerd-marrow.com>
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com
Subject: Re: comments on fs/nfsd/nfscache.c
Message-ID: <20171117174002.GA13501@fieldses.org>
References: <20171108160725.GA4812@nerd-marrow.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171108160725.GA4812@nerd-marrow.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry, I overlooked this message til now:

On Wed, Nov 08, 2017 at 11:07:25AM -0500, Jay Fenlason wrote:
> I was looking through nfscache.c and noticed a few details that might
> be worth fixing:
> 
> 1: a comment says:
> /*                
>  * Stats and other tracking of on the duplicate reply cache. All of these and
>  * the "rc" fields in nfsdstats are protected by the cache_lock
>  */
> 
>    This is misleading.  There is a separate cache_lock for each bucket
>    in the hash table, so a thread holding the lock on bucket#0 can
>    race unimpeded with a thread holding the lock on bucket#1, leading
>    to corruption of these data.  Fortunately, these data are
>    statistics whose corruption will not affect the operation of the
>    sytem.

I'm assuming num_drc_entries at least is still OK thanks to being
atomic, but I haven't audited that carefully.  That one at least does
need to be correct.

Damage from corruption of those other variables may be limited to
incorrect reporting of statistics, but we should still figure out how to
fix those....  (Maybe track them per-bucket and then sum across buckets
in nfsd_reply_cache_stats_show?  I'm not sure.)

> 2: the prune_bucket(b) function removes expired entries from the
>    specified bucket, and additionally removes unexpired entries
>    (possibly all of them in the bucket) when num_drc_entries >
>    max_drc_entries.  This means that when prune_cache_entries() is
>    called, it will delete all entries in low-numbered hash buckets
>    before removing expired entries in other buckets.
> 
>    A more correct implementation would remove all expired entries from
>    all buckets before removing any unexpired entries if
>    num_drc_entries is still > max_drc_entries. It would also not
>    target a single range of the hash table for unexpired entry
>    removal. However this additional code complexity is probably
>    excessive for an unlikely edge case.

Hm, I don't know.  I think a busy server could have its DRC full most of
the time.  There may be some clever compromises possible here.

On the other hand this is "legacy" code to some degree: the DRC isn't
needed at all for protocol versions since 4.1.  And I'd prefer to hear
from people with real life workloads and problems so we know whether a
given clever idea really helps in practice.

> 3: in nfs_cache_lookup we calculate age = jiffies - rp->c_timestamp;
>    If jiffies has wrapped such that rp->c_timestamp is a very large
>    value, but jiffies is now a small value, age will approach ~0,
>    causing the entry to expire long before its time.  This is a
>    more-theoretical-than-practical flaw that might prevent the cache
>    from detecting a rexmit.

Surely this could be fixed with some variation on the trick that
time_before & friends use.  See e.g. time_in_range.

> Does anyone feel strongly that these are woth patching?

They're not a huge priority for me personally but I'd certainly take
patches.

--b.
