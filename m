Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f45.google.com ([209.85.219.45]:64322 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078Ab3CSNLv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 09:11:51 -0400
Received: by mail-oa0-f45.google.com with SMTP id o6so418944oag.18
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 06:11:51 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] nfsd: duplicate reply cache improvements for 3.10
Date: Tue, 19 Mar 2013 09:11:40 -0400
Message-Id: <1363698706-22036-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset replaces the last one I sent that starts with:

    [PATCH v2 0/5] nfsd: add a reply_cache_stats file to nfsd for tracking DRC performance

I've done quite a bit of testing over the last month or so (with much
help from the RH QA folks), and the changes here are largely due to the
results of that testing.

The main changes are:

1/ I've dropped the patch to track the max and average time to search the
   cache. What I found was that occasionally the search gets preempted
   to service an IRQ or bottom half handler, and that would blow the
   stats out of the water. Since they aren't reliably indicative, it's
   probably best not to track that for now.

   In some of the testing I did, I left this in place and disabled IRQs
   during the search. That's not a suitable change for upstream but it
   did help prove the efficacy of some of the later changes.

2/ I've added a patch to scale out the number of hash buckets with the
   max size of the cache. This seems to greatly improve performance by
   simply keeping the hash chain lengths low. I saw about 5-6 fold
   decrease in the average search time with this change. The downside
   of course is that we have to allocate that many more buckets up
   front, but I don't think that's entirely unreasonable.

These patches represent the DRC-related changes that I'd like to see
merged in 3.10, possibly sooner if we get any reports of performance
regressions in the DRC due to the changes that went into 3.9.

Jeff Layton (6):
  nfsd: eliminate one of the DRC cache searches
  nfsd: break out comparator into separate function
  nfsd: track memory utilization by the DRC
  nfsd: add new reply_cache_stats file in nfsdfs
  nfsd: keep stats on worst hash balancing seen so far
  nfsd: scale up the number of DRC hash buckets with cache size

 fs/nfsd/cache.h    |   1 +
 fs/nfsd/nfscache.c | 195 +++++++++++++++++++++++++++++++++++++++--------------
 fs/nfsd/nfsctl.c   |   9 +++
 3 files changed, 155 insertions(+), 50 deletions(-)

-- 
1.7.11.7

