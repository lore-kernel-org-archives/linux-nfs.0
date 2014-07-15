Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753313AbaGOPJp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:45 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 02/15] gss_log: Convert existing gss debugging routines
Date: Tue, 15 Jul 2014 11:09:21 -0400
Message-Id: <1405436974-4161-3-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert the gss_log_XXX routines to used the
new LIBTIRPC_DEBUG() macros.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/authgss_prot.c | 41 +++++++++++------------------------------
 1 file changed, 11 insertions(+), 30 deletions(-)

diff --git a/src/authgss_prot.c b/src/authgss_prot.c
index a3c93c9..d7480fc 100644
--- a/src/authgss_prot.c
+++ b/src/authgss_prot.c
@@ -42,8 +42,11 @@
 #include <rpc/auth.h>
 #include <rpc/auth_gss.h>
 #include <rpc/rpc.h>
+#include <ctype.h>
 #include <gssapi/gssapi.h>
 
+#include "debug.h"
+
 /* additional space needed for encoding */
 #define RPC_SLACK_SPACE 1024
 
@@ -296,18 +299,13 @@ xdr_rpc_gss_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
 	return (FALSE);
 }
 
-#ifdef DEBUG
-#include <ctype.h>
-
 void
 gss_log_debug(const char *fmt, ...)
 {
 	va_list ap;
 
 	va_start(ap, fmt);
-	fprintf(stderr, "rpcsec_gss: ");
-	vfprintf(stderr, fmt, ap);
-	fprintf(stderr, "\n");
+	vlibtirpc_log_dbg(2, fmt, ap);
 	va_end(ap);
 }
 
@@ -316,18 +314,18 @@ gss_log_status(char *m, OM_uint32 maj_stat, OM_uint32 min_stat)
 {
 	OM_uint32 min;
 	gss_buffer_desc msg;
-	int msg_ctx = 0;
+	u_int32_t msg_ctx = 0;
 
-	fprintf(stderr, "rpcsec_gss: %s: ", m);
+	LIBTIRPC_DEBUG(1, ("rpcsec_gss: %s: ", m));
 
 	gss_display_status(&min, maj_stat, GSS_C_GSS_CODE, GSS_C_NULL_OID,
 			   &msg_ctx, &msg);
-	fprintf(stderr, "%s - ", (char *)msg.value);
+	LIBTIRPC_DEBUG(1, ("%s - ", (char *)msg.value));
 	gss_release_buffer(&min, &msg);
 
 	gss_display_status(&min, min_stat, GSS_C_MECH_CODE, GSS_C_NULL_OID,
 			   &msg_ctx, &msg);
-	fprintf(stderr, "%s\n", (char *)msg.value);
+	LIBTIRPC_DEBUG(1, ("%s", (char *)msg.value));
 	gss_release_buffer(&min, &msg);
 }
 
@@ -337,6 +335,9 @@ gss_log_hexdump(const u_char *buf, int len, int offset)
 	u_int i, j, jm;
 	int c;
 
+	if (libtirpc_debug_level < 3 || log_stderr == 0)
+		return;
+
 	fprintf(stderr, "\n");
 	for (i = 0; i < len; i += 0x10) {
 		fprintf(stderr, "  %04x: ", (u_int)(i + offset));
@@ -364,23 +365,3 @@ gss_log_hexdump(const u_char *buf, int len, int offset)
 	}
 }
 
-#else
-
-void
-gss_log_debug(const char *fmt, ...)
-{
-}
-
-void
-gss_log_status(char *m, OM_uint32 maj_stat, OM_uint32 min_stat)
-{
-}
-
-void
-gss_log_hexdump(const u_char *buf, int len, int offset)
-{
-}
-
-#endif
-
-
-- 
1.9.3

