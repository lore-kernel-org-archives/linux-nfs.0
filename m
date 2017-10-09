Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43462 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754894AbdJINTL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Oct 2017 09:19:11 -0400
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
CC: akpm@linux-foundation.org,
        "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <Anna.Schumaker@Netapp.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        "Jeff Layton" <jlayton@poochiereds.net>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 09 Oct 2017 13:44:24 +0100
Message-ID: <lsq.1507553064.109173247@decadent.org.uk>
Subject: [PATCH 3.16 113/192] sunrpc: use constant time memory comparison
 for mac
In-Reply-To: <lsq.1507553063.449494954@decadent.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

3.16.49-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: "Jason A. Donenfeld" <Jason@zx2c4.com>

commit 15a8b93fd5690de017ce665382ea45e5d61811a4 upstream.

Otherwise, we enable a MAC forgery via timing attack.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
[bwh: Backported to 3.16: adjust context]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/sunrpc/auth_gss/gss_krb5_crypto.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -34,6 +34,7 @@
  * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
  */
 
+#include <crypto/algapi.h>
 #include <linux/err.h>
 #include <linux/types.h>
 #include <linux/mm.h>
@@ -838,7 +839,7 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kc
 	if (ret)
 		goto out_err;
 
-	if (memcmp(pkt_hmac, our_hmac, kctx->gk5e->cksumlength) != 0) {
+	if (crypto_memneq(pkt_hmac, our_hmac, kctx->gk5e->cksumlength) != 0) {
 		ret = GSS_S_BAD_SIG;
 		goto out_err;
 	}

