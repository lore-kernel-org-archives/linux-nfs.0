From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 7/7] nfsd: nfs4xdr decode_stateid helper function
Date: Tue, 12 Aug 2008 20:46:18 +0300
Message-ID: <1218563178-25480-1-git-send-email-bhalevy@panasas.com>
References: <48A1CB0C.4090906@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>,
	Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48676 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbYHLRqe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2008 13:46:34 -0400
In-Reply-To: <48A1CB0C.4090906@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |   99 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 55 insertions(+), 44 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 47ac498..9570b1b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -413,6 +413,18 @@ out_nfserr:
 }
 
 static __be32
+nfsd4_decode_stateid(struct nfsd4_compoundargs *argp, stateid_t *sid)
+{
+	DECODE_HEAD;
+
+	READ_BUF(sizeof(stateid_t));
+	READ32(sid->si_generation);
+	COPYMEM(&sid->si_opaque, sizeof(stateid_opaque_t));
+
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_access(struct nfsd4_compoundargs *argp, struct nfsd4_access *access)
 {
 	DECODE_HEAD;
@@ -429,10 +441,9 @@ nfsd4_decode_close(struct nfsd4_compoundargs *argp, struct nfsd4_close *close)
 	DECODE_HEAD;
 
 	close->cl_stateowner = NULL;
-	READ_BUF(4 + sizeof(stateid_t));
+	READ_BUF(4);
 	READ32(close->cl_seqid);
-	READ32(close->cl_stateid.si_generation);
-	COPYMEM(&close->cl_stateid.si_opaque, sizeof(stateid_opaque_t));
+	return nfsd4_decode_stateid(argp, &close->cl_stateid);
 
 	DECODE_TAIL;
 }
@@ -493,13 +504,7 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
 static inline __be32
 nfsd4_decode_delegreturn(struct nfsd4_compoundargs *argp, struct nfsd4_delegreturn *dr)
 {
-	DECODE_HEAD;
-
-	READ_BUF(sizeof(stateid_t));
-	READ32(dr->dr_stateid.si_generation);
-	COPYMEM(&dr->dr_stateid.si_opaque, sizeof(stateid_opaque_t));
-
-	DECODE_TAIL;
+	return nfsd4_decode_stateid(argp, &dr->dr_stateid);
 }
 
 static inline __be32
@@ -542,20 +547,22 @@ nfsd4_decode_lock(struct nfsd4_compoundargs *argp, struct nfsd4_lock *lock)
 	READ32(lock->lk_is_new);
 
 	if (lock->lk_is_new) {
-		READ_BUF(36);
+		READ_BUF(4);
 		READ32(lock->lk_new_open_seqid);
-		READ32(lock->lk_new_open_stateid.si_generation);
-
-		COPYMEM(&lock->lk_new_open_stateid.si_opaque, sizeof(stateid_opaque_t));
+		status = nfsd4_decode_stateid(argp, &lock->lk_new_open_stateid);
+		if (status)
+			return status;
+		READ_BUF(8 + sizeof(clientid_t));
 		READ32(lock->lk_new_lock_seqid);
 		COPYMEM(&lock->lk_new_clientid, sizeof(clientid_t));
 		READ32(lock->lk_new_owner.len);
 		READ_BUF(lock->lk_new_owner.len);
 		READMEM(lock->lk_new_owner.data, lock->lk_new_owner.len);
 	} else {
-		READ_BUF(20);
-		READ32(lock->lk_old_lock_stateid.si_generation);
-		COPYMEM(&lock->lk_old_lock_stateid.si_opaque, sizeof(stateid_opaque_t));
+		status = nfsd4_decode_stateid(argp, &lock->lk_old_lock_stateid);
+		if (status)
+			return status;
+		READ_BUF(4);
 		READ32(lock->lk_old_lock_seqid);
 	}
 
@@ -587,13 +594,15 @@ nfsd4_decode_locku(struct nfsd4_compoundargs *argp, struct nfsd4_locku *locku)
 	DECODE_HEAD;
 
 	locku->lu_stateowner = NULL;
-	READ_BUF(24 + sizeof(stateid_t));
+	READ_BUF(8);
 	READ32(locku->lu_type);
 	if ((locku->lu_type < NFS4_READ_LT) || (locku->lu_type > NFS4_WRITEW_LT))
 		goto xdr_error;
 	READ32(locku->lu_seqid);
-	READ32(locku->lu_stateid.si_generation);
-	COPYMEM(&locku->lu_stateid.si_opaque, sizeof(stateid_opaque_t));
+	status = nfsd4_decode_stateid(argp, &locku->lu_stateid);
+	if (status)
+		return status;
+	READ_BUF(16);
 	READ64(locku->lu_offset);
 	READ64(locku->lu_length);
 
@@ -678,10 +687,10 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 		READ32(open->op_delegate_type);
 		break;
 	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
-		READ_BUF(sizeof(stateid_t) + 4);
-		READ32(open->op_delegate_stateid.si_generation);
-		COPYMEM(&open->op_delegate_stateid.si_opaque,
-			sizeof(stateid_opaque_t));
+		status = nfsd4_decode_stateid(argp, &open->op_delegate_stateid);
+		if (status)
+			return status;
+		READ_BUF(4);
 		READ32(open->op_fname.len);
 		READ_BUF(open->op_fname.len);
 		SAVEMEM(open->op_fname.data, open->op_fname.len);
@@ -701,9 +710,10 @@ nfsd4_decode_open_confirm(struct nfsd4_compoundargs *argp, struct nfsd4_open_con
 	DECODE_HEAD;
 		    
 	open_conf->oc_stateowner = NULL;
-	READ_BUF(4 + sizeof(stateid_t));
-	READ32(open_conf->oc_req_stateid.si_generation);
-	COPYMEM(&open_conf->oc_req_stateid.si_opaque, sizeof(stateid_opaque_t));
+	status = nfsd4_decode_stateid(argp, &open_conf->oc_req_stateid);
+	if (status)
+		return status;
+	READ_BUF(4);
 	READ32(open_conf->oc_seqid);
 						        
 	DECODE_TAIL;
@@ -715,9 +725,10 @@ nfsd4_decode_open_downgrade(struct nfsd4_compoundargs *argp, struct nfsd4_open_d
 	DECODE_HEAD;
 		    
 	open_down->od_stateowner = NULL;
-	READ_BUF(12 + sizeof(stateid_t));
-	READ32(open_down->od_stateid.si_generation);
-	COPYMEM(&open_down->od_stateid.si_opaque, sizeof(stateid_opaque_t));
+	status = nfsd4_decode_stateid(argp, &open_down->od_stateid);
+	if (status)
+		return status;
+	READ_BUF(12);
 	READ32(open_down->od_seqid);
 	READ32(open_down->od_share_access);
 	READ32(open_down->od_share_deny);
@@ -745,9 +756,10 @@ nfsd4_decode_read(struct nfsd4_compoundargs *argp, struct nfsd4_read *read)
 {
 	DECODE_HEAD;
 
-	READ_BUF(sizeof(stateid_t) + 12);
-	READ32(read->rd_stateid.si_generation);
-	COPYMEM(&read->rd_stateid.si_opaque, sizeof(stateid_opaque_t));
+	status = nfsd4_decode_stateid(argp, &read->rd_stateid);
+	if (status)
+		return status;
+	READ_BUF(12);
 	READ64(read->rd_offset);
 	READ32(read->rd_length);
 
@@ -836,15 +848,13 @@ nfsd4_decode_secinfo(struct nfsd4_compoundargs *argp,
 static __be32
 nfsd4_decode_setattr(struct nfsd4_compoundargs *argp, struct nfsd4_setattr *setattr)
 {
-	DECODE_HEAD;
-
-	READ_BUF(sizeof(stateid_t));
-	READ32(setattr->sa_stateid.si_generation);
-	COPYMEM(&setattr->sa_stateid.si_opaque, sizeof(stateid_opaque_t));
-	if ((status = nfsd4_decode_fattr(argp, setattr->sa_bmval, &setattr->sa_iattr, &setattr->sa_acl)))
-		goto out;
+	__be32 status;
 
-	DECODE_TAIL;
+	status = nfsd4_decode_stateid(argp, &setattr->sa_stateid);
+	if (status)
+		return status;
+	return nfsd4_decode_fattr(argp, setattr->sa_bmval,
+				  &setattr->sa_iattr, &setattr->sa_acl);
 }
 
 static __be32
@@ -929,9 +939,10 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 	int len;
 	DECODE_HEAD;
 
-	READ_BUF(sizeof(stateid_opaque_t) + 20);
-	READ32(write->wr_stateid.si_generation);
-	COPYMEM(&write->wr_stateid.si_opaque, sizeof(stateid_opaque_t));
+	status = nfsd4_decode_stateid(argp, &write->wr_stateid);
+	if (status)
+		return status;
+	READ_BUF(16);
 	READ64(write->wr_offset);
 	READ32(write->wr_stable_how);
 	if (write->wr_stable_how > 2)
-- 
1.5.6.5

