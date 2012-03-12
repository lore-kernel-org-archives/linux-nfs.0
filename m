Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14884 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756365Ab2CLSyY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 14:54:24 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Kevin Coffman <kwc@citi.umich.edu>, Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Don't use variable length automatic arrays in kernel code
Date: Mon, 12 Mar 2012 14:54:16 -0400
Message-Id: <1331578456-10917-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the variable length array in the RPCSEC_GSS crypto code with
a fixed length one. The size should be bounded by the variable
GSS_KRB5_MAX_BLOCKSIZE, so use that.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/gss_krb5_crypto.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 9576f35..0f43e89 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -600,11 +600,14 @@ gss_krb5_cts_crypt(struct crypto_blkcipher *cipher, struct xdr_buf *buf,
 	u32 ret;
 	struct scatterlist sg[1];
 	struct blkcipher_desc desc = { .tfm = cipher, .info = iv };
-	u8 data[crypto_blkcipher_blocksize(cipher) * 2];
+	u8 data[GSS_KRB5_MAX_BLOCKSIZE * 2];
 	struct page **save_pages;
 	u32 len = buf->len - offset;
 
-	BUG_ON(len > crypto_blkcipher_blocksize(cipher) * 2);
+	if (len > ARRAY_SIZE(data)) {
+		WARN_ON(0);
+		return -ENOMEM;
+	}
 
 	/*
 	 * For encryption, we want to read from the cleartext
-- 
1.7.7.6

