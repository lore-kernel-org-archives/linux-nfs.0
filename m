Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:40189 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726572AbeJCDnn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Oct 2018 23:43:43 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        James Ettle <james@ettle.org.uk>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] SUNRPC: use cmpxchg64() in gss_seq_send64_fetch_and_inc()
Date: Tue,  2 Oct 2018 22:57:46 +0200
Message-Id: <20181002205809.2300654-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The newly introduced gss_seq_send64_fetch_and_inc() fails to build on
32-bit architectures:

net/sunrpc/auth_gss/gss_krb5_seal.c:144:14: note: in expansion of macro 'cmpxchg'
   seq_send = cmpxchg(&ctx->seq_send64, old, old + 1);
              ^~~~~~~
arch/x86/include/asm/cmpxchg.h:128:3: error: call to '__cmpxchg_wrong_size' declared with attribute error: Bad argument size for cmpxchg
   __cmpxchg_wrong_size();     \

As the message tells us, cmpxchg() cannot be used on 64-bit arguments,
that's what cmpxchg64() does.

Fixes: 571ed1fd2390 ("SUNRPC: Replace krb5_seq_lock with a lockless scheme")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/sunrpc/auth_gss/gss_krb5_seal.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 92594681d619..5775b9805bdc 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -141,7 +141,7 @@ gss_seq_send64_fetch_and_inc(struct krb5_ctx *ctx)
 
 	do {
 		old = seq_send;
-		seq_send = cmpxchg(&ctx->seq_send64, old, old + 1);
+		seq_send = cmpxchg64(&ctx->seq_send64, old, old + 1);
 	} while (old != seq_send);
 	return seq_send;
 }
-- 
2.18.0
