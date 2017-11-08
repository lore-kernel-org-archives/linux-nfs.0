Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from host1.domainmonger.com ([96.30.18.234]:45275 "EHLO
        host1.domainmonger.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751763AbdKHQ0Z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Nov 2017 11:26:25 -0500
Received: from c-24-62-100-84.hsd1.ma.comcast.net ([24.62.100.84]:49038 helo=nerd-marrow.com)
        by host1.domainmonger.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
        (Exim 4.89)
        (envelope-from <hack@nerd-marrow.com>)
        id 1eCSsx-0008Iv-E9
        for linux-nfs@vger.kernel.org; Wed, 08 Nov 2017 10:07:27 -0600
Date: Wed, 8 Nov 2017 11:07:25 -0500
From: Jay Fenlason <hack@nerd-marrow.com>
To: linux-nfs@vger.kernel.org
Subject: comments on fs/nfsd/nfscache.c
Message-ID: <20171108160725.GA4812@nerd-marrow.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I was looking through nfscache.c and noticed a few details that might
be worth fixing:

1: a comment says:
/*                
 * Stats and other tracking of on the duplicate reply cache. All of these and
 * the "rc" fields in nfsdstats are protected by the cache_lock
 */

   This is misleading.  There is a separate cache_lock for each bucket
   in the hash table, so a thread holding the lock on bucket#0 can
   race unimpeded with a thread holding the lock on bucket#1, leading
   to corruption of these data.  Fortunately, these data are
   statistics whose corruption will not affect the operation of the
   sytem.

2: the prune_bucket(b) function removes expired entries from the
   specified bucket, and additionally removes unexpired entries
   (possibly all of them in the bucket) when num_drc_entries >
   max_drc_entries.  This means that when prune_cache_entries() is
   called, it will delete all entries in low-numbered hash buckets
   before removing expired entries in other buckets.

   A more correct implementation would remove all expired entries from
   all buckets before removing any unexpired entries if
   num_drc_entries is still > max_drc_entries. It would also not
   target a single range of the hash table for unexpired entry
   removal. However this additional code complexity is probably
   excessive for an unlikely edge case.

3: in nfs_cache_lookup we calculate age = jiffies - rp->c_timestamp;
   If jiffies has wrapped such that rp->c_timestamp is a very large
   value, but jiffies is now a small value, age will approach ~0,
   causing the entry to expire long before its time.  This is a
   more-theoretical-than-practical flaw that might prevent the cache
   from detecting a rexmit.

Does anyone feel strongly that these are woth patching?

   -- JF
