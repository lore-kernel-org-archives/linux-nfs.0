From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 2/2] svcgssd: use the actual context expiration for cache
	expiration
Date: Thu, 04 Dec 2008 18:35:03 -0500
Message-ID: <20081204233503.5951.90189.stgit@jazz.citi.umich.edu>
References: <20081204233341.5951.62162.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:2799 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbYLDXfD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Dec 2008 18:35:03 -0500
In-Reply-To: <20081204233341.5951.62162.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of sending down an infinite expiration value for the rsi(init) and
rsc(context) cache entries, use a reasonable value for the rsi cache, and
the actual context expiration value for the rsc cache.

Prompted by a proposal from Neil Brown as a result of a complaint of a
server running out of kernel memory when under heavy load of rpcsec_gss
traffic.  Neil's original patch used one minute for the init cache and one
hour for the context cache.  Using the actual expiration time prevents
unnecessary context re-negotiation.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/svcgssd_proc.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index d021d49..f162152 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -46,6 +46,7 @@
 #include <errno.h>
 #include <nfsidmap.h>
 #include <nfslib.h>
+#include <time.h>
 
 #include "svcgssd.h"
 #include "gss_util.h"
@@ -67,7 +68,8 @@ struct svc_cred {
 
 static int
 do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
-		gss_OID mech, gss_buffer_desc *context_token)
+		gss_OID mech, gss_buffer_desc *context_token,
+		int32_t endtime)
 {
 	FILE *f;
 	int i;
@@ -86,13 +88,15 @@ do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
 	}
 	qword_printhex(f, out_handle->value, out_handle->length);
 	/* XXX are types OK for the rest of this? */
-	qword_printint(f, 0x7fffffff); /*XXX need a better timeout */
+	/* For context cache, use the actual context endtime */
+	qword_printint(f, endtime);
 	qword_printint(f, cred->cr_uid);
 	qword_printint(f, cred->cr_gid);
 	qword_printint(f, cred->cr_ngroups);
-	printerr(2, "mech: %s, hndl len: %d, ctx len %d, timeout: %d, "
+	printerr(2, "mech: %s, hndl len: %d, ctx len %d, timeout: %d (%d from now), "
 		 "uid: %d, gid: %d, num aux grps: %d:\n",
-		 fname, out_handle->length, context_token->length, 0x7fffffff,
+		 fname, out_handle->length, context_token->length,
+		 endtime, endtime - time(0),
 		 cred->cr_uid, cred->cr_gid, cred->cr_ngroups);
 	for (i=0; i < cred->cr_ngroups; i++) {
 		qword_printint(f, cred->cr_groups[i]);
@@ -130,7 +134,8 @@ send_response(FILE *f, gss_buffer_desc *in_handle, gss_buffer_desc *in_token,
 
 	qword_addhex(&bp, &blen, in_handle->value, in_handle->length);
 	qword_addhex(&bp, &blen, in_token->value, in_token->length);
-	qword_addint(&bp, &blen, 0x7fffffff); /*XXX need a better timeout */
+	/* For init cache, only needed for a short time */
+	qword_addint(&bp, &blen, time(0) + 60);
 	qword_adduint(&bp, &blen, maj_stat);
 	qword_adduint(&bp, &blen, min_stat);
 	qword_addhex(&bp, &blen, out_handle->value, out_handle->length);
@@ -320,6 +325,7 @@ handle_nullreq(FILE *f) {
 	static char		*lbuf = NULL;
 	static int		lbuflen = 0;
 	static char		*cp;
+	int32_t			ctx_endtime;
 
 	printerr(1, "handling null request\n");
 
@@ -396,7 +402,7 @@ handle_nullreq(FILE *f) {
 
 	/* kernel needs ctx to calculate verifier on null response, so
 	 * must give it context before doing null call: */
-	if (serialize_context_for_kernel(ctx, &ctx_token, mech, NULL)) {
+	if (serialize_context_for_kernel(ctx, &ctx_token, mech, &ctx_endtime)) {
 		printerr(0, "WARNING: handle_nullreq: "
 			    "serialize_context_for_kernel failed\n");
 		maj_stat = GSS_S_FAILURE;
@@ -405,7 +411,7 @@ handle_nullreq(FILE *f) {
 	/* We no longer need the gss context */
 	gss_delete_sec_context(&ignore_min_stat, &ctx, &ignore_out_tok);
 
-	do_svc_downcall(&out_handle, &cred, mech, &ctx_token);
+	do_svc_downcall(&out_handle, &cred, mech, &ctx_token, ctx_endtime);
 continue_needed:
 	send_response(f, &in_handle, &in_tok, maj_stat, min_stat,
 			&out_handle, &out_tok);

