Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25689 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932146Ab0KKCLW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 21:11:22 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/3] pnfs-submit: set back channel highest slot used
Date: Thu, 11 Nov 2010 09:10:38 -0500
Message-Id: <1289484640-4100-2-git-send-email-andros@netapp.com>
In-Reply-To: <1289484640-4100-1-git-send-email-andros@netapp.com>
References: <1289484640-4100-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Prepare for the state manager thread to drain back channel.
Use the back channel highest_slot_used to indicate to the state manager
that a callback is being processed by the callback thread.

Fix the BADSLOT check - the first and only slotid is 0.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c |   13 ++++++++++++-
 fs/nfs/callback_xdr.c  |   16 +++++++++++++++-
 2 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 6e21add..6ba528a 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -469,6 +469,9 @@ int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const n
  * We have a single slot backchannel at this time, so we don't bother
  * checking the used_slots bit array on the table.  The lower layer guarantees
  * a single outstanding callback request at a time.
+ *
+ * We set the highest slot used to let the state manager know when a
+ * callback is being processed and to wait until completion.
  */
 static __be32
 validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
@@ -478,10 +481,18 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 	dprintk("%s enter. slotid %d seqid %d\n",
 		__func__, args->csa_slotid, args->csa_sequenceid);
 
-	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS)
+	/* Single slot, so slotid must be 0 */
+	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS - 1 ||
+	    args->csa_slotid < 0)
 		return htonl(NFS4ERR_BADSLOT);
 
+	spin_lock(&tbl->slot_tbl_lock);
 	slot = tbl->slots + args->csa_slotid;
+
+	/* Only a single slot */
+	tbl->highest_used_slotid = args->csa_slotid;
+	spin_unlock(&tbl->slot_tbl_lock);
+
 	dprintk("%s slot table seqid: %d\n", __func__, slot->seq_nr);
 
 	/* Normal */
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 695d15a..e05d1b3 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -773,8 +773,22 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 
 	*hdr_res.status = status;
 	*hdr_res.nops = htonl(nops);
-	if (cps.session) /* matched by cb_sequence find_client_with_session */
+	if (cps.session) {
+		struct nfs4_slot_table *tbl = &cps.session->bc_slot_table;
+
+		spin_lock(&tbl->slot_tbl_lock);
+		/*
+		 * Let the state manager know callback processing done.
+		 * A single slot, so highest used slotid is either 0 or -1
+		 */
+		tbl->highest_used_slotid--;
+		spin_unlock(&tbl->slot_tbl_lock);
+		dprintk("%s highest_used_slotid %d\n", __func__,
+			tbl->highest_used_slotid);
+
+		/* matched by cb_sequence find_client_with_session */
 		nfs_put_client(cps.session->clp);
+	}
 	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
 	return rpc_success;
 }
-- 
1.6.6

