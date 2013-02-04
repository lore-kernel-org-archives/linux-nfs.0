Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f44.google.com ([209.85.213.44]:55984 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415Ab3BDNSN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 08:18:13 -0500
Received: by mail-yh0-f44.google.com with SMTP id q11so172704yhf.3
        for <linux-nfs@vger.kernel.org>; Mon, 04 Feb 2013 05:18:12 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/8] nfsd: duplicate reply cache overhaul
Date: Mon,  4 Feb 2013 08:17:59 -0500
Message-Id: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the second posting of the remaining unmerged patches in this
set. There are a number of differences from the first set:

- The bug in the checksum patch has been fixed.

- A hard cap on the number of DRC entries is retained, but it's larger
  than the original cap, and scales with the amount of low memory in
  the machine.

- A shrinker is still registered, but it will now only free entries
  that are expired or are over the max number of entries.

Our QA group has been reporting on and off for the last several years
about occasional failures in testing, especially on UDP. When we go to
look at traces, we see a missing reply from a server on a non-idempotent
request. The client then retransmits the request and the server tries to
redo it instead of just sending the DRC entry.

With an instrumented kernel on the server and a synthetic reproducer, we
found that it's quite easy to hammer the server so fast that DRC entries
get flushed out long before a retransmit can come in.

This patchset is a first pass at fixing this. Instead of simply keeping
a cache of the last 1024 entries, it allows nfsd to grow and shrink the
DRC dynamically.

While most of us will probably say "so what" when it comes to UDP
failures, it's a potential problem on connected transports as well. I'm
also inclined to try and fix things that screw up the people that are
helping us test our code.

I'd like to see this merged for 3.9 if possible...

Jeff Layton (8):
  nfsd: always move DRC entries to the end of LRU list when updating
    timestamp
  nfsd: track the number of DRC entries in the cache
  nfsd: dynamically allocate DRC entries
  nfsd: remove the cache_disabled flag
  nfsd: when updating an entry with RC_NOCACHE, just free it
  nfsd: add recurring workqueue job to clean the cache
  nfsd: register a shrinker for DRC cache entries
  nfsd: keep a checksum of the first 256 bytes of request

 fs/nfsd/cache.h    |   5 +
 fs/nfsd/nfscache.c | 271 ++++++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 209 insertions(+), 67 deletions(-)

-- 
1.7.11.7

