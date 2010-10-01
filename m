Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46575 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902Ab0JATwF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 15:52:05 -0400
Received: from bfields by fieldses.org with local (Exim 4.71)
	(envelope-from <bfields@fieldses.org>)
	id 1P1le2-0001HV-83
	for linux-nfs@vger.kernel.org; Fri, 01 Oct 2010 15:51:50 -0400
Date: Fri, 1 Oct 2010 15:51:50 -0400
To: linux-nfs@vger.kernel.org
Subject: spkm3 removal
Message-ID: <20101001195150.GB1472@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Shall we go ahead and remove this?

Somebody stumbled across a security problem in the spkm3 code
recently--unexploitable, as far as I can tell, since you'd need an spkm3
context first, and those are hard to come by....  But I feel a little
bad leaving this code around for innocent bystanders to waste their time
auditing.

The only remaining references I find:

bfields@pepper:linux-2.6$ git grep -i spkm3
arch/arm/configs/pnx4008_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/mips/configs/bcm47xx_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/mips/configs/bigsur_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/mips/configs/jazz_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/mips/configs/mtx1_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/mips/configs/rm200_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/parisc/configs/712_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/parisc/configs/a500_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/parisc/configs/default_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/powerpc/configs/c2k_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/powerpc/configs/iseries_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/powerpc/configs/ppc64_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/powerpc/configs/ppc64e_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/powerpc/configs/ppc6xx_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/powerpc/configs/pseries_defconfig:CONFIG_RPCSEC_GSS_SPKM3=m
arch/xtensa/configs/common_defconfig:# CONFIG_RPCSEC_GSS_SPKM3 is not set

No idea what to do about those.

fs/nfs/super.c: { Opt_sec_spkm, "spkm3" },
fs/nfs/super.c: { Opt_sec_spkmi, "spkm3i" },
fs/nfs/super.c: { Opt_sec_spkmp, "spkm3p" },

Should those mount options be removed to?  They could be done in a
followup patch, I guess.

And then there's a couple comments.

There's also a bunch of glue code we could remove later if we assume
there's only one gss mechanism--but I'd rather leave that in.

--b.

commit a069e192e1e396d5a80add73c30bc43a0f7353f1
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Oct 1 15:40:01 2010 -0400

    nfsd4: remove spkm3
    
    Unfortunately, spkm3 never got very far; while interoperability with one
    other implementation was demonstrated at some point, problems were found
    with the spec that were deemed not worth fixing.
    
    The kernel code is useless on its own without nfs-utils patches which
    were never merged into nfs-utils, and were only ever available from
    citi.umich.edu.  They appear not to have been updated since 2005.
    
    Therefore it seems safe to assume that this code has no users, and never
    will.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/include/linux/sunrpc/gss_spkm3.h b/include/linux/sunrpc/gss_spkm3.h
deleted file mode 100644
index e3e6a34..0000000
--- a/include/linux/sunrpc/gss_spkm3.h
+++ /dev/null
@@ -1,55 +0,0 @@
-/*
- *  linux/include/linux/sunrpc/gss_spkm3.h
- *
- *  Copyright (c) 2000 The Regents of the University of Michigan.
- *  All rights reserved.
- *
- *  Andy Adamson   <andros@umich.edu>
- */
-
-#include <linux/sunrpc/auth_gss.h>
-#include <linux/sunrpc/gss_err.h>
-#include <linux/sunrpc/gss_asn1.h>
-
-struct spkm3_ctx {
-	struct xdr_netobj	ctx_id;  /* per message context id */
-	int			endtime; /* endtime of the context */
-	struct xdr_netobj	mech_used;
-	unsigned int		ret_flags ;
-	struct xdr_netobj	conf_alg;
-	struct xdr_netobj	derived_conf_key;
-	struct xdr_netobj	intg_alg;
-	struct xdr_netobj 	derived_integ_key;
-};
-
-/* OIDs declarations for K-ALG, I-ALG, C-ALG, and OWF-ALG */
-extern const struct xdr_netobj hmac_md5_oid;
-extern const struct xdr_netobj cast5_cbc_oid;
-
-/* SPKM InnerContext Token types */
-
-#define SPKM_ERROR_TOK	3
-#define SPKM_MIC_TOK	4
-#define SPKM_WRAP_TOK	5
-#define SPKM_DEL_TOK	6
-
-u32 spkm3_make_token(struct spkm3_ctx *ctx, struct xdr_buf * text, struct xdr_netobj * token, int toktype);
-
-u32 spkm3_read_token(struct spkm3_ctx *ctx, struct xdr_netobj *read_token, struct xdr_buf *message_buffer, int toktype);
-
-#define CKSUMTYPE_RSA_MD5            0x0007
-#define CKSUMTYPE_HMAC_MD5           0x0008
-
-s32 make_spkm3_checksum(s32 cksumtype, struct xdr_netobj *key, char *header,
-		unsigned int hdrlen, struct xdr_buf *body,
-		unsigned int body_offset, struct xdr_netobj *cksum);
-void asn1_bitstring_len(struct xdr_netobj *in, int *enclen, int *zerobits);
-int decode_asn1_bitstring(struct xdr_netobj *out, char *in, int enclen,
-                   int explen);
-void spkm3_mic_header(unsigned char **hdrbuf, unsigned int *hdrlen, 
-                   unsigned char *ctxhdr, int elen, int zbit);
-void spkm3_make_mic_token(unsigned  char **tokp, int toklen, 
-                   struct xdr_netobj *mic_hdr,
-                   struct xdr_netobj *md5cksum, int md5elen, int md5zbit);
-u32 spkm3_verify_mic_token(unsigned char **tokp, int *mic_hdrlen, 
-                   unsigned char **cksum);
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 3376d76..8873fd8 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -36,22 +36,3 @@ config RPCSEC_GSS_KRB5
 	  Kerberos support should be installed.
 
 	  If unsure, say Y.
