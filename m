Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:47372 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933913AbaH0PSG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Aug 2014 11:18:06 -0400
From: <bjschuma@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] NFSD: Create nfs v4.2 decode ops
Date: Wed, 27 Aug 2014 11:17:57 -0400
Message-ID: <1409152678-7806-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1409152678-7806-1-git-send-email-bjschuma@netapp.com>
References: <1409152678-7806-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

It's cleaner to introduce everything at once and have the server reply
with "not supported" than it would be to introduce extra operations when
implementing a specific one in the middle of the list.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4xdr.c    | 28 ++++++++++++++++++++++++++++
 include/linux/nfs4.h | 18 ++++++++++++++++--
 2 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f9821ce..94dde7b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1593,6 +1593,20 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_WANT_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_DESTROY_CLIENTID]	= (nfsd4_dec)nfsd4_decode_destroy_clientid,
 	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
+
+	/* new operations for NFSv4.2 */
+	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTERROR]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_LAYOUTSTATS]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_OFFLOAD_CANCEL]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_WRITE_SAME]		= (nfsd4_dec)nfsd4_decode_notsupp,
 };
 
 static inline bool
@@ -3822,6 +3836,20 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_WANT_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_DESTROY_CLIENTID]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_RECLAIM_COMPLETE]	= (nfsd4_enc)nfsd4_encode_noop,
+
+	/* NFSv4.2 operations */
+	[OP_ALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_DEALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_LAYOUTERROR]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_LAYOUTSTATS]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_OFFLOAD_CANCEL]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_WRITE_SAME]		= (nfsd4_enc)nfsd4_encode_noop,
 };
 
 /*
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 79b2a0f..cf38224 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -110,6 +110,20 @@ enum nfs_opnum4 {
 	OP_DESTROY_CLIENTID = 57,
 	OP_RECLAIM_COMPLETE = 58,
 
+	/* nfs42 */
+	OP_ALLOCATE = 59,
+	OP_COPY = 60,
+	OP_COPY_NOTIFY = 61,
+	OP_DEALLOCATE = 62,
+	OP_IO_ADVISE = 63,
+	OP_LAYOUTERROR = 64,
+	OP_LAYOUTSTATS = 65,
+	OP_OFFLOAD_CANCEL = 66,
+	OP_OFFLOAD_STATUS = 67,
+	OP_READ_PLUS = 68,
+	OP_SEEK = 69,
+	OP_WRITE_SAME = 70,
+
 	OP_ILLEGAL = 10044,
 };
 
@@ -117,10 +131,10 @@ enum nfs_opnum4 {
 Needs to be updated if more operations are defined in future.*/
 
 #define FIRST_NFS4_OP	OP_ACCESS
-#define LAST_NFS4_OP 	OP_RECLAIM_COMPLETE
+#define LAST_NFS4_OP 	OP_WRITE_SAME
 #define LAST_NFS40_OP	OP_RELEASE_LOCKOWNER
 #define LAST_NFS41_OP	OP_RECLAIM_COMPLETE
-#define LAST_NFS42_OP	OP_RECLAIM_COMPLETE
+#define LAST_NFS42_OP	OP_WRITE_SAME
 
 enum nfsstat4 {
 	NFS4_OK = 0,
-- 
2.1.0

