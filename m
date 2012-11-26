Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755938Ab2KZURL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:11 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 22/28] NFSv4.1: If slot allocation fails due to OOM, retry more quickly
Date: Mon, 26 Nov 2012 15:16:39 -0500
Message-Id: <1353961005-63874-23-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-22-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-11-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-15-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-16-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-17-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-18-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-19-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-20-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-21-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-22-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the NFSv4.1 session slot allocation fails due to an ENOMEM condition,
then set the task->tk_timeout to 1/4 second to ensure that we do retry
the slot allocation more quickly.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ec2b034..5f78c8c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -663,7 +663,7 @@ static struct nfs4_slot *nfs4_find_or_create_slot(struct nfs4_slot_table  *tbl,
 			return slot;
 		p = &slot->next;
 	}
-	return NULL;
+	return ERR_PTR(-ENOMEM);
 }
 
 /*
@@ -677,7 +677,7 @@ static struct nfs4_slot *nfs4_find_or_create_slot(struct nfs4_slot_table  *tbl,
  */
 static struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl)
 {
-	struct nfs4_slot *ret = NULL;
+	struct nfs4_slot *ret = ERR_PTR(-EBUSY);
 	u32 slotid;
 
 	dprintk("--> %s used_slots=%04lx highest_used=%u max_slots=%u\n",
@@ -687,7 +687,7 @@ static struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl)
 	if (slotid > tbl->max_slotid)
 		goto out;
 	ret = nfs4_find_or_create_slot(tbl, slotid, 1, GFP_NOWAIT);
-	if (ret == NULL)
+	if (IS_ERR(ret))
 		goto out;
 	__set_bit(slotid, tbl->used_slots);
 	if (slotid > tbl->highest_used_slotid ||
@@ -699,7 +699,7 @@ static struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl)
 out:
 	dprintk("<-- %s used_slots=%04lx highest_used=%d slotid=%d \n",
 		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
-		ret ? ret->slot_nr : -1);
+		!IS_ERR(ret) ? ret->slot_nr : -1);
 	return ret;
 }
 
@@ -728,6 +728,8 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 
 	tbl = &session->fc_slot_table;
 
+	task->tk_timeout = 0;
+
 	spin_lock(&tbl->slot_tbl_lock);
 	if (test_bit(NFS4_SESSION_DRAINING, &session->session_state) &&
 	    !rpc_task_has_priority(task, RPC_PRIORITY_PRIVILEGED)) {
@@ -747,7 +749,10 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 	}
 
 	slot = nfs4_alloc_slot(tbl);
-	if (slot == NULL) {
+	if (IS_ERR(slot)) {
+		/* If out of memory, try again in 1/4 second */
+		if (slot == ERR_PTR(-ENOMEM))
+			task->tk_timeout = HZ >> 2;
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
 		spin_unlock(&tbl->slot_tbl_lock);
 		dprintk("<-- %s: no free slots\n", __func__);
@@ -5779,7 +5784,7 @@ static int nfs4_grow_slot_table(struct nfs4_slot_table *tbl,
 {
 	if (max_reqs <= tbl->max_slots)
 		return 0;
-	if (nfs4_find_or_create_slot(tbl, max_reqs - 1, ivalue, GFP_NOFS))
+	if (!IS_ERR(nfs4_find_or_create_slot(tbl, max_reqs - 1, ivalue, GFP_NOFS)))
 		return 0;
 	return -ENOMEM;
 }
-- 
1.7.11.7

