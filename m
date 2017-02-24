Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:5704 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751380AbdBXWUc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:32 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 16/17] SUNRPC SVCAUTH_GSS set gss3 label on nfsd thread
Date: Fri, 24 Feb 2017 17:19:52 -0500
Message-ID: <20170224221953.5502-17-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Note: will need to give nfsd selinux authority to change thread label.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/auth.c                    | 11 ++++++++++-
 include/linux/sunrpc/svcauth.h    |  1 +
 net/sunrpc/auth_gss/svcauth_gss.c | 41 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 52 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index 62469c6..0330fe9 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -1,6 +1,7 @@
 /* Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de> */
 
 #include <linux/sched.h>
+#include <linux/selinux.h>
 #include "nfsd.h"
 #include "auth.h"
 
@@ -22,7 +23,7 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 	struct group_info *rqgi;
 	struct group_info *gi;
 	struct cred *new;
-	int i;
+	int i, ret;
 	int flags = nfsexp_flags(rqstp, exp);
 
 	validate_process_creds();
@@ -77,6 +78,14 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 	else
 		new->cap_effective = cap_raise_nfsd_set(new->cap_effective,
 							new->cap_permitted);
+
+	if (selinux_is_enabled() && rqstp->rq_authop->set_label &&
+	    (exp->ex_flags & NFSEXP_SECURITY_LABEL)) {
+		ret = rqstp->rq_authop->set_label(rqstp, new);
+		if (ret < 0)
+			/* Should nfsd fail this request? */
+			pr_warn("%s set_label FAILED  ret %d\n", __func__, ret);
+	}
 	validate_process_creds();
 	put_cred(override_creds(new));
 	put_cred(new);
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index d039320..eed6880 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -128,6 +128,7 @@ struct auth_ops {
 	int	(*release)(struct svc_rqst *rq);
 	void	(*domain_release)(struct auth_domain *);
 	int	(*set_client)(struct svc_rqst *rq);
+	int	(*set_label)(struct svc_rqst *rq, struct cred *new);
 };
 
 #define	SVC_GARBAGE	1
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index bd7ceab..f4c4ea1 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1068,6 +1068,46 @@ svcauth_gss_set_client(struct svc_rqst *rqstp)
 	return SVC_OK;
 }
 
+/**
+ * the svcdata->rsci pointer is the parent context.
+ * the svcdata->cl_cred->gc_ctx may hold the child context handle
+ * assume one GSS3_LABEL per child context.
+ */
+static int
+svcauth_gss_set_label(struct svc_rqst *rqstp, struct cred *new)
+{
+	struct gss_svc_data *svcdata = rqstp->rq_auth_data;
+	struct rpc_gss_wire_cred *gc = &svcdata->clcred;
+	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net,
+						sunrpc_net_id);
+	struct rsc *rsci;
+	struct gss3_svc_assert *g3a;
+	struct gss3_label *g3l;
+	int ret = -1;
+
+	rsci = gss_svc_searchbyctx(sn->rsc_cache, &gc->gc_ctx);
+	if (!rsci)
+		goto out;
+
+	if (rsci->parent_handle.len == 0 || !rsci->assertions)
+		goto out_put;
+
+	g3a = rsci->assertions;
+	g3l = &g3a->sa_assert.u.au_label;
+
+	if (g3a->sa_num != 1 || g3a->sa_assert.au_type != GSS3_LABEL ||
+	    g3l->la_label.len == 0)
+		goto out_put;
+
+	/* Assume SeLinux - need to validate la_lfs and la_pi ? */
+	ret = set_security_override_from_ctx(new, (char *)g3l->la_label.data);
+
+out_put:
+	cache_put(&rsci->h, sn->rsc_cache);
+out:
+	return ret;
+}
+
 static inline int
 gss_write_init_verf(struct cache_detail *cd, struct svc_rqst *rqstp,
 		    struct rpc_gss_wire_cred *gc,
@@ -2110,6 +2150,7 @@ static struct auth_ops svcauthops_gss = {
 	.release	= svcauth_gss_release,
 	.domain_release = svcauth_gss_domain_release,
 	.set_client	= svcauth_gss_set_client,
+	.set_label	= svcauth_gss_set_label,
 };
 
 static int rsi_cache_create_net(struct net *net)
-- 
2.9.3

