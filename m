Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:7727 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932925AbbDJPKO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 11:10:14 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH] NFS: Add stubs for GETDEVICELIST
Date: Fri, 10 Apr 2015 11:10:09 -0400
Message-ID: <1428678609-28156-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

d4b18c3e (pnfs: remove GETDEVICELIST implementation) removed the
GETDEVICELIST operation from the NFS client, but left a "hole" in the
nfs4_procedures array.  This caused /proc/self/mountstats to report an
operation named "51" where GETDEVICELIST used to be.  This patch adds
back stubs to fix mountstats.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4xdr.c     | 26 ++++++++++++++++++++++++--
 fs/nfs/nfs4xdr.c.rej | 10 ++++++++++
 2 files changed, 34 insertions(+), 2 deletions(-)
 create mode 100644 fs/nfs/nfs4xdr.c.rej

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 39e521a..aadcc91 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -860,6 +860,8 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_dec_free_stateid_sz	(compound_decode_hdr_maxsz + \
 					 decode_sequence_maxsz + \
 					 decode_free_stateid_maxsz)
+#define NFS4_enc_getdevicelist_sz	(0)
+#define NFS4_dec_getdevicelist_sz	(0)
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				      compound_encode_hdr_maxsz +
@@ -2997,6 +2999,16 @@ static void nfs4_xdr_enc_free_stateid(struct rpc_rqst *req,
 	encode_free_stateid(xdr, args, &hdr);
 	encode_nops(&hdr);
 }
+
+/*
+ *  Encode GEDEVICELIST request
+ */
+static void nfs4_xdr_enc_getdevicelist(struct rpc_rqst *req,
+				       struct xdr_stream *xdr,
+				       void *args)
+{
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
@@ -7202,6 +7214,16 @@ static int nfs4_xdr_dec_free_stateid(struct rpc_rqst *rqstp,
 out:
 	return status;
 }
+
+/*
+ * Decide GETDEVICELIST response
+ */
+static int nfs4_xdr_dec_getdevicelist(struct rpc_rqst *rqstp,
+				      struct xdr_stream *xdr,
+				      void *res)
+{
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /**
@@ -7413,8 +7435,8 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(SECINFO_NO_NAME,	enc_secinfo_no_name,	dec_secinfo_no_name),
 	PROC(TEST_STATEID,	enc_test_stateid,	dec_test_stateid),
 	PROC(FREE_STATEID,	enc_free_stateid,	dec_free_stateid),
-	PROC(BIND_CONN_TO_SESSION,
-			enc_bind_conn_to_session, dec_bind_conn_to_session),
+	PROC(GETDEVICELIST,	enc_getdevicelist,	dec_getdevicelist),
+	PROC(BIND_CONN_TO_SESSION, enc_bind_conn_to_session, dec_bind_conn_to_session),
 	PROC(DESTROY_CLIENTID,	enc_destroy_clientid,	dec_destroy_clientid),
 #endif /* CONFIG_NFS_V4_1 */
 #ifdef CONFIG_NFS_V4_2
diff --git a/fs/nfs/nfs4xdr.c.rej b/fs/nfs/nfs4xdr.c.rej
new file mode 100644
index 0000000..5560fe6
--- /dev/null
+++ b/fs/nfs/nfs4xdr.c.rej
@@ -0,0 +1,10 @@
+--- fs/nfs/nfs4xdr.c
++++ fs/nfs/nfs4xdr.c
+@@ -7435,6 +7457,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
+ 	PROC(SECINFO_NO_NAME,	enc_secinfo_no_name,	dec_secinfo_no_name),
+ 	PROC(TEST_STATEID,	enc_test_stateid,	dec_test_stateid),
+ 	PROC(FREE_STATEID,	enc_free_stateid,	dec_free_stateid),
++	PROC(GETDEVICELIST,	enc_getdevicelist,	dec_getdevicelist),
+ 	PROC(BIND_CONN_TO_SESSION,
+ 			enc_bind_conn_to_session, dec_bind_conn_to_session),
+ 	PROC(DESTROY_CLIENTID,	enc_destroy_clientid,	dec_destroy_clientid),
-- 
2.3.5

