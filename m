Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from m50-132.163.com ([123.125.50.132]:49342 "EHLO m50-132.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932247AbcEKJTg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2016 05:19:36 -0400
From: zengzhaoxiu@163.com
To: linux-kernel@vger.kernel.org
Cc: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [patch V4 10/31] sunrpc: use parity8
Date: Wed, 11 May 2016 17:17:13 +0800
Message-Id: <1462958235-24945-1-git-send-email-zengzhaoxiu@163.com>
In-Reply-To: <1462955158-28394-1-git-send-email-zengzhaoxiu@163.com>
References: <1462955158-28394-1-git-send-email-zengzhaoxiu@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>

Signed-off-by: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>
---
 net/sunrpc/auth_gss/gss_krb5_keys.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
index 8701331..c41b389 100644
--- a/net/sunrpc/auth_gss/gss_krb5_keys.c
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -243,16 +243,12 @@ err_return:
 	return ret;
 }
 
-#define smask(step) ((1<<step)-1)
-#define pstep(x, step) (((x)&smask(step))^(((x)>>step)&smask(step)))
-#define parity_char(x) pstep(pstep(pstep((x), 4), 2), 1)
-
 static void mit_des_fixup_key_parity(u8 key[8])
 {
 	int i;
 	for (i = 0; i < 8; i++) {
 		key[i] &= 0xfe;
-		key[i] |= 1^parity_char(key[i]);
+		key[i] |= !parity8(key[i]);
 	}
 }
 
-- 
2.7.4


