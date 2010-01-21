From: andros@netapp.com
Subject: [PATCH 1/2] nfs41: fix nfs4_callback_recallslot
Date: Thu, 21 Jan 2010 14:19:16 -0500
Message-ID: <1264101557-6619-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14143 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754566Ab0AUTTY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jan 2010 14:19:24 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Return NFS4_OK if target high slotid equals enforced high slotid.
Fix nfs_client reference leak.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index e5155d9..c79e18c 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -381,13 +381,17 @@ unsigned nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy)
 	fc_tbl = &clp->cl_session->fc_slot_table;
 
 	status = htonl(NFS4ERR_BAD_HIGH_SLOT);
-	if (args->crsa_target_max_slots >= fc_tbl->max_slots ||
+	if (args->crsa_target_max_slots > fc_tbl->max_slots ||
 	    args->crsa_target_max_slots < 1)
-		goto out;
+		goto out_putclient;
+
+	status = htonl(NFS4_OK);
+	if (args->crsa_target_max_slots == fc_tbl->max_slots)
+		goto out_putclient;
 
 	fc_tbl->target_max_slots = args->crsa_target_max_slots;
 	nfs41_handle_recall_slot(clp);
-	status = htonl(NFS4_OK);
+out_putclient:
 	nfs_put_client(clp);	/* balance nfs_find_client */
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
-- 
1.6.6

