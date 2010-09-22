Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35480 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912Ab0IVRv5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Sep 2010 13:51:57 -0400
Date: Wed, 22 Sep 2010 13:50:27 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/7] sunrpc: fix race in new cache_wait code.
Message-ID: <20100922175027.GF15560@fieldses.org>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
 <20100922025506.31745.67177.stgit@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100922025506.31745.67177.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 22, 2010 at 12:55:06PM +1000, NeilBrown wrote:
> If we set up to wait for a cache item to be filled in, and then find
> that it is no longer pending, it could be that some other thread is
> in 'cache_revisit_request' and has moved our request to its 'pending' list.
> So when our setup_deferral calls cache_revisit_request it will find nothing to
> put on the pending list, and do nothing.
> 
> We then return from cache_wait_req, thus leaving the 'sleeper'
> on-stack structure open to being corrupted by subsequent stack usage.
> 
> However that 'sleeper' could still be on the 'pending' list that the
> other thread is looking at and so any corruption could cause it to behave badly.
> 
> To avoid this race we simply take the same path as if the
> 'wait_for_completion_interruptible_timeout' was interrupted and if the
> sleeper is no longer on the list (which it won't be) we wait on the
> completion - which will ensure that any other cache_revisit_request
> will have let go of the sleeper.

OK, but I don't think we need that first CACHE_PENDING check in
setup_deferral at all.  Best just to ignore it?:

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index d789dfc..82804b4 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -567,10 +567,9 @@ static int cache_wait_req(struct cache_req *req, struct cache_head *item, int ti
 	sleeper.completion = COMPLETION_INITIALIZER_ONSTACK(sleeper.completion);
 	dreq->revisit = cache_restart_thread;
 
-	ret = setup_deferral(dreq, item);
+	setup_deferral(dreq, item);
 
-	if (ret ||
-	    wait_for_completion_interruptible_timeout(
+	if (wait_for_completion_interruptible_timeout(
 		    &sleeper.completion, timeout) <= 0) {
 		/* The completion wasn't completed, so we need
 		 * to clean up

Then it's obvious that we always wait for completion, and that we fill
the basic requirement to avoid corruption here.

(Which is, in more detail: cache_wait_req must not return while dreq is
still reachable from anywhere else.  Since dreq is reachable from
elsewhere only as long as it is hashed, and since anyone else that might
unhash it will call our revisit (which unconditionally calls complete),
then forget about it, it suffices for cache_wait_req to either wait for
completion, or unhash dreq *itself* (before someone else does).)

Also we don't need the PENDING check to ensure we wait only when
necessary--we only wait while dreq is hashed, and as long as we're
hashed anyone clearing PENDING will also end up doing the complete().

In the deferral case it's maybe a useful optimization if it avoids
an unnecessary drop sometimes.  Here it doesn't help.

--b.
