Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:16703 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753951AbbDNOeX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Apr 2015 10:34:23 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v3] NFS: Add a stub for GETDEVICELIST
Date: Tue, 14 Apr 2015 10:34:20 -0400
Message-ID: <1429022060-11222-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

d4b18c3e (pnfs: remove GETDEVICELIST implementation) removed the
GETDEVICELIST operation from the NFS client, but left a "hole" in the
nfs4_procedures array.  This caused /proc/self/mountstats to report an
operation named "51" where GETDEVICELIST used to be.  This patch adds a
stub to fix mountstats.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4xdr.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6b28a60..a26880c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7361,6 +7361,11 @@ nfs4_stat_to_errno(int stat)
 	.p_name   = #proc,					\
 }
 
+#define STUB(proc)		\
+[NFSPROC4_CLNT_##proc] = {	\
+	.p_name = #proc,	\
+}
+
 struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(READ,		enc_read,		dec_read),
 	PROC(WRITE,		enc_write,		dec_write),
@@ -7413,6 +7418,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(SECINFO_NO_NAME,	enc_secinfo_no_name,	dec_secinfo_no_name),
 	PROC(TEST_STATEID,	enc_test_stateid,	dec_test_stateid),
 	PROC(FREE_STATEID,	enc_free_stateid,	dec_free_stateid),
+	STUB(GETDEVICELIST),
 	PROC(BIND_CONN_TO_SESSION,
 			enc_bind_conn_to_session, dec_bind_conn_to_session),
 	PROC(DESTROY_CLIENTID,	enc_destroy_clientid,	dec_destroy_clientid),
-- 
2.3.5

