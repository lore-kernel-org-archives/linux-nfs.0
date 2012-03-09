Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031011Ab2CITtw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 14:49:52 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q29Jnqrb029980
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 9 Mar 2012 14:49:52 -0500
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 3/7] Kill SPKM3: remove spkm3 from common gssd code
Date: Fri,  9 Mar 2012 14:49:42 -0500
Message-Id: <1331322586-4631-4-git-send-email-simo@redhat.com>
In-Reply-To: <1331322586-4631-1-git-send-email-simo@redhat.com>
References: <1331322586-4631-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/gssd/Makefile.am     |    1 -
 utils/gssd/context.c       |    4 -
 utils/gssd/context.h       |    2 -
 utils/gssd/context_spkm3.c |  184 --------------------------------------------
 4 files changed, 0 insertions(+), 191 deletions(-)
 delete mode 100644 utils/gssd/context_spkm3.c

diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index d29e132ab7191ed88ce625903c3afc651e4aca07..2365704c5db9b15d17f42b75adcb17f07f7e216f 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -17,7 +17,6 @@ COMMON_SRCS = \
 	context_mit.c \
 	context_heimdal.c \
 	context_lucid.c \
-	context_spkm3.c \
 	gss_util.c \
 	gss_oids.c \
 	err_util.c \
