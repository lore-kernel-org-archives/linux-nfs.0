From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 10/12] Share handling of lucid_sec_context for Heimdal
	and MIT
Date: Thu, 08 Feb 2007 17:27:40 -0500
Message-ID: <20070208222740.23464.54397.stgit@rock.citi.umich.edu>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk7-0006sn-2X
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:51 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HFHk8-0004Qq-BD
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:53 -0800
In-Reply-To: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>

The 0.8 release of Heimdal has (will have) support for the lucid context.
The handling of lucid_sec_context can be shared between builds with MIT
or Heimdal Kerberos.

Split out the lucid_sec_context code from context_mit.c
and make a new common file, context_lucid.c.
---

 utils/gssd/Makefile.am       |    1 
 utils/gssd/context.h         |    4 +
 utils/gssd/context_heimdal.c |    6 +
 utils/gssd/context_lucid.c   |  220 ++++++++++++++++++++++++++++++++++++++++++
 utils/gssd/context_mit.c     |  173 +--------------------------------
 5 files changed, 234 insertions(+), 170 deletions(-)

diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index 7009d8d..7c32597 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -16,6 +16,7 @@ COMMON_SRCS = \
 	context.c \
 	context_mit.c \
 	context_heimdal.c \
+	context_lucid.c \
 	context_spkm3.c \
 	gss_util.c \
 	gss_oids.c \
diff --git a/utils/gssd/context.h b/utils/gssd/context.h
index 2c9396a..67ed3bb 100644
--- a/utils/gssd/context.h
+++ b/utils/gssd/context.h
@@ -33,6 +33,10 @@ #define _CONTEXT_H_
 
 #include <rpc/rpc.h>
 
+/* Hopefully big enough to hold any serialized context */
+#define MAX_CTX_LEN 4096
+
+
 int serialize_context_for_kernel(gss_ctx_id_t ctx, gss_buffer_desc *buf,
 				 gss_OID mech);
 int serialize_spkm3_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf);
diff --git a/utils/gssd/context_heimdal.c b/utils/gssd/context_heimdal.c
index edd4dfc..5520cbc 100644
--- a/utils/gssd/context_heimdal.c
+++ b/utils/gssd/context_heimdal.c
@@ -1,5 +1,5 @@
 /*
-  Copyright (c) 2004 The Regents of the University of Michigan.
+  Copyright (c) 2004-2006 The Regents of the University of Michigan.
   All rights reserved.
 
   Redistribution and use in source and binary forms, with or without
@@ -30,6 +30,7 @@
 
 #include "config.h"
 
+#ifndef HAVE_LUCID_CONTEXT_SUPPORT
 #ifdef HAVE_HEIMDAL
 
 #include <stdio.h>
@@ -46,8 +47,6 @@ #include "err_util.h"
 #include "gss_oids.h"
 #include "write_bytes.h"
 
-#define MAX_CTX_LEN 4096
-
 int write_heimdal_keyblock(char **p, char *end, krb5_keyblock *key)
 {
 	gss_buffer_desc tmp;
@@ -265,3 +264,4 @@ out_err:
 }
 
 #endif	/* HAVE_HEIMDAL */
