Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:6166 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941241AbcLWQLD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:11:03 -0500
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/2] RPCSEC_GSSv3 new reply verifier
Date: Fri, 23 Dec 2016 11:09:27 -0500
Message-ID: <1482509367-22381-3-git-send-email-andros@netapp.com>
In-Reply-To: <1482509367-22381-1-git-send-email-andros@netapp.com>
References: <1482509367-22381-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 src/auth_gss.c | 179 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 src/clnt_vc.c  |   1 +
 src/debug.c    |   2 +-
 3 files changed, 178 insertions(+), 4 deletions(-)

diff --git a/src/auth_gss.c b/src/auth_gss.c
index 5bb1685..81771d1 100644
--- a/src/auth_gss.c
+++ b/src/auth_gss.c
@@ -48,6 +48,7 @@
 #include <rpc/rpcsec_gss.h>
 #include <rpc/clnt.h>
 #include <netinet/in.h>
+#include <rpc/rpc_msg.h>
 
 #include "debug.h"
 
@@ -202,10 +203,13 @@ retry_gssv1:
 	save_auth = clnt->cl_auth;
 	clnt->cl_auth = auth;
 
+	gss_log_debug("authgss_create() gc_v %d", gd->gc.gc_v);
 	fprintf(stderr, "authgss_create CALLING authgss_refresh\n");
 	if (!authgss_refresh(auth, NULL)) {
 		if (vers == RPCSEC_GSS3_VERSION) {
 			vers = RPCSEC_GSS_VERSION;
+			gss_log_debug("authgss_create() RETRY GSSv1\n");
+
 			goto retry_gssv1;
 		} else
 			auth = NULL;
@@ -214,6 +218,9 @@ retry_gssv1:
 
 	clnt->cl_auth = save_auth;
 
+	gd = auth->ah_private;
+	gss_log_debug("authgss_create() DONE gc_v %d", gd->gc.gc_v);
+
 	return (auth);
 }
 
@@ -224,6 +231,7 @@ authgss_create_default(CLIENT *clnt, char *service, struct rpc_gss_sec *sec)
 	OM_uint32		 maj_stat = 0, min_stat = 0;
 	gss_buffer_desc		 sname;
 	gss_name_t		 name = GSS_C_NO_NAME;
+	struct rpc_gss_data     *gd;
 
 	gss_log_debug("in authgss_create_default()");
 
@@ -249,6 +257,8 @@ authgss_create_default(CLIENT *clnt, char *service, struct rpc_gss_sec *sec)
  		gss_release_name(&min_stat, &name);
 	}
 
+	gd = auth->ah_private;
+	gss_log_debug("authgss_create_default() DONE gc_v %d", gd->gc.gc_v);
 	return (auth);
 }
 
@@ -271,6 +281,7 @@ authgss_get_private_data(AUTH *auth, struct authgss_private_data *pd)
 	pd->pd_ctx_hndl = gd->gc.gc_ctx;
 	pd->pd_seq_win = gd->win;
 	pd->pd_gss_vers = gd->gc.gc_v;
+	gss_log_debug("authgss_get_private_data() GSS Version %d", gd->gc.gc_v);
 	/*
 	 * We've given this away -- don't try to use it ourself any more
 	 * Caller should call authgss_free_private_data to free data.
@@ -429,21 +440,52 @@ authgss_validate(AUTH *auth, struct opaque_auth *verf)
 	return (TRUE);
 }
 
+void
+print_bytes(unsigned char *buf, int len)
+{
+	uint32_t *ptr = (uint32_t *)buf;
+	int i, in32len = len / 4;
+
+	fprintf(stderr,"print_bytes in32len %d\n", in32len); 
+	for (i = 0; i < in32len; i++) {
+		fprintf(stderr, "%x:", *ptr); 
+		ptr++;
+	}
+	fprintf(stderr,"\n\n"); 
+
+}
+
 static bool_t
 _rpc_gss_refresh(AUTH *auth, rpc_gss_options_ret_t *options_ret)
 {
 	struct rpc_gss_data	*gd;
+	struct rpc_gss_cred	pregc = {
+					.gc_v = 0,
+				};
 	struct rpc_gss_init_res	 gr;
 	gss_buffer_desc		*recv_tokenp, send_token;
 	OM_uint32		 maj_stat, min_stat, call_stat, ret_flags,
 				 time_ret;
 	gss_OID			 actual_mech_type;
 	char			*mechanism;
+	unsigned char		*buf = NULL;
+	int32_t			*ptr;
 
 	gss_log_debug("in authgss_refresh()");
 
 	gd = AUTH_PRIVATE(auth);
 
+	/** The RPCSEC_GSSv3 verifier is over the call header data caveat 
+	 * the gss seq_num which is the current to be sent seq_num, and the
+	 * mtype which is changed from CALL to REPLY.
+	 * Save the input rpc_gss_cred to use values before they are changed.
+	 */
+	pregc = gd->gc;
+	
+	gss_log_debug("PREGC gc_v %d gc_proc %d gc_svc %d  gc_ctx.length %d\n",
+			pregc.gc_v, pregc.gc_proc, pregc.gc_svc,
+			pregc.gc_ctx.length);
+
 	if (gd->established)
 		return (TRUE);
 
