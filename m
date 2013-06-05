Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:25113 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755723Ab3FEPZP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jun 2013 11:25:15 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Add in v4.2 callback operation
Date: Wed,  5 Jun 2013 11:15:02 -0400
Message-Id: <1370445302-1261-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1370445302-1261-1-git-send-email-bjschuma@netapp.com>
References: <1370445302-1261-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

NFS v4.2 adds a CB_OFFLOAD operation used by COPY and WRITE_PLUS.  Since
neither of these operations have been implemented yet, simply return
NFS4ERR_NOTSUPP.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/callback.h     |  2 ++
 fs/nfs/callback_xdr.c | 31 +++++++++++++++++++++++++++++--
 2 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 41cf893..84326e9 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -32,6 +32,8 @@ enum nfs4_callback_opnum {
 	OP_CB_WANTS_CANCELLED = 12,
 	OP_CB_NOTIFY_LOCK   = 13,
 	OP_CB_NOTIFY_DEVICEID = 14,
+/* Callback operations new to NFSv4.2 */
+	OP_CB_OFFLOAD = 15,
 	OP_CB_ILLEGAL = 10044,
 };
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 77c0b88..2a5ac66 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -786,6 +786,26 @@ static void nfs4_cb_free_slot(struct cb_process_state *cps)
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+static __be32
+preprocess_nfs42_op(int nop, unsigned int op_nr, struct callback_op **op)
+{
+	__be32 status = preprocess_nfs41_op(nop, op_nr, op);
+	if (status != htonl(NFS4ERR_OP_ILLEGAL))
+		return status;
+
+	if (op_nr == OP_CB_OFFLOAD)
+		return htonl(NFS4ERR_NOTSUPP);
+	return htonl(NFS4ERR_OP_ILLEGAL);
+}
+#else /* CONFIG_NFS_V4_2 */
+static __be32
+preprocess_nfs42_op(int nop, unsigned int op_nr, struct callback_op **op)
+{
+	return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static __be32
 preprocess_nfs4_op(unsigned int op_nr, struct callback_op **op)
 {
@@ -820,8 +840,15 @@ static __be32 process_op(int nop, struct svc_rqst *rqstp,
 	dprintk("%s: minorversion=%d nop=%d op_nr=%u\n",
 		__func__, cps->minorversion, nop, op_nr);
 
-	status = cps->minorversion ? preprocess_nfs41_op(nop, op_nr, &op) :
-				preprocess_nfs4_op(op_nr, &op);
+	if (cps->minorversion == 0)
+		status = preprocess_nfs4_op(op_nr, &op);
+	else if (cps->minorversion == 1)
+		status = preprocess_nfs41_op(nop, op_nr, &op);
+	else if (cps->minorversion == 2)
+		status = preprocess_nfs42_op(nop, op_nr, &op);
+	else
+		status = htonl(NFS4ERR_MINOR_VERS_MISMATCH);
+
 	if (status == htonl(NFS4ERR_OP_ILLEGAL))
 		op_nr = OP_CB_ILLEGAL;
 	if (status)
-- 
1.8.3

