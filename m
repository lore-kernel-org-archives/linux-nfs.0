Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:5170 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753632Ab2KVSoH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Nov 2012 13:44:07 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 15/20] NFSv4.1: Don't confuse target_highest_slotid and max_slots in cb_recall_slot
Date: Wed, 21 Nov 2012 17:43:14 -0500
Message-Id: <1353537799-60488-16-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353537799-60488-15-git-send-email-Trond.Myklebust@netapp.com>
References: <1353537799-60488-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-11-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-15-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't confuse the table size and the target_highest_slotid...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback.h      |  2 +-
 fs/nfs/callback_proc.c | 12 +++++-------
 fs/nfs/callback_xdr.c  |  2 +-
 3 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 4251c2a..e75631e 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -142,7 +142,7 @@ extern __be32 nfs4_callback_recallany(struct cb_recallanyargs *args,
 
 struct cb_recallslotargs {
 	struct sockaddr	*crsa_addr;
-	uint32_t	crsa_target_max_slots;
+	uint32_t	crsa_target_highest_slotid;
 };
 extern __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args,
 					 void *dummy,
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 15b9879..ed0b446 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -561,22 +561,20 @@ __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
 	if (!cps->clp) /* set in cb_sequence */
 		goto out;
 
-	dprintk_rcu("NFS: CB_RECALL_SLOT request from %s target max slots %d\n",
+	dprintk_rcu("NFS: CB_RECALL_SLOT request from %s target highest slotid %d\n",
 		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR),
-		args->crsa_target_max_slots);
+		args->crsa_target_highest_slotid);
 
 	fc_tbl = &cps->clp->cl_session->fc_slot_table;
 
 	status = htonl(NFS4ERR_BAD_HIGH_SLOT);
-	if (args->crsa_target_max_slots > fc_tbl->max_slots ||
-	    args->crsa_target_max_slots < 1)
+	if (args->crsa_target_highest_slotid >= fc_tbl->max_slots ||
+	    args->crsa_target_highest_slotid < 1)
 		goto out;
 
 	status = htonl(NFS4_OK);
-	if (args->crsa_target_max_slots == fc_tbl->max_slots)
-		goto out;
 
-	nfs41_set_target_slotid(fc_tbl, args->crsa_target_max_slots);
+	nfs41_set_target_slotid(fc_tbl, args->crsa_target_highest_slotid);
 	nfs41_handle_recall_slot(cps->clp);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 742ff4f..81e8c7d 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -520,7 +520,7 @@ static __be32 decode_recallslot_args(struct svc_rqst *rqstp,
 	p = read_buf(xdr, 4);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_BADXDR);
-	args->crsa_target_max_slots = ntohl(*p++);
+	args->crsa_target_highest_slotid = ntohl(*p++);
 	return 0;
 }
 
-- 
1.7.11.7

