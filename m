Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5406 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756099Ab2DQOIS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 10:08:18 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q3HE8HKh007561
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2012 10:08:18 -0400
From: Simo Sorce <simo@redhat.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 5/5] SUNRPC: Use gssproxy upcall for nfsd's RPCGSS authentication.
Date: Tue, 17 Apr 2012 09:39:08 -0400
Message-Id: <1334669948-4156-6-git-send-email-simo@redhat.com>
In-Reply-To: <1334669948-4156-1-git-send-email-simo@redhat.com>
References: <1334669948-4156-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The main advantge of this new upcall mechanism is that it can handle
big tickets as seen in Kerberos implementations where tickets carry
authorization data like the MS-PAC buffer with AD or the Posix Authorization
Data being discussed in IETF on the krbwg working group.

The Gssproxy program is used to perform the accept_sec_context call on the
kernel's behalf. The code is changed to also pass the input buffer straight
to upcall mechanism to avoid allocating and copying many pages as tokens can
be as big (potentially more in future) as 64KiB.

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 include/linux/sunrpc/auth_gss.h    |    3 +
 include/linux/sunrpc/svcauth_gss.h |    2 +-
 net/sunrpc/auth_gss/auth_gss.c     |    9 +-
 net/sunrpc/auth_gss/svcauth_gss.c  |  249 ++++++++++++++++++++++++++++++++++--
 4 files changed, 248 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index f1cfd4c85cd047c4b2fadd367eeb819aabc57d29..eb2670f6cf9113f1b4c161b9deda05ee4757fa85 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -19,6 +19,9 @@
 
 #define RPC_GSS_VERSION		1
 
