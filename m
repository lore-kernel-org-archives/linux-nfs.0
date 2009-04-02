From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 33/67] nfs41: nfs41_sequence_done
Date: Thu,  2 Apr 2009 16:55:09 +0300
Message-ID: <1238680509-14433-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30570 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757901AbZDBNzU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:55:20 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
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
[nfs41: nfs4_sequence_free_slot use nfs_client for data server]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: remove unused error checking in nfs41_sequence_done]
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41: remove nfs4_has_session check in nfs41_sequence_done]
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41: remove nfs_client pointer check]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   58 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5e49696..dbc701b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -330,6 +330,46 @@ void nfs41_sequence_free_slot(const struct nfs_client *clp,
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
+	/* -ERESTARTSYS can result in skipping nfs41_sequence_setup */
+	if (res->sr_slotid == NFS4_MAX_SLOT_TABLE)
+		goto out;
+
+	tbl = &clp->cl_session->fc_slot_table;
+	slot = tbl->slots + res->sr_slotid;
+
+	if (res->sr_status == 0) {
+		/* Update the slot's sequence and clientid lease timer */
+		++slot->seq_nr;
+		timestamp = res->sr_renewal_time;
+		spin_lock(&clp->cl_lock);
+		if (time_before(clp->cl_last_renewal, timestamp))
+			clp->cl_last_renewal = timestamp;
+		spin_unlock(&clp->cl_lock);
+		return;
+	}
+out:
+	/* The session may be reset by one of the error handlers. */
+	dprintk("%s: Error %d free the slot \n", __func__, res->sr_status);
+	nfs41_sequence_free_slot(clp, res);
+}
+
 /*
  * nfs4_find_slot - efficiently look for a free slot
  *
@@ -515,6 +555,24 @@ int _nfs4_call_sync(struct nfs_server *server,
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
+	nfs4_sequence_free_slot(server->nfs_client, res);
+}
+
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
-- 
1.6.2.1