diff --git a/utils/gssd/context.c b/utils/gssd/context.c
index 1e50bbfd85d6073c8bea39e2ae84d36c0ee5fec9..fee7da27906e94b990fb7c49d73bf4f27a7003ac 100644
--- a/utils/gssd/context.c
+++ b/utils/gssd/context.c
@@ -51,10 +51,6 @@ serialize_context_for_kernel(gss_ctx_id_t ctx,
 {
 	if (g_OID_equal(&krb5oid, mech))
 		return serialize_krb5_ctx(ctx, buf, endtime);
-#ifdef HAVE_SPKM3_H
-	else if (g_OID_equal(&spkm3oid, mech))
-		return serialize_spkm3_ctx(ctx, buf, endtime);
-#endif
 	else {
 		printerr(0, "ERROR: attempting to serialize context with "
 				"unknown/unsupported mechanism oid\n");
diff --git a/utils/gssd/context.h b/utils/gssd/context.h
index c9cb0bd7496398e8304a1040bae8b7f30ea7d05a..0e437f4a34f0862b8f89bd0d6fe62c41a3a1c906 100644
--- a/utils/gssd/context.h
+++ b/utils/gssd/context.h
@@ -43,8 +43,6 @@
 
 int serialize_context_for_kernel(gss_ctx_id_t ctx, gss_buffer_desc *buf,
 				 gss_OID mech, int32_t *endtime);
-int serialize_spkm3_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf,
-			int32_t *endtime);
 int serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf,
 		       int32_t *endtime);
 
diff --git a/utils/gssd/context_spkm3.c b/utils/gssd/context_spkm3.c
deleted file mode 100644
index b927475c63692a7a5a6a1565151013595d83b643..0000000000000000000000000000000000000000
--- a/utils/gssd/context_spkm3.c
+++ /dev/null
@@ -1,184 +0,0 @@
-/*
-  Copyright (c) 2004 The Regents of the University of Michigan.
-  All rights reserved.
-
-  Redistribution and use in source and binary forms, with or without
-  modification, are permitted provided that the following conditions
-  are met:
-
-  1. Redistributions of source code must retain the above copyright
-     notice, this list of conditions and the following disclaimer.
-  2. Redistributions in binary form must reproduce the above copyright
-     notice, this list of conditions and the following disclaimer in the
-     documentation and/or other materials provided with the distribution.
-  3. Neither the name of the University nor the names of its
-     contributors may be used to endorse or promote products derived
-     from this software without specific prior written permission.
-
-  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
-  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
-  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
-  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
-  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-*/
-
-#ifdef HAVE_CONFIG_H
-#include <config.h>
-#endif	/* HAVE_CONFIG_H */
-
-#include <stdio.h>
-#include <syslog.h>
-#include <string.h>
-#include <gssapi/gssapi.h>
-#include <rpc/rpc.h>
-#include <rpc/auth_gss.h>
-#include "gss_util.h"
-#include "gss_oids.h"
-#include "err_util.h"
-#include "context.h"
-
-#ifdef HAVE_SPKM3_H
-
-#include <spkm3.h>
-
-/*
- * Function: prepare_spkm3_ctx_buffer()
- *
- * Prepare spkm3 lucid context for the kernel
- *
- *	buf->length should be:
- *
- *      version 4
- *	ctx_id 4 + 12
- *	qop 4
- *	mech_used 4 + 7
- *	ret_fl  4
- *	req_fl  4
- *      share   4 + key_len
- *      conf_alg 4 + oid_len
- *      d_conf_key 4 + key_len
- *      intg_alg 4 + oid_len
- *      d_intg_key 4 + key_len
- *      kyestb 4 + oid_len
- *      owl alg 4 + oid_len
-*/
-static int
-prepare_spkm3_ctx_buffer(gss_spkm3_lucid_ctx_t *lctx, gss_buffer_desc *buf)
-{
-	char *p, *end;
-	unsigned int buf_size = 0;
-
-	buf_size = sizeof(lctx->version) +
-		lctx->ctx_id.length + sizeof(lctx->ctx_id.length) +
-		sizeof(lctx->endtime) +
-		sizeof(lctx->mech_used.length) + lctx->mech_used.length +
-		sizeof(lctx->ret_flags) +
-		sizeof(lctx->conf_alg.length) + lctx->conf_alg.length +
-		sizeof(lctx->derived_conf_key.length) +
-		lctx->derived_conf_key.length +
-		sizeof(lctx->intg_alg.length) + lctx->intg_alg.length +
-		sizeof(lctx->derived_integ_key.length) +
-		lctx->derived_integ_key.length;
-
-	if (!(buf->value = calloc(1, buf_size)))
-		goto out_err;
-	p = buf->value;
-	end = buf->value + buf_size;
-
-	if (WRITE_BYTES(&p, end, lctx->version))
-		goto out_err;
-	printerr(2, "DEBUG: exporting version = %d\n", lctx->version);
-
-	if (write_buffer(&p, end, &lctx->ctx_id))
-		goto out_err;
-	printerr(2, "DEBUG: exporting ctx_id(%d)\n", lctx->ctx_id.length);
-
-	if (WRITE_BYTES(&p, end, lctx->endtime))
-		goto out_err;
-	printerr(2, "DEBUG: exporting endtime = %d\n", lctx->endtime);
-
-	if (write_buffer(&p, end, &lctx->mech_used))
-		goto out_err;
-	printerr(2, "DEBUG: exporting mech oid (%d)\n", lctx->mech_used.length);
-
-	if (WRITE_BYTES(&p, end, lctx->ret_flags))
-		goto out_err;
-	printerr(2, "DEBUG: exporting ret_flags = %d\n", lctx->ret_flags);
-
-	if (write_buffer(&p, end, &lctx->conf_alg))
-		goto out_err;
-	printerr(2, "DEBUG: exporting conf_alg oid (%d)\n", lctx->conf_alg.length);
-
-	if (write_buffer(&p, end, &lctx->derived_conf_key))
-		goto out_err;
-	printerr(2, "DEBUG: exporting conf key (%d)\n", lctx->derived_conf_key.length);
-
-	if (write_buffer(&p, end, &lctx->intg_alg))
-		goto out_err;
-	printerr(2, "DEBUG: exporting intg_alg oid (%d)\n", lctx->intg_alg.length);
-
-	if (write_buffer(&p, end, &lctx->derived_integ_key))
-		goto out_err;
-	printerr(2, "DEBUG: exporting intg key (%d)\n", lctx->derived_integ_key.length);
-
-	buf->length = p - (char *)buf->value;
-	return 0;
-out_err:
-	printerr(0, "ERROR: failed serializing spkm3 context for kernel\n");
-	if (buf->value) free(buf->value);
-	buf->length = 0;
-
-	return -1;
-}
-
-/* ANDROS: need to determine which fields of the spkm3_gss_ctx_id_desc_t
- * are needed in the kernel for get_mic, validate, wrap, unwrap, and destroy
- * and only export those fields to the kernel.
- */
-int
-serialize_spkm3_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
-{
-	OM_uint32 vers, ret, maj_stat, min_stat;
-	void *ret_ctx = 0;
-	gss_spkm3_lucid_ctx_t     *lctx;
-
-	printerr(1, "serialize_spkm3_ctx called\n");
-
-	printerr(2, "DEBUG: serialize_spkm3_ctx: lucid version!\n");
-	maj_stat = gss_export_lucid_sec_context(&min_stat, &ctx, 1, &ret_ctx);
-	if (maj_stat != GSS_S_COMPLETE)
-		goto out_err;
-
-	lctx = (gss_spkm3_lucid_ctx_t *)ret_ctx;
-
-	vers = lctx->version;
-	if (vers != 1) {
-		printerr(0, "ERROR: unsupported spkm3 context version %d\n",
-			vers);
-		goto out_err;
-	}
-	ret = prepare_spkm3_ctx_buffer(lctx, buf);
-
-	if (endtime)
-		*endtime = lctx->endtime;
-
-	maj_stat = gss_free_lucid_sec_context(&min_stat, ctx, ret_ctx);
-
-	if (maj_stat != GSS_S_COMPLETE)
-		printerr(0, "WARN: failed to free lucid sec context\n");
-	if (ret)
-		goto out_err;
-	printerr(2, "DEBUG: serialize_spkm3_ctx: success\n");
-	return 0;
-
-out_err:
-	printerr(2, "DEBUG: serialize_spkm3_ctx: failed\n");
-	return -1;
-}
-#endif /* HAVE_SPKM3_H */
-- 
1.7.7.6

