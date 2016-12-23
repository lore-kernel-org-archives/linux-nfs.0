Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:55108 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941308AbcLWQLD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:11:03 -0500
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/2] Use RPCSEC_GSS version 3
Date: Fri, 23 Dec 2016 11:09:26 -0500
Message-ID: <1482509367-22381-2-git-send-email-andros@netapp.com>
In-Reply-To: <1482509367-22381-1-git-send-email-andros@netapp.com>
References: <1482509367-22381-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

If that fails, fall back to version 1

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 autogen.sh           |  0
 src/auth_gss.c       | 16 ++++++++++++----
 tirpc/rpc/auth_gss.h | 10 ++++++++--
 3 files changed, 20 insertions(+), 6 deletions(-)
 mode change 100644 => 100755 autogen.sh

diff --git a/autogen.sh b/autogen.sh
old mode 100644
new mode 100755
diff --git a/src/auth_gss.c b/src/auth_gss.c
index cf96ada..5bb1685 100644
--- a/src/auth_gss.c
+++ b/src/auth_gss.c
@@ -156,9 +156,11 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
 	AUTH			*auth, *save_auth;
 	struct rpc_gss_data	*gd;
 	OM_uint32		min_stat = 0;
+	int			vers=RPCSEC_GSS3_VERSION;
 
 	gss_log_debug("in authgss_create()");
 
+retry_gssv1:
 	memset(&rpc_createerr, 0, sizeof(rpc_createerr));
 
 	if ((auth = calloc(sizeof(*auth), 1)) == NULL) {
@@ -190,7 +192,7 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
 	gd->ctx = GSS_C_NO_CONTEXT;
 	gd->sec = *sec;
 
-	gd->gc.gc_v = RPCSEC_GSS_VERSION;
+	gd->gc.gc_v = vers;
 	gd->gc.gc_proc = RPCSEC_GSS_INIT;
 	gd->gc.gc_svc = gd->sec.svc;
 
@@ -200,9 +202,14 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
 	save_auth = clnt->cl_auth;
 	clnt->cl_auth = auth;
 
-	if (!authgss_refresh(auth, NULL))
-		auth = NULL;
-	else
+	fprintf(stderr, "authgss_create CALLING authgss_refresh\n");
+	if (!authgss_refresh(auth, NULL)) {
+		if (vers == RPCSEC_GSS3_VERSION) {
+			vers = RPCSEC_GSS_VERSION;
+			goto retry_gssv1;
+		} else
+			auth = NULL;
+	} else
 		auth_get(auth); /* Reference for caller */
 
 	clnt->cl_auth = save_auth;
@@ -263,6 +270,7 @@ authgss_get_private_data(AUTH *auth, struct authgss_private_data *pd)
 	pd->pd_ctx = gd->ctx;
 	pd->pd_ctx_hndl = gd->gc.gc_ctx;
 	pd->pd_seq_win = gd->win;
+	pd->pd_gss_vers = gd->gc.gc_v;
 	/*
 	 * We've given this away -- don't try to use it ourself any more
 	 * Caller should call authgss_free_private_data to free data.
diff --git a/tirpc/rpc/auth_gss.h b/tirpc/rpc/auth_gss.h
index a17b34b..b662ac5 100644
--- a/tirpc/rpc/auth_gss.h
+++ b/tirpc/rpc/auth_gss.h
@@ -45,17 +45,22 @@ typedef enum {
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
 typedef enum {
 	RPCSEC_GSS_SVC_NONE = 1,
 	RPCSEC_GSS_SVC_INTEGRITY = 2,
-	RPCSEC_GSS_SVC_PRIVACY = 3
+	RPCSEC_GSS_SVC_PRIVACY = 3,
+	RPC_GSS_SVC_CHANNEL_PROT = 4	/* GSS2, not used */
 } rpc_gss_svc_t;
 
 #define RPCSEC_GSS_VERSION	1
+#define RPCSEC_GSS3_VERSION	3
 
 /* RPCSEC_GSS security triple. */
 struct rpc_gss_sec {
@@ -71,6 +76,7 @@ struct authgss_private_data {
 	gss_ctx_id_t	pd_ctx;		/* Session context handle */
 	gss_buffer_desc	pd_ctx_hndl;	/* Credentials context handle */
 	u_int		pd_seq_win;	/* Sequence window */
+	u_int		pd_gss_vers;	/* RPCSEC_GSS version */
 };
 
 #define g_OID_equal(o1, o2) \
-- 
1.8.3.1

