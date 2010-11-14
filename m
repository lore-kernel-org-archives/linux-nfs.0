Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31293 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755320Ab0KNMIm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Nov 2010 07:08:42 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: Andy Adamson <andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: pnfs-submit: highest backchannel slot used for !CONFIG_NFS_V4_1
Date: Sun, 14 Nov 2010 14:08:38 +0200
Message-Id: <1289736518-22008-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1289484640-4100-2-git-send-email-andros@netapp.com>
References: <1289484640-4100-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_xdr.c |   38 +++++++++++++++++++++-----------------
 1 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 39da338..a77877c 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -728,6 +728,24 @@ encode_hdr:
 	return status;
 }
 
+static void nfs4_callback_free_slot(struct nfs4_session *session)
+{
+#if defined(CONFIG_NFS_V4_1)
+	struct nfs4_slot_table *tbl = &session->bc_slot_table;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	/*
+	 * Let the state manager know callback processing done.
+	 * A single slot, so highest used slotid is either 0 or -1
+	 */
+	tbl->highest_used_slotid--;
+	nfs41_check_drain_bc_complete(session);
+	spin_unlock(&tbl->slot_tbl_lock);
+	dprintk("%s highest_used_slotid %d\n", __func__,
+		tbl->highest_used_slotid);
+#endif /* CONFIG_NFS_V4_1 */
+}
+
 /*
  * Decode, process and encode a COMPOUND
  */
@@ -773,23 +791,9 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 
 	*hdr_res.status = status;
 	*hdr_res.nops = htonl(nops);
-	if (cps.session) {
-		struct nfs4_slot_table *tbl = &cps.session->bc_slot_table;
-
-		spin_lock(&tbl->slot_tbl_lock);
-		/*
-		 * Let the state manager know callback processing done.
-		 * A single slot, so highest used slotid is either 0 or -1
-		 */
-		tbl->highest_used_slotid--;
-		nfs41_check_drain_bc_complete(cps.session);
-		spin_unlock(&tbl->slot_tbl_lock);
-		dprintk("%s highest_used_slotid %d\n", __func__,
-			tbl->highest_used_slotid);
-
-		/* matched by cb_sequence find_client_with_session */
-                put_session_client(cps.session);
-        }
+	nfs4_callback_free_slot(cps.session);
+	/* matched by cb_sequence find_client_with_session */
+	put_session_client(cps.session);
 	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
 	return rpc_success;
 }
-- 
1.7.2.3

