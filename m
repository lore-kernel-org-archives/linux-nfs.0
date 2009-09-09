From: NeilBrown <neilb@suse.de>
Subject: [PATCH 0/9] Some improvements to request deferral and related code
Date: Wed, 09 Sep 2009 16:32:54 +1000
Message-ID: <20090909062539.20462.67466.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37912 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184AbZIIGcd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 02:32:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
 here again are those patches from request deferral improvement set
 that have not yet been applied.

 I had previously missed the cache lookups in svcauth_gss, and have now
 made them work correctly.

 I also discovered that for NFSv4.1 and later, the current deferral
 scheme is disabled once the request gets into the NFS layer (i.e. out
 of the RPC layer).  I don't know that 4.0 doesn't disable it as well
 - maybe the problems it can cause are more severe with 4.1?  With
 this patch set included it might be acceptable to disable the current
 scheme for 4.0.

 I believe this is ready for wider testing and probably mainline
 inclusion.

Thanks,
NeilBrown


---

NeilBrown (9):
      sunrpc: close connection when a request is irretrievably lost.
      sunrpc/cache: change deferred-request hash table to use hlist.
      nfsd/idmap: drop special request deferal in favour of improved default.
      sunrpc/cache: retry cache lookups that return -ETIMEDOUT
      sunrpc/cache: allow threads to block while waiting for cache update.
      sunrpc/cache: avoid variable over-loading in cache_defer_req
      sunrpc/cache: use list_del_init for the list_head entries in cache_deferred_req
      sunrpc/cache: simplify cache_fresh_locked and cache_fresh_unlocked.
      sunrpc/cache: change cache_defer_req to return -ve error, not boolean.


 fs/nfsd/export.c                  |   18 ++++++
 fs/nfsd/nfs4idmap.c               |  105 ++++------------------------------
 include/linux/sunrpc/cache.h      |    5 +-
 include/linux/sunrpc/svcauth.h    |   10 ++-
 net/sunrpc/auth_gss/svcauth_gss.c |   29 ++++++---
 net/sunrpc/cache.c                |  115 ++++++++++++++++++++++++-------------
 net/sunrpc/svc.c                  |    3 +
 net/sunrpc/svc_xprt.c             |   11 ++++
 net/sunrpc/svcauth_unix.c         |   34 +++++++++--
 9 files changed, 176 insertions(+), 154 deletions(-)

-- 
Signature

