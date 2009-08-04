From: NeilBrown <neilb@suse.de>
Subject: [PATCH 00/12] Some improvements to request deferral and related code
Date: Tue, 04 Aug 2009 15:22:38 +1000
Message-ID: <20090804051145.15929.11356.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41276 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752787AbZHDFYF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 01:24:05 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce and all.

 When I wrote the authentication cache all those years ago I handled
 cache misses by arranging to simply retry the whole request, either
 by saving a copy for be replayed later, or by waiting for the client
 to resend.

 As we know this isn't ideal.  Large requests (e.g. writes) don't get
 saved, TCP connections don't resend in a suitable time, and NFSv4
 request are sufficiently complex that restarting from the beginning
 isn't really a good idea.

 So I have finally implemented the "wait a while" approach which has
 probably been suggested several times and is even implemented in a
 somewhat hackish way for nfsidmap.

 Yes, I know I have probably argued against this in the past.  I was
 wrong.

 This series fixes a few little bugs and tidies up some code but does
 two main important things.

 1/ 'allow thread to block....' will wait a little while if there is a
 cache miss.  If an answer is available in that time, it continues on
 it's merry way.  If no answer arrives, the old deferral approach is
 used.  It waits 5 seconds if there are spare nfsd threads, and 1
 second if there all threads are busy.  I have almost nothing with
 which to justify these numbers.

 2/ 'close connection when...' provides a better fall back for TCP.
 If the sunrpc layer decides to drop the request without queueing it
 at all, it will close the connection.  This encourages the client to
 retry sooner.

 Please review and comment.

 If you like them all, they can be pulled from

      git://neil.brown.name/linux-2.6/ nfsd

Thanks,
NeilBrown


---

NeilBrown (12):
      sunrpc: close connection when a request is irretrievably lost.
      sunrpc/cache: change deferred-request hash table to use hlist.
      sunrpc: fix memory leak in unix_gid cache.
      nfsd/idmap: drop special request deferal in favour of improved default.
      sunrpc/cache: retry cache lookups that return -ETIMEDOUT
      sunrpc/cache: allow thread to block while waiting for cache update.
      sunrpc/cache: avoid variable over-loading in cache_defer_req
      sunrpc/cache: use list_del_init for the list_head entries in cache_deferred_req
      sunrpc/cache: recheck cache validity after cache_defer_req
      sunrpc/cache: simplify cache_fresh_locked and cache_fresh_unlocked.
      sunrpc/cache: make sure deferred requests eventually get revisited.
      sunrpc/cache: rename queue_loose to cache_dequeue


 fs/nfsd/export.c               |   18 ++++
 fs/nfsd/nfs4idmap.c            |  105 +++---------------------
 include/linux/sunrpc/cache.h   |    5 +
 include/linux/sunrpc/svcauth.h |   10 ++
 net/sunrpc/cache.c             |  173 ++++++++++++++++++++++++++--------------
 net/sunrpc/svc.c               |    3 +
 net/sunrpc/svc_xprt.c          |   11 +++
 net/sunrpc/svcauth_unix.c      |   31 ++++++-
 8 files changed, 192 insertions(+), 164 deletions(-)

-- 