-
-config RPCSEC_GSS_SPKM3
-	tristate "Secure RPC: SPKM3 mechanism (EXPERIMENTAL)"
-	depends on SUNRPC && EXPERIMENTAL
-	select SUNRPC_GSS
-	select CRYPTO
-	select CRYPTO_MD5
-	select CRYPTO_DES
-	select CRYPTO_CAST5
-	select CRYPTO_CBC
-	help
-	  Choose Y here to enable Secure RPC using the SPKM3 public key
-	  GSS-API mechanism (RFC 2025).
-
-	  Secure RPC calls with SPKM3 require an auxiliary userspace
-	  daemon which may be found in the Linux nfs-utils package
-	  available from http://linux-nfs.org/.
-
-	  If unsure, say N.
diff --git a/net/sunrpc/auth_gss/Makefile b/net/sunrpc/auth_gss/Makefile
index 74a2317..7350d86 100644
--- a/net/sunrpc/auth_gss/Makefile
+++ b/net/sunrpc/auth_gss/Makefile
@@ -11,8 +11,3 @@ obj-$(CONFIG_RPCSEC_GSS_KRB5) += rpcsec_gss_krb5.o
 
 rpcsec_gss_krb5-objs := gss_krb5_mech.o gss_krb5_seal.o gss_krb5_unseal.o \
 	gss_krb5_seqnum.o gss_krb5_wrap.o gss_krb5_crypto.o gss_krb5_keys.o
