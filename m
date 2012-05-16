Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44935 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933390Ab2EPMso (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 08:48:44 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 11/11] nfsd4: move rq_flavor into svc_cred
Date: Wed, 16 May 2012 08:48:39 -0400
Message-Id: <1337172519-17335-12-git-send-email-bfields@redhat.com>
In-Reply-To: <1337172519-17335-1-git-send-email-bfields@redhat.com>
References: <1337172519-17335-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Move the rq_flavor into struct svc_cred, and use it in setclientid and
exchange_id comparisons as well.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/auth.c                    |    2 +-
 fs/nfsd/export.c                  |    6 +++---
 fs/nfsd/nfs4idmap.c               |    4 ++--
 fs/nfsd/nfs4state.c               |    6 +++---
 include/linux/sunrpc/svc.h        |    1 -
 include/linux/sunrpc/svcauth.h    |    1 +
 net/sunrpc/auth_gss/svcauth_gss.c |    2 +-
 net/sunrpc/svcauth_unix.c         |    4 ++--
 8 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index 79717a4..b42eaf3 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -10,7 +10,7 @@ int nfsexp_flags(struct svc_rqst *rqstp, struct svc_export *exp)
 	struct exp_flavor_info *end = exp->ex_flavors + exp->ex_nflavors;
 
 	for (f = exp->ex_flavors; f < end; f++) {
-		if (f->pseudoflavor == rqstp->rq_flavor)
+		if (f->pseudoflavor == rqstp->rq_cred.cr_flavor)
 			return f->flags;
 	}
 	return exp->ex_flags;
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index ec16364..ba23349 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -904,13 +904,13 @@ __be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp)
 		return 0;
 	/* ip-address based client; check sec= export option: */
 	for (f = exp->ex_flavors; f < end; f++) {
-		if (f->pseudoflavor == rqstp->rq_flavor)
+		if (f->pseudoflavor == rqstp->rq_cred.cr_flavor)
 			return 0;
 	}
 	/* defaults in absence of sec= options: */
 	if (exp->ex_nflavors == 0) {
-		if (rqstp->rq_flavor == RPC_AUTH_NULL ||
-		    rqstp->rq_flavor == RPC_AUTH_UNIX)
+		if (rqstp->rq_cred.cr_flavor == RPC_AUTH_NULL ||
+		    rqstp->rq_cred.cr_flavor == RPC_AUTH_UNIX)
 			return 0;
 	}
 	return nfserr_wrongsec;
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 286a7f8..dae36f1 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -605,7 +605,7 @@ numeric_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namel
 static __be32
 do_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, uid_t *id)
 {
-	if (nfs4_disable_idmapping && rqstp->rq_flavor < RPC_AUTH_GSS)
+	if (nfs4_disable_idmapping && rqstp->rq_cred.cr_flavor < RPC_AUTH_GSS)
 		if (numeric_name_to_id(rqstp, type, name, namelen, id))
 			return 0;
 		/*
@@ -618,7 +618,7 @@ do_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, u
 static int
 do_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
 {
-	if (nfs4_disable_idmapping && rqstp->rq_flavor < RPC_AUTH_GSS)
+	if (nfs4_disable_idmapping && rqstp->rq_cred.cr_flavor < RPC_AUTH_GSS)
 		return sprintf(name, "%u", id);
 	return idmap_id_to_name(rqstp, type, id, name);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f6d2a55..3a8c2df 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1140,6 +1140,7 @@ static int copy_cred(struct svc_cred *target, struct svc_cred *source)
 			return -ENOMEM;
 	} else
 		target->cr_principal = NULL;
+	target->cr_flavor = source->cr_flavor;
 	target->cr_uid = source->cr_uid;
 	target->cr_gid = source->cr_gid;
 	target->cr_group_info = source->cr_group_info;
@@ -1176,11 +1177,11 @@ static bool groups_equal(struct group_info *g1, struct group_info *g2)
 	return true;
 }
 
-/* XXX what about NGROUP */
 static int
 same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
 {
-	if ((cr1->cr_uid != cr2->cr_uid)
+	if ((cr1->cr_flavor != cr2->cr_flavor)
+		|| (cr1->cr_uid != cr2->cr_uid)
 		|| (cr1->cr_gid != cr2->cr_gid)
 		|| !groups_equal(cr1->cr_group_info, cr2->cr_group_info))
 		return false;
@@ -1262,7 +1263,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
 	copy_verf(clp, verf);
 	rpc_copy_addr((struct sockaddr *) &clp->cl_addr, sa);
-	clp->cl_flavor = rqstp->rq_flavor;
 	gen_confirm(clp);
 	clp->cl_cb_session = NULL;
 	return clp;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 2b43e02..40e0a27 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -232,7 +232,6 @@ struct svc_rqst {
 	struct svc_pool *	rq_pool;	/* thread pool */
 	struct svc_procedure *	rq_procinfo;	/* procedure info */
 	struct auth_ops *	rq_authop;	/* authentication flavour */
-	u32			rq_flavor;	/* pseudoflavor */
 	struct svc_cred		rq_cred;	/* auth info */
 	void *			rq_xprt_ctxt;	/* transport specific context ptr */
 	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index 16fe477..dd74084 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -21,6 +21,7 @@ struct svc_cred {
 	uid_t			cr_uid;
 	gid_t			cr_gid;
 	struct group_info	*cr_group_info;
+	u32			cr_flavor; /* pseudoflavor */
 	char			*cr_principal; /* for gss */
 };
 
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index d091d7d..bcb7737 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1202,7 +1202,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 		}
 		svcdata->rsci = rsci;
 		cache_get(&rsci->h);
-		rqstp->rq_flavor = gss_svc_to_pseudoflavor(
+		rqstp->rq_cred.cr_flavor = gss_svc_to_pseudoflavor(
 					rsci->mechctx->mech_type, gc->gc_svc);
 		ret = SVC_OK;
 		goto out;
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 12e4897..88962cf 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -768,7 +768,7 @@ svcauth_null_accept(struct svc_rqst *rqstp, __be32 *authp)
 	svc_putnl(resv, RPC_AUTH_NULL);
 	svc_putnl(resv, 0);
 
-	rqstp->rq_flavor = RPC_AUTH_NULL;
+	rqstp->rq_cred.cr_flavor = RPC_AUTH_NULL;
 	return SVC_OK;
 }
 
@@ -839,7 +839,7 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 	svc_putnl(resv, RPC_AUTH_NULL);
 	svc_putnl(resv, 0);
 
-	rqstp->rq_flavor = RPC_AUTH_UNIX;
+	rqstp->rq_cred.cr_flavor = RPC_AUTH_UNIX;
 	return SVC_OK;
 
 badcred:
-- 
1.7.9.5

