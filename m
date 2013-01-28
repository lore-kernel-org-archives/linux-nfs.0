Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f173.google.com ([209.85.161.173]:41953 "EHLO
	mail-gg0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3A1TsJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:48:09 -0500
Received: by mail-gg0-f173.google.com with SMTP id b6so472658ggm.4
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:48:09 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 00/16] nfsd: duplicate reply cache overhaul
Date: Mon, 28 Jan 2013 14:41:06 -0500
Message-Id: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Our QA group has been reporting on and off for the last several years
about occasional failures in testing, especially on UDP. When we go to
look at traces, we see a missing reply from a server on a non-idempotent
request. The client then retransmits the request and the server tries to
redo it instead of just sending the DRC entry.

With an instrumented kernel on the server and a synthetic reproducer, we
found that it's quite easy to hammer the server so fast the DRC entries
get flushed out long before a retransmit can come in.

This patchset is a first pass at fixing this. Instead of simply keeping
a cache of the last 1024 entries, it allows nfsd to grow and shrink the
DRC dynamically.

The first patch is a bugfix for IPv6 support. The next several are
cleanups and reorganizations of the existing code. The tenth patch makes
them dynamically allocated, and the ones following that add various
mechanisms to help keep the cache to a manageable size. The final patch
adds the ability to checksum the first part the request, intended as a
way to mitigate the effects of an XID collision.

While most of us will probably say "so what" when it comes to UDP
failures, it's a potential problem on connected transports as well. I'm
also inclined to try and fix things that screw up the people that are
helping us test our code.

I'd like to see this merged for 3.9 if possible...

Jeff Layton (16):
  nfsd: fix IPv6 address handling in the DRC
  nfsd: remove unneeded spinlock in nfsd_cache_update
  nfsd: get rid of RC_INTR
  nfsd: create a dedicated slabcache for DRC entries
  nfsd: add alloc and free functions for DRC entries
  nfsd: remove redundant test from nfsd_reply_cache_free
  nfsd: clean up and clarify the cache expiration code
  nfsd: break out hashtable search into separate function
  nfsd: always move DRC entries to the end of LRU list when updating
    timestamp
  nfsd: dynamically allocate DRC entries
  nfsd: remove the cache_disabled flag
  nfsd: when updating an entry with RC_NOCACHE, just free it
  nfsd: add recurring workqueue job to clean the cache
  nfsd: track the number of DRC entries in the cache
  nfsd: register a shrinker for DRC cache entries
  nfsd: keep a checksum of the first 256 bytes of request

 fs/nfsd/cache.h             |  17 ++-
 fs/nfsd/nfscache.c          | 337 ++++++++++++++++++++++++++++++++++----------
 fs/nfsd/nfssvc.c            |   1 -
 include/linux/sunrpc/clnt.h |   4 +-
 4 files changed, 278 insertions(+), 81 deletions(-)

-- 
1.7.11.7

