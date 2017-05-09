Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:35926 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753161AbdEIJVY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:21:24 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 25/32] nfsd4: properly type op_set_currentstateid callbacks
Date: Tue,  9 May 2017 11:20:03 +0200
Message-Id: <20170509092010.30752-26-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Given the args union in struct nfsd4_op a name, and pass it to the
op_set_currentstateid callbacks instead of using unsafe function
pointer casts.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/current_stateid.h | 12 ++++++++----
 fs/nfsd/nfs4proc.c        | 12 ++++++------
 fs/nfsd/nfs4state.c       | 20 ++++++++++++--------
 fs/nfsd/xdr4.h            |  2 +-
 4 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
index 4123551208d8..3c80a7b5302d 100644
--- a/fs/nfsd/current_stateid.h
+++ b/fs/nfsd/current_stateid.h
@@ -8,10 +8,14 @@ extern void clear_current_stateid(struct nfsd4_compound_state *cstate);
 /*
  * functions to set current state id
  */
-extern void nfsd4_set_opendowngradestateid(struct nfsd4_compound_state *cstate, struct nfsd4_open_downgrade *);
-extern void nfsd4_set_openstateid(struct nfsd4_compound_state *, struct nfsd4_open *);
-extern void nfsd4_set_lockstateid(struct nfsd4_compound_state *, struct nfsd4_lock *);
-extern void nfsd4_set_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
+extern void nfsd4_set_opendowngradestateid(struct nfsd4_compound_state *,
+		union nfsd4_op_u *);
+extern void nfsd4_set_openstateid(struct nfsd4_compound_state *,
+		union nfsd4_op_u *);
+extern void nfsd4_set_lockstateid(struct nfsd4_compound_state *,
+		union nfsd4_op_u *);
+extern void nfsd4_set_closestateid(struct nfsd4_compound_state *,
+		union nfsd4_op_u *);
 
 /*
  * functions to consume current state id
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1e0387a1e32f..49640f6ffb8d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1524,7 +1524,6 @@ typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
 typedef u32(*nfsd4op_rsize)(struct svc_rqst *, struct nfsd4_op *op);
 
-typedef void(*stateid_setter)(struct nfsd4_compound_state *, void *);
 typedef void(*stateid_getter)(struct nfsd4_compound_state *, void *);
 
 enum nfsd4_op_flags {
@@ -1564,7 +1563,8 @@ struct nfsd4_operation {
 	/* Try to get response size before operation */
 	nfsd4op_rsize op_rsize_bop;
 	stateid_getter op_get_currentstateid;
-	stateid_setter op_set_currentstateid;
+	void (*op_set_currentstateid)(struct nfsd4_compound_state *,
+			union nfsd4_op_u *);
 };
 
 static struct nfsd4_operation nfsd4_ops[];
@@ -2104,7 +2104,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_CLOSE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
 		.op_get_currentstateid = (stateid_getter)nfsd4_get_closestateid,
-		.op_set_currentstateid = (stateid_setter)nfsd4_set_closestateid,
+		.op_set_currentstateid = nfsd4_set_closestateid,
 	},
 	[OP_COMMIT] = {
 		.op_func = (nfsd4op_func)nfsd4_commit,
@@ -2148,7 +2148,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LOCK",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_lock_rsize,
-		.op_set_currentstateid = (stateid_setter)nfsd4_set_lockstateid,
+		.op_set_currentstateid = nfsd4_set_lockstateid,
 	},
 	[OP_LOCKT] = {
 		.op_func = (nfsd4op_func)nfsd4_lockt,
@@ -2184,7 +2184,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_open_rsize,
-		.op_set_currentstateid = (stateid_setter)nfsd4_set_openstateid,
+		.op_set_currentstateid = nfsd4_set_openstateid,
 	},
 	[OP_OPEN_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_open_confirm,
@@ -2198,7 +2198,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_OPEN_DOWNGRADE",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
 		.op_get_currentstateid = (stateid_getter)nfsd4_get_opendowngradestateid,
-		.op_set_currentstateid = (stateid_setter)nfsd4_set_opendowngradestateid,
+		.op_set_currentstateid = nfsd4_set_opendowngradestateid,
 	},
 	[OP_PUTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putfh,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e9ef50addddb..4cf05b59ddf6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7116,27 +7116,31 @@ clear_current_stateid(struct nfsd4_compound_state *cstate)
  * functions to set current state id
  */
 void
-nfsd4_set_opendowngradestateid(struct nfsd4_compound_state *cstate, struct nfsd4_open_downgrade *odp)
+nfsd4_set_opendowngradestateid(struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
-	put_stateid(cstate, &odp->od_stateid);
+	put_stateid(cstate, &u->open_downgrade.od_stateid);
 }
 
 void
-nfsd4_set_openstateid(struct nfsd4_compound_state *cstate, struct nfsd4_open *open)
+nfsd4_set_openstateid(struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
-	put_stateid(cstate, &open->op_stateid);
+	put_stateid(cstate, &u->open.op_stateid);
 }
 
 void
-nfsd4_set_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
+nfsd4_set_closestateid(struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
-	put_stateid(cstate, &close->cl_stateid);
+	put_stateid(cstate, &u->close.cl_stateid);
 }
 
 void
-nfsd4_set_lockstateid(struct nfsd4_compound_state *cstate, struct nfsd4_lock *lock)
+nfsd4_set_lockstateid(struct nfsd4_compound_state *cstate,
+		union nfsd4_op_u *u)
 {
-	put_stateid(cstate, &lock->lk_resp_stateid);
+	put_stateid(cstate, &u->lock.lk_resp_stateid);
 }
 
 /*
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index eb7f9239304f..b625f4aa1061 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -539,7 +539,7 @@ struct nfsd4_seek {
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
-	union {
+	union nfsd4_op_u {
 		struct nfsd4_access		access;
 		struct nfsd4_close		close;
 		struct nfsd4_commit		commit;
-- 
2.11.0

