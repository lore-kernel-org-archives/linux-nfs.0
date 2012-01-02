Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp5-g21.free.fr ([212.27.42.5]:34613 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469Ab2ABP4C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jan 2012 10:56:02 -0500
Received: from mx.meyering.net (unknown [88.168.87.75])
	by smtp5-g21.free.fr (Postfix) with ESMTP id 4B62AD48290
	for <linux-nfs@vger.kernel.org>; Mon,  2 Jan 2012 16:55:56 +0100 (CET)
Received: from rho.meyering.net (localhost.localdomain [127.0.0.1])
	by rho.meyering.net (Acme Bit-Twister) with ESMTP id 131E3600E3
	for <linux-nfs@vger.kernel.org>; Mon,  2 Jan 2012 16:55:55 +0100 (CET)
From: Jim Meyering <jim@meyering.net>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] gssd: avoid double-free upon write failure
Date: Mon, 02 Jan 2012 16:55:54 +0100
Message-ID: <87lipqumid.fsf@rho.meyering.net>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* utils/gssd/context_lucid.c (prepare_krb5_rfc1964_buffer): Free just-
calloc'd enc_key.data from one place, unconditionally, after calling
write_lucid_keyblock, rather than from three places.  Before, upon
failed write, we would free it, then goto out_err, where we would
free it again, if it happened to be non-NULL.
Coverity spotted the possible double free.
---
 utils/gssd/context_lucid.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
index 3e695ab..64146d7 100644
--- a/utils/gssd/context_lucid.c
+++ b/utils/gssd/context_lucid.c
@@ -80,6 +80,7 @@ prepare_krb5_rfc1964_buffer(gss_krb5_lucid_context_v1_t *lctx,
 	uint32_t i;
 	char *skd, *dkd;
 	gss_buffer_desc fakeoid;
+	int err;

 	/*
 	 * The new Kerberos interface to get the gss context
@@ -138,11 +139,10 @@ prepare_krb5_rfc1964_buffer(gss_krb5_lucid_context_v1_t *lctx,
 	dkd = (char *) enc_key.data;
 	for (i = 0; i < enc_key.length; i++)
 		dkd[i] = skd[i] ^ 0xf0;
-	if (write_lucid_keyblock(&p, end, &enc_key)) {
-		free(enc_key.data);
-		goto out_err;
-	}
+	err = write_lucid_keyblock(&p, end, &enc_key);
 	free(enc_key.data);
+	if (err)
+		goto out_err;

 	if (write_lucid_keyblock(&p, end, &lctx->rfc1964_kd.ctx_key))
 		goto out_err;
@@ -153,7 +153,6 @@ out_err:
 	printerr(0, "ERROR: failed serializing krb5 context for kernel\n");
 	if (buf->value) free(buf->value);
 	buf->length = 0;
-	if (enc_key.data) free(enc_key.data);
 	return -1;
 }

--
1.7.8.1.391.g2c2ad
