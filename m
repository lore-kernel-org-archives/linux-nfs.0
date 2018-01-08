Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:46501 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755000AbeAHS1h (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jan 2018 13:27:37 -0500
Received: by mail-io0-f195.google.com with SMTP id z130so15606044ioe.13
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jan 2018 10:27:37 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix nfsstat breakage due to LOOKUPP
Date: Mon,  8 Jan 2018 13:25:23 -0500
Message-Id: <20180108182523.3701-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The LOOKUPP operation was inserted into the nfs4_procedures array
rather than being appended, which put /proc/net/rpc/nfs out of
whack, and broke the nfsstat utility.
Fix by moving the LOOKUPP operation to the end of the array, and
by ensuring that it keeps the same length whether or not NFSV4.1
and NFSv4.2 are compiled in.

Fixes: 5b5faaf6df734 ("nfs4: add NFSv4 LOOKUPP handlers")
Cc: stable@vger.kernel.org # v4.13+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c     | 64 +++++++++++++++++++++++++++++++---------------------
 include/linux/nfs4.h | 12 ++++++----
 2 files changed, 46 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 77c6729e57f0..65c9c4175145 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7678,6 +7678,22 @@ nfs4_stat_to_errno(int stat)
 	.p_name = #proc,	\
 }
 
+#if defined(CONFIG_NFS_V4_1)
+#define PROC41(proc, argtype, restype)				\
+	PROC(proc, argtype, restype)
+#else
+#define PROC41(proc, argtype, restype)				\
+	STUB(proc)
+#endif
+
+#if defined(CONFIG_NFS_V4_2)
+#define PROC42(proc, argtype, restype)				\
+	PROC(proc, argtype, restype)
+#else
+#define PROC42(proc, argtype, restype)				\
+	STUB(proc)
+#endif
+
 const struct rpc_procinfo nfs4_procedures[] = {
 	PROC(READ,		enc_read,		dec_read),
 	PROC(WRITE,		enc_write,		dec_write),
@@ -7698,7 +7714,6 @@ const struct rpc_procinfo nfs4_procedures[] = {
 	PROC(ACCESS,		enc_access,		dec_access),
 	PROC(GETATTR,		enc_getattr,		dec_getattr),
 	PROC(LOOKUP,		enc_lookup,		dec_lookup),
-	PROC(LOOKUPP,		enc_lookupp,		dec_lookupp),
 	PROC(LOOKUP_ROOT,	enc_lookup_root,	dec_lookup_root),
 	PROC(REMOVE,		enc_remove,		dec_remove),
 	PROC(RENAME,		enc_rename,		dec_rename),
@@ -7717,33 +7732,30 @@ const struct rpc_procinfo nfs4_procedures[] = {
 	PROC(RELEASE_LOCKOWNER,	enc_release_lockowner,	dec_release_lockowner),
 	PROC(SECINFO,		enc_secinfo,		dec_secinfo),
 	PROC(FSID_PRESENT,	enc_fsid_present,	dec_fsid_present),
-#if defined(CONFIG_NFS_V4_1)
-	PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
-	PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
-	PROC(DESTROY_SESSION,	enc_destroy_session,	dec_destroy_session),
-	PROC(SEQUENCE,		enc_sequence,		dec_sequence),
-	PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
-	PROC(RECLAIM_COMPLETE,	enc_reclaim_complete,	dec_reclaim_complete),
-	PROC(GETDEVICEINFO,	enc_getdeviceinfo,	dec_getdeviceinfo),
-	PROC(LAYOUTGET,		enc_layoutget,		dec_layoutget),
-	PROC(LAYOUTCOMMIT,	enc_layoutcommit,	dec_layoutcommit),
-	PROC(LAYOUTRETURN,	enc_layoutreturn,	dec_layoutreturn),
-	PROC(SECINFO_NO_NAME,	enc_secinfo_no_name,	dec_secinfo_no_name),
-	PROC(TEST_STATEID,	enc_test_stateid,	dec_test_stateid),
-	PROC(FREE_STATEID,	enc_free_stateid,	dec_free_stateid),
+	PROC41(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
+	PROC41(CREATE_SESSION,	enc_create_session,	dec_create_session),
+	PROC41(DESTROY_SESSION,	enc_destroy_session,	dec_destroy_session),
+	PROC41(SEQUENCE,	enc_sequence,		dec_sequence),
+	PROC41(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
+	PROC41(RECLAIM_COMPLETE,enc_reclaim_complete,	dec_reclaim_complete),
+	PROC41(GETDEVICEINFO,	enc_getdeviceinfo,	dec_getdeviceinfo),
+	PROC41(LAYOUTGET,	enc_layoutget,		dec_layoutget),
+	PROC41(LAYOUTCOMMIT,	enc_layoutcommit,	dec_layoutcommit),
+	PROC41(LAYOUTRETURN,	enc_layoutreturn,	dec_layoutreturn),
+	PROC41(SECINFO_NO_NAME,	enc_secinfo_no_name,	dec_secinfo_no_name),
+	PROC41(TEST_STATEID,	enc_test_stateid,	dec_test_stateid),
+	PROC41(FREE_STATEID,	enc_free_stateid,	dec_free_stateid),
 	STUB(GETDEVICELIST),
-	PROC(BIND_CONN_TO_SESSION,
+	PROC41(BIND_CONN_TO_SESSION,
 			enc_bind_conn_to_session, dec_bind_conn_to_session),
-	PROC(DESTROY_CLIENTID,	enc_destroy_clientid,	dec_destroy_clientid),
-#endif /* CONFIG_NFS_V4_1 */
-#ifdef CONFIG_NFS_V4_2
-	PROC(SEEK,		enc_seek,		dec_seek),
-	PROC(ALLOCATE,		enc_allocate,		dec_allocate),
-	PROC(DEALLOCATE,	enc_deallocate,		dec_deallocate),
-	PROC(LAYOUTSTATS,	enc_layoutstats,	dec_layoutstats),
-	PROC(CLONE,		enc_clone,		dec_clone),
-	PROC(COPY,		enc_copy,		dec_copy),
-#endif /* CONFIG_NFS_V4_2 */
+	PROC41(DESTROY_CLIENTID,enc_destroy_clientid,	dec_destroy_clientid),
+	PROC42(SEEK,		enc_seek,		dec_seek),
+	PROC42(ALLOCATE,	enc_allocate,		dec_allocate),
+	PROC42(DEALLOCATE,	enc_deallocate,		dec_deallocate),
+	PROC42(LAYOUTSTATS,	enc_layoutstats,	dec_layoutstats),
+	PROC42(CLONE,		enc_clone,		dec_clone),
+	PROC42(COPY,		enc_copy,		dec_copy),
+	PROC(LOOKUPP,		enc_lookupp,		dec_lookupp),
 };
 
 static unsigned int nfs_version4_counts[ARRAY_SIZE(nfs4_procedures)];
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 47adac640191..57ffaa20d564 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -457,7 +457,12 @@ enum lock_type4 {
 
 #define NFS4_DEBUG 1
 
-/* Index of predefined Linux client operations */
+/*
+ * Index of predefined Linux client operations
+ *
+ * To ensure that /proc/net/rpc/nfs remains correctly ordered, please
+ * append only to this enum when adding new client operations.
+ */
 
 enum {
 	NFSPROC4_CLNT_NULL = 0,		/* Unused */
@@ -480,7 +485,6 @@ enum {
 	NFSPROC4_CLNT_ACCESS,
 	NFSPROC4_CLNT_GETATTR,
 	NFSPROC4_CLNT_LOOKUP,
-	NFSPROC4_CLNT_LOOKUPP,
 	NFSPROC4_CLNT_LOOKUP_ROOT,
 	NFSPROC4_CLNT_REMOVE,
 	NFSPROC4_CLNT_RENAME,
@@ -500,7 +504,6 @@ enum {
 	NFSPROC4_CLNT_SECINFO,
 	NFSPROC4_CLNT_FSID_PRESENT,
 
-	/* nfs41 */
 	NFSPROC4_CLNT_EXCHANGE_ID,
 	NFSPROC4_CLNT_CREATE_SESSION,
 	NFSPROC4_CLNT_DESTROY_SESSION,
@@ -518,13 +521,14 @@ enum {
 	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
 	NFSPROC4_CLNT_DESTROY_CLIENTID,
 
-	/* nfs42 */
 	NFSPROC4_CLNT_SEEK,
 	NFSPROC4_CLNT_ALLOCATE,
 	NFSPROC4_CLNT_DEALLOCATE,
 	NFSPROC4_CLNT_LAYOUTSTATS,
 	NFSPROC4_CLNT_CLONE,
 	NFSPROC4_CLNT_COPY,
+
+	NFSPROC4_CLNT_LOOKUPP,
 };
 
 /* nfs41 types */
-- 
2.14.3

