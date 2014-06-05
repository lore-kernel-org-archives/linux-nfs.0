Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:60117 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbaFEREn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 13:04:43 -0400
Received: by mail-ie0-f170.google.com with SMTP id to1so1168766ieb.15
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 10:04:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Use raw_write_seqcount_begin/end int nfs4_reclaim_open_state
Date: Thu,  5 Jun 2014 13:04:39 -0400
Message-Id: <1401987879-2927-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The addition of lockdep code to write_seqcount_begin/end has lead to
a bunch of false positive claims of ABBA deadlocks with the so_lock
spinlock. Audits show that this simply cannot happen because the
read side code does not spin while holding so_lock.

Cc: <stable@vger.kernel.org> # 3.13.x
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2349518eef2c..21275148fc13 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1456,7 +1456,7 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 	 * server that doesn't support a grace period.
 	 */
 	spin_lock(&sp->so_lock);
-	write_seqcount_begin(&sp->so_reclaim_seqcount);
+	raw_write_seqcount_begin(&sp->so_reclaim_seqcount);
 restart:
 	list_for_each_entry(state, &sp->so_states, open_states) {
 		if (!test_and_clear_bit(ops->state_flag_bit, &state->flags))
@@ -1519,13 +1519,13 @@ restart:
 		spin_lock(&sp->so_lock);
 		goto restart;
 	}
-	write_seqcount_end(&sp->so_reclaim_seqcount);
+	raw_write_seqcount_end(&sp->so_reclaim_seqcount);
 	spin_unlock(&sp->so_lock);
 	return 0;
 out_err:
 	nfs4_put_open_state(state);
 	spin_lock(&sp->so_lock);
-	write_seqcount_end(&sp->so_reclaim_seqcount);
+	raw_write_seqcount_end(&sp->so_reclaim_seqcount);
 	spin_unlock(&sp->so_lock);
 	return status;
 }
-- 
1.9.3

