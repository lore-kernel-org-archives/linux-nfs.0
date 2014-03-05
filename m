Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52089 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755165AbaCEDBF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 22:01:05 -0500
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 05 Mar 2014 14:00:28 +1100
Subject: [PATCH/RFC 0/8] Extend RCU-walk support to NFS.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140305025813.27421.23871.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Linux 2.6.38 introduced RCU-walk (https://lwn.net/Articles/419811/)
to improve path-name lookup by avoiding locking in many cases,
particularly when everything is in cache.

NFS doesn't benefit from this, returning -ECHILD whenever RCU-walk is
detected.

For workloads that can be served entirely from the cache and are
metadata-heavy (e.g. 'make') this can be a performance problem
particularly if multiple threads are using multiple cores.

The following series extends RCU-walk into NFS allowing a synthetic
stat-heavy workload to avoid locking and refcounting most of the
time. It provides about 20% performance improvement with 4 threads on
2 core, and will probably have a much more significant effect with 4
or 8 cores (though I haven't tested yet).

The key to providing RCU-walk support is to avoid sleeping and, where
possible, avoid locking or refcounting.
So in nfs_permission and nfs{,4}_lookup_revalidate we should return
-ECHILD only if a memory allocation or RPC request are required.  In
other cases we can simply complete as normal.

There are two data-structures which need to be searched for
nfs_permission: the credential cache (in sunrpc) and the nfs
access_cache.
The credential cache is already rcu-aware so it is easy to return a
credential without locking if LOOKUP_RCU is set.

The access_cache uses an rbtree which is not rcu-aware and cannot
easily be made so.  There are two approaches we can take here.
1/ take the required locks and perform the access check with locks
   held (as nfs_access_get_cached already does).  This is easy but
   requires taking locks which doesn't scale as well as not taking
   them.
2/ Use rcu to free cache entries and use a simpler rcu-safe search
   mechanism when performing an RCU-walk.  This search doesn't have
   to be perfect.  If it finds the right value most of the time that
   will still help.  When it doesn't find the required value we fall
   back on taking the lock.

The early patches assume the first approach.  The final patch attempts
the second.  The rcu-safe search method used is simple to examine
the final (most recent) entry on the lru.

This final patch provides about 2% performance increase over not
having the patch in my 4-thread tests on 2-core CPU.
It is the most "RFC" part of the series.  The earlier patches I am
comfortable with (though review is always appreciated of course).

---

NeilBrown (8):
      NFS: nfs4_lookup_revalidate: only evaluate parent if it will be used.
      NFS: prepare for RCU-walk support but pushing tests later in code.
      sunrpc/auth: allow lockless (rcu) lookup of credential cache.
      sunrpc/auth: add 'rcu_walk' arg to rpc_lookup_cred.
      NFS: teach nfs_do_access to understand MAY_NOT_BLOCK
      NFS: teach nfs_neg_need_reval to understand LOOKUP_RCU
      NFS: teach nfs_lookup_verify_inode to handle LOOKUP_RCU
      NFS: allow lockless access to access_cache


 fs/nfs/dir.c                |  134 +++++++++++++++++++++++++++++++++----------
 fs/nfs/inode.c              |   11 +++-
 fs/nfs/nfs4proc.c           |    2 -
 fs/nfs/unlink.c             |    4 +
 include/linux/nfs_fs.h      |    2 +
 include/linux/sunrpc/auth.h |    3 +
 net/sunrpc/auth.c           |   17 +++++
 net/sunrpc/auth_generic.c   |    5 +-
 net/sunrpc/auth_null.c      |    2 +
 9 files changed, 139 insertions(+), 41 deletions(-)

-- 
Signature

