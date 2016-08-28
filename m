Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36375 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756028AbcH1WZG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2016 18:25:06 -0400
Received: by mail-it0-f68.google.com with SMTP id x131so5030006ite.3
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2016 15:25:05 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4.1: Defer bumping the slot sequence number until we free the slot
Date: Sun, 28 Aug 2016 18:21:03 -0400
Message-Id: <1472422865-28698-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472422865-28698-3-git-send-email-trond.myklebust@primarydata.com>
References: <1472422865-28698-1-git-send-email-trond.myklebust@primarydata.com>
 <1472422865-28698-2-git-send-email-trond.myklebust@primarydata.com>
 <1472422865-28698-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For operations like OPEN or LAYOUTGET, which return recallable state
(i.e. delegations and layouts) we want to enable the mechanism for
resolving recall races in RFC5661 Section 2.10.6.3.
To do so, we will want to defer bumping the slot's sequence number until
we have finished processing the RPC results.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c    | 9 +++++++--
 fs/nfs/nfs4session.h | 3 ++-
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0cc0c319cfdd..de4a89d3d740 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -666,6 +666,11 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	tbl = slot->table;
 	session = tbl->session;
 
+	/* Bump the slot sequence number */
+	if (slot->seq_done)
+		slot->seq_nr++;
+	slot->seq_done = 0;
+
 	spin_lock(&tbl->slot_tbl_lock);
 	/* Be nice to the server: try to ensure that the last transmitted
 	 * value for highest_user_slotid <= target_highest_slotid
@@ -716,7 +721,7 @@ int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 	switch (res->sr_status) {
 	case 0:
 		/* Update the slot's sequence and clientid lease timer */
-		++slot->seq_nr;
+		slot->seq_done = 1;
 		clp = session->clp;
 		do_renew_lease(clp, res->sr_timestamp);
 		/* Check sequence flags */
@@ -771,7 +776,7 @@ int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 		goto retry_nowait;
 	default:
 		/* Just update the slot sequence no. */
-		++slot->seq_nr;
+		slot->seq_done = 1;
 	}
 out:
 	/* The session may be reset by one of the error handlers. */
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index fa75d7db3db3..f703b755351b 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -21,7 +21,8 @@ struct nfs4_slot {
 	unsigned long		generation;
 	u32			slot_nr;
 	u32		 	seq_nr;
-	unsigned int		interrupted : 1;
+	unsigned int		interrupted : 1,
+				seq_done : 1;
 };
 
 /* Sessions */
-- 
2.7.4

