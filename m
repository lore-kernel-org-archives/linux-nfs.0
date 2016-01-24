Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:53112 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755297AbcAXNTq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:19:46 -0500
Subject: [PATCH 19/26] ipsec: Use skcipher and ahash when probing algorithms
References: <20160124131021.GA31153@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        dm-devel@redhat.com, linux-wireless@vger.kernel.org,
        linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
        linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
        drbd-dev@lists.linbit.com, open-iscsi@googlegroups.com
Message-Id: <E1aNKZT-0008Ew-7q@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:19:11 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch removes the last reference to hash and ablkcipher from
IPsec and replaces them with ahash and skcipher respectively.  For
skcipher there is currently no difference at all, while for ahash
the current code is actually buggy and would prevent asynchronous
algorithms from being discovered.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/xfrm/xfrm_algo.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index f07224d..250e567 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -9,6 +9,8 @@
  * any later version.
  */
 
+#include <crypto/hash.h>
+#include <crypto/skcipher.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/pfkeyv2.h>
@@ -782,14 +784,13 @@ void xfrm_probe_algs(void)
 	BUG_ON(in_softirq());
 
 	for (i = 0; i < aalg_entries(); i++) {
-		status = crypto_has_hash(aalg_list[i].name, 0,
-					 CRYPTO_ALG_ASYNC);
+		status = crypto_has_ahash(aalg_list[i].name, 0, 0);
 		if (aalg_list[i].available != status)
 			aalg_list[i].available = status;
 	}
 
 	for (i = 0; i < ealg_entries(); i++) {
-		status = crypto_has_ablkcipher(ealg_list[i].name, 0, 0);
+		status = crypto_has_skcipher(ealg_list[i].name, 0, 0);
 		if (ealg_list[i].available != status)
 			ealg_list[i].available = status;
 	}
