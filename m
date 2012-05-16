Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44931 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933337Ab2EPMso (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 08:48:44 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/11] nfsd4: move principal name into svc_cred
Date: Wed, 16 May 2012 08:48:37 -0400
Message-Id: <1337172519-17335-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1337172519-17335-1-git-send-email-bfields@redhat.com>
References: <1337172519-17335-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Instead of keeping the principal name associated with a request in a
structure that's private to auth_gss and using an accessor function,
move it to svc_cred.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/callback.c                  |    2 +-
 fs/nfsd/nfs4callback.c             |    5 +++--
 fs/nfsd/nfs4state.c                |   34 +++++++++++++++++-----------------
 fs/nfsd/state.h                    |    1 -
 include/linux/sunrpc/svcauth.h     |    9 +++++++++
 include/linux/sunrpc/svcauth_gss.h |    1 -
 net/sunrpc/auth_gss/svcauth_gss.c  |   25 ++++++-------------------
 net/sunrpc/svcauth_unix.c          |    2 ++
 8 files changed, 38 insertions(+), 41 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index cff3940..970659d 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -343,7 +343,7 @@ void nfs_callback_down(int minorversion)
 int
 check_gss_callback_principal(struct nfs_client *clp, struct svc_rqst *rqstp)
 {
-	char *p = svc_gss_principal(rqstp);
+	char *p = rqstp->rq_cred.cr_principal;
 
 	if (rqstp->rq_authop->flavour != RPC_AUTH_GSS)
 		return 1;
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c8e9f63..a5fd6b9 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -650,9 +650,10 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 	struct rpc_clnt *client;
 
 	if (clp->cl_minorversion == 0) {
-		if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
+		if (!clp->cl_cred.cr_principal &&
+				(clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
 			return -EINVAL;
-		args.client_name = clp->cl_principal;
+		args.client_name = clp->cl_cred.cr_principal;
 		args.prognumber	= conn->cb_prog,
 		args.protocol = XPRT_TRANSPORT_TCP;
 		args.authflavor = clp->cl_flavor;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e7f61d3..625ec80 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1050,9 +1050,7 @@ free_client(struct nfs4_client *clp)
 		list_del(&ses->se_perclnt);
 		nfsd4_put_session_locked(ses);
 	}
-	if (clp->cl_cred.cr_group_info)
-		put_group_info(clp->cl_cred.cr_group_info);
-	kfree(clp->cl_principal);
+	free_svc_cred(&clp->cl_cred);
 	kfree(clp->cl_name.data);
 	kfree(clp);
 }
@@ -1133,12 +1131,20 @@ static void copy_clid(struct nfs4_client *target, struct nfs4_client *source)
 	target->cl_clientid.cl_id = source->cl_clientid.cl_id; 
 }
 
-static void copy_cred(struct svc_cred *target, struct svc_cred *source)
+static int copy_cred(struct svc_cred *target, struct svc_cred *source)
 {
+	if (source->cr_principal) {
+		target->cr_principal =
+				kstrdup(source->cr_principal, GFP_KERNEL);
+		if (target->cr_principal == NULL)
+			return -ENOMEM;
+	} else
+		target->cr_principal = NULL;
 	target->cr_uid = source->cr_uid;
 	target->cr_gid = source->cr_gid;
 	target->cr_group_info = source->cr_group_info;
 	get_group_info(target->cr_group_info);
+	return 0;
 }
 
 static int same_name(const char *n1, const char *n2)
@@ -1205,25 +1211,20 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 {
 	struct nfs4_client *clp;
 	struct sockaddr *sa = svc_addr(rqstp);
-	char *princ;
+	int ret;
 
 	clp = alloc_client(name);
 	if (clp == NULL)
 		return NULL;
 
 	INIT_LIST_HEAD(&clp->cl_sessions);
-
-	princ = svc_gss_principal(rqstp);
-	if (princ) {
-		clp->cl_principal = kstrdup(princ, GFP_KERNEL);
-		if (clp->cl_principal == NULL) {
-			spin_lock(&client_lock);
-			free_client(clp);
-			spin_unlock(&client_lock);
-			return NULL;
-		}
+	ret = copy_cred(&clp->cl_cred, &rqstp->rq_cred);
+	if (ret) {
+		spin_lock(&client_lock);
+		free_client(clp);
+		spin_unlock(&client_lock);
+		return NULL;
 	}
-
 	idr_init(&clp->cl_stateids);
 	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
 	atomic_set(&clp->cl_refcount, 0);
@@ -1242,7 +1243,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	copy_verf(clp, verf);
 	rpc_copy_addr((struct sockaddr *) &clp->cl_addr, sa);
 	clp->cl_flavor = rqstp->rq_flavor;
-	copy_cred(&clp->cl_cred, &rqstp->rq_cred);
 	gen_confirm(clp);
 	clp->cl_cb_session = NULL;
 	return clp;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 89ab137..849091e 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -232,7 +232,6 @@ struct nfs4_client {
 	time_t                  cl_time;        /* time of last lease renewal */
 	struct sockaddr_storage	cl_addr; 	/* client ipaddress */
 	u32			cl_flavor;	/* setclientid pseudoflavor */
-	char			*cl_principal;	/* setclientid principal name */
 	struct svc_cred		cl_cred; 	/* setclientid principal */
 	clientid_t		cl_clientid;	/* generated by server */
 	nfs4_verifier		cl_confirm;	/* generated by server */
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index 2c54683..16fe477 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -15,13 +15,22 @@
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/cache.h>
 #include <linux/hash.h>
+#include <linux/cred.h>
 
 struct svc_cred {
 	uid_t			cr_uid;
 	gid_t			cr_gid;
 	struct group_info	*cr_group_info;
+	char			*cr_principal; /* for gss */
 };
 
+static inline void free_svc_cred(struct svc_cred *cred)
+{
+	if (cred->cr_group_info)
+		put_group_info(cred->cr_group_info);
+	kfree(cred->cr_principal);
+}
+
 struct svc_rqst;		/* forward decl */
 struct in6_addr;
 
diff --git a/include/linux/sunrpc/svcauth_gss.h b/include/linux/sunrpc/svcauth_gss.h
index 7c32daa..726aff1 100644
--- a/include/linux/sunrpc/svcauth_gss.h
+++ b/include/linux/sunrpc/svcauth_gss.h
@@ -22,7 +22,6 @@ int gss_svc_init_net(struct net *net);
 void gss_svc_shutdown_net(struct net *net);
 int svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name);
 u32 svcauth_gss_flavor(struct auth_domain *dom);
-char *svc_gss_principal(struct svc_rqst *);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_SVCAUTH_GSS_H */
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index f0a0cd4..d091d7d 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -335,7 +335,6 @@ struct rsc {
 	struct svc_cred		cred;
 	struct gss_svc_seq_data	seqdata;
 	struct gss_ctx		*mechctx;
-	char			*client_name;
 };
 
 static struct rsc *rsc_update(struct cache_detail *cd, struct rsc *new, struct rsc *old);
@@ -346,9 +345,7 @@ static void rsc_free(struct rsc *rsci)
 	kfree(rsci->handle.data);
 	if (rsci->mechctx)
 		gss_delete_sec_context(&rsci->mechctx);
-	if (rsci->cred.cr_group_info)
-		put_group_info(rsci->cred.cr_group_info);
-	kfree(rsci->client_name);
+	free_svc_cred(&rsci->cred);
 }
 
 static void rsc_put(struct kref *ref)
@@ -386,7 +383,7 @@ rsc_init(struct cache_head *cnew, struct cache_head *ctmp)
 	tmp->handle.data = NULL;
 	new->mechctx = NULL;
 	new->cred.cr_group_info = NULL;
-	new->client_name = NULL;
+	new->cred.cr_principal = NULL;
 }
 
 static void
@@ -401,8 +398,8 @@ update_rsc(struct cache_head *cnew, struct cache_head *ctmp)
 	spin_lock_init(&new->seqdata.sd_lock);
 	new->cred = tmp->cred;
 	tmp->cred.cr_group_info = NULL;
-	new->client_name = tmp->client_name;
-	tmp->client_name = NULL;
+	new->cred.cr_principal = tmp->cred.cr_principal;
+	tmp->cred.cr_principal = NULL;
 }
 
 static struct cache_head *
