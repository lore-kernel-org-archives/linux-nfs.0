Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:54444 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752965Ab0IVC5n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 22:57:43 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 22 Sep 2010 12:55:06 +1000
Subject: [PATCH 1/7] sunrpc: fix race in new cache_wait code.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100922025506.31745.67177.stgit@localhost.localdomain>
In-Reply-To: <20100922025009.31745.98237.stgit@localhost.localdomain>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

If we set up to wait for a cache item to be filled in, and then find
that it is no longer pending, it could be that some other thread is
in 'cache_revisit_request' and has moved our request to its 'pending' list.
So when our setup_deferral calls cache_revisit_request it will find nothing to
put on the pending list, and do nothing.

We then return from cache_wait_req, thus leaving the 'sleeper'
on-stack structure open to being corrupted by subsequent stack usage.

However that 'sleeper' could still be on the 'pending' list that the
other thread is looking at and so any corruption could cause it to behave badly.

To avoid this race we simply take the same path as if the
'wait_for_completion_interruptible_timeout' was interrupted and if the
sleeper is no longer on the list (which it won't be) we wait on the
completion - which will ensure that any other cache_revisit_request
will have let go of the sleeper.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/cache.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index ca7c621..62078be 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -579,10 +579,9 @@ static int cache_wait_req(struct cache_req *req, struct cache_head *item)
 	dreq->revisit = cache_restart_thread;
 
 	ret = setup_deferral(dreq, item);
-	if (ret)
-		return ret;
 
-	if (wait_for_completion_interruptible_timeout(
+	if (ret ||
+	    wait_for_completion_interruptible_timeout(
 		    &sleeper.completion, req->thread_wait) <= 0) {
 		/* The completion wasn't completed, so we need
 		 * to clean up


