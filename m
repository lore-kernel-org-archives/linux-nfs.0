From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 09/35] nfsd41: proc stubs
Date: Fri,  3 Apr 2009 08:27:58 +0300
Message-ID: <1238736478-17357-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:26887 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754619AbZDCF2D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:03 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |   22 ++++++++++++++++++++++
 fs/nfsd/nfs4state.c       |   32 ++++++++++++++++++++++++++++++++
 include/linux/nfsd/xdr4.h |   12 ++++++++++++
 3 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ded469f..f7be7fa 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1101,6 +1101,28 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
 		.op_name = "OP_RELEASE_LOCKOWNER",
 	},
+
+	/* NFSv4.1 operations */
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
 };
 
 static const char *nfsd4_op_name(unsigned opnum)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fc20e1f..cfc01f4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -833,6 +833,38 @@ out_err:
 }
 
 __be32
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
+
+__be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_setclientid *setclid)
 {
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 28af925..294940c 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -471,6 +471,18 @@ extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid_confirm *setclientid_confirm);
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
 extern __be32 nfsd4_process_open1(struct nfsd4_open *open);
 extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
 		struct svc_fh *current_fh, struct nfsd4_open *open);
-- 
1.6.2.1

