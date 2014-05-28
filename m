Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54121 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754130AbaE1QQK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 May 2014 12:16:10 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Avoid buffer overruns by allocating buffer in svcauth_gss_validate()
Date: Wed, 28 May 2014 12:15:58 -0400
Message-Id: <1401293758-8506-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/svc_auth_gss.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/src/svc_auth_gss.c b/src/svc_auth_gss.c
index 601a691..e31010f 100644
--- a/src/svc_auth_gss.c
+++ b/src/svc_auth_gss.c
@@ -280,29 +280,35 @@ svcauth_gss_accept_sec_context(struct svc_req *rqst,
 	return (TRUE);
 }
 
+#ifndef RPCHDRSZ
+#define RPCHDRSZ 128
+#endif
+
 static bool_t
 svcauth_gss_validate(struct svc_rpc_gss_data *gd, struct rpc_msg *msg)
 {
 	struct opaque_auth	*oa;
 	gss_buffer_desc		 rpcbuf, checksum;
 	OM_uint32		 maj_stat, min_stat, qop_state;
-	u_char			 rpchdr[128];
+	u_char			 *rpchdr;
 	int32_t			*buf;
 
 	gss_log_debug("in svcauth_gss_validate()");
 
-	memset(rpchdr, 0, sizeof(rpchdr));
-
 	/* XXX - Reconstruct RPC header for signing (from xdr_callmsg). */
 	oa = &msg->rm_call.cb_cred;
 	if (oa->oa_length > MAX_AUTH_BYTES)
 		return (FALSE);
 	
 	/* 8 XDR units from the IXDR macro calls. */
-	if (sizeof(rpchdr) < (8 * BYTES_PER_XDR_UNIT +
+	if (RPCHDRSZ < (8 * BYTES_PER_XDR_UNIT +
 			RNDUP(oa->oa_length)))
 		return (FALSE);
 
+	rpchdr = (u_char *)calloc(RPCHDRSZ+MAX_AUTH_BYTES, 1);
+	if (rpchdr == NULL)
+		return (FALSE);
+
 	buf = (int32_t *)rpchdr;
 	IXDR_PUT_LONG(buf, msg->rm_xid);
 	IXDR_PUT_ENUM(buf, msg->rm_direction);
@@ -325,6 +331,8 @@ svcauth_gss_validate(struct svc_rpc_gss_data *gd, struct rpc_msg *msg)
 	maj_stat = gss_verify_mic(&min_stat, gd->ctx, &rpcbuf, &checksum,
 				  &qop_state);
 
+	free(rpchdr);
+
 	if (maj_stat != GSS_S_COMPLETE) {
 		gss_log_status("gss_verify_mic", maj_stat, min_stat);
 		return (FALSE);
-- 
1.7.1