+#endif	/* HAVE_LUCID_CONTEXT_SUPPORT */
diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
new file mode 100644
index 0000000..3550762
--- /dev/null
+++ b/utils/gssd/context_lucid.c
@@ -0,0 +1,220 @@
+/*
+ * COPYRIGHT (c) 2006
+ * The Regents of the University of Michigan
+ * ALL RIGHTS RESERVED
+ *
+ * Permission is granted to use, copy, create derivative works
+ * and redistribute this software and such derivative works
+ * for any purpose, so long as the name of The University of
+ * Michigan is not used in any advertising or publicity
+ * pertaining to the use of distribution of this software
+ * without specific, written prior authorization.  If the
+ * above copyright notice or any other identification of the
+ * University of Michigan is included in any copy of any
+ * portion of this software, then the disclaimer below must
+ * also be included.
+ *
+ * THIS SOFTWARE IS PROVIDED AS IS, WITHOUT REPRESENTATION
+ * FROM THE UNIVERSITY OF MICHIGAN AS TO ITS FITNESS FOR ANY
+ * PURPOSE, AND WITHOUT WARRANTY BY THE UNIVERSITY OF
+ * MICHIGAN OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING
+ * WITHOUT LIMITATION THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
+ * REGENTS OF THE UNIVERSITY OF MICHIGAN SHALL NOT BE LIABLE
+ * FOR ANY DAMAGES, INCLUDING SPECIAL, INDIRECT, INCIDENTAL, OR
+ * CONSEQUENTIAL DAMAGES, WITH RESPECT TO ANY CLAIM ARISING
+ * OUT OF OR IN CONNECTION WITH THE USE OF THE SOFTWARE, EVEN
+ * IF IT HAS BEEN OR IS HEREAFTER ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGES.
+ */
+
+#include "config.h"
+
+#ifdef HAVE_LUCID_CONTEXT_SUPPORT
+
+/*
+ * Newer versions of MIT and Heimdal have lucid context support.
+ * We can use common code if it is supported.
+ */
+
+#include <stdio.h>
+#include <syslog.h>
+#include <string.h>
+#include "gss_util.h"
+#include "gss_oids.h"
+#include "err_util.h"
+#include "context.h"
+
+#include <krb5.h>
+#include <gssapi/gssapi.h>
+#ifndef OM_uint64
+typedef uint64_t OM_uint64;
+#endif
+#include <gssapi/gssapi_krb5.h>
+
+static int
+write_lucid_keyblock(char **p, char *end, gss_krb5_lucid_key_t *key)
+{
+	gss_buffer_desc tmp;
+
+	if (WRITE_BYTES(p, end, key->type)) return -1;
+	tmp.length = key->length;
+	tmp.value = key->data;
+	if (write_buffer(p, end, &tmp)) return -1;
+	return 0;
+}
+
+static int
+prepare_krb5_rfc1964_buffer(gss_krb5_lucid_context_v1_t *lctx,
+	gss_buffer_desc *buf)
+{
+	char *p, *end;
+	static int constant_zero = 0;
+	unsigned char fakeseed[16];
+	uint32_t word_send_seq;
+	gss_krb5_lucid_key_t enc_key;
+	int i;
+	char *skd, *dkd;
+	gss_buffer_desc fakeoid;
+
+	/*
+	 * The new Kerberos interface to get the gss context
+	 * does not include the seed or seed_init fields
+	 * because we never really use them.  But for now,
+	 * send down a fake buffer so we can use the same
+	 * interface to the kernel.
+	 */
+	memset(&enc_key, 0, sizeof(enc_key));
+	memset(&fakeoid, 0, sizeof(fakeoid));
+
+	if (!(buf->value = calloc(1, MAX_CTX_LEN)))
+		goto out_err;
+	p = buf->value;
+	end = buf->value + MAX_CTX_LEN;
+
+	if (WRITE_BYTES(&p, end, lctx->initiate)) goto out_err;
+
+	/* seed_init and seed not used by kernel anyway */
+	if (WRITE_BYTES(&p, end, constant_zero)) goto out_err;
+	if (write_bytes(&p, end, &fakeseed, 16)) goto out_err;
+
+	if (WRITE_BYTES(&p, end, lctx->rfc1964_kd.sign_alg)) goto out_err;
+	if (WRITE_BYTES(&p, end, lctx->rfc1964_kd.seal_alg)) goto out_err;
+	if (WRITE_BYTES(&p, end, lctx->endtime)) goto out_err;
+	word_send_seq = lctx->send_seq;	/* XXX send_seq is 64-bit */
+	if (WRITE_BYTES(&p, end, word_send_seq)) goto out_err;
+	if (write_oid(&p, end, &krb5oid)) goto out_err;
+
+#ifdef HAVE_HEIMDAL
+	/*
+	 * The kernel gss code expects des-cbc-raw for all flavors of des.
+	 * The keytype from MIT has this type, but Heimdal does not.
+	 * Force the Heimdal keytype to 4 (des-cbc-raw).
+	 * Note that the rfc1964 version only supports DES enctypes.
+	 */
+	if (lctx->rfc1964_kd.ctx_key.type != 4) {
+		printerr(1, "prepare_krb5_rfc1964_buffer: "
+			    "overriding heimdal keytype (%d => %d)\n",
+			    lctx->rfc1964_kd.ctx_key.type, 4);
+		lctx->rfc1964_kd.ctx_key.type = 4;
+	}
+#endif
+	printerr(2, "prepare_krb5_rfc1964_buffer: serializing keys with "
+		 "enctype %d and length %d\n",
+		 lctx->rfc1964_kd.ctx_key.type,
+		 lctx->rfc1964_kd.ctx_key.length);
+
+	/* derive the encryption key and copy it into buffer */
+	enc_key.type = lctx->rfc1964_kd.ctx_key.type;
+	enc_key.length = lctx->rfc1964_kd.ctx_key.length;
+	if ((enc_key.data = calloc(1, enc_key.length)) == NULL)
+		goto out_err;
+	skd = (char *) lctx->rfc1964_kd.ctx_key.data;
+	dkd = (char *) enc_key.data;
+	for (i = 0; i < enc_key.length; i++)
+		dkd[i] = skd[i] ^ 0xf0;
+	if (write_lucid_keyblock(&p, end, &enc_key)) {
+		free(enc_key.data);
+		goto out_err;
+	}
+	free(enc_key.data);
+
+	if (write_lucid_keyblock(&p, end, &lctx->rfc1964_kd.ctx_key))
+		goto out_err;
+
+	buf->length = p - (char *)buf->value;
+	return 0;
+out_err:
+	printerr(0, "ERROR: failed serializing krb5 context for kernel\n");
+	if (buf->value) free(buf->value);
+	buf->length = 0;
+	if (enc_key.data) free(enc_key.data);
+	return -1;
+}
+
+static int
+prepare_krb5_rfc_cfx_buffer(gss_krb5_lucid_context_v1_t *lctx,
+	gss_buffer_desc *buf)
+{
+	printerr(0, "ERROR: prepare_krb5_rfc_cfx_buffer: not implemented\n");
+	return -1;
+}
+
+
+int
+serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf)
+{
+	OM_uint32 maj_stat, min_stat;
+	void *return_ctx = 0;
+	OM_uint32 vers;
+	gss_krb5_lucid_context_v1_t *lctx = 0;
+	int retcode = 0;
+
+	printerr(2, "DEBUG: serialize_krb5_ctx: lucid version!\n");
+	maj_stat = gss_export_lucid_sec_context(&min_stat, &ctx,
+						1, &return_ctx);
+	if (maj_stat != GSS_S_COMPLETE) {
+		pgsserr("gss_export_lucid_sec_context",
+			maj_stat, min_stat, &krb5oid);
+		goto out_err;
+	}
+
+	/* Check the version returned, we only support v1 right now */
+	vers = ((gss_krb5_lucid_context_version_t *)return_ctx)->version;
+	switch (vers) {
+	case 1:
+		lctx = (gss_krb5_lucid_context_v1_t *) return_ctx;
+		break;
+	default:
+		printerr(0, "ERROR: unsupported lucid sec context version %d\n",
+			vers);
+		goto out_err;
+		break;
+	}
+
+	/* Now lctx points to a lucid context that we can send down to kernel */
+	if (lctx->protocol == 0)
+		retcode = prepare_krb5_rfc1964_buffer(lctx, buf);
+	else
+		retcode = prepare_krb5_rfc_cfx_buffer(lctx, buf);
+
+	maj_stat = gss_free_lucid_sec_context(&min_stat, ctx, return_ctx);
+	if (maj_stat != GSS_S_COMPLETE) {
+		pgsserr("gss_export_lucid_sec_context",
+			maj_stat, min_stat, &krb5oid);
+		printerr(0, "WARN: failed to free lucid sec context\n");
+	}
+
+	if (retcode) {
+		printerr(1, "serialize_krb5_ctx: prepare_krb5_*_buffer "
+			 "failed (retcode = %d)\n", retcode);
+		goto out_err;
+	}
+
+	return 0;
+
+out_err:
+	printerr(0, "ERROR: failed serializing krb5 context for kernel\n");
+	return -1;
+}
+#endif /* HAVE_LUCID_CONTEXT_SUPPORT */
diff --git a/utils/gssd/context_mit.c b/utils/gssd/context_mit.c
index 5eb900f..94b2266 100644
--- a/utils/gssd/context_mit.c
+++ b/utils/gssd/context_mit.c
@@ -29,6 +29,10 @@
 */
 
 #include "config.h"
