Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:3328 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753735Ab3KLTET (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 14:04:19 -0500
From: Anna Schumaker <bjschuma@netapp.com>
To: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 2/3] NFSD: Create nfs v4.2 decode ops
Date: Tue, 12 Nov 2013 14:04:07 -0500
Message-ID: <1384283048-7699-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's cleaner to introduce everything at once and have the server reply
with "not supported" than it would be to introduce extra operations when
implementing a specific one in the middle of the list.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4xdr.c    | 22 ++++++++++++++++++++++
 include/linux/nfs4.h | 15 +++++++++++++--
 2 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 83db5a7..3af6c46 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1580,6 +1580,17 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_WANT_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_DESTROY_CLIENTID]	= (nfsd4_dec)nfsd4_decode_destroy_clientid,
 	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
+
+	/* new operations for NFSv4.2 */
+	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_OFFLOAD_ABORT]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_OFFLOAD_REVOKE]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_WRITE_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
 };
 
 static inline bool
@@ -3575,6 +3586,17 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_WANT_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_DESTROY_CLIENTID]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_RECLAIM_COMPLETE]	= (nfsd4_enc)nfsd4_encode_noop,
+
+	/* NFSv4.2 operations */
+	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_OFFLOAD_ABORT]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_OFFLOAD_REVOKE]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_WRITE_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
 };
 
 /*
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 6d79deb..01119ed 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -110,6 +110,17 @@ enum nfs_opnum4 {
 	OP_DESTROY_CLIENTID = 57,
 	OP_RECLAIM_COMPLETE = 58,
 
+	/* nfs42 */
+	OP_COPY = 59,
+	OP_OFFLOAD_ABORT = 60,
+	OP_COPY_NOTIFY = 61,
+	OP_OFFLOAD_REVOKE = 62,
+	OP_OFFLOAD_STATUS = 63,
+	OP_WRITE_PLUS = 64,
+	OP_READ_PLUS = 65,
+	OP_SEEK = 66,
+	OP_IO_ADVISE = 67,
+
 	OP_ILLEGAL = 10044,
 };
 
@@ -117,10 +128,10 @@ enum nfs_opnum4 {
 Needs to be updated if more operations are defined in future.*/
 
 #define FIRST_NFS4_OP	OP_ACCESS
-#define LAST_NFS4_OP 	OP_RECLAIM_COMPLETE
+#define LAST_NFS4_OP 	OP_IO_ADVISE
 #define LAST_NFS40_OP	OP_RELEASE_LOCKOWNER
 #define LAST_NFS41_OP	OP_RECLAIM_COMPLETE
-#define LAST_NFS42_OP	OP_RECLAIM_COMPLETE
+#define LAST_NFS42_OP	OP_IO_ADVISE
 
 enum nfsstat4 {
 	NFS4_OK = 0,
-- 
1.8.4.2

