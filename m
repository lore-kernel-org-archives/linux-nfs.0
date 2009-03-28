From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 14/47] nfsd41: proc stubs
Date: Sat, 28 Mar 2009 11:32:09 +0300
Message-ID: <1238229129-10651-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15804 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754527AbZC1IcV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:32:21 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |   22 ++++++++++++++++++++++
 fs/nfsd/nfs4state.c       |   34 ++++++++++++++++++++++++++++++++++
 include/linux/nfsd/xdr4.h |   14 ++++++++++++++
 3 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ded469f..f618e8e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1101,6 +1101,28 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
 		.op_name = "OP_RELEASE_LOCKOWNER",
 	},
+#if defined(CONFIG_NFSD_V4_1)
+	[OP_EXCHANGE_ID] = {
+		.op_func = (nfsd4op_func)nfsd4_exchange_id,
+		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_name = "OP_EXCHANGE_ID",
+	},
+	[OP_CREATE_SESSION] = {
+		.op_func = (nfsd4op_func)nfsd4_create_session,
+		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_name = "OP_CREATE_SESSION",
+	},
+	[OP_DESTROY_SESSION] = {
+		.op_func = (nfsd4op_func)nfsd4_destroy_session,
+		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_name = "OP_DESTROY_SESSION",
+	},
+	[OP_SEQUENCE] = {
+		.op_func = (nfsd4op_func)nfsd4_sequence,
+		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_name = "OP_SEQUENCE",
+	},
+#endif /* CONFIG_NFSD_V4_1 */
 };
 
 static const char *nfsd4_op_name(unsigned opnum)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ac4e8f2..bbb7455 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -840,6 +840,40 @@ out_err:
 	return;
 }
 
+#if defined(CONFIG_NFSD_V4_1)
+__be32
+nfsd4_exchange_id(struct svc_rqst *rqstp,
+		  struct nfsd4_compound_state *cstate,
+		  struct nfsd4_exchange_id *exid)
+{
+	return -1;	/* stub */
+}
+
+__be32
+nfsd4_create_session(struct svc_rqst *rqstp,
+		     struct nfsd4_compound_state *cstate,
+		     struct nfsd4_create_session *cr_ses)
+{
+	return -1;	/* stub */
+}
+
+__be32
+nfsd4_destroy_session(struct svc_rqst *r,
+		      struct nfsd4_compound_state *cstate,
+		      struct nfsd4_destroy_session *sessionid)
+{
+	return -1;	/* stub */
+}
+
+__be32
+nfsd4_sequence(struct svc_rqst *r,
+	       struct nfsd4_compound_state *cstate,
+	       struct nfsd4_sequence *seq)
+{
+	return -1;	/* stub */
+}
+#endif /* CONFIG_NFSD_V4_1 */
+
 __be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_setclientid *setclid)
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 40b148e..0148d54 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -475,6 +475,20 @@ extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid_confirm *setclientid_confirm);
+#if defined(CONFIG_NFSD_V4_1)
+extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *,
+struct nfsd4_exchange_id *);
+		extern __be32 nfsd4_create_session(struct svc_rqst *,
+		struct nfsd4_compound_state *,
+		struct nfsd4_create_session *);
+extern __be32 nfsd4_sequence(struct svc_rqst *,
+		struct nfsd4_compound_state *,
+		struct nfsd4_sequence *);
+extern __be32 nfsd4_destroy_session(struct svc_rqst *,
+		struct nfsd4_compound_state *,
+		struct nfsd4_destroy_session *);
+#endif /* CONFIG_NFSD_V4_1 */
 extern __be32 nfsd4_process_open1(struct nfsd4_open *open);
 extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
 		struct svc_fh *current_fh, struct nfsd4_open *open);
-- 
1.6.2.1

