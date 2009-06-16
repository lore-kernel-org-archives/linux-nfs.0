From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 3/3] SQUASHME: nfs41: Backchannel: Be more obvious about the return value
Date: Tue, 16 Jun 2009 11:26:40 -0700
Message-ID: <1245176800-10595-3-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1245176800-10595-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1245176800-10595-2-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61377 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759216AbZFPSbM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Jun 2009 14:31:12 -0400
In-Reply-To: <1245176800-10595-2-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

validate_seqid() returns the error value that will be encoded into the XDR
result. Change validate_seqid() to return be32 so that it's obvious that this
error is meant to be XDR encoded.

[squash with: nfs41: Backchannel: CB_SEQUENCE validation]

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/callback_proc.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index c85d66f..95e9022 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -127,7 +127,7 @@ validate_seqid(struct nfs4_slot_table *tbl, u32 slotid, u32 seqid)
 		__func__, slotid, seqid);
 
 	if (slotid > NFS41_BC_MAX_CALLBACKS)
-		return NFS4ERR_BADSLOT;
+		return htonl(NFS4ERR_BADSLOT);
 
 	slot = tbl->slots + slotid;
 	dprintk("%s slot table seqid: %d\n", __func__, slot->seq_nr);
@@ -135,24 +135,24 @@ validate_seqid(struct nfs4_slot_table *tbl, u32 slotid, u32 seqid)
 	/* Normal */
 	if (likely(seqid == slot->seq_nr + 1)) {
 		slot->seq_nr++;
-		return NFS4_OK;
+		return htonl(NFS4_OK);
 	}
 
 	/* Replay */
 	if (seqid == slot->seq_nr) {
 		dprintk("%s seqid %d is a replay - no DRC available\n",
 			__func__, seqid);
-		return NFS4_OK;
+		return htonl(NFS4_OK);
 	}
 
 	/* Wraparound */
 	if (seqid == 1 && (slot->seq_nr + 1) == 0) {
 		slot->seq_nr = 1;
-		return NFS4_OK;
+		return htonl(NFS4_OK);
 	}
 
 	/* Misordered request */
-	return NFS4ERR_SEQ_MISORDERED;
+	return htonl(NFS4ERR_SEQ_MISORDERED);
 }
 
 /*
@@ -202,7 +202,7 @@ unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
 		kfree(args->csa_rclists[i].rcl_refcalls);
 	kfree(args->csa_rclists);
 
-	status = NFS4ERR_BADSESSION;
+	status = htonl(NFS4ERR_BADSESSION);
 	clp = find_client_with_session(args->csa_addr, 4, &args->csa_sessionid);
 	if (clp == NULL)
 		goto out;
@@ -223,7 +223,7 @@ out_putclient:
 	nfs_put_client(clp);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, status);
-	res->csr_status = htonl(status);
+	res->csr_status = status;
 	return res->csr_status;
 }
 
-- 
1.5.4.3

