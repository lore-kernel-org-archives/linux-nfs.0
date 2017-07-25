Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:36958 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754204AbdGYTZd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jul 2017 15:25:33 -0400
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        stable@vger.kernel.org, "Jason A. Donenfeld" <Jason@zx2c4.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [PATCH 4.12 149/196] sunrpc: use constant time memory comparison for mac
Date: Tue, 25 Jul 2017 12:22:28 -0700
Message-Id: <20170725192053.327878085@linuxfoundation.org>
In-Reply-To: <20170725192046.422343510@linuxfoundation.org>
References: <20170725192046.422343510@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

4.12-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Jason A. Donenfeld <Jason@zx2c4.com>

commit 15a8b93fd5690de017ce665382ea45e5d61811a4 upstream.

Otherwise, we enable a MAC forgery via timing attack.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 net/sunrpc/auth_gss/gss_krb5_crypto.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -34,6 +34,7 @@
  * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
  */
 
+#include <crypto/algapi.h>
 #include <crypto/hash.h>
 #include <crypto/skcipher.h>
 #include <linux/err.h>
@@ -927,7 +928,7 @@ gss_krb5_aes_decrypt(struct krb5_ctx *kc
 	if (ret)
 		goto out_err;
 
-	if (memcmp(pkt_hmac, our_hmac, kctx->gk5e->cksumlength) != 0) {
+	if (crypto_memneq(pkt_hmac, our_hmac, kctx->gk5e->cksumlength) != 0) {
 		ret = GSS_S_BAD_SIG;
 		goto out_err;
 	}


