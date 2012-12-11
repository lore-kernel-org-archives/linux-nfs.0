Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:31223 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753769Ab2LKSo3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2012 13:44:29 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/7] NFSD: grow the session slot table more aggressively
Date: Tue, 11 Dec 2012 13:44:17 -0500
Message-Id: <1355251459-18034-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1355251459-18034-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1355251459-18034-1-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-2-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-3-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the client is bumping against our session limits, then be
more aggressive about growing the slot table. Do not assume that
we need to wait for the client to see previous updates.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfsd/nfs4state.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 88d0de9..a380a61 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2073,12 +2073,6 @@ static void nfsd4_sequence_adjust_slot_table(struct nfsd4_session *session,
 	u32 next_highest;
 
 	spin_lock(&tbl->slt_lock);
-	/*
-	 * If this slot hasn't seen our previous values, then don't trust
-	 * that the client has seen them. Don't adjust the slot table yet.
-	 */
-	if (slot->sl_generation != tbl->slt_generation)
-		goto out;
 
 	next_target = tbl->slt_target_highest_slotid;
 
@@ -2088,6 +2082,13 @@ static void nfsd4_sequence_adjust_slot_table(struct nfsd4_session *session,
 		next_target += 1 + (tbl->slt_target_highest_slotid >> 2);
 		next_highest = next_target;
 	} else {
+		/*
+		 * If this slot hasn't seen our previous values, then don't
+		 * trust that the client has seen them. Don't adjust the
+		 * slot table yet.
+		 */
+		if (slot->sl_generation != tbl->slt_generation)
+			goto out;
 		/* No! Try to shrink the window size by 1/2 */
 		next_target >>= 1;
 		if (sa_highest_slotid + 1 > next_target)
-- 
1.7.11.7

