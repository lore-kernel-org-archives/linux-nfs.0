Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1103 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932351Ab0KOCIN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Nov 2010 21:08:13 -0500
Subject: [PATCH] net/sunrpc/auth_gss/gss_krb5_crypto.c: Use normal negative
 error value return
From: Joe Perches <joe@perches.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 14 Nov 2010 18:08:11 -0800
Message-ID: <1289786891.16461.102.camel@Joe-Laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

And remove unnecessary double semicolon too.

No effect to code, as test is != 0.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/auth_gss/gss_krb5_crypto.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 75ee993..9576f35 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -137,7 +137,7 @@ arcfour_hmac_md5_usage_to_salt(unsigned int usage, u8 salt[4])
 		ms_usage = 13;
 		break;
 	default:
-		return EINVAL;;
+		return -EINVAL;
 	}
 	salt[0] = (ms_usage >> 0) & 0xff;
 	salt[1] = (ms_usage >> 8) & 0xff;


