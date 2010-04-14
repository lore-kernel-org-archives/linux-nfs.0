From: steved@redhat.com
Subject: [PATCH 3/3] Add support for non-DES encryption types.
Date: Wed, 14 Apr 2010 15:18:49 -0400
Message-ID: <1271272729-24422-4-git-send-email-steved@redhat.com>
References: <1271272729-24422-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:49712 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751504Ab0DNTSw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Apr 2010 15:18:52 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1O286s-0006m9-K6
	for linux-nfs@vger.kernel.org; Wed, 14 Apr 2010 15:18:50 -0400
In-Reply-To: <1271272729-24422-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Sends a new format of context information to the kernel.
(Requires kernel support to do anything useful.)

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/context.h       |    6 ++-
 utils/gssd/context_lucid.c |  128 ++++++++++++++++++++++++++++++++++++-----
 utils/gssd/context_mit.c   |  136 +++++++++++++++++++++++++++++++++-----------
 3 files changed, 222 insertions(+), 48 deletions(-)

diff --git a/utils/gssd/context.h b/utils/gssd/context.h
index be47f9c..c9cb0bd 100644
--- a/utils/gssd/context.h
+++ b/utils/gssd/context.h
@@ -1,5 +1,5 @@
 /*
-  Copyright (c) 2004 The Regents of the University of Michigan.
+  Copyright (c) 2004,2008 The Regents of the University of Michigan.
   All rights reserved.
 
   Redistribution and use in source and binary forms, with or without
@@ -36,6 +36,10 @@
 /* Hopefully big enough to hold any serialized context */
 #define MAX_CTX_LEN 4096
 
+/* New context format flag values */
+#define KRB5_CTX_FLAG_INITIATOR         0x00000001
+#define KRB5_CTX_FLAG_CFX               0x00000002
+#define KRB5_CTX_FLAG_ACCEPTOR_SUBKEY   0x00000004
 
 int serialize_context_for_kernel(gss_ctx_id_t ctx, gss_buffer_desc *buf,
 				 gss_OID mech, int32_t *endtime);
diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
index 4a682ae..b87bf76 100644
--- a/utils/gssd/context_lucid.c
+++ b/utils/gssd/context_lucid.c
@@ -42,6 +42,7 @@
 #include <stdio.h>
 #include <syslog.h>
 #include <string.h>
+#include <errno.h>
 
 #include <gssapi/gssapi_krb5.h>
 