+#define GSS_UPCALL_LEGACY	0
+#define GSS_UPCALL_GSSPROXY	1
+
 #define MAXSEQ 0x80000000 /* maximum legal sequence number, from rfc 2203 */
 
 enum rpc_gss_proc {
diff --git a/include/linux/sunrpc/svcauth_gss.h b/include/linux/sunrpc/svcauth_gss.h
index 7c32daa025eb07b644d8185a27c8ea10d8b7c55f..678c6fc8f1593bc53bc3d875175ed7098cd4db40 100644
--- a/include/linux/sunrpc/svcauth_gss.h
+++ b/include/linux/sunrpc/svcauth_gss.h
@@ -16,7 +16,7 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/auth_gss.h>
 
-int gss_svc_init(void);
+int gss_svc_init(unsigned int upcall_type);
 void gss_svc_shutdown(void);
 int gss_svc_init_net(struct net *net);
 void gss_svc_shutdown_net(struct net *net);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 836cbecb1947235d38c62eadf79ae96ad73906e6..97fe72609387cb8b948bc3aa4d14db4956138d3c 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -60,6 +60,8 @@ static const struct rpc_credops gss_nullops;
 #define GSS_RETRY_EXPIRED 5
 static unsigned int gss_expired_cred_retry_delay = GSS_RETRY_EXPIRED;
 
+static unsigned int gss_upcall_daemon_type = GSS_UPCALL_LEGACY;
+
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
@@ -1687,7 +1689,7 @@ static int __init init_rpcsec_gss(void)
 	err = rpcauth_register(&authgss_ops);
 	if (err)
 		goto out;
-	err = gss_svc_init();
+	err = gss_svc_init(gss_upcall_daemon_type);
 	if (err)
 		goto out_unregister;
 	err = register_pernet_subsys(&rpcsec_gss_net_ops);
@@ -1717,6 +1719,11 @@ module_param_named(expired_cred_retry_delay,
 		   uint, 0644);
 MODULE_PARM_DESC(expired_cred_retry_delay, "Timeout (in seconds) until "
 		"the RPC engine retries an expired credential");
+module_param_named(upcall_daemon_type,
+		   gss_upcall_daemon_type,
+		   uint, 0644);
+MODULE_PARM_DESC(upcall_daemon_type, "Type of svcgss upcall daemon used "
+		"(legacy=0 or gssproxy=1)");
 
 module_init(init_rpcsec_gss)
 module_exit(exit_rpcsec_gss)
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index aa1b649749741c82e60f0f528ac645197fd7ab35..87dcc837fa10e8ee7176379b1cc27235800bd612 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -47,6 +47,7 @@
 #include <linux/sunrpc/svcauth.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/cache.h>
+#include "gss_rpc_upcall.h"
 
 #include "../netns.h"
 
@@ -54,6 +55,8 @@
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
+static bool use_gssp = false;
+
 /* The rpcsec_init cache is used for mapping RPCSEC_GSS_{,CONT_}INIT requests
  * into replies.
  *
@@ -554,6 +557,7 @@ static struct rsc *rsc_update(struct cache_detail *cd, struct rsc *new, struct r
 }
 
 
+
 static struct rsc *
 gss_svc_searchbyctx(struct cache_detail *cd, struct xdr_netobj *handle)
 {
@@ -984,13 +988,10 @@ gss_write_init_verf(struct cache_detail *cd, struct svc_rqst *rqstp,
 }
 
 static inline int
-gss_read_verf(struct rpc_gss_wire_cred *gc,
-	      struct kvec *argv, __be32 *authp,
-	      struct xdr_netobj *in_handle,
-	      struct xdr_netobj *in_token)
+gss_read_common_verf(struct rpc_gss_wire_cred *gc,
+		     struct kvec *argv, __be32 *authp,
+		     struct xdr_netobj *in_handle)
 {
-	struct xdr_netobj tmpobj;
-
 	/* Read the verifier; should be NULL: */
 	*authp = rpc_autherr_badverf;
 	if (argv->iov_len < 2 * 4)
@@ -1006,6 +1007,23 @@ gss_read_verf(struct rpc_gss_wire_cred *gc,
 	if (dup_netobj(in_handle, &gc->gc_ctx))
 		return SVC_CLOSE;
 	*authp = rpc_autherr_badverf;
+
+	return 0;
+}
+
+static inline int
+gss_read_verf(struct rpc_gss_wire_cred *gc,
+	      struct kvec *argv, __be32 *authp,
+	      struct xdr_netobj *in_handle,
+	      struct xdr_netobj *in_token)
+{
+	struct xdr_netobj tmpobj;
+	int res;
+
+	res = gss_read_common_verf(gc, argv, authp, in_handle);
+	if (res)
+		return res;
+
 	if (svc_safe_getnetobj(argv, &tmpobj)) {
 		kfree(in_handle->data);
 		return SVC_DENIED;
@@ -1018,6 +1036,42 @@ gss_read_verf(struct rpc_gss_wire_cred *gc,
 	return 0;
 }
 
+/* Ok this is really heavily depending on a set of semantics in
+ * how rqstp is set up by svc_recv and pages laid down by the
+ * server when reading a request. We are basically guaranteed that
+ * the token lays all down linearly across a set of pages, starting
+ * at iov_base in rq_arg.head[0] which happens to be the first of a
+ * set of pages stored in rq_pages[].
+ * rq_arg.head[0].iov_base will provide us the page_base to pass
+ * to the upcall.
+ */
+static inline int
+gss_read_proxy_verf(struct svc_rqst *rqstp,
+		    struct rpc_gss_wire_cred *gc, __be32 *authp,
+		    struct xdr_netobj *in_handle,
+		    struct gssp_in_token *in_token)
+{
+	struct kvec *argv = &rqstp->rq_arg.head[0];
+	u32 inlen;
+	int res;
+
+	res = gss_read_common_verf(gc, argv, authp, in_handle);
+	if (res)
+		return res;
+
+	inlen = svc_getnl(argv);
+	if (inlen > (argv->iov_len + rqstp->rq_arg.page_len))
+		return SVC_DENIED;
+
+	in_token->pages = rqstp->rq_pages;
+	in_token->page_base = (ulong)argv->iov_base & ~PAGE_MASK;
+	in_token->page_len = inlen;
+
+	/* FIXME: change argv to point to the end of in_token ? */
+
+	return 0;
+}
+
 static inline int
 gss_write_resv(struct kvec *resv, size_t size_limit,
 	       struct xdr_netobj *out_handle, struct xdr_netobj *out_token,
@@ -1045,7 +1099,7 @@ gss_write_resv(struct kvec *resv, size_t size_limit,
  * the upcall results are available, write the verifier and result.
  * Otherwise, drop the request pending an answer to the upcall.
  */
-static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
+static int svcauth_gss_legacy_init(struct svc_rqst *rqstp,
 			struct rpc_gss_wire_cred *gc, __be32 *authp)
 {
 	struct kvec *argv = &rqstp->rq_arg.head[0];
@@ -1085,6 +1139,158 @@ out:
 	return ret;
 }
 
+static int gss_proxy_save_rsc(struct cache_detail *cd,
+				struct gssp_upcall_data *ud,
+				struct xdr_netobj *handle)
+{
+	struct rsc rsci, *rscp = NULL;
+	static atomic64_t ctxhctr;
+	long long ctxh;
+	struct gss_api_mech *gm = NULL;
+	time_t expiry;
+	char *c;
+	int status = -EINVAL;
+
+	memset(&rsci, 0, sizeof(rsci));
+	/* context handle */
+	status = -ENOMEM;
+	/* the handle needs to be just a unique id,
+	 * use a static counter */
+	ctxh = atomic64_inc_return(&ctxhctr);
+	handle->data = kmemdup(&ctxh, sizeof(ctxh), GFP_KERNEL);
+	if (handle->data == NULL)
+		goto out;
+	handle->len = sizeof(ctxh);
+	if (dup_to_netobj(&rsci.handle, handle->data, handle->len))
+		goto out;
+
+	rscp = rsc_lookup(cd, &rsci);
+	if (!rscp)
+		goto out;
+
+	/* creds */
+	if (!ud->creds) {
+		dprintk("RPC:       No creds found, marking Negative!\n");
+		set_bit(CACHE_NEGATIVE, &rsci.h.flags);
+	} else {
+
+		/* steal creds */
+		rsci.cred = *ud->creds;
+		ud->creds->cr_group_info = NULL;
+
+		status = -EOPNOTSUPP;
+		/* get mech handle from OID */
+		gm = gss_mech_get_by_OID(&ud->mech_oid);
+		if (!gm)
+			goto out;
+
+		status = -EINVAL;
+		/* mech-specific data: */
+		status = gss_import_sec_context(ud->out_handle.data,
+						ud->out_handle.len,
+						gm, &rsci.mechctx,
+						&expiry, GFP_KERNEL);
+		if (status)
+			goto out;
+
+		/* get client name */
+		if (ud->client_name.len != 0) {
+			status = -ENOMEM;
+			/* convert to GSS_NT_HOSTBASED_SERVICE form */
+			rsci.client_name = kstrndup(ud->client_name.data,
+							ud->client_name.len,
+							GFP_KERNEL);
+			if (!rsci.client_name)
+				goto out;
+			/* terminate and remove realm part */
+			c = strchr(rsci.client_name, '@');
+			if (c) {
+				*c = '\0';
+
+				/* change service-hostname delimiter */
+				c = strchr(rsci.client_name, '/');
+				if (c) *c = '@';
+			}
+			if (!c) {
+				/* not a service principal */
+				kfree(rsci.client_name);
+				rsci.client_name = NULL;
+			}
+		}
+	}
+
+	rsci.h.expiry_time = expiry;
+	rscp = rsc_update(cd, &rsci, rscp);
+	status = 0;
+out:
+	gss_mech_put(gm);
+	rsc_free(&rsci);
+	if (rscp)
+		cache_put(&rscp->h, cd);
+	else
+		status = -ENOMEM;
+	return status;
+}
+
+static int svcauth_gss_proxy_init(struct svc_rqst *rqstp,
+			struct rpc_gss_wire_cred *gc, __be32 *authp)
+{
+	struct kvec *resv = &rqstp->rq_res.head[0];
+	struct xdr_netobj cli_handle;
+	struct gssp_upcall_data ud;
+	int status;
+	int ret;
+	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);
+
+	memset(&cli_handle, 0, sizeof(cli_handle));
+	memset(&ud, 0, sizeof(ud));
+	ret = gss_read_proxy_verf(rqstp, gc, authp,
+				  &ud.in_handle, &ud.in_token);
+	if (ret)
+		return ret;
+
+	ret = SVC_CLOSE;
+
+	/* Perform synchronous upcall to gss-proxy */
+	status = gssp_accept_sec_context_upcall(&ud);
+	if (status) {
+		goto out;
+	}
+
+	dprintk("RPC:       svcauth_gss: gss major status = %d\n",
+			ud.major_status);
+
+	switch (ud.major_status) {
+	case GSS_S_CONTINUE_NEEDED:
+		cli_handle = ud.out_handle;
+		ud.out_handle.data = NULL;
+		break;
+	case GSS_S_COMPLETE:
+		status = gss_proxy_save_rsc(sn->rsc_cache, &ud, &cli_handle);
+		if (status)
+			goto out;
+		break;
+	default:
+		ret = SVC_CLOSE;
+		goto out;
+	}
+
+	/* Got an answer to the upcall; use it: */
+	if (gss_write_init_verf(sn->rsc_cache, rqstp,
+				&cli_handle, &ud.major_status))
+		goto out;
+	if (gss_write_resv(resv, PAGE_SIZE,
+			   &cli_handle, &ud.out_token,
+			   ud.major_status, ud.minor_status))
+		goto out;
+
+	ret = SVC_COMPLETE;
+out:
+	gssp_free_upcall_data(&ud);
+	kfree(cli_handle.data);
+	return ret;
+}
+
 /*
  * Accept an rpcsec packet.
  * If context establishment, punt to user space
@@ -1151,7 +1357,10 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	switch (gc->gc_proc) {
 	case RPC_GSS_PROC_INIT:
 	case RPC_GSS_PROC_CONTINUE_INIT:
-		return svcauth_gss_handle_init(rqstp, gc, authp);
+		if (use_gssp)
+			return svcauth_gss_proxy_init(rqstp, gc, authp);
+		else
+			return svcauth_gss_legacy_init(rqstp, gc, authp);
 	case RPC_GSS_PROC_DATA:
 	case RPC_GSS_PROC_DESTROY:
 		/* Look up the context, and check the verifier: */
@@ -1523,9 +1732,12 @@ gss_svc_init_net(struct net *net)
 	rv = rsc_cache_create_net(net);
 	if (rv)
 		return rv;
-	rv = rsi_cache_create_net(net);
-	if (rv)
-		goto out1;
+	if (!use_gssp) {
+		rv = rsi_cache_create_net(net);
+		if (rv)
+			goto out1;
+	}
+
 	return 0;
 out1:
 	rsc_cache_destroy_net(net);
@@ -1535,13 +1747,24 @@ out1:
 void
 gss_svc_shutdown_net(struct net *net)
 {
-	rsi_cache_destroy_net(net);
+	if (!use_gssp)
+		rsi_cache_destroy_net(net);
 	rsc_cache_destroy_net(net);
 }
 
 int
-gss_svc_init(void)
+gss_svc_init(unsigned int upcall_type)
 {
+	switch (upcall_type) {
+	case GSS_UPCALL_LEGACY:
+		break;
+	case GSS_UPCALL_GSSPROXY:
+		dprintk("RPC:       svcauth_gss: Initializing for use with gss-proxy\n");
+		use_gssp = true;
+		break;
+	default:
+		return -EINVAL;
+	}
 	return svc_auth_register(RPC_AUTH_GSS, &svcauthops_gss);
 }
 
-- 
1.7.7.6

