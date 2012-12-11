Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:31223 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753769Ab2LKSob (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2012 13:44:31 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 7/7] NFSD: Try to eliminate outliers when updating highest_slotid
Date: Tue, 11 Dec 2012 13:44:19 -0500
Message-Id: <1355251459-18034-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1355251459-18034-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1355251459-18034-1-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-2-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-3-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-4-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-5-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Look for sudden changes in the first and second derivatives in order
to eliminate outlier changes to target_highest_slotid (which are
due to out-of-order RPC requests).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfsd/nfs4state.c | 91 +++++++++++++++++++++++++++++++++++++++++++----------
 fs/nfsd/state.h     |  3 ++
 2 files changed, 77 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ed937c8..0eb563d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2064,6 +2064,57 @@ out:
 	return status;
 }
 
+static s32 nfs41_derivative_target_slotid(s32 s1, s32 s2)
+{
+	s1 -= s2;
+	if (s1 == 0)
+		return 0;
+	if (s1 < 0)
+		return (s1 - 1) >> 1;
+	return (s1 + 1) >> 1;
+}
+
+static int nfs41_sign_s32(s32 s1)
+{
+	if (s1 > 0)
+		return 1;
+	if (s1 < 0)
+		return -1;
+	return 0;
+}
+
+static bool nfs41_same_sign_or_zero_s32(s32 s1, s32 s2)
+{
+	if (!s1 || !s2)
+		return true;
+	return nfs41_sign_s32(s1) == nfs41_sign_s32(s2);
+}
+
+/* Try to eliminate outliers by checking for sharp changes in the
+ * derivatives and second derivatives
+ */
+static bool nfsd4_is_outlier_target_slotid(struct nfsd4_slot_table *tbl,
+		u32 new_highest)
+{
+	s32 d_highest, d2_highest;
+	bool ret = true;
+
+	d_highest = nfs41_derivative_target_slotid(new_highest,
+			tbl->slt_client_highest_slotid);
+	d2_highest = nfs41_derivative_target_slotid(d_highest,
+			tbl->slt_d_client_highest_slotid);
+	/* Is first derivative same sign? */
+	if (nfs41_same_sign_or_zero_s32(d_highest, tbl->slt_d_client_highest_slotid))
+		ret = false;
+	/* Is second derivative same sign? */
+	if (nfs41_same_sign_or_zero_s32(d2_highest, tbl->slt_d2_client_highest_slotid))
+		ret = false;
+	tbl->slt_client_highest_slotid = new_highest;
+	tbl->slt_d_client_highest_slotid = d_highest;
+	tbl->slt_d2_client_highest_slotid = d2_highest;
+	return ret;
+}
+
 static void nfsd4_sequence_adjust_slot_table(struct nfsd4_session *session,
 		struct nfsd4_slot *slot, u32 sa_highest_slotid,
 		struct nfsd4_sequence *res)
@@ -2074,26 +2125,32 @@ static void nfsd4_sequence_adjust_slot_table(struct nfsd4_session *session,
 
 	spin_lock(&tbl->slt_lock);
 
+	if (nfsd4_is_outlier_target_slotid(tbl, sa_highest_slotid))
+		goto out;
+	if (slot->sl_generation != tbl->slt_generation)
+		goto out;
+
+	/* Deal with slot table truncation... */
+	nfsd4_truncate_slot_table_locked(tbl,
+			max(sa_highest_slotid, tbl->slt_highest_slotid));
+
 	next_target = tbl->slt_target_highest_slotid;
+	next_highest = tbl->slt_highest_slotid;
 
 	/* Is the client bumping against our current window limits? */
-	if (sa_highest_slotid >= tbl->slt_target_highest_slotid) {
-		/* Yes! Grow the window size by 1/4 */
-		next_target += 1 + (tbl->slt_target_highest_slotid >> 2);
-		next_highest = next_target;
-	} else {
-		/*
-		 * If this slot hasn't seen our previous values, then don't
-		 * trust that the client has seen them. Don't adjust the
-		 * slot table yet.
-		 */
-		if (slot->sl_generation != tbl->slt_generation)
-			goto out;
-		/* No! Try to shrink the window size by 1/2 */
-		next_target >>= 1;
-		if (sa_highest_slotid + 1 > next_target)
-			next_target = sa_highest_slotid + 1;
-		next_highest = tbl->slt_target_highest_slotid;
+	if (tbl->slt_d_client_highest_slotid > 0) {
+		if (sa_highest_slotid >= tbl->slt_target_highest_slotid) {
+			/* Yes! Grow the window size by 1/4 */
+			next_target += 1 + (tbl->slt_target_highest_slotid >> 2);
+			next_highest = next_target;
+		}
+	} else /* (tbl->slt_d_client_highest_slotid <= 0) */ {
+		if (next_target > sa_highest_slotid + 1) {
+			/* Try to shrink the window size by 1/2 */
+			next_target >>= 1;
+			next_target = max(next_target, sa_highest_slotid + 1);
+		}
+		next_highest = max(tbl->slt_target_highest_slotid, next_target);
 	}
 	nfsd4_fc_set_highest_slotid_locked(session, tbl,
 			next_target, next_highest);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c2f897f..94a72e5 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -150,6 +150,9 @@ struct nfsd4_slot_table {
 	unsigned long		slt_generation;
 	u32			slt_target_highest_slotid;
 	u32			slt_highest_slotid;
+	u32			slt_client_highest_slotid;
+	s32			slt_d_client_highest_slotid;
+	s32			slt_d2_client_highest_slotid;
 };
 
 struct nfsd4_channel_attrs {
-- 
1.7.11.7