@@ -496,8 +493,8 @@ static int rsc_parse(struct cache_detail *cd,
 		/* get client name */
 		len = qword_get(&mesg, buf, mlen);
 		if (len > 0) {
-			rsci.client_name = kstrdup(buf, GFP_KERNEL);
-			if (!rsci.client_name)
+			rsci.cred.cr_principal = kstrdup(buf, GFP_KERNEL);
+			if (!rsci.cred.cr_principal)
 				goto out;
 		}
 
@@ -927,16 +924,6 @@ struct gss_svc_data {
 	struct rsc			*rsci;
 };
 
-char *svc_gss_principal(struct svc_rqst *rqstp)
-{
-	struct gss_svc_data *gd = (struct gss_svc_data *)rqstp->rq_auth_data;
-
-	if (gd && gd->rsci)
-		return gd->rsci->client_name;
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(svc_gss_principal);
-
 static int
 svcauth_gss_set_client(struct svc_rqst *rqstp)
 {
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 9c3b9f0..12e4897 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -740,6 +740,7 @@ svcauth_null_accept(struct svc_rqst *rqstp, __be32 *authp)
 	struct svc_cred	*cred = &rqstp->rq_cred;
 
 	cred->cr_group_info = NULL;
+	cred->cr_principal = NULL;
 	rqstp->rq_client = NULL;
 
 	if (argv->iov_len < 3*4)
@@ -805,6 +806,7 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 	int		len   = argv->iov_len;
 
 	cred->cr_group_info = NULL;
+	cred->cr_principal = NULL;
 	rqstp->rq_client = NULL;
 
 	if ((len -= 3*4) < 0)
-- 
1.7.9.5

