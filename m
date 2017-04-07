Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:5551 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932552AbdDGSPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:48 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 03/34] NFS: Remove extra dprintk()s from callback_proc.c
Date: Fri, 7 Apr 2017 14:14:57 -0400
Message-ID: <20170407181528.2832-4-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/callback_proc.c | 22 ----------------------
 1 file changed, 22 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index e61e4ccc181a..e7f041447afd 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -351,8 +351,6 @@ __be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
 	struct nfs_client *clp = cps->clp;
 	struct nfs_server *server = NULL;
 
-	dprintk("%s: -->\n", __func__);
-
 	if (!clp) {
 		res = cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
 		goto out;
@@ -371,8 +369,6 @@ __be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
 					goto found;
 				}
 			rcu_read_unlock();
-			dprintk("%s: layout type %u not found\n",
-				__func__, dev->cbd_layout_type);
 			continue;
 		}
 
@@ -382,8 +378,6 @@ __be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
 
 out:
 	kfree(args->devs);
-	dprintk("%s: exit with status = %u\n",
-		__func__, be32_to_cpu(res));
 	return res;
 }
 
@@ -404,16 +398,11 @@ static __be32
 validate_seqid(const struct nfs4_slot_table *tbl, const struct nfs4_slot *slot,
 		const struct cb_sequenceargs * args)
 {
-	dprintk("%s enter. slotid %u seqid %u, slot table seqid: %u\n",
-		__func__, args->csa_slotid, args->csa_sequenceid, slot->seq_nr);
-
 	if (args->csa_slotid > tbl->server_highest_slotid)
 		return htonl(NFS4ERR_BADSLOT);
 
 	/* Replay */
 	if (args->csa_sequenceid == slot->seq_nr) {
-		dprintk("%s seqid %u is a replay\n",
-			__func__, args->csa_sequenceid);
 		if (nfs4_test_locked_slot(tbl, slot->slot_nr))
 			return htonl(NFS4ERR_DELAY);
 		/* Signal process_op to set this error on next op */
@@ -467,15 +456,6 @@ static bool referring_call_exists(struct nfs_client *clp,
 
 		for (j = 0; j < rclist->rcl_nrefcalls; j++) {
 			ref = &rclist->rcl_refcalls[j];
-
-			dprintk("%s: sessionid %x:%x:%x:%x sequenceid %u "
-				"slotid %u\n", __func__,
-				((u32 *)&rclist->rcl_sessionid.data)[0],
-				((u32 *)&rclist->rcl_sessionid.data)[1],
-				((u32 *)&rclist->rcl_sessionid.data)[2],
-				((u32 *)&rclist->rcl_sessionid.data)[3],
-				ref->rc_sequenceid, ref->rc_slotid);
-
 			status = nfs4_slot_wait_on_seqid(tbl, ref->rc_slotid,
 					ref->rc_sequenceid, HZ >> 1) < 0;
 			if (status)
@@ -580,8 +560,6 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 		res->csr_status = status;
 
 	trace_nfs4_cb_sequence(args, res, status);
-	dprintk("%s: exit with status = %d res->csr_status %d\n", __func__,
-		ntohl(status), ntohl(res->csr_status));
 	return status;
 }
 
-- 
2.12.2

