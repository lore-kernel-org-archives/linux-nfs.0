Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:10649 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752909AbdG1UuF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:50:05 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <anna.schumaker@netapp.com>, <olga.kornievskaia@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 2/2] RPCSEC_GSSv3 new reply verifier
Date: Fri, 28 Jul 2017 16:50:00 -0400
Message-ID: <1501275000-24236-3-git-send-email-andros@netapp.com>
In-Reply-To: <1501275000-24236-1-git-send-email-andros@netapp.com>
References: <1501275000-24236-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 src/auth_gss.c | 133 +++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 src/clnt_vc.c  |   1 +
 2 files changed, 131 insertions(+), 3 deletions(-)

diff --git a/src/auth_gss.c b/src/auth_gss.c
index 8f3da2c..c015552 100644
--- a/src/auth_gss.c
+++ b/src/auth_gss.c
@@ -47,6 +47,7 @@
 #include <rpc/auth_gss.h>
 #include <rpc/rpcsec_gss.h>
 #include <rpc/clnt.h>
+#include <rpc/rpc_msg.h>
 #include <netinet/in.h>
 
 #include "debug.h"
@@ -209,6 +210,7 @@ retry_gssv1:
 	if (!authgss_refresh(auth, NULL)) {
 		if (vers == RPCSEC_GSS3_VERSION) {
 			vers = RPCSEC_GSS_VERSION;
+			gss_log_debug("authgss_create() RETRY with GSSv1\n");
 			goto retry_gssv1;
 		} else
 			auth = NULL;
@@ -436,17 +438,33 @@ static bool_t
 _rpc_gss_refresh(AUTH *auth, rpc_gss_options_ret_t *options_ret)
 {
 	struct rpc_gss_data	*gd;
+	struct rpc_gss_cred	pregc = {
+		.gc_v = 0,
+	};
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
+	gss_log_debug("PREGC gc_v %d gc_proc %d gc_svc %d  gc_ctx.length %d",
+			pregc.gc_v, pregc.gc_proc, pregc.gc_svc,
+			pregc.gc_ctx.length);
+
 	if (gd->established)
 		return (TRUE);
 
@@ -534,15 +552,124 @@ _rpc_gss_refresh(AUTH *auth, rpc_gss_options_ret_t *options_ret)
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
+				buf = (u_char *)malloc((8 * BYTES_PER_XDR_UNIT)
+					 + crlen);
+				if (buf == NULL)
+					return (FALSE);
+				ptr = (int32_t *)buf;
+
+				/* XID */
+				CLNT_CONTROL(gd->clnt, CLGET_XID, &dummy);
+				*ptr++ = dummy;  /* hmm, need htonl?*/
+
+				/* direction */
+				IXDR_PUT_ENUM(ptr, REPLY);
+
+				/* rpc vers */
+				IXDR_PUT_LONG(ptr, RPC_MSG_VERSION);
+
+				/* program (NFS) */
+				CLNT_CONTROL(gd->clnt, CLGET_PROG, &dummy);
+				*ptr++ = htonl(dummy);
+
+				/* version (NFS version 4) */
+				CLNT_CONTROL(gd->clnt, CLGET_VERS, &dummy);
+				*ptr++ = htonl(dummy);
+
+				/* NFS Program */
+				IXDR_PUT_LONG(ptr, NULLPROC);
+
+				/* credential */
+				/* flavor */
+				IXDR_PUT_LONG(ptr, RPCSEC_GSS);
+
+				/* cred length goes here */
+				IXDR_PUT_LONG(ptr, crlen);
+
+				/* gss version */
+				IXDR_PUT_LONG(ptr, gd->gc.gc_v);
+
+				/* gss proc from CALL */
+				IXDR_PUT_LONG(ptr, pregc.gc_proc);
+
+				/* gss seq */
+				IXDR_PUT_LONG(ptr, gr.gr_win);
+
+				/* gss service from CALL */
+				IXDR_PUT_LONG(ptr, pregc.gc_svc);
+
+				/* gss ctx len */
+				IXDR_PUT_LONG(ptr, pregc.gc_ctx.length);
+				if (pregc.gc_ctx.length > 0) {
+					memcpy(ptr, pregc.gc_ctx.value,
+						pregc.gc_ctx.length);
+				}
+				ptr += RNDUP(pregc.gc_ctx.length);
+				bufin.value = buf;
+				bufin.length = (8 * BYTES_PER_XDR_UNIT) + crlen;
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
-- 
1.8.3.1

