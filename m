From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/4] NLM: don't reattempt GRANT_MSG when there is already an RPC in flight
Date: Wed,  6 Feb 2008 11:34:12 -0500
Message-ID: <1202315653-11840-4-git-send-email-jlayton@redhat.com>
References: <1202315653-11840-1-git-send-email-jlayton@redhat.com>
 <1202315653-11840-2-git-send-email-jlayton@redhat.com>
 <1202315653-11840-3-git-send-email-jlayton@redhat.com>
To: bfields@fieldses.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34200 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755223AbYBFQeQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 11:34:16 -0500
In-Reply-To: <1202315653-11840-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With the current scheme in nlmsvc_grant_blocked, we can end up with more
than one GRANT_MSG callback for a block in flight. Right now, we requeue
the block unconditionally so that a GRANT_MSG callback is done again in
30s. If the client is unresponsive, it can take more than 30s for the
call already in flight to time out.

There's no benefit to having more than one GRANT_MSG RPC queued up at a
time, so put it on the list with a timeout of NLM_NEVER before doing the
RPC call. If the RPC call submission fails, we requeue it with a short
timeout. If it works, then nlmsvc_grant_callback will end up requeueing
it with a shorter timeout after it completes.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svclock.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 2f4d8fa..82db7b3 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -763,11 +763,20 @@ callback:
 	dprintk("lockd: GRANTing blocked lock.\n");
 	block->b_granted = 1;
 
-	/* Schedule next grant callback in 30 seconds */
-	nlmsvc_insert_block(block, 30 * HZ);
+	/* keep block on the list, but don't reattempt until the RPC
+	 * completes or the submission fails
+	 */
+	nlmsvc_insert_block(block, NLM_NEVER);
 
-	/* Call the client */
-	nlm_async_call(block->b_call, NLMPROC_GRANTED_MSG, &nlmsvc_grant_ops);
+	/* Call the client -- use a soft RPC task since nlmsvc_retry_blocked
+	 * will queue up a new one if this one times out
+	 */
+	error = nlm_async_call(block->b_call, NLMPROC_GRANTED_MSG,
+				&nlmsvc_grant_ops);
+
+	/* RPC submission failed, wait a bit and retry */
+	if (error < 0)
+		nlmsvc_insert_block(block, 10 * HZ);
 }
 
 /*
-- 
1.5.3.8

