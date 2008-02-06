From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/4] NLM: don't requeue block if it was invalidated while GRANT_MSG was in flight
Date: Wed,  6 Feb 2008 11:34:13 -0500
Message-ID: <1202315653-11840-5-git-send-email-jlayton@redhat.com>
References: <1202315653-11840-1-git-send-email-jlayton@redhat.com>
 <1202315653-11840-2-git-send-email-jlayton@redhat.com>
 <1202315653-11840-3-git-send-email-jlayton@redhat.com>
 <1202315653-11840-4-git-send-email-jlayton@redhat.com>
To: bfields@fieldses.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754269AbYBFQeR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 11:34:17 -0500
In-Reply-To: <1202315653-11840-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible for lockd to catch a SIGKILL while a GRANT_MSG callback
is in flight. If this happens we don't want lockd to insert the block
back into the nlm_blocked list.

This helps that situation, but there's still a possible race. Fixing
that will mean adding real locking for nlm_blocked.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svclock.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 82db7b3..fe9bdb4 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -795,6 +795,17 @@ static void nlmsvc_grant_callback(struct rpc_task *task, void *data)
 
 	dprintk("lockd: GRANT_MSG RPC callback\n");
 
+	/* if the block is not on a list at this point then it has
+	 * been invalidated. Don't try to requeue it.
+	 *
+	 * FIXME: it's possible that the block is removed from the list
+	 * after this check but before the nlmsvc_insert_block. In that
+	 * case it will be added back. Perhaps we need better locking
+	 * for nlm_blocked?
+	 */
+	if (list_empty(&block->b_list))
+		return;
+
 	/* Technically, we should down the file semaphore here. Since we
 	 * move the block towards the head of the queue only, no harm
 	 * can be done, though. */
-- 
1.5.3.8