@@ -119,15 +120,13 @@ prepare_krb5_rfc1964_buffer(gss_krb5_lucid_context_v1_t *lctx,
 	 * Note that the rfc1964 version only supports DES enctypes.
 	 */
 	if (lctx->rfc1964_kd.ctx_key.type != 4) {
-		printerr(1, "prepare_krb5_rfc1964_buffer: "
-			    "overriding heimdal keytype (%d => %d)\n",
-			    lctx->rfc1964_kd.ctx_key.type, 4);
+		printerr(2, "%s: overriding heimdal keytype (%d => %d)\n",
+			 __FUNCTION__, lctx->rfc1964_kd.ctx_key.type, 4);
 		lctx->rfc1964_kd.ctx_key.type = 4;
 	}
 #endif
-	printerr(2, "prepare_krb5_rfc1964_buffer: serializing keys with "
-		 "enctype %d and length %d\n",
-		 lctx->rfc1964_kd.ctx_key.type,
+	printerr(2, "%s: serializing keys with enctype %d and length %d\n",
+		 __FUNCTION__, lctx->rfc1964_kd.ctx_key.type,
 		 lctx->rfc1964_kd.ctx_key.length);
 
 	/* derive the encryption key and copy it into buffer */
@@ -158,11 +157,100 @@ out_err:
 	return -1;
 }
 
+/* Flags for version 2 context flags */
+#define KRB5_CTX_FLAG_INITIATOR		0x00000001
+#define KRB5_CTX_FLAG_CFX		0x00000002
+#define KRB5_CTX_FLAG_ACCEPTOR_SUBKEY	0x00000004
+
+/*
+ * Prepare a new-style buffer, as defined in rfc4121 (a.k.a. cfx),
+ * to send to the kernel for newer encryption types -- or for DES3.
+ *
+ * The new format is:
+ *
+ *	u32 flags;
+ *	#define KRB5_CTX_FLAG_INITIATOR		0x00000001
+ *	#define KRB5_CTX_FLAG_CFX		0x00000002
+ *	#define KRB5_CTX_FLAG_ACCEPTOR_SUBKEY	0x00000004
+ *	s32 endtime;
+ *	u64 seq_send;
+ *	u32  enctype;			( encrption type of key )
+ *	raw key;			( raw key bytes (kernel will derive))
+ *
+ */
 static int
-prepare_krb5_rfc_cfx_buffer(gss_krb5_lucid_context_v1_t *lctx,
+prepare_krb5_rfc4121_buffer(gss_krb5_lucid_context_v1_t *lctx,
 	gss_buffer_desc *buf, int32_t *endtime)
 {
-	printerr(0, "ERROR: prepare_krb5_rfc_cfx_buffer: not implemented\n");
+	char *p, *end;
+	uint32_t v2_flags = 0;
+	uint32_t enctype;
+	uint32_t keysize;
+
+	if (!(buf->value = calloc(1, MAX_CTX_LEN)))
+		goto out_err;
+	p = buf->value;
+	end = buf->value + MAX_CTX_LEN;
+
+	/* Version 2 */
+	if (lctx->initiate)
+		v2_flags |= KRB5_CTX_FLAG_INITIATOR;
+	if (lctx->protocol != 0)
+		v2_flags |= KRB5_CTX_FLAG_CFX;
+	if (lctx->protocol != 0 && lctx->cfx_kd.have_acceptor_subkey == 1)
+		v2_flags |= KRB5_CTX_FLAG_ACCEPTOR_SUBKEY;
+
+	if (WRITE_BYTES(&p, end, v2_flags)) goto out_err;
+	if (WRITE_BYTES(&p, end, lctx->endtime)) goto out_err;
+	if (WRITE_BYTES(&p, end, lctx->send_seq)) goto out_err;
+
+	/* Protocol 0 here implies DES3 or RC4 */
+	printerr(2, "%s: protocol %d\n", __FUNCTION__, lctx->protocol);
+	if (lctx->protocol == 0) {
+		enctype = lctx->rfc1964_kd.ctx_key.type;
+		keysize = lctx->rfc1964_kd.ctx_key.length;
+	} else {
+		if (lctx->cfx_kd.have_acceptor_subkey) {
+			enctype = lctx->cfx_kd.acceptor_subkey.type;
+			keysize = lctx->cfx_kd.acceptor_subkey.length;
+		} else {
+			enctype = lctx->cfx_kd.ctx_key.type;
+			keysize = lctx->cfx_kd.ctx_key.length;
+		}
+	}
+	printerr(2, "%s: serializing key with enctype %d and size %d\n",
+		 __FUNCTION__, enctype, keysize);
+
+	if (WRITE_BYTES(&p, end, enctype)) goto out_err;
+
+	if (lctx->protocol == 0) {
+		if (write_bytes(&p, end, lctx->rfc1964_kd.ctx_key.data,
+				lctx->rfc1964_kd.ctx_key.length))
+			goto out_err;
+	} else {
+		if (lctx->cfx_kd.have_acceptor_subkey) {
+			if (write_bytes(&p, end,
+					lctx->cfx_kd.acceptor_subkey.data,
+					lctx->cfx_kd.acceptor_subkey.length))
+				goto out_err;
+		} else {
+			if (write_bytes(&p, end, lctx->cfx_kd.ctx_key.data,
+					lctx->cfx_kd.ctx_key.length))
+				goto out_err;
+		}
+	}
+
+	buf->length = p - (char *)buf->value;
+	return 0;
+
+out_err:
+	printerr(0, "ERROR: %s: failed serializing krb5 context for kernel\n",
+		 __FUNCTION__);
+	if (buf->value) {
+		free(buf->value);
+		buf->value = NULL;
+	}
+	buf->length = 0;
 	return -1;
 }
 
@@ -176,7 +264,7 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
 	gss_krb5_lucid_context_v1_t *lctx = 0;
 	int retcode = 0;
 
-	printerr(2, "DEBUG: serialize_krb5_ctx: lucid version!\n");
+	printerr(2, "DEBUG: %s: lucid version!\n", __FUNCTION__);
 	maj_stat = gss_export_lucid_sec_context(&min_stat, &ctx,
 						1, &return_ctx);
 	if (maj_stat != GSS_S_COMPLETE) {
@@ -198,11 +286,20 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
 		break;
 	}
 
-	/* Now lctx points to a lucid context that we can send down to kernel */
-	if (lctx->protocol == 0)
+	/*
+	 * Now lctx points to a lucid context that we can send down to kernel
+	 *
+	 * Note: we send down different information to the kernel depending
+	 * on the protocol version and the enctyption type.
+	 * For protocol version 0 with all enctypes besides DES3, we use
+	 * the original format.  For protocol version != 0 or DES3, we
+	 * send down the new style information.
+	 */
+
+	if (lctx->protocol == 0 && lctx->rfc1964_kd.ctx_key.type <= 4)
 		retcode = prepare_krb5_rfc1964_buffer(lctx, buf, endtime);
 	else
-		retcode = prepare_krb5_rfc_cfx_buffer(lctx, buf, endtime);
+		retcode = prepare_krb5_rfc4121_buffer(lctx, buf, endtime);
 
 	maj_stat = gss_free_lucid_sec_context(&min_stat, ctx, return_ctx);
 	if (maj_stat != GSS_S_COMPLETE) {
@@ -212,8 +309,8 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
 	}
 
 	if (retcode) {
-		printerr(1, "serialize_krb5_ctx: prepare_krb5_*_buffer "
-			 "failed (retcode = %d)\n", retcode);
+		printerr(1, "%s: prepare_krb5_*_buffer failed (retcode = %d)\n",
+			 __FUNCTION__, retcode);
 		goto out_err;
 	}
 
@@ -223,4 +320,7 @@ out_err:
 	printerr(0, "ERROR: failed serializing krb5 context for kernel\n");
 	return -1;
 }
+
+
+
 #endif /* HAVE_LUCID_CONTEXT_SUPPORT */
diff --git a/utils/gssd/context_mit.c b/utils/gssd/context_mit.c
index 709a903..f9cbb02 100644
--- a/utils/gssd/context_mit.c
+++ b/utils/gssd/context_mit.c
@@ -1,5 +1,5 @@
 /*
-  Copyright (c) 2004 The Regents of the University of Michigan.
+  Copyright (c) 2004-2006 The Regents of the University of Michigan.
   All rights reserved.
 
   Redistribution and use in source and binary forms, with or without
@@ -38,6 +38,7 @@
 #include <stdio.h>
 #include <syslog.h>
 #include <string.h>
+#include <errno.h>
 #include <gssapi/gssapi.h>
 #include <rpc/rpc.h>
 #include <rpc/auth_gss.h>
@@ -52,8 +53,7 @@
 /* XXX argggg, there's gotta be a better way than just duplicating this
  * whole struct.  Unfortunately, this is in a "private" header file,
  * so this is our best choice at this point :-/
- *
- * XXX Does this match the Heimdal definition?  */
+ */
 
 typedef struct _krb5_gss_ctx_id_rec {
    unsigned int initiate : 1;   /* nonzero if initiating, zero if accepting */
@@ -156,50 +156,120 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
 {
 	krb5_gss_ctx_id_t kctx = ((gss_union_ctx_id_t)ctx)->internal_ctx_id;
 	char *p, *end;
-	static int constant_one = 1;
 	static int constant_zero = 0;
+	static int constant_one = 1;
+	static int constant_two = 2;
 	uint32_t word_seq_send;
+	u_int64_t seq_send_64bit;
+	uint32_t v2_flags = 0;
 
 	if (!(buf->value = calloc(1, MAX_CTX_LEN)))
 		goto out_err;
 	p = buf->value;
 	end = buf->value + MAX_CTX_LEN;
 
-	if (kctx->initiate) {
-		if (WRITE_BYTES(&p, end, constant_one)) goto out_err;
-	}
-	else {
-		if (WRITE_BYTES(&p, end, constant_zero)) goto out_err;
-	}
-	if (kctx->seed_init) {
-		if (WRITE_BYTES(&p, end, constant_one)) goto out_err;
-	}
-	else {
-		if (WRITE_BYTES(&p, end, constant_zero)) goto out_err;
-	}
-	if (write_bytes(&p, end, &kctx->seed, sizeof(kctx->seed)))
+	switch (kctx->enc->enctype) {
+	case ENCTYPE_DES_CBC_CRC:
+	case ENCTYPE_DES_CBC_MD4:
+	case ENCTYPE_DES_CBC_MD5:
+	case ENCTYPE_DES_CBC_RAW:
+		/* Old format of context to the kernel */
+		if (kctx->initiate) {
+			if (WRITE_BYTES(&p, end, constant_one)) goto out_err;
+		}
+		else {
+			if (WRITE_BYTES(&p, end, constant_zero)) goto out_err;
+		}
+		if (kctx->seed_init) {
+			if (WRITE_BYTES(&p, end, constant_one)) goto out_err;
+		}
+		else {
+			if (WRITE_BYTES(&p, end, constant_zero)) goto out_err;
+		}
+		if (write_bytes(&p, end, &kctx->seed, sizeof(kctx->seed)))
+			goto out_err;
+		if (WRITE_BYTES(&p, end, kctx->signalg)) goto out_err;
+		if (WRITE_BYTES(&p, end, kctx->sealalg)) goto out_err;
+		if (WRITE_BYTES(&p, end, kctx->endtime)) goto out_err;
+		word_seq_send = kctx->seq_send;
+		if (WRITE_BYTES(&p, end, word_seq_send)) goto out_err;
+		if (write_oid(&p, end, kctx->mech_used)) goto out_err;
+
+		printerr(2, "serialize_krb5_ctx: serializing keys with "
+			 "enctype %d and length %d\n",
+			 kctx->enc->enctype, kctx->enc->length);
+
+		if (write_keyblock(&p, end, kctx->enc)) goto out_err;
+		if (write_keyblock(&p, end, kctx->seq)) goto out_err;
+		break;
+	case ENCTYPE_DES3_CBC_RAW:
+	case ENCTYPE_DES3_CBC_SHA1:
+	case ENCTYPE_ARCFOUR_HMAC:
+	case ENCTYPE_ARCFOUR_HMAC_EXP:
+	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
+	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
+		/* New format of context to the kernel */
+		/* u32 flags;
+		 * #define KRB5_CTX_FLAG_INITIATOR        0x00000001
+		 * #define KRB5_CTX_FLAG_CFX              0x00000002
+		 * #define KRB5_CTX_FLAG_ACCEPTOR_SUBKEY  0x00000004
+		 * s32 endtime;
+		 * u64 seq_send;
+		 * u32  enctype;
+		 * rawkey data
+		 */
+
+		if (kctx->initiate)
+			v2_flags |= KRB5_CTX_FLAG_INITIATOR;
+		if (kctx->proto == 1)
+			v2_flags |= KRB5_CTX_FLAG_CFX;
+		if (kctx->have_acceptor_subkey)
+			v2_flags |= KRB5_CTX_FLAG_ACCEPTOR_SUBKEY;
+		if (WRITE_BYTES(&p, end, v2_flags)) goto out_err;
+		if (WRITE_BYTES(&p, end, kctx->endtime)) goto out_err;
+
+		seq_send_64bit = kctx->seq_send;
+		if (WRITE_BYTES(&p, end, seq_send_64bit)) goto out_err;
+
+		if (kctx->have_acceptor_subkey) {
+			if (WRITE_BYTES(&p, end, kctx->acceptor_subkey->enctype))
+				goto out_err;
+			printerr(2, "serialize_krb5_ctx: serializing subkey "
+				 "with enctype %d and size %d\n",
+				 kctx->acceptor_subkey->enctype,
+				 kctx->acceptor_subkey->length);
+
+			if (write_bytes(&p, end,
+					kctx->acceptor_subkey->contents,
+					kctx->acceptor_subkey->length))
+				goto out_err;
+		} else {
+			if (WRITE_BYTES(&p, end, kctx->enc->enctype))
+				goto out_err;
+			printerr(2, "serialize_krb5_ctx: serializing key "
+				 "with enctype %d and size %d\n",
+				 kctx->enc->enctype, kctx->enc->length);
+
+			if (write_bytes(&p, end, kctx->enc->contents,
+					kctx->enc->length))
+				goto out_err;
+		}
+		break;
+	default:
+		printerr(0, "ERROR: serialize_krb5_ctx: unsupported encryption "
+			 "algorithm %d\n", kctx->enc->enctype);
 		goto out_err;
-	if (WRITE_BYTES(&p, end, kctx->signalg)) goto out_err;
-	if (WRITE_BYTES(&p, end, kctx->sealalg)) goto out_err;
-	if (WRITE_BYTES(&p, end, kctx->endtime)) goto out_err;
-	if (endtime)
-		*endtime = kctx->endtime;
-	word_seq_send = kctx->seq_send;
-	if (WRITE_BYTES(&p, end, word_seq_send)) goto out_err;
-	if (write_oid(&p, end, kctx->mech_used)) goto out_err;
-
-	printerr(2, "serialize_krb5_ctx: serializing keys with "
-		 "enctype %d and length %d\n",
-		 kctx->enc->enctype, kctx->enc->length);
-
-	if (write_keyblock(&p, end, kctx->enc)) goto out_err;
-	if (write_keyblock(&p, end, kctx->seq)) goto out_err;
+	}
 
 	buf->length = p - (char *)buf->value;
 	return 0;
+
 out_err:
 	printerr(0, "ERROR: failed serializing krb5 context for kernel\n");
-	if (buf->value) free(buf->value);
+	if (buf->value) {
+		free(buf->value);
+	}
+	buf->value = NULL;
 	buf->length = 0;
 	return -1;
 }
-- 
1.6.6.1

