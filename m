Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:4695 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754688Ab3HETrM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Aug 2013 15:47:12 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] nfsd: Fix SP4_MACH_CRED negotiation in EXCHANGE_ID
Date: Mon, 5 Aug 2013 15:47:07 -0400
Message-ID: <1375732027-4905-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 - don't BUG_ON() when not SP4_NONE
 - calculate recv and send reserve sizes correctly

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfsd/nfs4proc.c | 2 +-
 fs/nfsd/nfs4xdr.c  | 5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0d4c410..419572f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1524,7 +1524,7 @@ static inline u32 nfsd4_write_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 static inline u32 nfsd4_exchange_id_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
 	return (op_encode_hdr_size + 2 + 1 + /* eir_clientid, eir_sequenceid */\
-		1 + 1 + 0 + /* eir_flags, spr_how, SP4_NONE (for now) */\
+		1 + 1 + 2 + /* eir_flags, spr_how, spo_must_enforce & _allow */\
 		2 + /*eir_server_owner.so_minor_id */\
 		/* eir_server_owner.so_major_id<> */\
 		XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 +\
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0c0f3ea9..c2a4701 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3360,7 +3360,8 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 		8 /* eir_clientid */ +
 		4 /* eir_sequenceid */ +
 		4 /* eir_flags */ +
-		4 /* spr_how (SP4_NONE) */ +
+		4 /* spr_how */ +
+		8 /* spo_must_enforce, spo_must_allow */ +
 		8 /* so_minor_id */ +
 		4 /* so_major_id.len */ +
 		(XDR_QUADLEN(major_id_sz) * 4) +
@@ -3372,8 +3373,6 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITE32(exid->seqid);
 	WRITE32(exid->flags);
 
-	/* state_protect4_r. Currently only support SP4_NONE */
-	BUG_ON(exid->spa_how != SP4_NONE);
 	WRITE32(exid->spa_how);
 	switch (exid->spa_how) {
 	case SP4_NONE:
-- 
1.7.12.4 (Apple Git-37)