@@ -531,15 +573,145 @@ _rpc_gss_refresh(AUTH *auth, rpc_gss_options_ret_t *options_ret)
 			gss_buffer_desc   bufout;
 			u_int seq, qop_state = 0;
 
-			seq = htonl(gr.gr_win);
-			bufin.value = (unsigned char *)&seq;
-			bufin.length = sizeof(seq);
+			if (gd->gc.gc_v == RPCSEC_GSS_VERSION) {
+				seq = htonl(gr.gr_win);
+				bufin.value = (unsigned char *)&seq;
+				bufin.length = sizeof(seq);
+			}
+			if (gd->gc.gc_v == RPCSEC_GSS3_VERSION) {
+				int32_t dummy, crlen;
+				/*
+				 * GSSv3 draft: "compute the verifier using the
+				 * exact same input as is used to compute the
+				 * request verfier, except for the mtype is
+				 * changed from CALL to REPLY.
+				 *
+				 * NOTE: Need to add: the sequence number is
+				 * also different - as it is the seq number
+				 * for the reply. (same seq for gssv1)
+				 *
+				 * NOTE: RFC 2203: creation requests the
+				 * seq_num and the service fields are
+				 * undefined and must be ignored by the server.
+				 * So, send the same gc_svc as used in the call
+				 * as this is what the server should return??.
+				 *
+				 * 1.XID  CLNT_CONTROL(cl, CLGET_XID, <dest>)	
+				 * gets the xid of the PREVIOUS call
+				 * see clnt_vc_control, CLGET_XID
+				 *
+				 * 2. direction	REPLY
+				 * 3. rpcvers	RPC_MSG_VERSION
+				 * 4.  prog		RPCBPROG
+				 * 5.  vers		RPCBVERS
+				 * 6.  proc             NULLPROC
+				 *
+				 * 	credential
+				 * 	NOTE: need to use pregc credential
+				 * 	as that is what was passed in CALL
+				 *
+				 * 7. flavor	RPCSEC_GSS
+				 * 8. length
+				 * 	xdr_rpc_gss_cred may do this for you
+				 * 	gd->gc
+				 * 9. gss version     gc_v
+				 * 10. gss proc	   gc_proc
+				 * 11. gss seq	gr.gr_win used above for v1
+				 * 12. gss service
+				 * --------------
+				 *  total 12 xdr units
+				 * gss ctx
+				 * 13. 	len  1 xdr unit
+				 * 	data 	
+				 */
+				crlen = ((5 * BYTES_PER_XDR_UNIT)
+					 + RNDUP(pregc.gc_ctx.length));
+
+				gss_log_debug("GSS3 buf len %d crlen %d\n",
+				       (8 * BYTES_PER_XDR_UNIT) + crlen, crlen);
+
+				buf = (u_char *)malloc((8 * BYTES_PER_XDR_UNIT)
+					 + crlen);
+				if (buf == NULL)
+					return (FALSE);
+				ptr = (int32_t *)buf;
+
+				gss_log_debug("GSS3 ptr prior to XID %p\n", ptr);
+				/* XID */
+				CLNT_CONTROL(gd->clnt, CLGET_XID, &dummy);
+				gss_log_debug("GSS3 XID 0x%x\n", dummy);
+				*ptr++ = dummy;  /* hmm, need htonl?*/
+				gss_log_debug("GSS3 ptr %p 1\n", ptr);
+
+				/* direction */
+				IXDR_PUT_ENUM(ptr, REPLY);
+				gss_log_debug("GSS3 ptr %p 2\n", ptr);
+
+				/* rpc vers */
+				IXDR_PUT_LONG(ptr, RPC_MSG_VERSION);
+				gss_log_debug("GSS3 ptr %p 3\n", ptr);
+
+				/* program (NFS) */
+				CLNT_CONTROL(gd->clnt, CLGET_PROG, &dummy);
+				*ptr++ = htonl(dummy);
+				gss_log_debug("GSS3 ptr %p 4\n", ptr);
+
+				/* version (NFS version 4) */
+				CLNT_CONTROL(gd->clnt, CLGET_VERS, &dummy);
+				*ptr++ = htonl(dummy);
+				gss_log_debug("GSS3 ptr %p 5\n", ptr);
+
+				/* NFS Program */
+				IXDR_PUT_LONG(ptr, NULLPROC);
+				gss_log_debug("GSS3 ptr %p 6\n", ptr);
+
+				/* credential */
+				/* flavor */
+				IXDR_PUT_LONG(ptr, RPCSEC_GSS);
+				gss_log_debug("GSS3 ptr %p 7\n", ptr);
+
+				/* cred length goes here */ 
+				IXDR_PUT_LONG(ptr, crlen);
+				gss_log_debug("crlen %d ptr %p\n", crlen, ptr);
+
+				/* gss version */
+				IXDR_PUT_LONG(ptr, gd->gc.gc_v);
+				gss_log_debug("GSS3 ptr %p 8\n", ptr);
+
+				/* gss proc from CALL */
+				IXDR_PUT_LONG(ptr, pregc.gc_proc);
+				gss_log_debug("GSS3 ptr %p 9\n", ptr);
+
+				/* gss seq */
+				IXDR_PUT_LONG(ptr, gr.gr_win);
+				gss_log_debug("GSS3 ptr %p 10\n", ptr);
+
+				/* gss service from CALL */
+				IXDR_PUT_LONG(ptr, pregc.gc_svc);
+				gss_log_debug("GSS3 ptr %p 11\n", ptr);
+
+				/* gss ctx len */
+				IXDR_PUT_LONG(ptr, pregc.gc_ctx.length);
+				gss_log_debug("GSS3 ptr %p 12 ctx.length %d\n",
+						ptr, gd->gc.gc_ctx.length);
+				if (pregc.gc_ctx.length > 0) {
+					memcpy(ptr, pregc.gc_ctx.value,
+						pregc.gc_ctx.length);
+				}
+				ptr += RNDUP(pregc.gc_ctx.length);
+				bufin.value = buf;
+				bufin.length = (8 * BYTES_PER_XDR_UNIT) + crlen;
+				print_bytes(bufin.value, bufin.length);
+				gss_log_debug("GSS3 DONE\n");
+			}
 			bufout.value = (unsigned char *)gd->gc_wire_verf.value;
 			bufout.length = gd->gc_wire_verf.length;
 
 			maj_stat = gss_verify_mic(&min_stat, gd->ctx,
 				&bufin, &bufout, &qop_state);
 