+
+#ifndef HAVE_LUCID_CONTEXT_SUPPORT
+#ifdef HAVE_KRB5
+
 #include <stdio.h>
 #include <syslog.h>
 #include <string.h>
@@ -40,18 +44,9 @@ #include "gss_oids.h"
 #include "err_util.h"
 #include "context.h"
 
-#ifdef HAVE_KRB5
 #include <krb5.h>
 
-/* XXX spkm3 seems to actually want it this big, yipes. */
-#define MAX_CTX_LEN 4096
-
-#ifdef HAVE_LUCID_CONTEXT_SUPPORT
-
-/* Don't use the private structure, use the exported lucid structure */
-#include <gssapi/gssapi_krb5.h>
-
-#elif (KRB5_VERSION > 131)
+#if (KRB5_VERSION > 131)
 /* XXX argggg, there's gotta be a better way than just duplicating this
  * whole struct.  Unfortunately, this is in a "private" header file,
  * so this is our best choice at this point :-/
@@ -131,162 +126,6 @@ typedef struct _krb5_gss_ctx_id_rec {
 #endif /* KRB5_VERSION */
 
 
-#ifdef HAVE_LUCID_CONTEXT_SUPPORT /* Lucid context support */
-static int
-write_lucid_keyblock(char **p, char *end, gss_krb5_lucid_key_t *key)
-{
-	gss_buffer_desc tmp;
-
-	if (WRITE_BYTES(p, end, key->type)) return -1;
-	tmp.length = key->length;
-	tmp.value = key->data;
-	if (write_buffer(p, end, &tmp)) return -1;
-	return 0;
-}
-
-static int
-prepare_krb5_rfc1964_buffer(gss_krb5_lucid_context_v1_t *lctx,
-	gss_buffer_desc *buf)
-{
-	char *p, *end;
-	static int constant_zero = 0;
-	unsigned char fakeseed[16];
-	uint32_t word_send_seq;
-	gss_krb5_lucid_key_t enc_key;
-	int i;
-	char *skd, *dkd;
-	gss_buffer_desc fakeoid;
-
-	/*
-	 * The new Kerberos interface to get the gss context
-	 * does not include the seed or seed_init fields
-	 * because we never really use them.  But for now,
-	 * send down a fake buffer so we can use the same
-	 * interface to the kernel.
-	 */
-	memset(&enc_key, 0, sizeof(enc_key));
-	memset(&fakeoid, 0, sizeof(fakeoid));
-
-	if (!(buf->value = calloc(1, MAX_CTX_LEN)))
-		goto out_err;
-	p = buf->value;
-	end = buf->value + MAX_CTX_LEN;
-
-	if (WRITE_BYTES(&p, end, lctx->initiate)) goto out_err;
-
-	/* seed_init and seed not used by kernel anyway */
-	if (WRITE_BYTES(&p, end, constant_zero)) goto out_err;
-	if (write_bytes(&p, end, &fakeseed, 16)) goto out_err;
-
-	if (WRITE_BYTES(&p, end, lctx->rfc1964_kd.sign_alg)) goto out_err;
-	if (WRITE_BYTES(&p, end, lctx->rfc1964_kd.seal_alg)) goto out_err;
-	if (WRITE_BYTES(&p, end, lctx->endtime)) goto out_err;
-	word_send_seq = lctx->send_seq;	/* XXX send_seq is 64-bit */
-	if (WRITE_BYTES(&p, end, word_send_seq)) goto out_err;
-	if (write_oid(&p, end, &krb5oid)) goto out_err;
-
-	printerr(2, "prepare_krb5_rfc1964_buffer: serializing keys with "
-		 "enctype %d and length %d\n",
-		 lctx->rfc1964_kd.ctx_key.type,
-		 lctx->rfc1964_kd.ctx_key.length);
-
-	/* derive the encryption key and copy it into buffer */
-	enc_key.type = lctx->rfc1964_kd.ctx_key.type;
-	enc_key.length = lctx->rfc1964_kd.ctx_key.length;
-	if ((enc_key.data = calloc(1, enc_key.length)) == NULL)
-		goto out_err;
-	skd = (char *) lctx->rfc1964_kd.ctx_key.data;
-	dkd = (char *) enc_key.data;
-	for (i = 0; i < enc_key.length; i++)
-		dkd[i] = skd[i] ^ 0xf0;
-	if (write_lucid_keyblock(&p, end, &enc_key)) {
-		free(enc_key.data);
-		goto out_err;
-	}
-	free(enc_key.data);
-
-	if (write_lucid_keyblock(&p, end, &lctx->rfc1964_kd.ctx_key))
-		goto out_err;
-
-	buf->length = p - (char *)buf->value;
-	return 0;
-out_err:
-	printerr(0, "ERROR: failed serializing krb5 context for kernel\n");
-	if (buf->value) free(buf->value);
-	buf->length = 0;
-	if (enc_key.data) free(enc_key.data);
-	return -1;
-}
-
-static int
-prepare_krb5_rfc_cfx_buffer(gss_krb5_lucid_context_v1_t *lctx,
-	gss_buffer_desc *buf)
-{
-	printerr(0, "ERROR: prepare_krb5_rfc_cfx_buffer: not implemented\n");
-	return -1;
-}
-
-
-int
-serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf)
-{
-	OM_uint32 maj_stat, min_stat;
-	void *return_ctx = 0;
-	OM_uint32 vers;
-	gss_krb5_lucid_context_v1_t *lctx = 0;
-	int retcode = 0;
-
-	printerr(2, "DEBUG: serialize_krb5_ctx: lucid version!\n");
-	maj_stat = gss_export_lucid_sec_context(&min_stat, &ctx,
-						1, &return_ctx);
-	if (maj_stat != GSS_S_COMPLETE) {
-		pgsserr("gss_export_lucid_sec_context",
-			maj_stat, min_stat, &krb5oid);
-		goto out_err;
-	}
-
-	/* Check the version returned, we only support v1 right now */
-	vers = ((gss_krb5_lucid_context_version_t *)return_ctx)->version;
-	switch (vers) {
-	case 1:
-		lctx = (gss_krb5_lucid_context_v1_t *) return_ctx;
-		break;
-	default:
-		printerr(0, "ERROR: unsupported lucid sec context version %d\n",
-			vers);
-		goto out_err;
-		break;
-	}
-
-	/* Now lctx points to a lucid context that we can send down to kernel */
-	if (lctx->protocol == 0)
-		retcode = prepare_krb5_rfc1964_buffer(lctx, buf);
-	else
-		retcode = prepare_krb5_rfc_cfx_buffer(lctx, buf);
-
-	maj_stat = gss_free_lucid_sec_context(&min_stat, ctx, return_ctx);
-	if (maj_stat != GSS_S_COMPLETE) {
-		pgsserr("gss_export_lucid_sec_context",
-			maj_stat, min_stat, &krb5oid);
-		printerr(0, "WARN: failed to free lucid sec context\n");
-	}
-
-	if (retcode) {
-		printerr(1, "serialize_krb5_ctx: prepare_krb5_*_buffer "
-			 "failed (retcode = %d)\n", retcode);
-		goto out_err;
-	}
-
-	return 0;
-
-out_err:
-	printerr(0, "ERROR: failed serializing krb5 context for kernel\n");
-	return -1;
-}
-
-
-#else /* HAVE_LUCID_CONTEXT_SUPPORT */
-
 static int
 write_keyblock(char **p, char *end, struct _krb5_keyblock *arg)
 {
@@ -360,6 +199,6 @@ out_err:
 	buf->length = 0;
 	return -1;
 }
-#endif /* HAVE_LUCID_CONTEXT_SUPPORT */
 
 #endif /* HAVE_KRB5 */
+#endif /* HAVE_LUCID_CONTEXT_SUPPORT */

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
