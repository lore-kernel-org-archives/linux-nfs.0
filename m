Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53777 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755695Ab0HCVXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 17:23:44 -0400
Date: Tue, 3 Aug 2010 17:22:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH] SUNRPC: prevent task_cleanup running on freed xprt
Message-ID: <20100803212220.GI31579@fieldses.org>
References: <20100803132453.4fa18444@tlielax.poochiereds.net>
 <1280860815.9771.25.camel@heimdal.trondhjem.org>
 <1280861363.12283.2.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1280861363.12283.2.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

We saw a report of a NULL dereference in xprt_autoclose:

	https://bugzilla.redhat.com/show_bug.cgi?id=611938

This appears to be the result of an xprt's task_cleanup running after
the xprt is destroyed.  Nothing in the current code appears to prevent
that.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/xprt.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

On Tue, Aug 03, 2010 at 02:49:23PM -0400, Trond Myklebust wrote:
> Hmm... On the other hand, since xprt_destroy() may get called from
> inside the rpciod_workqueue, the wait_on_bit_lock() may end up
> deadlocking.
> 
> Nevermind, then. Let's go with the cancel_work_sync().

Here you are--only if you don't have something equivalent already queued
up.--b.

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index dcd0132..2a1f664 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1129,6 +1129,7 @@ static void xprt_destroy(struct kref *kref)
 	rpc_destroy_wait_queue(&xprt->sending);
 	rpc_destroy_wait_queue(&xprt->resend);
 	rpc_destroy_wait_queue(&xprt->backlog);
+	cancel_work_sync(&xprt->task_cleanup);
 	/*
 	 * Tear down transport state and free the rpc_xprt
 	 */
-- 
1.7.0.4

