Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:54551 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752496AbeA1UeS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jan 2018 15:34:18 -0500
Received: from kowalski.cb.ettle ([51.9.57.50]) by mrelayeu.kundenserver.de
 (mreue007 [212.227.15.163]) with ESMTPSA (Nemesis) id
 0MMtUx-1egiL00Lmh-008dd0 for <linux-nfs@vger.kernel.org>; Sun, 28 Jan 2018
 21:34:17 +0100
To: linux-nfs@vger.kernel.org
From: James Ettle <james@ettle.org.uk>
Subject: [PATCH] Fix unaligned access in gss_{get,verify}_mic_v2() on sparc64
Message-ID: <5b06ae76-dae4-db81-8e1c-ea6ac035f5f1@ettle.org.uk>
Date: Sun, 28 Jan 2018 20:34:16 +0000
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I submitted this patch around a month ago but did it mid-thread and it without the proper subject line. I think it fell off the belt so here it is again. Checked against 4.14.15.


commit a90324ca784dea5a7259a2672c24626f5c03f576
Author: James Ettle <james@ettle.org.uk>
Date:   Thu Dec 7 00:50:28 2017 +0000

    Fix unaligned access on sparc64.

diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 1d74d653e6c0..94a2b3f082a8 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -177,6 +177,7 @@ gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
 	u64 seq_send;
 	u8 *cksumkey;
 	unsigned int cksum_usage;
+	__be64 seq_send_be64;

 	dprintk("RPC:       %s\n", __func__);

@@ -187,7 +188,9 @@ gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
 	spin_lock(&krb5_seq_lock);
 	seq_send = ctx->seq_send64++;
 	spin_unlock(&krb5_seq_lock);
-	*((__be64 *)(krb5_hdr + 8)) = cpu_to_be64(seq_send);
+
+	seq_send_be64 = cpu_to_be64(seq_send);
+	memcpy(krb5_hdr + 8, (char *) &seq_send_be64, 8);

 	if (ctx->initiate) {
 		cksumkey = ctx->initiator_sign;
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index dcf9515d9aef..8ea6e30d6f3f 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -155,10 +155,12 @@ gss_verify_mic_v2(struct krb5_ctx *ctx,
 	u8 flags;
 	int i;
 	unsigned int cksum_usage;
-
+	__be16 be16_ptr;
+	
 	dprintk("RPC:       %s\n", __func__);

-	if (be16_to_cpu(*((__be16 *)ptr)) != KG2_TOK_MIC)
+	memcpy(&be16_ptr, (char *) ptr, 2);
+	if (be16_to_cpu(be16_ptr) != KG2_TOK_MIC)
 		return GSS_S_DEFECTIVE_TOKEN;

 	flags = ptr[2];
