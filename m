Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28756 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753513AbaGOPJr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:47 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 05/15] git_log_status: Add function names to status message
Date: Tue, 15 Jul 2014 11:09:24 -0400
Message-Id: <1405436974-4161-6-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added the calling function name to the status message to
identify where the message is coming from.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/auth_gss.c     | 15 ++++++++++-----
 src/authgss_prot.c |  9 ++++++---
 src/svc_auth_gss.c | 27 ++++++++++++++++++---------
 3 files changed, 34 insertions(+), 17 deletions(-)

diff --git a/src/auth_gss.c b/src/auth_gss.c
index e36f5d9..76bab66 100644
--- a/src/auth_gss.c
+++ b/src/auth_gss.c
@@ -225,7 +225,8 @@ authgss_create_default(CLIENT *clnt, char *service, struct rpc_gss_sec *sec)
 		&name);
 
 	if (maj_stat != GSS_S_COMPLETE) {
-		gss_log_status("gss_import_name", maj_stat, min_stat);
+		gss_log_status("authgss_create_default: gss_import_name", 
+			maj_stat, min_stat);
 		rpc_createerr.cf_stat = RPC_AUTHERROR;
 		return (NULL);
 	}
@@ -344,7 +345,8 @@ authgss_marshal(AUTH *auth, XDR *xdrs)
 			    &rpcbuf, &checksum);
 
 	if (maj_stat != GSS_S_COMPLETE) {
-		gss_log_status("gss_get_mic", maj_stat, min_stat);
+		gss_log_status("authgss_marshal: gss_get_mic", 
+			maj_stat, min_stat);
 		if (maj_stat == GSS_S_CONTEXT_EXPIRED) {
 			gd->established = FALSE;
 			authgss_destroy_context(auth);
@@ -406,7 +408,8 @@ authgss_validate(AUTH *auth, struct opaque_auth *verf)
 				  &checksum, &qop_state);
 
 	if (maj_stat != GSS_S_COMPLETE || qop_state != gd->sec.qop) {
-		gss_log_status("gss_verify_mic", maj_stat, min_stat);
+		gss_log_status("authgss_validate: gss_verify_mic", 
+			maj_stat, min_stat);
 		if (maj_stat == GSS_S_CONTEXT_EXPIRED) {
 			gd->established = FALSE;
 			authgss_destroy_context(auth);
@@ -464,7 +467,8 @@ authgss_refresh(AUTH *auth, void *dummy)
 		}
 		if (maj_stat != GSS_S_COMPLETE &&
 		    maj_stat != GSS_S_CONTINUE_NEEDED) {
-			gss_log_status("gss_init_sec_context", maj_stat, min_stat);
+			gss_log_status("authgss_refresh: gss_init_sec_context", 
+				maj_stat, min_stat);
 			break;
 		}
 		if (send_token.length != 0) {
@@ -521,7 +525,8 @@ authgss_refresh(AUTH *auth, void *dummy)
 
 			if (maj_stat != GSS_S_COMPLETE
 					|| qop_state != gd->sec.qop) {
-				gss_log_status("gss_verify_mic", maj_stat, min_stat);
+				gss_log_status("authgss_refresh: gss_verify_mic", 
+					maj_stat, min_stat);
 				if (maj_stat == GSS_S_CONTEXT_EXPIRED) {
 					gd->established = FALSE;
 					authgss_destroy_context(auth);
diff --git a/src/authgss_prot.c b/src/authgss_prot.c
index f233c24..7f4a019 100644
--- a/src/authgss_prot.c
+++ b/src/authgss_prot.c
@@ -192,7 +192,8 @@ xdr_rpc_gss_wrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
 		maj_stat = gss_wrap(&min_stat, ctx, TRUE, qop, &databuf,
 				    &conf_state, &wrapbuf);
 		if (maj_stat != GSS_S_COMPLETE) {
-			gss_log_status("gss_wrap", maj_stat, min_stat);
+			gss_log_status("xdr_rpc_gss_wrap_data: gss_wrap", 
+				maj_stat, min_stat);
 			return (FALSE);
 		}
 		/* Marshal databody_priv. */
@@ -241,7 +242,8 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
 
 		if (maj_stat != GSS_S_COMPLETE || qop_state != qop) {
 			gss_release_buffer(&min_stat, &databuf);
-			gss_log_status("gss_verify_mic", maj_stat, min_stat);
+			gss_log_status("xdr_rpc_gss_unwrap_data: gss_verify_mic", 
+				maj_stat, min_stat);
 			return (FALSE);
 		}
 	}
@@ -261,7 +263,8 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
 		if (maj_stat != GSS_S_COMPLETE || qop_state != qop ||
 			conf_state != TRUE) {
 			gss_release_buffer(&min_stat, &databuf);
-			gss_log_status("gss_unwrap", maj_stat, min_stat);
+			gss_log_status("xdr_rpc_gss_unwrap_data: gss_unwrap", 
+				maj_stat, min_stat);
 			return (FALSE);
 		}
 	}
diff --git a/src/svc_auth_gss.c b/src/svc_auth_gss.c
index 26c1065..a032dd6 100644
--- a/src/svc_auth_gss.c
+++ b/src/svc_auth_gss.c
@@ -93,7 +93,8 @@ svcauth_gss_set_svc_name(gss_name_t name)
 		maj_stat = gss_release_name(&min_stat, &_svcauth_gss_name);
 
 		if (maj_stat != GSS_S_COMPLETE) {
-			gss_log_status("gss_release_name", maj_stat, min_stat);
+			gss_log_status("svcauth_gss_set_svc_name: gss_release_name", 
+				maj_stat, min_stat);
 			return (FALSE);
 		}
 		_svcauth_gss_name = NULL;
@@ -101,7 +102,8 @@ svcauth_gss_set_svc_name(gss_name_t name)
 	maj_stat = gss_duplicate_name(&min_stat, name, &_svcauth_gss_name);
 
 	if (maj_stat != GSS_S_COMPLETE) {
-		gss_log_status("gss_duplicate_name", maj_stat, min_stat);
+		gss_log_status("svcauth_gss_set_svc_name: gss_duplicate_name", 
+			maj_stat, min_stat);
 		return (FALSE);
 	}
 
@@ -124,7 +126,8 @@ svcauth_gss_import_name(char *service)
 				   (gss_OID)GSS_C_NT_HOSTBASED_SERVICE, &name);
 
 	if (maj_stat != GSS_S_COMPLETE) {
-		gss_log_status("gss_import_name", maj_stat, min_stat);
+		gss_log_status("svcauth_gss_import_name: gss_import_name", 
+			maj_stat, min_stat);
 		return (FALSE);
 	}
 	if (svcauth_gss_set_svc_name(name) != TRUE) {
@@ -146,7 +149,8 @@ svcauth_gss_acquire_cred(void)
 				    &_svcauth_gss_creds, NULL, NULL);
 
 	if (maj_stat != GSS_S_COMPLETE) {
-		gss_log_status("gss_acquire_cred", maj_stat, min_stat);
+		gss_log_status("svcauth_gss_acquire_cred: gss_acquire_cred", 
+			maj_stat, min_stat);
 		return (FALSE);
 	}
 	return (TRUE);
@@ -162,7 +166,8 @@ svcauth_gss_release_cred(void)
 	maj_stat = gss_release_cred(&min_stat, &_svcauth_gss_creds);
 
 	if (maj_stat != GSS_S_COMPLETE) {
-		gss_log_status("gss_release_cred", maj_stat, min_stat);
+		gss_log_status("svcauth_gss_release_cred: gss_release_cred", 
+			maj_stat, min_stat);
 		return (FALSE);
 	}
 
@@ -208,7 +213,8 @@ svcauth_gss_accept_sec_context(struct svc_req *rqst,
 
 	if (gr->gr_major != GSS_S_COMPLETE &&
 	    gr->gr_major != GSS_S_CONTINUE_NEEDED) {
-		gss_log_status("accept_sec_context", gr->gr_major, gr->gr_minor);
+		gss_log_status("svcauth_gss_accept_sec_context: accept_sec_context",
+			gr->gr_major, gr->gr_minor);
 		gd->ctx = GSS_C_NO_CONTEXT;
 		gss_release_buffer(&min_stat, &gr->gr_token);
 		return (FALSE);
@@ -238,7 +244,8 @@ svcauth_gss_accept_sec_context(struct svc_req *rqst,
 		maj_stat = gss_display_name(&min_stat, gd->client_name,
 					    &gd->cname, &gd->sec.mech);
 		if (maj_stat != GSS_S_COMPLETE) {
-			gss_log_status("display_name", maj_stat, min_stat);
+			gss_log_status("svcauth_gss_accept_sec_context: display_name", 
+				maj_stat, min_stat);
 			return (FALSE);
 		}
 #ifdef DEBUG
@@ -326,7 +333,8 @@ svcauth_gss_validate(struct svc_rpc_gss_data *gd, struct rpc_msg *msg)
 	free(rpchdr);
 
 	if (maj_stat != GSS_S_COMPLETE) {
-		gss_log_status("gss_verify_mic", maj_stat, min_stat);
+		gss_log_status("svcauth_gss_validate: gss_verify_mic", 
+			maj_stat, min_stat);
 		return (FALSE);
 	}
 	return (TRUE);
@@ -353,7 +361,8 @@ svcauth_gss_nextverf(struct svc_req *rqst, u_int num)
 			       &signbuf, &checksum);
 
 	if (maj_stat != GSS_S_COMPLETE) {
-		gss_log_status("gss_get_mic", maj_stat, min_stat);
+		gss_log_status("svcauth_gss_nextverf: gss_get_mic", 
+			maj_stat, min_stat);
 		return (FALSE);
 	}
 	rqst->rq_xprt->xp_verf.oa_flavor = RPCSEC_GSS;
-- 
1.9.3

