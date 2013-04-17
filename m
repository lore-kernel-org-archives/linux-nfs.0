Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37481 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935880Ab3DQBy6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Apr 2013 21:54:58 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] nfsd4: remove unused macro
Date: Tue, 16 Apr 2013 21:54:55 -0400
Message-Id: <1366163696-10700-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Cleanup a piece I forgot to remove in
9411b1d4c7df26dca6bc6261b5dc87a5b4c81e5c "nfsd4: cleanup handling of
nfsv4.0 closed stateid's".

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   19 -------------------
 1 file changed, 19 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a5e8a64..1cf1545 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1693,14 +1693,6 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
 } while (0)
 #define ADJUST_ARGS()		resp->p = p
 
-/*
- * Header routine to setup seqid operation replay cache
- */
-#define ENCODE_SEQID_OP_HEAD					\
-	__be32 *save;						\
-								\
-	save = resp->p;
-
 /* Encode as an array of strings the string given with components
  * separated @sep, escaped with esc_enter and esc_exit.
  */
@@ -2640,8 +2632,6 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 static __be32
 nfsd4_encode_close(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_close *close)
 {
-	ENCODE_SEQID_OP_HEAD;
-
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &close->cl_stateid);
 
@@ -2740,8 +2730,6 @@ nfsd4_encode_lock_denied(struct nfsd4_compoundres *resp, struct nfsd4_lock_denie
 static __be32
 nfsd4_encode_lock(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_lock *lock)
 {
-	ENCODE_SEQID_OP_HEAD;
-
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &lock->lk_resp_stateid);
 	else if (nfserr == nfserr_denied)
@@ -2761,8 +2749,6 @@ nfsd4_encode_lockt(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_l
 static __be32
 nfsd4_encode_locku(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_locku *locku)
 {
-	ENCODE_SEQID_OP_HEAD;
-
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &locku->lu_stateid);
 
@@ -2788,7 +2774,6 @@ static __be32
 nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_open *open)
 {
 	__be32 *p;
-	ENCODE_SEQID_OP_HEAD;
 
 	if (nfserr)
 		goto out;
@@ -2866,8 +2851,6 @@ out:
 static __be32
 nfsd4_encode_open_confirm(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_open_confirm *oc)
 {
-	ENCODE_SEQID_OP_HEAD;
-
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &oc->oc_resp_stateid);
 
@@ -2877,8 +2860,6 @@ nfsd4_encode_open_confirm(struct nfsd4_compoundres *resp, __be32 nfserr, struct
 static __be32
 nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_open_downgrade *od)
 {
-	ENCODE_SEQID_OP_HEAD;
-
 	if (!nfserr)
 		nfsd4_encode_stateid(resp, &od->od_stateid);
 
-- 
1.7.9.5