-
-obj-$(CONFIG_RPCSEC_GSS_SPKM3) += rpcsec_gss_spkm3.o
-
-rpcsec_gss_spkm3-objs := gss_spkm3_mech.o gss_spkm3_seal.o gss_spkm3_unseal.o \
-	gss_spkm3_token.o
diff --git a/net/sunrpc/auth_gss/gss_spkm3_mech.c b/net/sunrpc/auth_gss/gss_spkm3_mech.c
deleted file mode 100644
index adade3d..0000000
--- a/net/sunrpc/auth_gss/gss_spkm3_mech.c
+++ /dev/null
@@ -1,247 +0,0 @@
-/*
- *  linux/net/sunrpc/gss_spkm3_mech.c
- *
- *  Copyright (c) 2003 The Regents of the University of Michigan.
- *  All rights reserved.
- *
- *  Andy Adamson <andros@umich.edu>
- *  J. Bruce Fields <bfields@umich.edu>
- *
- *  Redistribution and use in source and binary forms, with or without
- *  modification, are permitted provided that the following conditions
- *  are met:
- *
- *  1. Redistributions of source code must retain the above copyright
- *     notice, this list of conditions and the following disclaimer.
- *  2. Redistributions in binary form must reproduce the above copyright
- *     notice, this list of conditions and the following disclaimer in the
- *     documentation and/or other materials provided with the distribution.
- *  3. Neither the name of the University nor the names of its
- *     contributors may be used to endorse or promote products derived
- *     from this software without specific prior written permission.
- *
- *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
- *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
- *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
- *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
- *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
- *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
- *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
- *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
- *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- *
- */
-
-#include <linux/err.h>
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/types.h>
-#include <linux/slab.h>
-#include <linux/sunrpc/auth.h>
-#include <linux/in.h>
-#include <linux/sunrpc/svcauth_gss.h>
-#include <linux/sunrpc/gss_spkm3.h>
-#include <linux/sunrpc/xdr.h>
-#include <linux/crypto.h>
-
-#ifdef RPC_DEBUG
-# define RPCDBG_FACILITY	RPCDBG_AUTH
-#endif
-
-static const void *
-simple_get_bytes(const void *p, const void *end, void *res, int len)
-{
-	const void *q = (const void *)((const char *)p + len);
-	if (unlikely(q > end || q < p))
-		return ERR_PTR(-EFAULT);
-	memcpy(res, p, len);
-	return q;
-}
-
-static const void *
-simple_get_netobj(const void *p, const void *end, struct xdr_netobj *res)
-{
-	const void *q;
-	unsigned int len;
-	p = simple_get_bytes(p, end, &len, sizeof(len));
-	if (IS_ERR(p))
-		return p;
-	res->len = len;
-	if (len == 0) {
-		res->data = NULL;
-		return p;
-	}
-	q = (const void *)((const char *)p + len);
-	if (unlikely(q > end || q < p))
-		return ERR_PTR(-EFAULT);
-	res->data = kmemdup(p, len, GFP_NOFS);
-	if (unlikely(res->data == NULL))
-		return ERR_PTR(-ENOMEM);
-	return q;
-}
-
-static int
-gss_import_sec_context_spkm3(const void *p, size_t len,
-				struct gss_ctx *ctx_id,
-				gfp_t gfp_mask)
-{
-	const void *end = (const void *)((const char *)p + len);
-	struct	spkm3_ctx *ctx;
-	int	version;
-
-	if (!(ctx = kzalloc(sizeof(*ctx), gfp_mask)))
-		goto out_err;
-
-	p = simple_get_bytes(p, end, &version, sizeof(version));
-	if (IS_ERR(p))
-		goto out_err_free_ctx;
-	if (version != 1) {
-		dprintk("RPC:       unknown spkm3 token format: "
-				"obsolete nfs-utils?\n");
-		p = ERR_PTR(-EINVAL);
-		goto out_err_free_ctx;
-	}
-
-	p = simple_get_netobj(p, end, &ctx->ctx_id);
-	if (IS_ERR(p))
-		goto out_err_free_ctx;
-
-	p = simple_get_bytes(p, end, &ctx->endtime, sizeof(ctx->endtime));
-	if (IS_ERR(p))
-		goto out_err_free_ctx_id;
-
-	p = simple_get_netobj(p, end, &ctx->mech_used);
-	if (IS_ERR(p))
-		goto out_err_free_ctx_id;
-
-	p = simple_get_bytes(p, end, &ctx->ret_flags, sizeof(ctx->ret_flags));
-	if (IS_ERR(p))
-		goto out_err_free_mech;
-
-	p = simple_get_netobj(p, end, &ctx->conf_alg);
-	if (IS_ERR(p))
-		goto out_err_free_mech;
-
-	p = simple_get_netobj(p, end, &ctx->derived_conf_key);
-	if (IS_ERR(p))
-		goto out_err_free_conf_alg;
-
-	p = simple_get_netobj(p, end, &ctx->intg_alg);
-	if (IS_ERR(p))
-		goto out_err_free_conf_key;
-
-	p = simple_get_netobj(p, end, &ctx->derived_integ_key);
-	if (IS_ERR(p))
-		goto out_err_free_intg_alg;
-
-	if (p != end) {
-		p = ERR_PTR(-EFAULT);
-		goto out_err_free_intg_key;
-	}
-
-	ctx_id->internal_ctx_id = ctx;
-
-	dprintk("RPC:       Successfully imported new spkm context.\n");
-	return 0;
-
-out_err_free_intg_key:
-	kfree(ctx->derived_integ_key.data);
-out_err_free_intg_alg:
-	kfree(ctx->intg_alg.data);
-out_err_free_conf_key:
-	kfree(ctx->derived_conf_key.data);
-out_err_free_conf_alg:
-	kfree(ctx->conf_alg.data);
-out_err_free_mech:
-	kfree(ctx->mech_used.data);
-out_err_free_ctx_id:
-	kfree(ctx->ctx_id.data);
-out_err_free_ctx:
-	kfree(ctx);
-out_err:
-	return PTR_ERR(p);
-}
-
-static void
-gss_delete_sec_context_spkm3(void *internal_ctx)
-{
-	struct spkm3_ctx *sctx = internal_ctx;
-
-	kfree(sctx->derived_integ_key.data);
-	kfree(sctx->intg_alg.data);
-	kfree(sctx->derived_conf_key.data);
-	kfree(sctx->conf_alg.data);
-	kfree(sctx->mech_used.data);
-	kfree(sctx->ctx_id.data);
-	kfree(sctx);
-}
-
-static u32
-gss_verify_mic_spkm3(struct gss_ctx		*ctx,
-			struct xdr_buf		*signbuf,
-			struct xdr_netobj	*checksum)
-{
-	u32 maj_stat = 0;
-	struct spkm3_ctx *sctx = ctx->internal_ctx_id;
-
-	maj_stat = spkm3_read_token(sctx, checksum, signbuf, SPKM_MIC_TOK);
-
-	dprintk("RPC:       gss_verify_mic_spkm3 returning %d\n", maj_stat);
-	return maj_stat;
-}
-
-static u32
-gss_get_mic_spkm3(struct gss_ctx	*ctx,
-		     struct xdr_buf	*message_buffer,
-		     struct xdr_netobj	*message_token)
-{
-	u32 err = 0;
-	struct spkm3_ctx *sctx = ctx->internal_ctx_id;
-
-	err = spkm3_make_token(sctx, message_buffer,
-				message_token, SPKM_MIC_TOK);
-	dprintk("RPC:       gss_get_mic_spkm3 returning %d\n", err);
-	return err;
-}
-
-static const struct gss_api_ops gss_spkm3_ops = {
-	.gss_import_sec_context	= gss_import_sec_context_spkm3,
-	.gss_get_mic		= gss_get_mic_spkm3,
-	.gss_verify_mic		= gss_verify_mic_spkm3,
-	.gss_delete_sec_context	= gss_delete_sec_context_spkm3,
-};
-
-static struct pf_desc gss_spkm3_pfs[] = {
-	{RPC_AUTH_GSS_SPKM, RPC_GSS_SVC_NONE, "spkm3"},
-	{RPC_AUTH_GSS_SPKMI, RPC_GSS_SVC_INTEGRITY, "spkm3i"},
-};
-
-static struct gss_api_mech gss_spkm3_mech = {
-	.gm_name	= "spkm3",
-	.gm_owner	= THIS_MODULE,
-	.gm_oid		= {7, "\053\006\001\005\005\001\003"},
-	.gm_ops		= &gss_spkm3_ops,
-	.gm_pf_num	= ARRAY_SIZE(gss_spkm3_pfs),
-	.gm_pfs		= gss_spkm3_pfs,
-};
-
-static int __init init_spkm3_module(void)
-{
-	int status;
-
-	status = gss_mech_register(&gss_spkm3_mech);
-	if (status)
-		printk("Failed to register spkm3 gss mechanism!\n");
-	return status;
-}
-
-static void __exit cleanup_spkm3_module(void)
-{
-	gss_mech_unregister(&gss_spkm3_mech);
-}
-
-MODULE_LICENSE("GPL");
-module_init(init_spkm3_module);
-module_exit(cleanup_spkm3_module);
diff --git a/net/sunrpc/auth_gss/gss_spkm3_seal.c b/net/sunrpc/auth_gss/gss_spkm3_seal.c
deleted file mode 100644
index 5a3a65a..0000000
--- a/net/sunrpc/auth_gss/gss_spkm3_seal.c
+++ /dev/null
@@ -1,186 +0,0 @@
-/*
- *  linux/net/sunrpc/gss_spkm3_seal.c
- *
- *  Copyright (c) 2003 The Regents of the University of Michigan.
- *  All rights reserved.
- *
- *  Andy Adamson <andros@umich.edu>
- *
- *  Redistribution and use in source and binary forms, with or without
- *  modification, are permitted provided that the following conditions
- *  are met:
- *
- *  1. Redistributions of source code must retain the above copyright
- *     notice, this list of conditions and the following disclaimer.
- *  2. Redistributions in binary form must reproduce the above copyright
- *     notice, this list of conditions and the following disclaimer in the
- *     documentation and/or other materials provided with the distribution.
- *  3. Neither the name of the University nor the names of its
- *     contributors may be used to endorse or promote products derived
- *     from this software without specific prior written permission.
- *
- *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
- *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
- *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
- *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
- *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
- *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
- *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
- *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
- *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- *
- */
-
-#include <linux/types.h>
-#include <linux/jiffies.h>
-#include <linux/sunrpc/gss_spkm3.h>
-#include <linux/random.h>
-#include <linux/crypto.h>
-#include <linux/pagemap.h>
-#include <linux/scatterlist.h>
-#include <linux/sunrpc/xdr.h>
-
-#ifdef RPC_DEBUG
-# define RPCDBG_FACILITY        RPCDBG_AUTH
-#endif
-
-const struct xdr_netobj hmac_md5_oid = { 8, "\x2B\x06\x01\x05\x05\x08\x01\x01"};
-const struct xdr_netobj cast5_cbc_oid = {9, "\x2A\x86\x48\x86\xF6\x7D\x07\x42\x0A"};
-
-/*
- * spkm3_make_token()
- *
- * Only SPKM_MIC_TOK with md5 intg-alg is supported
- */
-
-u32
-spkm3_make_token(struct spkm3_ctx *ctx,
-		   struct xdr_buf * text, struct xdr_netobj * token,
-		   int toktype)
-{
-	s32			checksum_type;
-	char			tokhdrbuf[25];
-	char			cksumdata[16];
-	struct xdr_netobj	md5cksum = {.len = 0, .data = cksumdata};
-	struct xdr_netobj	mic_hdr = {.len = 0, .data = tokhdrbuf};
-	int			tokenlen = 0;
-	unsigned char		*ptr;
-	s32			now;
-	int			ctxelen = 0, ctxzbit = 0;
-	int			md5elen = 0, md5zbit = 0;
-
-	now = jiffies;
-
-	if (ctx->ctx_id.len != 16) {
-		dprintk("RPC:       spkm3_make_token BAD ctx_id.len %d\n",
-				ctx->ctx_id.len);
-		goto out_err;
-	}
-
-	if (!g_OID_equal(&ctx->intg_alg, &hmac_md5_oid)) {
-		dprintk("RPC:       gss_spkm3_seal: unsupported I-ALG "
-				"algorithm.  only support hmac-md5 I-ALG.\n");
-		goto out_err;
-	} else
-		checksum_type = CKSUMTYPE_HMAC_MD5;
-
-	if (!g_OID_equal(&ctx->conf_alg, &cast5_cbc_oid)) {
-		dprintk("RPC:       gss_spkm3_seal: unsupported C-ALG "
-				"algorithm\n");
-		goto out_err;
-	}
-
-	if (toktype == SPKM_MIC_TOK) {
-		/* Calculate checksum over the mic-header */
-		asn1_bitstring_len(&ctx->ctx_id, &ctxelen, &ctxzbit);
-		spkm3_mic_header(&mic_hdr.data, &mic_hdr.len, ctx->ctx_id.data,
-				ctxelen, ctxzbit);
-		if (make_spkm3_checksum(checksum_type, &ctx->derived_integ_key,
-					(char *)mic_hdr.data, mic_hdr.len,
-					text, 0, &md5cksum))
-			goto out_err;
-
-		asn1_bitstring_len(&md5cksum, &md5elen, &md5zbit);
-		tokenlen = 10 + ctxelen + 1 + md5elen + 1;
-
-		/* Create token header using generic routines */
-		token->len = g_token_size(&ctx->mech_used, tokenlen + 2);
-
-		ptr = token->data;
-		g_make_token_header(&ctx->mech_used, tokenlen + 2, &ptr);
-
-		spkm3_make_mic_token(&ptr, tokenlen, &mic_hdr, &md5cksum, md5elen, md5zbit);
-	} else if (toktype == SPKM_WRAP_TOK) { /* Not Supported */
-		dprintk("RPC:       gss_spkm3_seal: SPKM_WRAP_TOK "
-				"not supported\n");
-		goto out_err;
-	}
-
-	/* XXX need to implement sequence numbers, and ctx->expired */
-
-	return  GSS_S_COMPLETE;
-out_err:
-	token->data = NULL;
-	token->len = 0;
-	return GSS_S_FAILURE;
-}
-
-static int
-spkm3_checksummer(struct scatterlist *sg, void *data)
-{
-	struct hash_desc *desc = data;
-
-	return crypto_hash_update(desc, sg, sg->length);
-}
-
-/* checksum the plaintext data and hdrlen bytes of the token header */
-s32
-make_spkm3_checksum(s32 cksumtype, struct xdr_netobj *key, char *header,
-		    unsigned int hdrlen, struct xdr_buf *body,
-		    unsigned int body_offset, struct xdr_netobj *cksum)
-{
-	char				*cksumname;
-	struct hash_desc		desc; /* XXX add to ctx? */
-	struct scatterlist		sg[1];
-	int err;
-
-	switch (cksumtype) {
-		case CKSUMTYPE_HMAC_MD5:
-			cksumname = "hmac(md5)";
-			break;
-		default:
-			dprintk("RPC:       spkm3_make_checksum:"
-					" unsupported checksum %d", cksumtype);
-			return GSS_S_FAILURE;
-	}
-
-	if (key->data == NULL || key->len <= 0) return GSS_S_FAILURE;
-
-	desc.tfm = crypto_alloc_hash(cksumname, 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(desc.tfm))
-		return GSS_S_FAILURE;
-	cksum->len = crypto_hash_digestsize(desc.tfm);
-	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
-
-	err = crypto_hash_setkey(desc.tfm, key->data, key->len);
-	if (err)
-		goto out;
-
-	err = crypto_hash_init(&desc);
-	if (err)
-		goto out;
-
-	sg_init_one(sg, header, hdrlen);
-	crypto_hash_update(&desc, sg, sg->length);
-
-	xdr_process_buf(body, body_offset, body->len - body_offset,
-			spkm3_checksummer, &desc);
-	crypto_hash_final(&desc, cksum->data);
-
-out:
-	crypto_free_hash(desc.tfm);
-
-	return err ? GSS_S_FAILURE : 0;
-}
diff --git a/net/sunrpc/auth_gss/gss_spkm3_token.c b/net/sunrpc/auth_gss/gss_spkm3_token.c
deleted file mode 100644
index a99825d..0000000
--- a/net/sunrpc/auth_gss/gss_spkm3_token.c
+++ /dev/null
@@ -1,267 +0,0 @@
-/*
- *  linux/net/sunrpc/gss_spkm3_token.c
- *
- *  Copyright (c) 2003 The Regents of the University of Michigan.
- *  All rights reserved.
- *
- *  Andy Adamson <andros@umich.edu>
- *
- *  Redistribution and use in source and binary forms, with or without
- *  modification, are permitted provided that the following conditions
- *  are met:
- *
- *  1. Redistributions of source code must retain the above copyright
- *     notice, this list of conditions and the following disclaimer.
- *  2. Redistributions in binary form must reproduce the above copyright
- *     notice, this list of conditions and the following disclaimer in the
- *     documentation and/or other materials provided with the distribution.
- *  3. Neither the name of the University nor the names of its
- *     contributors may be used to endorse or promote products derived
- *     from this software without specific prior written permission.
- *
- *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
- *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
- *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
- *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
- *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
- *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
- *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
- *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
- *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- *
- */
-
-#include <linux/types.h>
-#include <linux/slab.h>
-#include <linux/jiffies.h>
-#include <linux/sunrpc/gss_spkm3.h>
-#include <linux/random.h>
-#include <linux/crypto.h>
-
-#ifdef RPC_DEBUG
-# define RPCDBG_FACILITY        RPCDBG_AUTH
-#endif
-
-/*
- * asn1_bitstring_len()
- *
- * calculate the asn1 bitstring length of the xdr_netobject
- */
-void
-asn1_bitstring_len(struct xdr_netobj *in, int *enclen, int *zerobits)
-{
-	int i, zbit = 0,elen = in->len;
-	char *ptr;
-
-	ptr = &in->data[in->len -1];
-
-	/* count trailing 0's */
-	for(i = in->len; i > 0; i--) {
-		if (*ptr == 0) {
-			ptr--;
-			elen--;
-		} else
-			break;
-	}
-
-	/* count number of 0 bits in final octet */
-	ptr = &in->data[elen - 1];
-	for(i = 0; i < 8; i++) {
-		short mask = 0x01;
-
-		if (!((mask << i) & *ptr))
-			zbit++;
-		else
-			break;
-	}
-	*enclen = elen;
-	*zerobits = zbit;
-}
-
-/*
- * decode_asn1_bitstring()
- *
- * decode a bitstring into a buffer of the expected length.
- * enclen = bit string length
- * explen = expected length (define in rfc)
- */
-int
-decode_asn1_bitstring(struct xdr_netobj *out, char *in, int enclen, int explen)
-{
-	if (!(out->data = kzalloc(explen,GFP_NOFS)))
-		return 0;
-	out->len = explen;
-	memcpy(out->data, in, enclen);
-	return 1;
-}
-
-/*
- * SPKMInnerContextToken choice SPKM_MIC asn1 token layout
- *
- * contextid is always 16 bytes plain data. max asn1 bitstring len = 17.
- *
- * tokenlen = pos[0] to end of token (max pos[45] with MD5 cksum)
- *
- * pos  value
- * ----------
- * [0]	a4  SPKM-MIC tag
- * [1]	??  innertoken length  (max 44)
- *
- *
- * tok_hdr piece of checksum data starts here
- *
- * the maximum mic-header len = 9 + 17 = 26
- *	mic-header
- *	----------
- * [2]	30      SEQUENCE tag
- * [3]	??	mic-header length: (max 23) = TokenID + ContextID
- *
- *		TokenID  - all fields constant and can be hardcoded
- *		-------
- * [4]	  02	Type 2
- * [5]	  02	Length 2
- * [6][7] 01 01	TokenID (SPKM_MIC_TOK)
- *
- *		ContextID  - encoded length not constant, calculated
- *		---------
- * [8]	03	Type 3
- * [9]	??	encoded length
- * [10]	??	ctxzbit
- * [11]	 	contextid
- *
- * mic_header piece of checksum data ends here.
- *
- *	int-cksum - encoded length not constant, calculated
- *	---------
- * [??]	03	Type 3
- * [??]	??	encoded length
- * [??]	??	md5zbit
- * [??]	 	int-cksum (NID_md5 = 16)
- *
- * maximum SPKM-MIC innercontext token length =
- *	 10 + encoded contextid_size(17 max) + 2 + encoded
- *       cksum_size (17 maxfor NID_md5) = 46
- */
-
-/*
- * spkm3_mic_header()
- *
- * Prepare the SPKM_MIC_TOK mic-header for check-sum calculation
- * elen: 16 byte context id asn1 bitstring encoded length
- */
-void
-spkm3_mic_header(unsigned char **hdrbuf, unsigned int *hdrlen, unsigned char *ctxdata, int elen, int zbit)
-{
-	char *hptr = *hdrbuf;
-	char *top = *hdrbuf;
-
-	*(u8 *)hptr++ = 0x30;
-	*(u8 *)hptr++ = elen + 7;  /* on the wire header length */
-
-	/* tokenid */
-	*(u8 *)hptr++ = 0x02;
-	*(u8 *)hptr++ = 0x02;
-	*(u8 *)hptr++ = 0x01;
-	*(u8 *)hptr++ = 0x01;
-
-	/* coniextid */
-	*(u8 *)hptr++ = 0x03;
-	*(u8 *)hptr++ = elen + 1; /* add 1 to include zbit */
-	*(u8 *)hptr++ = zbit;
-	memcpy(hptr, ctxdata, elen);
-	hptr += elen;
-	*hdrlen = hptr - top;
-}
-
-/*
- * spkm3_mic_innercontext_token()
- *
- * *tokp points to the beginning of the SPKM_MIC token  described
- * in rfc 2025, section 3.2.1:
- *
- * toklen is the inner token length
- */
-void
-spkm3_make_mic_token(unsigned char **tokp, int toklen, struct xdr_netobj *mic_hdr, struct xdr_netobj *md5cksum, int md5elen, int md5zbit)
-{
-	unsigned char *ict = *tokp;
-
-	*(u8 *)ict++ = 0xa4;
-	*(u8 *)ict++ = toklen;
-	memcpy(ict, mic_hdr->data, mic_hdr->len);
-	ict += mic_hdr->len;
-
-	*(u8 *)ict++ = 0x03;
-	*(u8 *)ict++ = md5elen + 1; /* add 1 to include zbit */
-	*(u8 *)ict++ = md5zbit;
-	memcpy(ict, md5cksum->data, md5elen);
-}
-
-u32
-spkm3_verify_mic_token(unsigned char **tokp, int *mic_hdrlen, unsigned char **cksum)
-{
-	struct xdr_netobj       spkm3_ctx_id = {.len =0, .data = NULL};
-	unsigned char 		*ptr = *tokp;
-	int 			ctxelen;
-	u32     		ret = GSS_S_DEFECTIVE_TOKEN;
-
-	/* spkm3 innercontext token preamble */
-	if ((ptr[0] != 0xa4) || (ptr[2] != 0x30)) {
-		dprintk("RPC:       BAD SPKM ictoken preamble\n");
-		goto out;
-	}
-
-	*mic_hdrlen = ptr[3];
-
-	/* token type */
-	if ((ptr[4] != 0x02) || (ptr[5] != 0x02)) {
-		dprintk("RPC:       BAD asn1 SPKM3 token type\n");
-		goto out;
-	}
-
-	/* only support SPKM_MIC_TOK */
-	if((ptr[6] != 0x01) || (ptr[7] != 0x01)) {
-		dprintk("RPC:       ERROR unsupported SPKM3 token\n");
-		goto out;
-	}
-
-	/* contextid */
-	if (ptr[8] != 0x03) {
-		dprintk("RPC:       BAD SPKM3 asn1 context-id type\n");
-		goto out;
-	}
-
-	ctxelen = ptr[9];
-	if (ctxelen > 17) {  /* length includes asn1 zbit octet */
-		dprintk("RPC:       BAD SPKM3 contextid len %d\n", ctxelen);
-		goto out;
-	}
-
-	/* ignore ptr[10] */
-
-	if(!decode_asn1_bitstring(&spkm3_ctx_id, &ptr[11], ctxelen - 1, 16))
-		goto out;
-
-	/*
-	* in the current implementation: the optional int-alg is not present
-	* so the default int-alg (md5) is used the optional snd-seq field is
-	* also not present
-	*/
-
-	if (*mic_hdrlen != 6 + ctxelen) {
-		dprintk("RPC:       BAD SPKM_ MIC_TOK header len %d: we only "
-				"support default int-alg (should be absent) "
-				"and do not support snd-seq\n", *mic_hdrlen);
-		goto out;
-	}
-	/* checksum */
-	*cksum = (&ptr[10] + ctxelen); /* ctxelen includes ptr[10] */
-
-	ret = GSS_S_COMPLETE;
-out:
-	kfree(spkm3_ctx_id.data);
-	return ret;
-}
-
diff --git a/net/sunrpc/auth_gss/gss_spkm3_unseal.c b/net/sunrpc/auth_gss/gss_spkm3_unseal.c
deleted file mode 100644
index cc21ee8..0000000
--- a/net/sunrpc/auth_gss/gss_spkm3_unseal.c
+++ /dev/null
@@ -1,127 +0,0 @@
-/*
- *  linux/net/sunrpc/gss_spkm3_unseal.c
- *
- *  Copyright (c) 2003 The Regents of the University of Michigan.
- *  All rights reserved.
- *
- *  Andy Adamson <andros@umich.edu>
- *
- *  Redistribution and use in source and binary forms, with or without
- *  modification, are permitted provided that the following conditions
- *  are met:
- *
- *  1. Redistributions of source code must retain the above copyright
- *     notice, this list of conditions and the following disclaimer.
- *  2. Redistributions in binary form must reproduce the above copyright
- *     notice, this list of conditions and the following disclaimer in the
- *     documentation and/or other materials provided with the distribution.
- *  3. Neither the name of the University nor the names of its
- *     contributors may be used to endorse or promote products derived
- *     from this software without specific prior written permission.
- *
- *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
- *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
- *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
- *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
- *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
- *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
- *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
- *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
- *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- *
- */
-
-#include <linux/types.h>
-#include <linux/slab.h>
-#include <linux/jiffies.h>
-#include <linux/sunrpc/gss_spkm3.h>
-#include <linux/crypto.h>
-
-#ifdef RPC_DEBUG
-# define RPCDBG_FACILITY        RPCDBG_AUTH
-#endif
-
-/*
- * spkm3_read_token()
- *
- * only SPKM_MIC_TOK with md5 intg-alg is supported
- */
-u32
-spkm3_read_token(struct spkm3_ctx *ctx,
-		struct xdr_netobj *read_token,    /* checksum */
-		struct xdr_buf *message_buffer, /* signbuf */
-		int toktype)
-{
-	s32			checksum_type;
-	s32			code;
-	struct xdr_netobj	wire_cksum = {.len =0, .data = NULL};
-	char			cksumdata[16];
-	struct xdr_netobj	md5cksum = {.len = 0, .data = cksumdata};
-	unsigned char		*ptr = (unsigned char *)read_token->data;
-	unsigned char		*cksum;
-	int			bodysize, md5elen;
-	int			mic_hdrlen;
-	u32			ret = GSS_S_DEFECTIVE_TOKEN;
-
-	if (g_verify_token_header((struct xdr_netobj *) &ctx->mech_used,
-					&bodysize, &ptr, read_token->len))
-		goto out;
-
-	/* decode the token */
-
-	if (toktype != SPKM_MIC_TOK) {
-		dprintk("RPC:       BAD SPKM3 token type: %d\n", toktype);
-		goto out;
-	}
-
-	if ((ret = spkm3_verify_mic_token(&ptr, &mic_hdrlen, &cksum)))
-		goto out;
-
-	if (*cksum++ != 0x03) {
-		dprintk("RPC:       spkm3_read_token BAD checksum type\n");
-		goto out;
-	}
-	md5elen = *cksum++;
-	cksum++; 	/* move past the zbit */
-
-	if (!decode_asn1_bitstring(&wire_cksum, cksum, md5elen - 1, 16))
-		goto out;
-
-	/* HARD CODED FOR MD5 */
-
-	/* compute the checksum of the message.
-	 * ptr + 2 = start of header piece of checksum
-	 * mic_hdrlen + 2 = length of header piece of checksum
-	 */
-	ret = GSS_S_DEFECTIVE_TOKEN;
-	if (!g_OID_equal(&ctx->intg_alg, &hmac_md5_oid)) {
-		dprintk("RPC:       gss_spkm3_seal: unsupported I-ALG "
-				"algorithm\n");
-		goto out;
-	}
-
-	checksum_type = CKSUMTYPE_HMAC_MD5;
-
-	code = make_spkm3_checksum(checksum_type,
-		&ctx->derived_integ_key, ptr + 2, mic_hdrlen + 2,
-		message_buffer, 0, &md5cksum);
-
-	if (code)
-		goto out;
-
-	ret = GSS_S_BAD_SIG;
-	code = memcmp(md5cksum.data, wire_cksum.data, wire_cksum.len);
-	if (code) {
-		dprintk("RPC:       bad MIC checksum\n");
-		goto out;
-	}
-
-
-	/* XXX: need to add expiration and sequencing */
-	ret = GSS_S_COMPLETE;
-out:
-	kfree(wire_cksum.data);
-	return ret;
-}
