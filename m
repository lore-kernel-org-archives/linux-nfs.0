From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 1/2] gssd/svcgssd: add support to retrieve actual context
	expiration
Date: Thu, 04 Dec 2008 18:34:58 -0500
Message-ID: <20081204233458.5951.93551.stgit@jazz.citi.umich.edu>
References: <20081204233341.5951.62162.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:47162 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244AbYLDXe6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Dec 2008 18:34:58 -0500
In-Reply-To: <20081204233341.5951.62162.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add some plumbing so that the context expiration can be returned while
serializing the information.  Later patch(es) will actually get the
expiration and pass it down to the kernel.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/context.c         |    7 ++++---
 utils/gssd/context.h         |    8 +++++---
 utils/gssd/context_heimdal.c |    5 ++++-
 utils/gssd/context_lucid.c   |   12 +++++++-----
 utils/gssd/context_mit.c     |    4 +++-
 utils/gssd/context_spkm3.c   |    5 ++++-
 utils/gssd/gssd_proc.c       |    4 ++--
 utils/gssd/svcgssd_proc.c    |    2 +-
 8 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/utils/gssd/context.c b/utils/gssd/context.c
index 4bab3e7..0ca7079 100644
--- a/utils/gssd/context.c
+++ b/utils/gssd/context.c
@@ -43,13 +43,14 @@
 int
 serialize_context_for_kernel(gss_ctx_id_t ctx,
 			     gss_buffer_desc *buf,
-			     gss_OID mech)
+			     gss_OID mech,
+			     int32_t *endtime)
 {
 	if (g_OID_equal(&krb5oid, mech))
-		return serialize_krb5_ctx(ctx, buf);
+		return serialize_krb5_ctx(ctx, buf, endtime);
 #ifdef HAVE_SPKM3_H
 	else if (g_OID_equal(&spkm3oid, mech))
-		return serialize_spkm3_ctx(ctx, buf);
+		return serialize_spkm3_ctx(ctx, buf, endtime);
 #endif
 	else {
 		printerr(0, "ERROR: attempting to serialize context with "
diff --git a/utils/gssd/context.h b/utils/gssd/context.h
index 67ed3bb..be47f9c 100644
--- a/utils/gssd/context.h
+++ b/utils/gssd/context.h
@@ -38,8 +38,10 @@
 
 
 int serialize_context_for_kernel(gss_ctx_id_t ctx, gss_buffer_desc *buf,
-				 gss_OID mech);
-int serialize_spkm3_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf);
-int serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf);
+				 gss_OID mech, int32_t *endtime);
+int serialize_spkm3_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf,
+			int32_t *endtime);
+int serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf,
+		       int32_t *endtime);
 
 #endif /* _CONTEXT_H_ */
diff --git a/utils/gssd/context_heimdal.c b/utils/gssd/context_heimdal.c
index 6fb8fbd..fc241e3 100644
--- a/utils/gssd/context_heimdal.c
+++ b/utils/gssd/context_heimdal.c
@@ -198,7 +198,7 @@ int write_heimdal_seq_key(char **p, char *end, gss_ctx_id_t ctx)
  */
 
 int
-serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf)
+serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
 {
 
 	char *p, *end;
@@ -239,6 +239,9 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf)
 	/* endtime */
 	if (WRITE_BYTES(&p, end, ctx->lifetime)) goto out_err;
 
+	if (endtime)
+		*endtime = ctx->lifetime;
+
 	/* seq_send */
 	if (WRITE_BYTES(&p, end, ctx->auth_context->local_seqnumber))
 		goto out_err;
diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
index 3550762..94403af 100644
--- a/utils/gssd/context_lucid.c
+++ b/utils/gssd/context_lucid.c
@@ -66,7 +66,7 @@ write_lucid_keyblock(char **p, char *end, gss_krb5_lucid_key_t *key)
 
 static int
 prepare_krb5_rfc1964_buffer(gss_krb5_lucid_context_v1_t *lctx,
-	gss_buffer_desc *buf)
+	gss_buffer_desc *buf, int32_t *endtime)
 {
 	char *p, *end;
 	static int constant_zero = 0;
@@ -101,6 +101,8 @@ prepare_krb5_rfc1964_buffer(gss_krb5_lucid_context_v1_t *lctx,
 	if (WRITE_BYTES(&p, end, lctx->rfc1964_kd.sign_alg)) goto out_err;
 	if (WRITE_BYTES(&p, end, lctx->rfc1964_kd.seal_alg)) goto out_err;
 	if (WRITE_BYTES(&p, end, lctx->endtime)) goto out_err;
+	if (endtime)
+		*endtime = lctx->endtime;
 	word_send_seq = lctx->send_seq;	/* XXX send_seq is 64-bit */
 	if (WRITE_BYTES(&p, end, word_send_seq)) goto out_err;
 	if (write_oid(&p, end, &krb5oid)) goto out_err;
@@ -154,7 +156,7 @@ out_err:
 
 static int
 prepare_krb5_rfc_cfx_buffer(gss_krb5_lucid_context_v1_t *lctx,
-	gss_buffer_desc *buf)
+	gss_buffer_desc *buf, int32_t *endtime)
 {
 	printerr(0, "ERROR: prepare_krb5_rfc_cfx_buffer: not implemented\n");
 	return -1;
@@ -162,7 +164,7 @@ prepare_krb5_rfc_cfx_buffer(gss_krb5_lucid_context_v1_t *lctx,
 
 
 int
-serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf)
+serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
 {
 	OM_uint32 maj_stat, min_stat;
 	void *return_ctx = 0;
@@ -194,9 +196,9 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf)
 
 	/* Now lctx points to a lucid context that we can send down to kernel */
 	if (lctx->protocol == 0)
-		retcode = prepare_krb5_rfc1964_buffer(lctx, buf);
+		retcode = prepare_krb5_rfc1964_buffer(lctx, buf, endtime);
 	else
-		retcode = prepare_krb5_rfc_cfx_buffer(lctx, buf);
+		retcode = prepare_krb5_rfc_cfx_buffer(lctx, buf, endtime);
 
 	maj_stat = gss_free_lucid_sec_context(&min_stat, ctx, return_ctx);
 	if (maj_stat != GSS_S_COMPLETE) {
diff --git a/utils/gssd/context_mit.c b/utils/gssd/context_mit.c
index 94b2266..e76a8b1 100644
--- a/utils/gssd/context_mit.c
+++ b/utils/gssd/context_mit.c
@@ -150,7 +150,7 @@ typedef struct gss_union_ctx_id_t {
 } gss_union_ctx_id_desc, *gss_union_ctx_id_t;
 
 int
-serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf)
+serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
 {
 	krb5_gss_ctx_id_t kctx = ((gss_union_ctx_id_t)ctx)->internal_ctx_id;
 	char *p, *end;
@@ -180,6 +180,8 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf)
 	if (WRITE_BYTES(&p, end, kctx->signalg)) goto out_err;
 	if (WRITE_BYTES(&p, end, kctx->sealalg)) goto out_err;
 	if (WRITE_BYTES(&p, end, kctx->endtime)) goto out_err;
+	if (endtime)
+		*endtime = kctx->endtime;
 	word_seq_send = kctx->seq_send;
 	if (WRITE_BYTES(&p, end, word_seq_send)) goto out_err;
 	if (write_oid(&p, end, kctx->mech_used)) goto out_err;
diff --git a/utils/gssd/context_spkm3.c b/utils/gssd/context_spkm3.c
index 4f41ee3..5b387bd 100644
--- a/utils/gssd/context_spkm3.c
+++ b/utils/gssd/context_spkm3.c
@@ -139,7 +139,7 @@ out_err:
  * and only export those fields to the kernel.
  */
 int
-serialize_spkm3_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf)
+serialize_spkm3_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
 {
 	OM_uint32 vers, ret, maj_stat, min_stat;
 	void *ret_ctx = 0;
@@ -162,6 +162,9 @@ serialize_spkm3_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf)
 	}
 	ret = prepare_spkm3_ctx_buffer(lctx, buf);
 
+	if (endtime)
+		*endtime = lctx->endtime;
+
 	maj_stat = gss_free_lucid_sec_context(&min_stat, ctx, ret_ctx);
 
 	if (maj_stat != GSS_S_COMPLETE)
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index f415a10..cb14d45 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -762,7 +762,7 @@ handle_krb5_upcall(struct clnt_info *clp)
 		goto out_return_error;
 	}
 
-	if (serialize_context_for_kernel(pd.pd_ctx, &token, &krb5oid)) {
+	if (serialize_context_for_kernel(pd.pd_ctx, &token, &krb5oid, NULL)) {
 		printerr(0, "WARNING: Failed to serialize krb5 context for "
 			    "user with uid %d for server %s\n",
 			 uid, clp->servername);
@@ -824,7 +824,7 @@ handle_spkm3_upcall(struct clnt_info *clp)
 		goto out_return_error;
 	}
 
-	if (serialize_context_for_kernel(pd.pd_ctx, &token, &spkm3oid)) {
+	if (serialize_context_for_kernel(pd.pd_ctx, &token, &spkm3oid, NULL)) {
 		printerr(0, "WARNING: Failed to serialize spkm3 context for "
 			    "user with uid %d for server\n",
 			 uid, clp->servername);
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 794c2f4..d021d49 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -396,7 +396,7 @@ handle_nullreq(FILE *f) {
 
 	/* kernel needs ctx to calculate verifier on null response, so
 	 * must give it context before doing null call: */
-	if (serialize_context_for_kernel(ctx, &ctx_token, mech)) {
+	if (serialize_context_for_kernel(ctx, &ctx_token, mech, NULL)) {
 		printerr(0, "WARNING: handle_nullreq: "
 			    "serialize_context_for_kernel failed\n");
 		maj_stat = GSS_S_FAILURE;

