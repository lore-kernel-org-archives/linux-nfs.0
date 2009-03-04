From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 36/46] nfs41: nfs41_sequence_done
Date: Wed,  4 Mar 2009 02:00:25 +0200
Message-ID: <1236124825-3965-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17848
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752024AbZCDAAj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 19:00:39 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Handle session level errors, update slot sequence id and
sessions bookeeping, free slot.

[nfs41: sequence res use slotid]
Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: check for session not minorversion]
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41: bail out early out of nfs41_sequence_done if !res->sr_session]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[move nfs4_sequence_done from nfs41: nfs41_call_sync_done]
Signed-off-by: Andy Adamson <andros@netapp.com>
[move nfs4_sequence_free_slot from nfs41: separate free slot from sequence done]
    Don't free the slot until after all rpc_restart_calls have completed.
    Session reset will require more work.
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[moved reset sr_slotid to nfs41_sequence_free_slot]
[free slot also on unexpectecd error]
[remove seq_res.sr_session member, use nfs_client's instead]
[ditch seq_res.sr_flags until used]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[look at sr_slotid for bailing out early from nfs41_sequence_done]
[nfs41: rpc_wake_up_next if sessions slot was not consumed.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   93 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ca40377..9179508 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -338,6 +338,81 @@ void nfs41_sequence_free_slot(const struct nfs_client *clp,
 	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
 }
 
+static void nfs41_sequence_done(struct nfs_client *clp,
+				struct nfs4_sequence_res *res,
+				int rpc_status)
+{
+	unsigned long timestamp;
+	struct nfs4_slot_table *tbl;
+	struct nfs4_slot *slot;
+
+	/*
+	 * sr_status remains 1 if an RPC level error occurred. The server
+	 * may or may not have processed the sequence operation..
+	 * Proceed as if the server received and processed the sequence
+	 * operation.
+	 */
+	if (res->sr_status == 1)
+		res->sr_status = NFS_OK;
+
+	if (!nfs4_has_session(clp))
+		return;
+
+	/* -ERESTARTSYS can result in skipping nfs41_sequence_setup */
+	if (res->sr_slotid == NFS4_MAX_SLOT_TABLE)
+		goto out;
+
+	tbl = &clp->cl_session->fc_slot_table;
+	slot = tbl->slots + res->sr_slotid;
+
+	switch (res->sr_status) {
+	case NFS4_OK:
+		/*
+		 * The sequence call was successful,
+		 * Update the slot's sequence and client's lease renewal timers
+		 */
+		++slot->seq_nr;
+		if (clp) {
+			timestamp = res->sr_renewal_time;
+			spin_lock(&clp->cl_lock);
+			if (time_before(clp->cl_last_renewal, timestamp))
+				clp->cl_last_renewal = timestamp;
+			spin_unlock(&clp->cl_lock);
+		}
+		return;
+
+	case -NFS4ERR_BADSESSION:
+	case -NFS4ERR_BADSLOT:
+	case -NFS4ERR_BADXDR:
+	case -NFS4ERR_BAD_HIGH_SLOT:
+	case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+	case -NFS4ERR_DEADSESSION:
+	case -NFS4ERR_DELAY:
+	case -NFS4ERR_REP_TOO_BIG:
+	case -NFS4ERR_REP_TOO_BIG_TO_CACHE:
+	case -NFS4ERR_REQ_TOO_BIG:
+	case -NFS4ERR_RETRY_UNCACHED_REP:
+	case -NFS4ERR_SEQUENCE_POS:
+	case -NFS4ERR_SEQ_FALSE_RETRY:
+	case -NFS4ERR_SEQ_MISORDERED:
+	case -NFS4ERR_TOO_MANY_OPS:
+		dprintk("%s: status %d\n", __func__, res->sr_status);
+		break;
+
+	default:
+		printk(KERN_WARNING "%s: Unexpected status %d\n", __func__,
+			res->sr_status);
+	}
+out:
+	/*
+	 * The session will be reset by one of the error handlers,
+	 * so free the slot and set the sr_slotid to NFS4_MAX_SLOT_TABLE
+	 * so that nfs4_setup_sequence calls nfs41_find_slot
+	 * to schedule session reset once all slots are drained.
+	 */
+	nfs41_sequence_free_slot(clp, res);
+}
+
 /*
  * nfs4_find_slot - efficiently look for a free slot
  *
@@ -511,6 +586,24 @@ int _nfs4_call_sync(struct nfs_server *server,
        (server)->nfs_client->cl_call_sync((server), (msg), &(args)->seq_args, \
                        &(res)->seq_res, (cache_reply))
 
+static void nfs4_sequence_done(const struct nfs_server *server,
+			       struct nfs4_sequence_res *res, int rpc_status)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (nfs4_has_session(server->nfs_client))
+		nfs41_sequence_done(server->nfs_client, res, rpc_status);
+#endif /* CONFIG_NFS_V4_1 */
+}
+
+/* no restart, therefore free slot here */
+static void nfs4_sequence_done_free_slot(const struct nfs_server *server,
+					 struct nfs4_sequence_res *res,
+					 int rpc_status)
+{
+	nfs4_sequence_done(server, res, rpc_status);
+	nfs4_sequence_free_slot(server, res);
+}
+
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
-- 
1.6.1.3