+			if (buf && gd->gc.gc_v == RPCSEC_GSS3_VERSION)
+				free(buf);
 			if (maj_stat != GSS_S_COMPLETE
 					|| qop_state != gd->sec.qop) {
 				gss_log_status("authgss_refresh: gss_verify_mic", 
@@ -704,6 +876,7 @@ authgss_unwrap(AUTH *auth, XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr)
 	gss_log_debug("in authgss_unwrap()");
 
 	gd = AUTH_PRIVATE(auth);
+	gss_log_debug("in authgss_unwrap() GSS Version %d", gd->gc.gc_v);
 
 	if (!gd->established || gd->sec.svc == RPCSEC_GSS_SVC_NONE) {
 		return ((*xdr_func)(xdrs, xdr_ptr));
diff --git a/src/clnt_vc.c b/src/clnt_vc.c
index a72f9f7..e6b2ff1 100644
--- a/src/clnt_vc.c
+++ b/src/clnt_vc.c
@@ -574,6 +574,7 @@ clnt_vc_control(cl, request, info)
 		 * first element in the call structure
 		 * This will get the xid of the PREVIOUS call
 		 */
+		fprintf(stderr, "GETXID xid 0x%x\n", ntohl(ct->ct_u.ct_mcalli));
 		*(u_int32_t *)info =
 		    ntohl(*(u_int32_t *)(void *)&ct->ct_u.ct_mcalli);
 		break;
diff --git a/src/debug.c b/src/debug.c
index b40ff37..f2f006f 100644
--- a/src/debug.c
+++ b/src/debug.c
@@ -28,7 +28,7 @@
 #include "debug.h"
 
 /* library global debug level */
-int libtirpc_debug_level = 0;
+int libtirpc_debug_level = 3;
 int  log_stderr = 1; /* log to stderr instead of systlog */
 
 /*
-- 
1.8.3.1

