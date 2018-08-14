Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35084 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727835AbeHOApa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Aug 2018 20:45:30 -0400
Received: by mail-it0-f65.google.com with SMTP id 139-v6so22244079itf.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Aug 2018 14:56:19 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Jia-Ju Bai <baijiaju1990@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix a sleep in atomic context in nfs4_callback_sequence()
Date: Tue, 14 Aug 2018 17:55:56 -0400
Message-Id: <20180814215556.100271-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must drop the lock before we can sleep in referring_call_exists().

Reported-by: Jia-Ju Bai <baijiaju1990@gmail.com>
Fixes: 045d2a6d076a ("NFSv4.1: Delay callback processing...")
Cc: stable@vger.kernel.org # v4.9+
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/callback_proc.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index be8e0d2196a5..f1a61bd55f04 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -442,11 +442,14 @@ validate_seqid(const struct nfs4_slot_table *tbl, const struct nfs4_slot *slot,
  * a match.  If the slot is in use and the sequence numbers match, the
  * client is still waiting for a response to the original request.
  */
-static bool referring_call_exists(struct nfs_client *clp,
+static int referring_call_exists(struct nfs_client *clp,
 				  uint32_t nrclists,
-				  struct referring_call_list *rclists)
+				  struct referring_call_list *rclists,
+				  spinlock_t *lock)
+	__releases(lock)
+	__acquires(lock)
 {
-	bool status = false;
+	int status = 0;
 	int i, j;
 	struct nfs4_session *session;
 	struct nfs4_slot_table *tbl;
@@ -469,8 +472,10 @@ static bool referring_call_exists(struct nfs_client *clp,
 
 		for (j = 0; j < rclist->rcl_nrefcalls; j++) {
 			ref = &rclist->rcl_refcalls[j];
+			spin_unlock(lock);
 			status = nfs4_slot_wait_on_seqid(tbl, ref->rc_slotid,
 					ref->rc_sequenceid, HZ >> 1) < 0;
+			spin_lock(lock);
 			if (status)
 				goto out;
 		}
@@ -547,7 +552,8 @@ __be32 nfs4_callback_sequence(void *argp, void *resp,
 	 * related callback was received before the response to the original
 	 * call.
 	 */
-	if (referring_call_exists(clp, args->csa_nrclists, args->csa_rclists)) {
+	if (referring_call_exists(clp, args->csa_nrclists, args->csa_rclists,
+				&tbl->slot_tbl_lock) < 0) {
 		status = htonl(NFS4ERR_DELAY);
 		goto out_unlock;
 	}
-- 
2.17.1
