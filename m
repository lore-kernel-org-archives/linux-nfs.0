From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 4/7] nfsd: nfs4xdr encode_stateid helper function
Date: Tue, 12 Aug 2008 20:45:07 +0300
Message-ID: <1218563107-25393-1-git-send-email-bhalevy@panasas.com>
References: <48A1CB0C.4090906@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>,
	Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:42176 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbYHLRpX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2008 13:45:23 -0400
In-Reply-To: <48A1CB0C.4090906@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |   76 ++++++++++++++++++++++------------------------------
 1 files changed, 32 insertions(+), 44 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4ec52f9..96da1aa 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1959,6 +1959,17 @@ fail:
 	return -EINVAL;
 }
 
+static void
+nfsd4_encode_stateid(struct nfsd4_compoundres *resp, stateid_t *sid)
+{
+	ENCODE_HEAD;
+
+	RESERVE_SPACE(sizeof(stateid_t));
+	WRITE32(sid->si_generation);
+	WRITEMEM(&sid->si_opaque, sizeof(stateid_opaque_t));
+	ADJUST_ARGS();
+}
+
 static __be32
 nfsd4_encode_access(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_access *access)
 {
@@ -1978,12 +1989,9 @@ nfsd4_encode_close(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_c
 {
 	ENCODE_SEQID_OP_HEAD;
 
-	if (!nfserr) {
-		RESERVE_SPACE(sizeof(stateid_t));
-		WRITE32(close->cl_stateid.si_generation);
-		WRITEMEM(&close->cl_stateid.si_opaque, sizeof(stateid_opaque_t));
-		ADJUST_ARGS();
-	}
+	if (!nfserr)
+		nfsd4_encode_stateid(resp, &close->cl_stateid);
+
 	ENCODE_SEQID_OP_TAIL(close->cl_stateowner);
 	return nfserr;
 }
@@ -2083,12 +2091,9 @@ nfsd4_encode_lock(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_lo
 {
 	ENCODE_SEQID_OP_HEAD;
 
-	if (!nfserr) {
-		RESERVE_SPACE(4 + sizeof(stateid_t));
-		WRITE32(lock->lk_resp_stateid.si_generation);
-		WRITEMEM(&lock->lk_resp_stateid.si_opaque, sizeof(stateid_opaque_t));
-		ADJUST_ARGS();
-	} else if (nfserr == nfserr_denied)
+	if (!nfserr)
+		nfsd4_encode_stateid(resp, &lock->lk_resp_stateid);
+	else if (nfserr == nfserr_denied)
 		nfsd4_encode_lock_denied(resp, &lock->lk_denied);
 
 	ENCODE_SEQID_OP_TAIL(lock->lk_replay_owner);
@@ -2108,13 +2113,9 @@ nfsd4_encode_locku(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_l
 {
 	ENCODE_SEQID_OP_HEAD;
 
-	if (!nfserr) {
-		RESERVE_SPACE(sizeof(stateid_t));
-		WRITE32(locku->lu_stateid.si_generation);
-		WRITEMEM(&locku->lu_stateid.si_opaque, sizeof(stateid_opaque_t));
-		ADJUST_ARGS();
-	}
-				        
+	if (!nfserr)
+		nfsd4_encode_stateid(resp, &locku->lu_stateid);
+
 	ENCODE_SEQID_OP_TAIL(locku->lu_stateowner);
 	return nfserr;
 }
@@ -2142,9 +2143,8 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	if (nfserr)
 		goto out;
 
-	RESERVE_SPACE(40 + sizeof(stateid_t));
-	WRITE32(open->op_stateid.si_generation);
-	WRITEMEM(&open->op_stateid.si_opaque, sizeof(stateid_opaque_t));
+	nfsd4_encode_stateid(resp, &open->op_stateid);
+	RESERVE_SPACE(40);
 	WRITECINFO(open->op_cinfo);
 	WRITE32(open->op_rflags);
 	WRITE32(2);
@@ -2157,10 +2157,8 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 	case NFS4_OPEN_DELEGATE_NONE:
 		break;
 	case NFS4_OPEN_DELEGATE_READ:
-		RESERVE_SPACE(20 + sizeof(stateid_t));
-		WRITE32(open->op_delegate_stateid.si_generation);
-		WRITEMEM(&open->op_delegate_stateid.si_opaque,
-			 sizeof(stateid_opaque_t));
+		nfsd4_encode_stateid(resp, &open->op_delegate_stateid);
+		RESERVE_SPACE(20);
 		WRITE32(open->op_recall);
 
 		/*
@@ -2173,10 +2171,8 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
 		ADJUST_ARGS();
 		break;
 	case NFS4_OPEN_DELEGATE_WRITE:
-		RESERVE_SPACE(32 + sizeof(stateid_t));
-		WRITE32(open->op_delegate_stateid.si_generation);
-		WRITEMEM(&open->op_delegate_stateid.si_opaque,
-			 sizeof(stateid_opaque_t));
+		nfsd4_encode_stateid(resp, &open->op_delegate_stateid);
+		RESERVE_SPACE(32);
 		WRITE32(0);
 
 		/*
@@ -2208,13 +2204,9 @@ static __be32
 nfsd4_encode_open_confirm(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_open_confirm *oc)
 {
 	ENCODE_SEQID_OP_HEAD;
-				        
-	if (!nfserr) {
-		RESERVE_SPACE(sizeof(stateid_t));
-		WRITE32(oc->oc_resp_stateid.si_generation);
-		WRITEMEM(&oc->oc_resp_stateid.si_opaque, sizeof(stateid_opaque_t));
-		ADJUST_ARGS();
-	}
+
+	if (!nfserr)
+		nfsd4_encode_stateid(resp, &oc->oc_resp_stateid);
 
 	ENCODE_SEQID_OP_TAIL(oc->oc_stateowner);
 	return nfserr;
@@ -2224,13 +2216,9 @@ static __be32
 nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_open_downgrade *od)
 {
 	ENCODE_SEQID_OP_HEAD;
-				        
-	if (!nfserr) {
-		RESERVE_SPACE(sizeof(stateid_t));
-		WRITE32(od->od_stateid.si_generation);
-		WRITEMEM(&od->od_stateid.si_opaque, sizeof(stateid_opaque_t));
-		ADJUST_ARGS();
-	}
+
+	if (!nfserr)
+		nfsd4_encode_stateid(resp, &od->od_stateid);
 
 	ENCODE_SEQID_OP_TAIL(od->od_stateowner);
 	return nfserr;
-- 
1.5.6.5

