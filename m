Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f54.google.com ([209.85.128.54]:65162 "EHLO
	mail-qe0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475Ab3LELBA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 06:01:00 -0500
Received: by mail-qe0-f54.google.com with SMTP id cy11so15199914qeb.41
        for <linux-nfs@vger.kernel.org>; Thu, 05 Dec 2013 03:01:00 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH RFC 0/3] nfsd: convert nfsd DRC code to use list_lru infrastructure
Date: Thu,  5 Dec 2013 06:00:50 -0500
Message-Id: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset converts the LRU list in the nfsd duplicate reply cache to
use the new list_lru infrastrucure. Note that this is based on top of
the patch that I sent to Bruce earlier this week that fixes the
svc_cacherep direct reclaim bug. I'm sending this as an RFC since I'm
not 100% convinced it's an improvement.

The majorly unintuitive thing about list_lru that I've found is that
you can't call call list_lru_del from list_lru_walk. So, you need
different routines to free an object depending on how it's being freed.

Using list_lru also means extra spinlocking since we'd be moving to a
per-node LRU, but that's probably not a big deal since all of this is
done under the cache_lock anyway.

In any case, here's what a conversion to list_lru would look like...

Discuss!

Jeff Layton (3):
  nfsd: don't try to reuse an expired DRC entry off the list
  list_lru: add a new LRU_SKIP_REST lru_status value and handling
  nfsd: convert DRC code to use list_lru

 fs/nfsd/nfscache.c       | 130 +++++++++++++++++++++++++----------------------
 include/linux/list_lru.h |   2 +
 mm/list_lru.c            |   4 +-
 3 files changed, 75 insertions(+), 61 deletions(-)

-- 
1.8.4.2

