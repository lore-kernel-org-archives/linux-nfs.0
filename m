Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:44274 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753182AbdEIJV1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:21:27 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 26/32] nfsd4: properly type op_get_currentstateid callbacks
Date: Tue,  9 May 2017 11:20:04 +0200
Message-Id: <20170509092010.30752-27-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass union nfsd4_op_u to the op_set_currentstateid callbacks instead of
using unsafe function pointer casts.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/current_stateid.h | 24 ++++++++++++++++--------
 fs/nfsd/nfs4proc.c        | 21 ++++++++++-----------
 fs/nfsd/nfs4state.c       | 40 ++++++++++++++++++++++++----------------
 3 files changed, 50 insertions(+), 35 deletions(-)

diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
index 3c80a7b5302d..34075cee573a 100644
--- a/fs/nfsd/current_stateid.h
+++ b/fs/nfsd/current_stateid.h
@@ -20,13 +20,21 @@ extern void nfsd4_set_closestateid(struct nfsd4_compound_state *,
 /*
  * functions to consume current state id
  */
-extern void nfsd4_get_opendowngradestateid(struct nfsd4_compound_state *cstate, struct nfsd4_open_downgrade *);
-extern void nfsd4_get_delegreturnstateid(struct nfsd4_compound_state *, struct nfsd4_delegreturn *);
-extern void nfsd4_get_freestateid(struct nfsd4_compound_state *, struct nfsd4_free_stateid *);
-extern void nfsd4_get_setattrstateid(struct nfsd4_compound_state *, struct nfsd4_setattr *);
-extern void nfsd4_get_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
-extern void nfsd4_get_lockustateid(struct nfsd4_compound_state *, struct nfsd4_locku *);
-extern void nfsd4_get_readstateid(struct nfsd4_compound_state *, struct nfsd4_read *);
-extern void nfsd4_get_writestateid(struct nfsd4_compound_state *, struct nfsd4_write *);
+extern void nfsd4_get_opendowngradestateid(struct nfsd4_compound_state *,
+		union nfsd4_op_u *);
+extern void nfsd4_get_delegreturnstateid(struct nfsd4_compound_state *,
+		union nfsd4_op_u *);
+extern void nfsd4_get_freestateid(struct nfsd4_compound_state *,
+		union nfsd4_op_u *);
+extern void nfsd4_get_setattrstateid(struct nfsd4_compound_state *,
+		union nfsd4_op_u *);
+extern void nfsd4_get_closestateid(struct nfsd4_compound_state *,
+		union nfsd4_op_u *);
+extern void nfsd4_get_lockustateid(struct nfsd4_compound_state *,
+		union nfsd4_op_u *);
+extern void nfsd4_get_readstateid(struct nfsd4_compound_state *,
+		union nfsd4_op_u *);
+extern void nfsd4_get_writestateid(struct nfsd4_compound_state *,
+		union nfsd4_op_u *);
 
 #endif   /* _NFSD4_CURRENT_STATE_H */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 49640f6ffb8d..dda05bd54a20 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1524,8 +1524,6 @@ typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
 typedef u32(*nfsd4op_rsize)(struct svc_rqst *, struct nfsd4_op *op);
 
-typedef void(*stateid_getter)(struct nfsd4_compound_state *, void *);
-
 enum nfsd4_op_flags {
 	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
 	ALLOWED_ON_ABSENT_FS = 1 << 1,	/* ops processed on absent fs */
@@ -1562,7 +1560,8 @@ struct nfsd4_operation {
 	char *op_name;
 	/* Try to get response size before operation */
 	nfsd4op_rsize op_rsize_bop;
-	stateid_getter op_get_currentstateid;
+	void (*op_get_currentstateid)(struct nfsd4_compound_state *,
+			union nfsd4_op_u *);
 	void (*op_set_currentstateid)(struct nfsd4_compound_state *,
 			union nfsd4_op_u *);
 };
@@ -2103,7 +2102,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_CLOSE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
-		.op_get_currentstateid = (stateid_getter)nfsd4_get_closestateid,
+		.op_get_currentstateid = nfsd4_get_closestateid,
 		.op_set_currentstateid = nfsd4_set_closestateid,
 	},
 	[OP_COMMIT] = {
@@ -2123,7 +2122,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_DELEGRETURN",
 		.op_rsize_bop = nfsd4_only_status_rsize,
-		.op_get_currentstateid = (stateid_getter)nfsd4_get_delegreturnstateid,
+		.op_get_currentstateid = nfsd4_get_delegreturnstateid,
 	},
 	[OP_GETATTR] = {
 		.op_func = (nfsd4op_func)nfsd4_getattr,
@@ -2160,7 +2159,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LOCKU",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
-		.op_get_currentstateid = (stateid_getter)nfsd4_get_lockustateid,
+		.op_get_currentstateid = nfsd4_get_lockustateid,
 	},
 	[OP_LOOKUP] = {
 		.op_func = (nfsd4op_func)nfsd4_lookup,
@@ -2197,7 +2196,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN_DOWNGRADE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
-		.op_get_currentstateid = (stateid_getter)nfsd4_get_opendowngradestateid,
+		.op_get_currentstateid = nfsd4_get_opendowngradestateid,
 		.op_set_currentstateid = nfsd4_set_opendowngradestateid,
 	},
 	[OP_PUTFH] = {
@@ -2225,7 +2224,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_func = (nfsd4op_func)nfsd4_read,
 		.op_name = "OP_READ",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_read_rsize,
-		.op_get_currentstateid = (stateid_getter)nfsd4_get_readstateid,
+		.op_get_currentstateid = nfsd4_get_readstateid,
 	},
 	[OP_READDIR] = {
 		.op_func = (nfsd4op_func)nfsd4_readdir,
@@ -2281,7 +2280,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_SETATTR",
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_setattr_rsize,
-		.op_get_currentstateid = (stateid_getter)nfsd4_get_setattrstateid,
+		.op_get_currentstateid = nfsd4_get_setattrstateid,
 	},
 	[OP_SETCLIENTID] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid,
@@ -2307,7 +2306,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_WRITE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
-		.op_get_currentstateid = (stateid_getter)nfsd4_get_writestateid,
+		.op_get_currentstateid = nfsd4_get_writestateid,
 	},
 	[OP_RELEASE_LOCKOWNER] = {
 		.op_func = (nfsd4op_func)nfsd4_release_lockowner,
@@ -2387,7 +2386,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_func = (nfsd4op_func)nfsd4_free_stateid,
 		.op_flags = ALLOWED_WITHOUT_FH | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_FREE_STATEID",
-		.op_get_currentstateid = (stateid_getter)nfsd4_get_freestateid,
+		.op_get_currentstateid = nfsd4_get_freestateid,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 #ifdef CONFIG_NFSD_PNFS
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4cf05b59ddf6..efe0c63bb74c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7148,49 +7148,57 @@ nfsd4_set_lockstateid(struct nfsd4_compound_state *cstate,
  */
 
 void
-nfsd4_get_opendowngradestateid(struct nfsd4_compound_state *cstate, struct nfsd4_open_downgrade *odp)
+nfsd4_get_opendowngradestateid(struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
-	get_stateid(cstate, &odp->od_stateid);
+	get_stateid(cstate, &u->open_downgrade.od_stateid);
 }
 
 void
-nfsd4_get_delegreturnstateid(struct nfsd4_compound_state *cstate, struct nfsd4_delegreturn *drp)
+nfsd4_get_delegreturnstateid(struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
-	get_stateid(cstate, &drp->dr_stateid);
+	get_stateid(cstate, &u->delegreturn.dr_stateid);
 }
 
 void
-nfsd4_get_freestateid(struct nfsd4_compound_state *cstate, struct nfsd4_free_stateid *fsp)
+nfsd4_get_freestateid(struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
-	get_stateid(cstate, &fsp->fr_stateid);
+	get_stateid(cstate, &u->free_stateid.fr_stateid);
 }
 
 void
-nfsd4_get_setattrstateid(struct nfsd4_compound_state *cstate, struct nfsd4_setattr *setattr)
+nfsd4_get_setattrstateid(struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
-	get_stateid(cstate, &setattr->sa_stateid);
+	get_stateid(cstate, &u->setattr.sa_stateid);
 }
 
 void
-nfsd4_get_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
+nfsd4_get_closestateid(struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
-	get_stateid(cstate, &close->cl_stateid);
+	get_stateid(cstate, &u->close.cl_stateid);
 }
 
 void
-nfsd4_get_lockustateid(struct nfsd4_compound_state *cstate, struct nfsd4_locku *locku)
+nfsd4_get_lockustateid(struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
-	get_stateid(cstate, &locku->lu_stateid);
+	get_stateid(cstate, &u->locku.lu_stateid);
 }
 
 void
-nfsd4_get_readstateid(struct nfsd4_compound_state *cstate, struct nfsd4_read *read)
+nfsd4_get_readstateid(struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
-	get_stateid(cstate, &read->rd_stateid);
+	get_stateid(cstate, &u->read.rd_stateid);
 }
 
 void
-nfsd4_get_writestateid(struct nfsd4_compound_state *cstate, struct nfsd4_write *write)
+nfsd4_get_writestateid(struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
-	get_stateid(cstate, &write->wr_stateid);
+	get_stateid(cstate, &u->write.wr_stateid);
 }
-- 
2.11.0

