From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 05/19] Correct grammer/typos in dprintks
Date: Thu, 21 Feb 2008 13:44:12 -0500
Message-ID: <20080221184412.19195.93743.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:16676 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753178AbYBUSoM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:44:12 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id 569804602
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:44:12 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

cleanup:  Fix grammer/typos to use "too" instead of "to"

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 net/sunrpc/auth_gss/gss_krb5_crypto.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 0dd7923..1d52308 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -66,8 +66,8 @@ krb5_encrypt(
 		goto out;
 
 	if (crypto_blkcipher_ivsize(tfm) > 16) {
-		dprintk("RPC:       gss_k5encrypt: tfm iv size to large %d\n",
-			 crypto_blkcipher_ivsize(tfm));
+		dprintk("RPC:       gss_k5encrypt: tfm iv size too large %d\n",
+			crypto_blkcipher_ivsize(tfm));
 		goto out;
 	}
 
@@ -102,7 +102,7 @@ krb5_decrypt(
 		goto out;
 
 	if (crypto_blkcipher_ivsize(tfm) > 16) {
-		dprintk("RPC:       gss_k5decrypt: tfm iv size to large %d\n",
+		dprintk("RPC:       gss_k5decrypt: tfm iv size too large %d\n",
 			crypto_blkcipher_ivsize(tfm));
 		goto out;
 	}

