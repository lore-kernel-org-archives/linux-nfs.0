Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64117 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754245Ab2EZSkY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 May 2012 14:40:24 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH v2 5/9] NFSv4.1: Move NFSPROC4_CLNT_BIND_CONN_TO_SESSION to the end of the operations
Date: Sat, 26 May 2012 14:39:56 -0400
Message-Id: <1338057600-11130-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1338057600-11130-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1338057600-11130-1-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-2-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-3-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For backward compatibility with nfs-utils.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4xdr.c     |    4 ++--
 include/linux/nfs4.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a6b95b7..1d4d259 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7221,8 +7221,6 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(RELEASE_LOCKOWNER,	enc_release_lockowner,	dec_release_lockowner),
 	PROC(SECINFO,		enc_secinfo,		dec_secinfo),
 #if defined(CONFIG_NFS_V4_1)
-	PROC(BIND_CONN_TO_SESSION,
-			enc_bind_conn_to_session, dec_bind_conn_to_session),
 	PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
 	PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
 	PROC(DESTROY_SESSION,	enc_destroy_session,	dec_destroy_session),
@@ -7237,6 +7235,8 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(TEST_STATEID,	enc_test_stateid,	dec_test_stateid),
 	PROC(FREE_STATEID,	enc_free_stateid,	dec_free_stateid),
 	PROC(GETDEVICELIST,	enc_getdevicelist,	dec_getdevicelist),
+	PROC(BIND_CONN_TO_SESSION,
+			enc_bind_conn_to_session, dec_bind_conn_to_session),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index a2b71cb..54006a9 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -593,7 +593,6 @@ enum {
 	NFSPROC4_CLNT_SECINFO,
 
 	/* nfs41 */
-	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
 	NFSPROC4_CLNT_EXCHANGE_ID,
 	NFSPROC4_CLNT_CREATE_SESSION,
 	NFSPROC4_CLNT_DESTROY_SESSION,
@@ -608,6 +607,7 @@ enum {
 	NFSPROC4_CLNT_TEST_STATEID,
 	NFSPROC4_CLNT_FREE_STATEID,
 	NFSPROC4_CLNT_GETDEVICELIST,
+	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
 };
 
 /* nfs41 types */
-- 
1.7.7.6

