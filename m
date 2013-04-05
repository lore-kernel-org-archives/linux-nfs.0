Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53778 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162903Ab3DEWhR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 18:37:17 -0400
From: Simo Sorce <simo@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Cc: Steve Dickson <steved@redhat.com>
Subject: [PATCH 2/2] Fix double free when exporting lucid context
Date: Fri,  5 Apr 2013 18:37:05 -0400
Message-Id: <1365201425-21702-3-git-send-email-simo@redhat.com>
In-Reply-To: <1365201425-21702-2-git-send-email-simo@redhat.com>
References: <1365201425-21702-1-git-send-email-simo@redhat.com>
 <1365201425-21702-2-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When using GSSAPI's gss_krb5_export_lucid_context the context passed into the
function is actually deleted during the export (to avoid reuse as the context
contains state that depends on its usage).
Change the code to pass in a pointer to the context so that it can be properly
NULLed if we are using the GSSAPI context and following calls to
gss_delete_sec_context will not cause double free errors and segfaults.

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/gssd/context.c         | 2 +-
 utils/gssd/context.h         | 4 ++--
 utils/gssd/context_heimdal.c | 4 ++--
 utils/gssd/context_lucid.c   | 4 ++--
 utils/gssd/context_mit.c     | 4 ++--
 utils/gssd/gssd_proc.c       | 4 ++--
 utils/gssd/svcgssd_proc.c    | 2 +-
 7 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/utils/gssd/context.c b/utils/gssd/context.c
index fee7da27906e94b990fb7c49d73bf4f27a7003ac..7757a7700d14dd7fbe07f9878d6d79f514467156 100644
--- a/utils/gssd/context.c
+++ b/utils/gssd/context.c
@@ -44,7 +44,7 @@
 #include "context.h"
 
 int
-serialize_context_for_kernel(gss_ctx_id_t ctx,
+serialize_context_for_kernel(gss_ctx_id_t *ctx,
 			     gss_buffer_desc *buf,
 			     gss_OID mech,
 			     int32_t *endtime)
diff --git a/utils/gssd/context.h b/utils/gssd/context.h
index 0e437f4a34f0862b8f89bd0d6fe62c41a3a1c906..3b55c8e4239cd9e814c8d540f0b3f90ade560107 100644
--- a/utils/gssd/context.h
+++ b/utils/gssd/context.h
@@ -41,9 +41,9 @@
 #define KRB5_CTX_FLAG_CFX               0x00000002
 #define KRB5_CTX_FLAG_ACCEPTOR_SUBKEY   0x00000004
 
-int serialize_context_for_kernel(gss_ctx_id_t ctx, gss_buffer_desc *buf,
+int serialize_context_for_kernel(gss_ctx_id_t *ctx, gss_buffer_desc *buf,
 				 gss_OID mech, int32_t *endtime);
-int serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf,
+int serialize_krb5_ctx(gss_ctx_id_t *ctx, gss_buffer_desc *buf,
 		       int32_t *endtime);
 
 #endif /* _CONTEXT_H_ */
diff --git a/utils/gssd/context_heimdal.c b/utils/gssd/context_heimdal.c
index 6f3b8fd03f37e12a048337eed1d0d80e3bdb3224..1e8738aba96b9ad9c8b7017366355cd3001389fb 100644
--- a/utils/gssd/context_heimdal.c
+++ b/utils/gssd/context_heimdal.c
@@ -203,9 +203,9 @@ int write_heimdal_seq_key(char **p, char *end, gss_ctx_id_t ctx)
  */
 
 int
-serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
+serialize_krb5_ctx(gss_ctx_id_t *_ctx, gss_buffer_desc *buf, int32_t *endtime)
 {
-
+	gss_ctx_id_t ctx = *_ctx;
 	char *p, *end;
 	static int constant_one = 1;
 	static int constant_zero = 0;
diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
index 64146d7078c9f31a82b2c0435f9ca7a170c29874..badbe88d82ec5c8c957aa880758f9ac51381f5ee 100644
--- a/utils/gssd/context_lucid.c
+++ b/utils/gssd/context_lucid.c
@@ -257,7 +257,7 @@ out_err:
 
 
 int
-serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
+serialize_krb5_ctx(gss_ctx_id_t *ctx, gss_buffer_desc *buf, int32_t *endtime)
 {
 	OM_uint32 maj_stat, min_stat;
 	void *return_ctx = 0;
@@ -266,7 +266,7 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
 	int retcode = 0;
 
 	printerr(2, "DEBUG: %s: lucid version!\n", __FUNCTION__);
-	maj_stat = gss_export_lucid_sec_context(&min_stat, &ctx,
+	maj_stat = gss_export_lucid_sec_context(&min_stat, ctx,
 						1, &return_ctx);
 	if (maj_stat != GSS_S_COMPLETE) {
 		pgsserr("gss_export_lucid_sec_context",
diff --git a/utils/gssd/context_mit.c b/utils/gssd/context_mit.c
index e6db9cbb77b858ba91f659b9a7f43ef312317a21..fad67569f47accdc6adc49bb0a59a025c5dd9973 100644
--- a/utils/gssd/context_mit.c
+++ b/utils/gssd/context_mit.c
@@ -152,9 +152,9 @@ typedef struct gss_union_ctx_id_t {
 } gss_union_ctx_id_desc, *gss_union_ctx_id_t;
 
 int
-serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
+serialize_krb5_ctx(gss_ctx_id_t *ctx, gss_buffer_desc *buf, int32_t *endtime)
 {
-	krb5_gss_ctx_id_t kctx = ((gss_union_ctx_id_t)ctx)->internal_ctx_id;
+	krb5_gss_ctx_id_t kctx = ((gss_union_ctx_id_t)(*ctx))->internal_ctx_id;
 	char *p, *end;
 	static int constant_zero = 0;
 	static int constant_one = 1;
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 21d4e1d78eb54d177626cb0a19b9de4e93e0a20d..afc2076cde74e3cea6764408ec839a6f99b86ea4 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -1091,7 +1091,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		printerr(1, "WARNING: Failed to inquire context for lifetme "
 			    "maj_stat %u\n", maj_stat);
 
-	if (serialize_context_for_kernel(pd.pd_ctx, &token, &krb5oid, NULL)) {
+	if (serialize_context_for_kernel(&pd.pd_ctx, &token, &krb5oid, NULL)) {
 		printerr(0, "WARNING: Failed to serialize krb5 context for "
 			    "user with uid %d for server %s\n",
 			 uid, clp->servername);
@@ -1104,7 +1104,7 @@ out:
 	if (token.value)
 		free(token.value);
 #ifdef HAVE_AUTHGSS_FREE_PRIVATE_DATA
-	if (pd.pd_ctx_hndl.length != 0)
+	if (pd.pd_ctx_hndl.length != 0 || pd.pd_ctx != 0)
 		authgss_free_private_data(&pd);
 #endif
 	if (auth)
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 0d4f78d9668396aaebb05ab97804cfb1e8d5ed5a..3757d5191041b0341ea8ed11db6b26d3bea4f460 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -484,7 +484,7 @@ handle_nullreq(FILE *f) {
 
 	/* kernel needs ctx to calculate verifier on null response, so
 	 * must give it context before doing null call: */
-	if (serialize_context_for_kernel(ctx, &ctx_token, mech, &ctx_endtime)) {
+	if (serialize_context_for_kernel(&ctx, &ctx_token, mech, &ctx_endtime)) {
 		printerr(0, "WARNING: handle_nullreq: "
 			    "serialize_context_for_kernel failed\n");
 		maj_stat = GSS_S_FAILURE;
-- 
1.8.1.4

