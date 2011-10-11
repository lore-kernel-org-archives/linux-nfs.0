Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44190 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754919Ab1JKQlJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Oct 2011 12:41:09 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/4] nfsd4: move name-length checks to xdr
Date: Tue, 11 Oct 2011 12:41:02 -0400
Message-Id: <1318351263-14918-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1318351263-14918-1-git-send-email-bfields@redhat.com>
References: <1318351263-14918-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Again, these checks are better in the xdr code.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   24 ++----------------------
 fs/nfsd/nfs4xdr.c   |   45 ++++++++++++++++++++++++++++++---------------
 fs/nfsd/xdr4.h      |    3 +--
 3 files changed, 33 insertions(+), 39 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6bfa293..5f35f35 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1189,17 +1189,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	return clp;
 }
 
-static int check_name(struct xdr_netobj name)
-{
-	if (name.len == 0) 
-		return 0;
-	if (name.len > NFS4_OPAQUE_LIMIT) {
-		dprintk("NFSD: check_name: name too long(%d)!\n", name.len);
-		return 0;
-	}
-	return 1;
-}
-
 static void
 add_to_unconfirmed(struct nfs4_client *clp, unsigned int strhashval)
 {
@@ -1442,7 +1431,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		__func__, rqstp, exid, exid->clname.len, exid->clname.data,
 		addr_str, exid->flags, exid->spa_how);
 
-	if (!check_name(exid->clname) || (exid->flags & ~EXCHGID4_FLAG_MASK_A))
+	if (exid->flags & ~EXCHGID4_FLAG_MASK_A)
 		return nfserr_inval;
 
 	/* Currently only support SP4_NONE */
@@ -1992,19 +1981,13 @@ __be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_setclientid *setclid)
 {
-	struct xdr_netobj 	clname = { 
-		.len = setclid->se_namelen,
-		.data = setclid->se_name,
-	};
+	struct xdr_netobj 	clname = setclid->se_name;
 	nfs4_verifier		clverifier = setclid->se_verf;
 	unsigned int 		strhashval;
 	struct nfs4_client	*conf, *unconf, *new;
 	__be32 			status;
 	char                    dname[HEXDIR_LEN];
 	
-	if (!check_name(clname))
-		return nfserr_inval;
-
 	status = nfs4_make_rec_clidname(dname, &clname);
 	if (status)
 		return status;
@@ -2523,9 +2506,6 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	struct nfs4_openowner *oo = NULL;
 	__be32 status;
 
-	if (!check_name(open->op_owner))
-		return nfserr_inval;
-
 	if (STALE_CLIENTID(&open->op_clientid))
 		return nfserr_stale_clientid;
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 94da8bb..2cab33c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -697,6 +697,23 @@ xdr_error:
 	return nfserr_bad_xdr;
 }
 
+static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_netobj *o)
+{
+	__be32 *p;
+
+	READ_BUF(4);
+	READ32(o->len);
+
+	if (o->len == 0 || o->len > NFS4_OPAQUE_LIMIT)
+		return nfserr_bad_xdr;
+
+	READ_BUF(o->len);
+	SAVEMEM(o->data, o->len);
+	return nfs_ok;
+xdr_error:
+	return nfserr_bad_xdr;
+}
+
 static __be32
 nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 {
@@ -715,13 +732,12 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 	status = nfsd4_decode_share_deny(argp, &open->op_share_deny);
 	if (status)
 		goto xdr_error;
-	READ_BUF(sizeof(clientid_t) + 4);
+	READ_BUF(sizeof(clientid_t));
 	COPYMEM(&open->op_clientid, sizeof(clientid_t));
-	READ32(open->op_owner.len);
-
-	/* owner, open_flag */
-	READ_BUF(open->op_owner.len + 4);
-	SAVEMEM(open->op_owner.data, open->op_owner.len);
+	status = nfsd4_decode_opaque(argp, &open->op_owner);
+	if (status)
+		goto xdr_error;
+	READ_BUF(4);
 	READ32(open->op_create);
 	switch (open->op_create) {
 	case NFS4_OPEN_NOCREATE:
@@ -964,12 +980,13 @@ nfsd4_decode_setclientid(struct nfsd4_compoundargs *argp, struct nfsd4_setclient
 {
 	DECODE_HEAD;
 
-	READ_BUF(12);
+	READ_BUF(8);
 	COPYMEM(setclientid->se_verf.data, 8);
-	READ32(setclientid->se_namelen);
 
-	READ_BUF(setclientid->se_namelen + 8);
-	SAVEMEM(setclientid->se_name, setclientid->se_namelen);
+	status = nfsd4_decode_opaque(argp, &setclientid->se_name);
+	if (status)
+		return nfserr_bad_xdr;
+	READ_BUF(8);
 	READ32(setclientid->se_callback_prog);
 	READ32(setclientid->se_callback_netid_len);
 
@@ -1112,11 +1129,9 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
 	READ_BUF(NFS4_VERIFIER_SIZE);
 	COPYMEM(exid->verifier.data, NFS4_VERIFIER_SIZE);
 
-	READ_BUF(4);
-	READ32(exid->clname.len);
-
-	READ_BUF(exid->clname.len);
-	SAVEMEM(exid->clname.data, exid->clname.len);
+	status = nfsd4_decode_opaque(argp, &exid->clname);
+	if (status)
+		return nfserr_bad_xdr;
 
 	READ_BUF(4);
 	READ32(exid->flags);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index c901214..4c8a7ec 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -317,8 +317,7 @@ struct nfsd4_setattr {
 
 struct nfsd4_setclientid {
 	nfs4_verifier	se_verf;            /* request */
-	u32		se_namelen;         /* request */
-	char *		se_name;            /* request */
+	struct xdr_netobj se_name;
 	u32		se_callback_prog;   /* request */
 	u32		se_callback_netid_len;  /* request */
 	char *		se_callback_netid_val;  /* request */
-- 
1.7.4.1

