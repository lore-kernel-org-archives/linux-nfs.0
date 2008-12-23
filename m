From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 66/69] rpc: allow gss callbacks to client
Date: Tue, 23 Dec 2008 18:02:26 -0500
Message-ID: <20081223230226.13743.85492.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1640 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752847AbYLWXYn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:43 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOcSq021557
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

This patch adds client-side support to allow for callbacks other than
AUTH_SYS.

Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/callback.c                 |   36 +++++++++++++++++++++++++++++++-----
 net/sunrpc/auth_gss/svcauth_gss.c |    1 +
 2 files changed, 32 insertions(+), 5 deletions(-)


diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index c2e9cfd..3e634f2 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -16,6 +16,7 @@
 #include <linux/mutex.h>
 #include <linux/freezer.h>
 #include <linux/kthread.h>
+#include <linux/sunrpc/svcauth_gss.h>
 
 #include <net/inet_sock.h>
 
@@ -182,10 +183,34 @@ void nfs_callback_down(void)
 	mutex_unlock(&nfs_callback_mutex);
 }
 
+static int check_gss_callback_principal(struct nfs_client *clp,
+					struct svc_rqst *rqstp)
+{
+	struct rpc_clnt *r = clp->cl_rpcclient;
+	char *p = svc_gss_principal(rqstp);
+
+	/*
+	 * It might just be a normal user principal, in which case
+	 * userspace won't bother to tell us the name at all.
+	 */
+	if (p == NULL)
+		return SVC_DENIED;
+
+	/* Expect a GSS_C_NT_HOSTBASED_NAME like "nfs@serverhostname" */
+
+	if (memcmp(p, "nfs@", 4) != 0)
+		return SVC_DENIED;
+	p += 4;
+	if (strcmp(p, r->cl_server) != 0)
+		return SVC_DENIED;
+	return SVC_OK;
+}
+
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
 	struct nfs_client *clp;
 	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
+	int ret = SVC_OK;
 
 	/* Don't talk to strangers */
 	clp = nfs_find_client(svc_addr(rqstp), 4);
@@ -194,21 +219,22 @@ static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 
 	dprintk("%s: %s NFSv4 callback!\n", __func__,
 			svc_print_addr(rqstp, buf, sizeof(buf)));
-	nfs_put_client(clp);
 
 	switch (rqstp->rq_authop->flavour) {
 		case RPC_AUTH_NULL:
 			if (rqstp->rq_proc != CB_NULL)
-				return SVC_DENIED;
+				ret = SVC_DENIED;
 			break;
 		case RPC_AUTH_UNIX:
 			break;
 		case RPC_AUTH_GSS:
-			/* FIXME: RPCSEC_GSS handling? */
+			ret = check_gss_callback_principal(clp, rqstp);
+			break;
 		default:
-			return SVC_DENIED;
+			ret = SVC_DENIED;
 	}
-	return SVC_OK;
+	nfs_put_client(clp);
+	return ret;
 }
 
 /*
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index e9baa6e..2278a50 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -935,6 +935,7 @@ char *svc_gss_principal(struct svc_rqst *rqstp)
 		return gd->rsci->client_name;
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(svc_gss_principal);
 
 static int
 svcauth_gss_set_client(struct svc_rqst *rqstp)

