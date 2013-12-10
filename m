Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f47.google.com ([209.85.160.47]:48357 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402Ab3LJHYm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Dec 2013 02:24:42 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so7071607pbc.20
        for <linux-nfs@vger.kernel.org>; Mon, 09 Dec 2013 23:24:41 -0800 (PST)
Message-ID: <52A6C1B4.9030501@gmail.com>
Date: Tue, 10 Dec 2013 15:24:36 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, dros@netapp.com
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: calculate the missing length of bitmap in EXCHANG_ID
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 58cd57bfd9db3bc213bf9d6a10920f82095f0114
"nfsd: Fix SP4_MACH_CRED negotiation in EXCHANGE_ID"
miss calculating the length of bitmap for spo_must_enforce and spo_must_allow.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c |  3 ++-
 fs/nfsd/nfs4xdr.c  | 24 ++++++++++++++++--------
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 419572f..7bac4bd 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1524,7 +1524,8 @@ static inline u32 nfsd4_write_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 static inline u32 nfsd4_exchange_id_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
 	return (op_encode_hdr_size + 2 + 1 + /* eir_clientid, eir_sequenceid */\
-		1 + 1 + 2 + /* eir_flags, spr_how, spo_must_enforce & _allow */\
+		1 + 1 + /* eir_flags, spr_how */\
+		4 + /* spo_must_enforce & _allow with bitmap */\
 		2 + /*eir_server_owner.so_minor_id */\
 		/* eir_server_owner.so_major_id<> */\
 		XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 +\
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a57e67d..817c99f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3368,35 +3368,43 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 		8 /* eir_clientid */ +
 		4 /* eir_sequenceid */ +
 		4 /* eir_flags */ +
-		4 /* spr_how */ +
-		8 /* spo_must_enforce, spo_must_allow */ +
-		8 /* so_minor_id */ +
-		4 /* so_major_id.len */ +
-		(XDR_QUADLEN(major_id_sz) * 4) +
-		4 /* eir_server_scope.len */ +
-		(XDR_QUADLEN(server_scope_sz) * 4) +
-		4 /* eir_server_impl_id.count (0) */);
+		4 /* spr_how */);
 
 	WRITEMEM(&exid->clientid, 8);
 	WRITE32(exid->seqid);
 	WRITE32(exid->flags);
 
 	WRITE32(exid->spa_how);
+	ADJUST_ARGS();
+
 	switch (exid->spa_how) {
 	case SP4_NONE:
 		break;
 	case SP4_MACH_CRED:
+		/* spo_must_enforce, spo_must_allow */
+		RESERVE_SPACE(16);
+
 		/* spo_must_enforce bitmap: */
 		WRITE32(2);
 		WRITE32(nfs4_minimal_spo_must_enforce[0]);
 		WRITE32(nfs4_minimal_spo_must_enforce[1]);
 		/* empty spo_must_allow bitmap: */
 		WRITE32(0);
+
+		ADJUST_ARGS();
 		break;
 	default:
 		WARN_ON_ONCE(1);
 	}
 
+	RESERVE_SPACE(
+		8 /* so_minor_id */ +
+		4 /* so_major_id.len */ +
+		(XDR_QUADLEN(major_id_sz) * 4) +
+		4 /* eir_server_scope.len */ +
+		(XDR_QUADLEN(server_scope_sz) * 4) +
+		4 /* eir_server_impl_id.count (0) */);
+
 	/* The server_owner struct */
 	WRITE64(minor_id);      /* Minor id */
 	/* major id */
-- 
1.8.4.2
