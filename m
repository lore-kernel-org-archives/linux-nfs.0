Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:49508 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923AbaHCRGH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:06:07 -0400
Received: by mail-qa0-f45.google.com with SMTP id cm18so5894588qab.18
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:06:05 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] NFS DRC scalability patches
Date: Sun,  3 Aug 2014 13:05:58 -0400
Message-Id: <1407085564-3227-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
 fs/nfsd/nfscache.c | 205 +++++++++++++++++++++++++++++------------------------
 2 files changed, 113 insertions(+), 93 deletions(-)

-- 
1.9.3

