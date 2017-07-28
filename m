Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:48581 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752910AbdG1UuK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:50:10 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <anna.schumaker@netapp.com>, <olga.kornievskaia@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 1/2] Use RPCSEC_GSS version 3
Date: Fri, 28 Jul 2017 16:49:59 -0400
Message-ID: <1501275000-24236-2-git-send-email-andros@netapp.com>
In-Reply-To: <1501275000-24236-1-git-send-email-andros@netapp.com>
References: <1501275000-24236-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Pass gss version to authgss_create
If version 3 fails, fall back to version 1

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 autogen.sh           |  0
 src/auth_gss.c       | 19 +++++++++++++++----
 tirpc/rpc/auth_gss.h |  8 +++++++-
 3 files changed, 22 insertions(+), 5 deletions(-)
 mode change 100644 => 100755 autogen.sh

diff --git a/autogen.sh b/autogen.sh
old mode 100644
new mode 100755
diff --git a/src/auth_gss.c b/src/auth_gss.c
index cf96ada..8f3da2c 100644
--- a/src/auth_gss.c
+++ b/src/auth_gss.c
@@ -132,6 +132,7 @@ char *p;
 	fprintf(stderr, "     qop: %d\n", ptr->qop);
 	fprintf(stderr, "     service: %d\n", ptr->svc);
 	fprintf(stderr, "     cred: %p\n", ptr->cred);
+	fprintf(stderr, "     gss version: %d\n", ptr->gss_vers);
 }
 
 struct rpc_gss_data {
@@ -156,9 +157,14 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
 	AUTH			*auth, *save_auth;
 	struct rpc_gss_data	*gd;
 	OM_uint32		min_stat = 0;
+	int                     vers;
 
 	gss_log_debug("in authgss_create()");
 
+	/* Old gssd versions do not set gss_vers */
+	vers = sec->gss_vers == 0 ? RPCSEC_GSS_VERSION : sec->gss_vers;
+
+retry_gssv1:
 	memset(&rpc_createerr, 0, sizeof(rpc_createerr));
 
 	if ((auth = calloc(sizeof(*auth), 1)) == NULL) {
@@ -190,7 +196,7 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
 	gd->ctx = GSS_C_NO_CONTEXT;
 	gd->sec = *sec;
 
-	gd->gc.gc_v = RPCSEC_GSS_VERSION;
+	gd->gc.gc_v = vers;
 	gd->gc.gc_proc = RPCSEC_GSS_INIT;
 	gd->gc.gc_svc = gd->sec.svc;
 
@@ -200,9 +206,13 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
 	save_auth = clnt->cl_auth;
 	clnt->cl_auth = auth;
 
-	if (!authgss_refresh(auth, NULL))
-		auth = NULL;
-	else
+	if (!authgss_refresh(auth, NULL)) {
+		if (vers == RPCSEC_GSS3_VERSION) {
+			vers = RPCSEC_GSS_VERSION;
+			goto retry_gssv1;
+		} else
+			auth = NULL;
+	} else
 		auth_get(auth); /* Reference for caller */
 
 	clnt->cl_auth = save_auth;
@@ -263,6 +273,7 @@ authgss_get_private_data(AUTH *auth, struct authgss_private_data *pd)
 	pd->pd_ctx = gd->ctx;
 	pd->pd_ctx_hndl = gd->gc.gc_ctx;
 	pd->pd_seq_win = gd->win;
+	pd->pd_gss_vers = gd->gc.gc_v;
 	/*
 	 * We've given this away -- don't try to use it ourself any more
 	 * Caller should call authgss_free_private_data to free data.
diff --git a/tirpc/rpc/auth_gss.h b/tirpc/rpc/auth_gss.h
index a17b34b..a311e08 100644
--- a/tirpc/rpc/auth_gss.h
+++ b/tirpc/rpc/auth_gss.h
@@ -45,7 +45,10 @@ typedef enum {
 	RPCSEC_GSS_DATA = 0,
 	RPCSEC_GSS_INIT = 1,
 	RPCSEC_GSS_CONTINUE_INIT = 2,
-	RPCSEC_GSS_DESTROY = 3
+	RPCSEC_GSS_DESTROY = 3,
+	RPCSEC_GSS_BIND_CHANNEL = 4,	/* GSSv2, not used */
+	RPCSEC_GSS_CREATE = 5,		/* GSSv3 */
+	RPCSEC_GSS_LIST = 6		/* GSSv3 */
 } rpc_gss_proc_t;
 
 /* RPCSEC_GSS services. */
@@ -56,6 +59,7 @@ typedef enum {
 } rpc_gss_svc_t;
 
 #define RPCSEC_GSS_VERSION	1
+#define RPCSEC_GSS3_VERSION	3
 
 /* RPCSEC_GSS security triple. */
 struct rpc_gss_sec {
@@ -64,6 +68,7 @@ struct rpc_gss_sec {
 	rpc_gss_svc_t	svc;		/* service */
 	gss_cred_id_t	cred;		/* cred handle */
 	u_int		req_flags;	/* req flags for init_sec_context */
+	int		gss_vers;	/* highest supported gss version */
 };
 
 /* Private data required for kernel implementation */
@@ -71,6 +76,7 @@ struct authgss_private_data {
 	gss_ctx_id_t	pd_ctx;		/* Session context handle */
 	gss_buffer_desc	pd_ctx_hndl;	/* Credentials context handle */
 	u_int		pd_seq_win;	/* Sequence window */
+	u_int		pd_gss_vers;	/* RPCSEC_GSS version */
 };
 
 #define g_OID_equal(o1, o2) \
-- 
1.8.3.1

