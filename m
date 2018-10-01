Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f180.google.com ([209.85.166.180]:51011 "EHLO
        mail-it1-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728979AbeJAVU3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:29 -0400
Received: by mail-it1-f180.google.com with SMTP id j81-v6so11613576ite.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:20 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 00/15] Performance improvements for knfsd
Date: Mon,  1 Oct 2018 10:41:42 -0400
Message-Id: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following set of patches aim to remove some of the global spinlocks
that are currently being taken during the processing of every incoming
RPC call. Most of these spinlocks are protecting read-mostly structures,
and so can be replaced with taking an RCU read lock.

The patchset also replaces the current reader/writer spinlock in the
server cache implementation with an RCU read lock + a regular spinlock.
This gives a slight scalability improvement by allowing lookups to be
concurrent with updates rather than excluding them.

Finally, there is a set of changes to the NFSv2/v3/v4.0 duplicate reply
cache to further optimise it for the common case where we're only
inserting new entries. By using a red-black tree rather than a simple
linked list, we reduce the typical number of entries we need to check
(a.k.a. "chain length" in /proc/fs/nfsd/reply_cache_stats) from
roughly 80 to 9 per incoming RPC request. This significantly reduces the
total amount of time spent in nfsd_cache_lookup() according to 'perf'.

Trond Myklebust (15):
  SUNRPC: Remove the server 'authtab_lock' and just use RCU
  SUNRPC: Add lockless lookup of the server's auth domain
  SUNRPC: Allow cache lookups to use RCU protection rather than the r/w
    spinlock
  SUNRPC: Make server side AUTH_UNIX use lockless lookups
  knfsd: Allow lockless lookups of the exports
  SUNRPC: Lockless server RPCSEC_GSS context lookup
  knfsd: Lockless lookup of NFSv4 identities.
  NFS: Lockless DNS lookups
  SUNRPC: Remove non-RCU protected lookup
  SUNRPC: Replace the cache_detail->hash_lock with a regular spinlock
  SUNRPC: Simplify TCP receive code
  knfsd: Remove dead code from nfsd_cache_lookup
  knfsd: Simplify NFS duplicate replay cache
  knfsd: Further simplify the cache lookup
  knfsd: Improve lookup performance in the duplicate reply cache using
    an rbtree

 Documentation/filesystems/nfs/rpc-cache.txt |   6 +-
 fs/nfs/dns_resolve.c                        |  15 +-
 fs/nfsd/cache.h                             |  19 ++-
 fs/nfsd/export.c                            |  14 +-
 fs/nfsd/export.h                            |   2 +
 fs/nfsd/nfs4idmap.c                         |  11 +-
 fs/nfsd/nfscache.c                          | 142 +++++++++---------
 include/linux/sunrpc/cache.h                |  18 ++-
 include/linux/sunrpc/svcauth.h              |   1 +
 net/sunrpc/auth_gss/svcauth_gss.c           |  41 +++++-
 net/sunrpc/cache.c                          | 153 ++++++++++++--------
 net/sunrpc/svcauth.c                        |  74 +++++++---
 net/sunrpc/svcauth_unix.c                   |  24 ++-
 net/sunrpc/svcsock.c                        |  53 ++-----
 14 files changed, 327 insertions(+), 246 deletions(-)

-- 
2.17.1
