Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:52179 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbaHFRod (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 13:44:33 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so9083900igc.6
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2014 10:44:33 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/6] NFS DRC scalability patches
Date: Wed,  6 Aug 2014 13:44:19 -0400
Message-Id: <1407347065-17463-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

Rebased onto your nfsd-next branch

Cheers
  Trond

---------------------------

Hi Bruce,

The following patchset is again more an FYI than a must have, but it
addresses a significant scalability problem for NFSv3 when running
over 10GigE and 40GigE networks. At one point, I was seeing >60% CPU
spinning on the DRC global spinlock...

The one thing to note is that because the statistics are moved outside
spinlocking, then their accuracy is slightly reduced (I do convert the
number of entries into an atomic, so that is still 100% correct). The
right thing to do there is probably to convert those into per-cpu
counters, however I've not had time to do so for now.

Cheers,
  Trond

Trond Myklebust (6):
  nfsd: Clean up drc cache in preparation for global spinlock
    elimination
  nfsd: convert the lru list into a per-bucket thing
  nfsd: Remove the cache_hash list
  nfsd: convert num_drc_entries to an atomic_t
  nfsd: split DRC global spinlock into per-bucket locks
  nfsd: Reorder nfsd_cache_match to check more powerful discriminators
    first

 fs/nfsd/cache.h    |   1 -
 fs/nfsd/nfscache.c | 214 ++++++++++++++++++++++++++++-------------------------
 2 files changed, 113 insertions(+), 102 deletions(-)

-- 
1.9.3

