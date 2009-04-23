From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 1/2] nfsd: eliminate ENCODE_HEAD macro
Date: Thu, 23 Apr 2009 17:31:56 -0400
Message-ID: <1240522317-1834-2-git-send-email-bfields@fieldses.org>
References: <1240522317-1834-1-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:46949 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754494AbZDWVb6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 17:31:58 -0400
In-Reply-To: <1240522317-1834-1-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

This macro doesn't serve any useful purpose.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4xdr.c |   46 ++++++++++++++++++++++------------------------
 1 files changed, 22 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b820c31..fe46ede 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1503,8 +1503,6 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
  * task to translate them into Linux-specific versions which are more
  * consistent with the style used in NFSv2/v3...
  */
-#define ENCODE_HEAD              __be32 *p
-
 #define WRITE32(n)               *p++ = htonl(n)
 #define WRITE64(n)               do {				\
 	*p++ = htonl((u32)((n) >> 32));				\
@@ -2334,7 +2332,7 @@ fail:
 static void
 nfsd4_encode_stateid(struct nfsd4_compoundres *resp, stateid_t *sid)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	RESERVE_SPACE(sizeof(stateid_t));
 	WRITE32(sid->si_generation);
@@ -2345,7 +2343,7 @@ nfsd4_encode_stateid(struct nfsd4_compoundres *resp, stateid_t *sid)
 static __be32
 nfsd4_encode_access(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_access *access)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (!nfserr) {
 		RESERVE_SPACE(8);
@@ -2372,7 +2370,7 @@ nfsd4_encode_close(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_c
 static __be32
 nfsd4_encode_commit(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_commit *commit)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (!nfserr) {
 		RESERVE_SPACE(8);
@@ -2385,7 +2383,7 @@ nfsd4_encode_commit(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 static __be32
 nfsd4_encode_create(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_create *create)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (!nfserr) {
 		RESERVE_SPACE(32);
@@ -2421,7 +2419,7 @@ nfsd4_encode_getfh(struct nfsd4_compoundres *resp, __be32 nfserr, struct svc_fh
 {
 	struct svc_fh *fhp = *fhpp;
 	unsigned int len;
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (!nfserr) {
 		len = fhp->fh_handle.fh_size;
@@ -2440,7 +2438,7 @@ nfsd4_encode_getfh(struct nfsd4_compoundres *resp, __be32 nfserr, struct svc_fh
 static void
 nfsd4_encode_lock_denied(struct nfsd4_compoundres *resp, struct nfsd4_lock_denied *ld)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	RESERVE_SPACE(32 + XDR_LEN(ld->ld_sop ? ld->ld_sop->so_owner.len : 0));
 	WRITE64(ld->ld_start);
@@ -2496,7 +2494,7 @@ nfsd4_encode_locku(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_l
 static __be32
 nfsd4_encode_link(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_link *link)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (!nfserr) {
 		RESERVE_SPACE(20);
@@ -2510,7 +2508,7 @@ nfsd4_encode_link(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_li
 static __be32
 nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_open *open)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 	ENCODE_SEQID_OP_HEAD;
 
 	if (nfserr)
@@ -2605,7 +2603,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	int v, pn;
 	unsigned long maxcount; 
 	long len;
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (nfserr)
 		return nfserr;
@@ -2667,7 +2665,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 {
 	int maxcount;
 	char *page;
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (nfserr)
 		return nfserr;
@@ -2716,7 +2714,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	int maxcount;
 	loff_t offset;
 	__be32 *page, *savep, *tailbase;
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (nfserr)
 		return nfserr;
@@ -2792,7 +2790,7 @@ err_no_verf:
 static __be32
 nfsd4_encode_remove(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_remove *remove)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (!nfserr) {
 		RESERVE_SPACE(20);
@@ -2805,7 +2803,7 @@ nfsd4_encode_remove(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 static __be32
 nfsd4_encode_rename(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_rename *rename)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (!nfserr) {
 		RESERVE_SPACE(40);
@@ -2825,7 +2823,7 @@ nfsd4_encode_secinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
 	u32 nflavs;
 	struct exp_flavor_info *flavs;
 	struct exp_flavor_info def_flavs[2];
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (nfserr)
 		goto out;
@@ -2890,7 +2888,7 @@ out:
 static __be32
 nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_setattr *setattr)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	RESERVE_SPACE(12);
 	if (nfserr) {
@@ -2910,7 +2908,7 @@ nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 static __be32
 nfsd4_encode_setclientid(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_setclientid *scd)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (!nfserr) {
 		RESERVE_SPACE(8 + sizeof(nfs4_verifier));
@@ -2930,7 +2928,7 @@ nfsd4_encode_setclientid(struct nfsd4_compoundres *resp, __be32 nfserr, struct n
 static __be32
 nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_write *write)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (!nfserr) {
 		RESERVE_SPACE(16);
@@ -2946,7 +2944,7 @@ static __be32
 nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, int nfserr,
 			 struct nfsd4_exchange_id *exid)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 	char *major_id;
 	char *server_scope;
 	int major_id_sz;
@@ -3001,7 +2999,7 @@ static __be32
 nfsd4_encode_create_session(struct nfsd4_compoundres *resp, int nfserr,
 			    struct nfsd4_create_session *sess)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (nfserr)
 		return nfserr;
@@ -3057,7 +3055,7 @@ __be32
 nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 		      struct nfsd4_sequence *seq)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 
 	if (nfserr)
 		return nfserr;
@@ -3205,7 +3203,7 @@ void
 nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 {
 	__be32 *statp;
-	ENCODE_HEAD;
+	__be32 *p;
 
 	RESERVE_SPACE(8);
 	WRITE32(op->opnum);
@@ -3239,7 +3237,7 @@ status:
 void
 nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 {
-	ENCODE_HEAD;
+	__be32 *p;
 	struct nfs4_replay *rp = op->replay;
 
 	BUG_ON(!rp);
-- 
1.6.0.4

